package fishermanjoeandchildren.thewater.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import fishermanjoeandchildren.thewater.util.LunarCalendarUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.json.JSONArray;
import org.json.JSONObject;
import java.net.URI;
import java.net.URISyntaxException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Service
public class WeatherService {

    @Value("${weather.api.key}")
    private String serviceKey;

    @Value("${weather.api.getUltraSrtNcst}")
    private String ultraSrtNcstUrl;
    @Value("${weather.api.getVilageFcst}")
    private String apiUrl;

    private final RestTemplate restTemplate;

    public WeatherService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    @Autowired
    private TideService tideService;
    @Autowired
    private WaterTempService waterTempService;
    @Autowired
    private ReverseGeocodingService reverseGeocodingService;
    @Autowired
    private LunarCalendarUtil lunarCalendarUtil;


    public String getWeatherData(double lat, double lon) {
        try {
            // 1. 위경도를 XY좌표로 변환
            int[] xy = GeoPointConverter.convertToXY(lat, lon);
            int nx = xy[0];
            int ny = xy[1];

            // 2. 현재 날짜와 시간 설정
            LocalDateTime now = LocalDateTime.now();
            LocalDateTime threeHoursAgo = now.minusHours(3);
            int[] availableHours = {2, 5, 8, 11, 14, 17, 20, 23};
            int currentHour = threeHoursAgo.getHour();
            int adjustedHour = -1;

            for (int i = availableHours.length - 1; i >= 0; i--) {
                if (availableHours[i] <= currentHour) {
                    adjustedHour = availableHours[i];
                    break;
                }
            }

            LocalDateTime adjustedDateTime;
            if (adjustedHour == -1) {
                adjustedDateTime = threeHoursAgo.minusDays(1).withHour(23).withMinute(0).withSecond(0);
            } else {
                adjustedDateTime = threeHoursAgo.withHour(adjustedHour).withMinute(0).withSecond(0);
            }

            String baseDate = adjustedDateTime.format(DateTimeFormatter.ofPattern("yyyyMMdd"));
            String baseTime = String.format("%02d00", adjustedDateTime.getHour());

            System.out.println("baseDate=" + baseDate + ", baseTime=" + baseTime);

            // 3. URL 문자열 구성
            String urlString = apiUrl +
                    "?serviceKey=" + serviceKey +
                    "&numOfRows=2000" +
                    "&pageNo=1" +
                    "&dataType=JSON" +
                    "&base_date=" + baseDate +
                    "&base_time=" + baseTime +
                    "&nx=" + nx +
                    "&ny=" + ny;

            System.out.println("API 요청 URL: " + urlString);

            // 4. URI 객체 생성 (이 과정에서 자동 인코딩 발생)
            URI uri = new URI(urlString);

            // 5. RestTemplate으로 API 호출 및 응답 그대로 반환
            String response = restTemplate.getForObject(uri, String.class);
            System.out.println("API 응답: " + response);

            return response;

        } catch (URISyntaxException e) {
            e.printStackTrace();
            return "Error creating URI: " + e.getMessage();
        } catch (Exception e) {
            e.printStackTrace();
            return "Error calling API: " + e.getMessage();
        }
    }
    // 3시간 간격으로 매핑된 날씨 데이터 제공
    public List<Map<String, Object>> getWeatherDataMappedToThreeHour(double lat, double lon) {
        try {
            // 1. 원래 메서드로 날씨 데이터 가져오기
            String apiResponse = getWeatherData(lat, lon);

            // 2. JSON 파싱
            ObjectMapper mapper = new ObjectMapper();
            JsonNode rootNode = mapper.readTree(apiResponse);

            // 3. 필요한 데이터 추출
            JsonNode items = rootNode.path("response").path("body").path("items").path("item");

            // 4. 결과를 저장할 맵 생성 (날짜별 -> 시간별 -> 카테고리별)
            Map<String, Map<String, Map<String, String>>> dateTimeData = new HashMap<>();

            // 5. 원하는 시간대 (3시간 간격)
            final int[] targetHours = {0, 3, 6, 9, 12, 15, 18, 21};

            // 6. 모든 아이템 순회
            for (JsonNode item : items) {
                String fcstDate = item.path("fcstDate").asText();
                String fcstTime = item.path("fcstTime").asText();
                String category = item.path("category").asText();
                String fcstValue = item.path("fcstValue").asText();

                // 7. 시간 추출 및 매핑
                int hour = Integer.parseInt(fcstTime.substring(0, 2));

                // 8. 3시간 간격으로 매핑
                int mappedHour = mapToThreeHourInterval(hour);

                // 9. 포맷에 맞게 시간 문자열 생성 (ex: 3 -> "0300")
                String mappedTimeStr = String.format("%02d00", mappedHour);

                // 10. 날짜-시간 기준으로 데이터 저장 구조 생성
                if (!dateTimeData.containsKey(fcstDate)) {
                    dateTimeData.put(fcstDate, new HashMap<>());
                }

                if (!dateTimeData.get(fcstDate).containsKey(mappedTimeStr)) {
                    dateTimeData.get(fcstDate).put(mappedTimeStr, new HashMap<>());
                }

                // 11. 카테고리별 값 저장 (기존 값이 없을 때만)
                Map<String, String> categoryMap = dateTimeData.get(fcstDate).get(mappedTimeStr);
                if (!categoryMap.containsKey(category)) {
                    categoryMap.put(category, fcstValue);
                }
            }

            // 12. 결과를 리스트로 변환
            List<Map<String, Object>> resultList = new ArrayList<>();

            // 13. 날짜-시간별로 데이터 구성
            for (String date : dateTimeData.keySet()) {
                Map<String, Map<String, String>> timesForDate = dateTimeData.get(date);

                for (String time : timesForDate.keySet()) {
                    Map<String, String> categories = timesForDate.get(time);

                    Map<String, Object> timeSlot = new HashMap<>();
                    timeSlot.put("fcstDate", date);
                    timeSlot.put("fcstTime", time);

                    // 모든 카테고리 정보 추가
                    for (String category : categories.keySet()) {
                        timeSlot.put(category, categories.get(category));
                    }

                    resultList.add(timeSlot);
                }
            }

            // 14. 날짜/시간 기준으로 정렬
            resultList.sort((map1, map2) -> {
                String dateTime1 = (String)map1.get("fcstDate") + (String)map1.get("fcstTime");
                String dateTime2 = (String)map2.get("fcstDate") + (String)map2.get("fcstTime");
                return dateTime1.compareTo(dateTime2);
            });

            // 15. 최종 결과 맵 생성
            Map<String, Object> result = new HashMap<>();
            result.put("data", resultList);

            return resultList;

        } catch (Exception e) {
            e.printStackTrace();
            // 에러 발생 시 빈 리스트 반환
            return new ArrayList<>();
        }
    }

