package fishermanjoeandchildren.thewater.service;

import org.json.JSONArray;
import org.json.JSONObject;
import org.json.XML;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.net.URI;
import java.net.URISyntaxException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class RiseSetService {

    @Value("${riseSet.api.key}")
    private String serviceKey;

    private final RestTemplate restTemplate;

    // API 기본 URL
    @Value("${riseSet.api}")
    private String BASE_URL;

    // 날짜 포맷터
    private static final DateTimeFormatter INPUT_FORMATTER = DateTimeFormatter.ofPattern("yyyyMMdd");
    private static final DateTimeFormatter OUTPUT_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    public RiseSetService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    /**
     * 일주일간의 일출/일몰 정보를 가져옵니다.
     */
    public List<Map<String, String>> getWeeklyRiseSetInfo(double lat, double lon) {
        List<Map<String, String>> weeklyInfo = new ArrayList<>();
        LocalDate today = LocalDate.now();

        // 오늘부터 7일간의 데이터 가져오기
        for (int i = 0; i < 7; i++) {
            LocalDate date = today.plusDays(i);
            String formattedDate = date.format(INPUT_FORMATTER);

            Map<String, String> dayInfo = getDailyRiseSetInfo(lat, lon, formattedDate);
            if (dayInfo != null) {
                weeklyInfo.add(dayInfo);
            }
        }

        return weeklyInfo;
    }

    /**
     * 특정 날짜의 일출/일몰 정보를 가져옵니다.
     */
    private Map<String, String> getDailyRiseSetInfo(double lat, double lon, String locDate) {


        try {
            // API URL 구성
            String url = BASE_URL +
                    "?longitude=" + lon +
                    "&latitude=" + lat +
                    "&locdate=" + locDate +
                    "&dnYn=" + "y" +
                    "&ServiceKey=" + serviceKey;

            URI uri = new URI(url);

            // API 호출하여 문자열로 응답 받기
            String xmlResponse = restTemplate.getForObject(uri, String.class);
            // 응답 내용 로깅
            System.out.println("API URL: " + uri);
            System.out.println("API 응답: " + xmlResponse);

            // 응답이 빈 문자열이거나 null인 경우 처리
            if (xmlResponse == null || xmlResponse.trim().isEmpty()) {
                System.err.println("API 응답이 비어있습니다.");
                return null;
            }
            // XML을 JSON으로 변환
            JSONObject jsonResponse = XML.toJSONObject(xmlResponse);

            // 결과 코드 확인
            String resultCode = jsonResponse.getJSONObject("response")
                    .getJSONObject("header")
                    .getString("resultCode");

            if ("00".equals(resultCode)) {
                // items 확인
                JSONObject body = jsonResponse.getJSONObject("response").getJSONObject("body");

                if (body.has("items") && !body.getJSONObject("items").isEmpty()) {
                    JSONObject items = body.getJSONObject("items");
                    JSONObject item;

                    // item이 배열인지 단일 객체인지 확인
                    if (items.has("item")) {
                        Object itemObj = items.get("item");
                        if (itemObj instanceof JSONArray) {
                            item = ((JSONArray) itemObj).getJSONObject(0);
                        } else {
                            item = items.getJSONObject("item");
                        }

                        // 필요한 데이터 추출
                        String itemLocdate = item.get("locdate").toString();
                        String sunrise = item.get("sunrise").toString().trim();
                        String sunset = item.get("sunset").toString().trim();

                        // 날짜 형식 변환 (yyyyMMdd -> yyyy-MM-dd)
                        String formattedDate = LocalDate.parse(itemLocdate, INPUT_FORMATTER)
                                .format(OUTPUT_FORMATTER);

                        // 시간 형식 변환 (HHMM -> HH:MM)
                        String formattedSunrise = formatTime(sunrise);
                        String formattedSunset = formatTime(sunset);

                        // Map으로 결과 반환
                        Map<String, String> result = new HashMap<>();
                        result.put("date", formattedDate);
                        result.put("sunrise", formattedSunrise);
                        result.put("sunset", formattedSunset);

                        return result;
                    }
                }
            }
            return null;
        } catch (URISyntaxException e) {
            System.err.println("일출/일몰 정보 가져오기 실패: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }

    /**
     * "HHMM" 형식의 시간을 "HH:MM" 형식으로 변환합니다.
     */
    private String formatTime(String time) {
        if (time == null || time.length() < 4) {
            return "";
        }

        // HHMM -> HH:MM 변환
        return time.substring(0, 2) + ":" + time.substring(2, 4);
    }
}