    public List<String> getNowWeather(double lat, double lon) {
        try {
            // 1. 위경도를 XY좌표로 변환
            int[] xy = GeoPointConverter.convertToXY(lat, lon);
            int nx = xy[0];
            int ny = xy[1];

            // 2. 현재 시간에서 1시간 전 정시로 맞추기
            LocalDateTime now = LocalDateTime.now();
            LocalDateTime baseDateTime = now.minusHours(1).withMinute(0).withSecond(0).withNano(0);

            String baseDate = baseDateTime.format(DateTimeFormatter.ofPattern("yyyyMMdd"));
            String baseTime = baseDateTime.format(DateTimeFormatter.ofPattern("HH00"));

            System.out.println("baseDate=" + baseDate + ", baseTime=" + baseTime);

            // 3. URL 생성
            String urlString = ultraSrtNcstUrl +
                    "?serviceKey=" + serviceKey +
                    "&numOfRows=100" +
                    "&pageNo=1" +
                    "&dataType=JSON" +
                    "&base_date=" + baseDate +
                    "&base_time=" + baseTime +
                    "&nx=" + nx +
                    "&ny=" + ny;

            System.out.println("API 요청 URL: " + urlString);

            // 4. API 요청 및 응답
            URI uri = new URI(urlString);
            String response = restTemplate.getForObject(uri, String.class);
            System.out.println("API 응답: " + response);

            // 5. JSON 파싱
            JSONObject jsonResponse = new JSONObject(response);
            JSONArray items = jsonResponse.getJSONObject("response")
                    .getJSONObject("body")
                    .getJSONObject("items")
                    .getJSONArray("item");

            // 6. 가독성 높은 리스트로 변환
            List<String> resultList = new ArrayList<>();
            for (int i = 0; i < items.length(); i++) {
                JSONObject item = items.getJSONObject(i);
                String category = item.getString("category");
                String obsrValue = item.get("obsrValue").toString(); // 숫자일 수도 있으므로 문자열 변환

                // "카테고리: 값" 형식으로 리스트에 추가
                resultList.add(category + ": " + obsrValue);
            }

            return resultList;

        } catch (URISyntaxException e) {
            e.printStackTrace();
            return new ArrayList<>();
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    // 시간을 3시간 간격으로 매핑하는 헬퍼 메서드
    private int mapToThreeHourInterval(int hour) {
        if (hour == 0 || hour == 1 || hour == 2) return 0;
        if (hour == 3 || hour == 4 || hour == 5) return 3;
        if (hour == 6 || hour == 7 || hour == 8) return 6;
        if (hour == 9 || hour == 10 || hour == 11) return 9;
        if (hour == 12 || hour == 13 || hour == 14) return 12;
        if (hour == 15 || hour == 16 || hour == 17) return 15;
        if (hour == 18 || hour == 19 || hour == 20) return 18;
        return 21; // 21, 22, 23시는 21시로 매핑
    }

    /**
     * 현재 위치의 날씨, 조위, 수온 정보를 통합하여 제공합니다.
     * @param lat 위도
     * @param lon 경도
     * @return 통합된 환경 정보 목록
     */
    public List<String> getIntegratedEnvironmentInfo(double lat, double lon) {
        try {
            // 1. 기존 날씨 정보 가져오기
            List<String> weatherInfo = getNowWeather(lat, lon);

            // 2. 조위 정보 가져오기 (TideService에서 getLatestTideData 메소드 호출)
            Map<String, Object> tideData = tideService.getLatestTideData(lat, lon);

            // 3. 수온 정보 가져오기 (WaterTempService에서 getLatestWaterTempData 메소드 호출)
            Map<String, Object> waterTempData = waterTempService.getLatestWaterTempData(lat, lon);

            // 4. 조위 정보 추가
            if (tideData.containsKey("tideLevel")) {
                weatherInfo.add("tideLevel: " + tideData.get("tideLevel"));
            }

            // 5. 수온 정보 추가
            if (waterTempData.containsKey("waterTemp")) {
                weatherInfo.add("waterTemp: " + waterTempData.get("waterTemp"));
            }

            return weatherInfo;

        } catch (Exception e) {
            throw new RuntimeException("통합 환경 정보를 가져오는데 실패했습니다: " + e.getMessage(), e);
        }
    }

    /**
     * 현재 위치의 날씨, 조위, 수온, 주소, 물때 정보를 통합하여 Map 형태로 제공합니다.
     * @param lat 위도
     * @param lon 경도
     * @return 통합된 환경 정보 맵
     */
    public Map<String, String> getFullIntegratedEnvironmentInfoAsMap(double lat, double lon) {
        try {
            Map<String, String> resultMap = new HashMap<>();

            // 1. 날씨 정보 가져오기
            List<String> weatherInfo = getNowWeather(lat, lon);

            // 날씨 정보를 맵으로 변환
            for (String info : weatherInfo) {
                String[] parts = info.split(":\\s*", 2);
                if (parts.length == 2) {
                    resultMap.put(parts[0].trim(), parts[1].trim());
                }
            }

            // 2. 주소 정보 가져오기
            String address = reverseGeocodingService.getAddressFromCoordinates(lat, lon);
            resultMap.put("주소", address != null ? address : "주소 정보 없음");

            // 3. 조위 정보 가져오기
            Map<String, Object> tideData = tideService.getLatestTideData(lat, lon);
            if (tideData.containsKey("tideLevel")) {
                resultMap.put("tideLevel", tideData.get("tideLevel").toString());
            }

            // 4. 수온 정보 가져오기
            Map<String, Object> waterTempData = waterTempService.getLatestWaterTempData(lat, lon);
            if (waterTempData.containsKey("waterTemp")) {
                resultMap.put("waterTemp", waterTempData.get("waterTemp").toString());
            }

            // 5. 물때 정보 가져오기
            int lunarDay = lunarCalendarUtil.getTodayLunarDay();
            Map<String, String> tideInfo = tideService.getTideByLunarDay(lunarDay);

            // 위치에 따라 남해/서해 물때 선택
            String tideName;
            if (lon > 127.0) {  // 대략적인 경도 기준으로 동/서 구분
                tideName = tideInfo.get("남해물때");
            } else {
                tideName = tideInfo.get("서해물때");
            }

            if (tideName != null) {
                resultMap.put("물때", tideName);
            }

            return resultMap;

        } catch (Exception e) {
            e.printStackTrace();
            Map<String, String> errorMap = new HashMap<>();
            errorMap.put("error", e.getMessage());
            return errorMap;
        }
    }
}