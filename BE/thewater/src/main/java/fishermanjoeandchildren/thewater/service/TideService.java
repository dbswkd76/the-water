package fishermanjoeandchildren.thewater.service;

import fishermanjoeandchildren.thewater.util.LunarCalendarUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.Map;
import java.util.HashMap;

@Service
public class TideService {

    @Value("${tide.api.key}")
    private String apiKey;

    @Value("${tide.api.url}")
    private String apiUrl;

    private final RestTemplate restTemplate;
    private final ObservatoryService observatoryService;
    private final ObjectMapper objectMapper;

    @Autowired
    private LunarCalendarUtil lunarCalendarUtil;

    // 남해물때 표
    private static final Map<Integer, String> southSeaTides = new HashMap<>();
    // 서해물때 표
    private static final Map<Integer, String> westSeaTides = new HashMap<>();
    static {
        // 남해물때 초기화
        southSeaTides.put(1, "여덟물");
        southSeaTides.put(2, "아홉물");
        southSeaTides.put(3, "열물");
        southSeaTides.put(4, "열한물");
        southSeaTides.put(5, "열두물");
        southSeaTides.put(6, "열셋물");
        southSeaTides.put(7, "열넷물");
        southSeaTides.put(8, "조금");
        southSeaTides.put(9, "한물");
        southSeaTides.put(10, "두물");
        southSeaTides.put(11, "세물");
        southSeaTides.put(12, "네물");
        southSeaTides.put(13, "다섯물");
        southSeaTides.put(14, "여섯물");
        southSeaTides.put(15, "일곱물");
        southSeaTides.put(16, "여덟물");
        southSeaTides.put(17, "아홉물");
        southSeaTides.put(18, "열물");
        southSeaTides.put(19, "열한물");
        southSeaTides.put(20, "열두물");
        southSeaTides.put(21, "열셋물");
        southSeaTides.put(22, "열넷물");
        southSeaTides.put(23, "조금");
        southSeaTides.put(24, "한물");
        southSeaTides.put(25, "두물");
        southSeaTides.put(26, "세물");
        southSeaTides.put(27, "네물");
        southSeaTides.put(28, "다섯물");
        southSeaTides.put(29, "여섯물");
        southSeaTides.put(30, "일곱물");

        // 서해물때 초기화
        westSeaTides.put(1, "일곱물");
        westSeaTides.put(2, "여덟물");
        westSeaTides.put(3, "아홉물");
        westSeaTides.put(4, "열물");
        westSeaTides.put(5, "열한물");
        westSeaTides.put(6, "열두물");
        westSeaTides.put(7, "열셋물");
        westSeaTides.put(8, "조금");
        westSeaTides.put(9, "무시");
        westSeaTides.put(10, "한물");
        westSeaTides.put(11, "두물");
        westSeaTides.put(12, "세물");
        westSeaTides.put(13, "네물");
        westSeaTides.put(14, "다섯물");
        westSeaTides.put(15, "여섯물");
        westSeaTides.put(16, "일곱물");
        westSeaTides.put(17, "여덟물");
        westSeaTides.put(18, "아홉물");
        westSeaTides.put(19, "열물");
        westSeaTides.put(20, "열한물");
        westSeaTides.put(21, "열두물");
        westSeaTides.put(22, "열셋물");
        westSeaTides.put(23, "조금");
        westSeaTides.put(24, "무시");
        westSeaTides.put(25, "한물");
        westSeaTides.put(26, "두물");
        westSeaTides.put(27, "세물");
        westSeaTides.put(28, "네물");
        westSeaTides.put(29, "다섯물");
        westSeaTides.put(30, "여섯물");
    }

    // 병렬 API 요청을 위한 ExecutorService
    private final ExecutorService executorService = Executors.newFixedThreadPool(8);

    @Autowired
    public TideService(RestTemplate restTemplate, ObservatoryService observatoryService, ObjectMapper objectMapper) {
        this.restTemplate = restTemplate;
        this.observatoryService = observatoryService;
        this.objectMapper = objectMapper;
    }

    /**
     * 지정된 위치의 전날부터 미래 7일간의 물때 정보를 가져옵니다.
     * @param latitude 위도
     * @param longitude 경도
     * @return 단순화된 물때 정보 JSON 문자열
     */
    public String getExtendedTideInfo(double latitude, double longitude) {
        try {
            // 가장 가까운 관측소 코드 찾기
            String observatoryCode = observatoryService.findNearestObservatory(latitude, longitude);

            // 오늘 날짜 구하기
            LocalDate today = LocalDate.now();
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");

            // 어제부터 향후 7일간의 날짜 리스트 생성 (총 8일)
            List<LocalDate> dateRange = new ArrayList<>();
            dateRange.add(today.minusDays(1)); // 어제
            for (int i = 0; i < 7; i++) {
                dateRange.add(today.plusDays(i)); // 오늘부터 6일 후까지
            }

            // 병렬로 API 호출하여 각 날짜별 물때 정보 가져오기
            List<CompletableFuture<JsonNode>> futures = new ArrayList<>();

            for (LocalDate date : dateRange) {
                CompletableFuture<JsonNode> future = CompletableFuture.supplyAsync(() -> {
                    try {
                        String dateStr = date.format(formatter);
                        String url = apiUrl +
                                "?ServiceKey=" + apiKey +
                                "&ObsCode=" + observatoryCode +
                                "&Date=" + dateStr +
                                "&ResultType=json";

                        String response = restTemplate.getForObject(url, String.class);

                        // 응답 파싱 및 날짜 정보 추가
                        JsonNode rootNode = objectMapper.readTree(response);

                        // 단순화된 응답 구조 생성
                        ObjectNode simplifiedNode = objectMapper.createObjectNode();
                        simplifiedNode.put("날짜", date.toString());
                        simplifiedNode.put("관측소 코드", observatoryCode);

                        // result.data 배열을 직접 tideData로 복사
                        if (rootNode.has("result") && rootNode.get("result").has("data")) {
                            JsonNode dataArray = rootNode.get("result").get("data");
                            ArrayNode tideDataArray = objectMapper.createArrayNode();

                            for (JsonNode item : dataArray) {
                                tideDataArray.add(item);
                            }

                            simplifiedNode.set("조석데이터", tideDataArray);

                            // 메타데이터 추가
                            if (rootNode.get("result").has("meta")) {
                                JsonNode meta = rootNode.get("result").get("meta");
                                if (meta.has("obs_last_req_cnt")) {
                                    simplifiedNode.put("잔여 API 요청 횟수 ", meta.get("obs_last_req_cnt").asText());
                                }
                            }
                        }

                        return simplifiedNode;
                    } catch (Exception e) {
                        ObjectNode errorNode = objectMapper.createObjectNode();
                        errorNode.put("date", date.toString());
                        errorNode.put("error", e.getMessage());
                        return errorNode;
                    }
                }, executorService);

                futures.add(future);
            }

            // 모든 미래 작업이 완료될 때까지 대기
            CompletableFuture<Void> allOf = CompletableFuture.allOf(
                    futures.toArray(new CompletableFuture[0])
            );

            // 결과 결합
            CompletableFuture<JsonNode> combinedResult = allOf.thenApply(v -> {
                ArrayNode resultArray = objectMapper.createArrayNode();
                String observatoryName = observatoryService.getObservatoryName(observatoryCode);

                for (CompletableFuture<JsonNode> future : futures) {
                    resultArray.add(future.join());
                }

                ObjectNode finalResult = objectMapper.createObjectNode();
                finalResult.put("observatoryName", observatoryName);
                finalResult.put("latitude", latitude);
                finalResult.put("longitude", longitude);
                finalResult.set("tideInfo", resultArray);

                return finalResult;
            });

            // 결과 반환
            JsonNode result = combinedResult.join();
            return objectMapper.writeValueAsString(result);

        } catch (Exception e) {
            e.printStackTrace();
            return "{\"error\": \"" + e.getMessage().replace("\"", "'") + "\"}";
        }
    }

    /**
     * 특정 날짜의 물때 정보를 가져옵니다.
     * @param latitude 위도
     * @param longitude 경도
     * @param date 날짜 (null인 경우 오늘 날짜 사용)
     * @return 물때 정보 JSON 문자열
     */
    public String getTideInfo(double latitude, double longitude, LocalDate date) {
        try {
            // 가장 가까운 관측소 코드 찾기
            String observatoryCode = observatoryService.findNearestObservatory(latitude, longitude);

            // 날짜 형식 지정 (yyyyMMdd)
            String dateStr = date != null ?
                    date.format(DateTimeFormatter.ofPattern("yyyyMMdd")) :
                    LocalDate.now().format(DateTimeFormatter.ofPattern("yyyyMMdd"));

            // API URL 구성
            String url = apiUrl +
                    "?ServiceKey=" + apiKey +
                    "&ObsCode=" + observatoryCode +
                    "&Date=" + dateStr +
                    "&ResultType=json";

            // API 호출
            String response = restTemplate.getForObject(url, String.class);

            // 응답을 단순화된 구조로 변환
            JsonNode rootNode = objectMapper.readTree(response);
            ObjectNode simplifiedNode = objectMapper.createObjectNode();

            String observatoryName = observatoryService.getObservatoryName(observatoryCode);
            simplifiedNode.put("observatoryName", observatoryName);
            simplifiedNode.put("observatoryCode", observatoryCode);
            simplifiedNode.put("date", date != null ? date.toString() : LocalDate.now().toString());

            // result.data 배열을 직접 tideData로 복사
            if (rootNode.has("result") && rootNode.get("result").has("data")) {
                JsonNode dataArray = rootNode.get("result").get("data");
                simplifiedNode.set("tideData", dataArray);
            }

            return objectMapper.writeValueAsString(simplifiedNode);

        } catch (Exception e) {
            e.printStackTrace();
            return "{\"error\": \"" + e.getMessage().replace("\"", "'") + "\"}";
        }
    }

    /**
            * 오늘의 물때 정보를 가져옵니다.
            * @return 남해와 서해의 물때 정보를 담은 Map
     */
    public Map<String, String> getTodayTide() {
        int lunarDay = lunarCalendarUtil.getTodayLunarDay();
        if (lunarDay == -1) {
            // 음력 변환 실패
            return createErrorResponse("음력 변환에 실패했습니다.");
        }

        return getTideByLunarDay(lunarDay);
    }

    /**
     * 주어진 음력 일에 해당하는 물때 정보를 가져옵니다.
     * @param lunarDay 음력 일(day)
     * @return 남해와 서해의 물때 정보를 담은 Map
     */
    public Map<String, String> getTideByLunarDay(int lunarDay) {
        Map<String, String> result = new HashMap<>();

        if (lunarDay < 1 || lunarDay > 30) {
            return createErrorResponse("유효하지 않은 음력일입니다. 1~30 사이의 값이어야 합니다.");
        }

        result.put("남해물때", southSeaTides.get(lunarDay));
        result.put("서해물때", westSeaTides.get(lunarDay));

        return result;
    }

    /**
     * 어제부터 일주일치 물때 정보를 가져옵니다.
     * @return 일주일치 물때 정보 목록
     */
    public List<Map<String, Object>> getWeeklyTides() {
        List<Map<String, Object>> weeklyTides = new ArrayList<>();
        LocalDate yesterday = LocalDate.now().minusDays(1);
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

        // 어제부터 일주일치
        for (int i = 0; i < 7; i++) {
            LocalDate date = yesterday.plusDays(i);
            int[] lunarDate = lunarCalendarUtil.solarToLunar(date);
            int lunarDay = lunarDate[2]; // 음력 일

            Map<String, Object> dayTide = new HashMap<>();
            dayTide.put("양력날짜", date.format(formatter));
            dayTide.put("남해물때", southSeaTides.get(lunarDay));
            dayTide.put("서해물때", westSeaTides.get(lunarDay));

            weeklyTides.add(dayTide);
        }

        return weeklyTides;
    }

    private Map<String, String> createErrorResponse(String errorMessage) {
        Map<String, String> errorResponse = new HashMap<>();
        errorResponse.put("error", errorMessage);
        return errorResponse;
    }

    // 현재 조위 가져오기
    public Map<String, Object> getLatestTideData(double latitude, double longitude) {
        try {
            // 1. 가장 가까운 실측용 관측소 찾기
            String observatoryCode = observatoryService.findNearestRealTimeObservatory(latitude, longitude);
            String observatoryName = observatoryService.getRealTimeObservatoryName(observatoryCode);

            // 2. 오늘 날짜 구하기
            LocalDate today = LocalDate.now();
            String dateStr = today.format(DateTimeFormatter.ofPattern("yyyyMMdd"));

            // 3. API URL 구성 (여기서는 조위 실측 API 사용)
            String url = "http://www.khoa.go.kr/api/oceangrid/tideObs/search.do" +
                    "?ServiceKey=" + apiKey +
                    "&ObsCode=" + observatoryCode +
                    "&Date=" + dateStr +
                    "&ResultType=json";

            // 4. API 호출
            String response = restTemplate.getForObject(url, String.class);

            // 5. 응답 파싱
            JsonNode rootNode = objectMapper.readTree(response);
            JsonNode dataArray = rootNode.path("result").path("data");

            // 6. 가장 최신 데이터 찾기
            JsonNode latestData = null;
            String latestTime = "";

            for (JsonNode item : dataArray) {
                String recordTime = item.path("record_time").asText();
                if (recordTime.compareTo(latestTime) > 0) {
                    latestTime = recordTime;
                    latestData = item;
                }
            }

            // 7. 결과 매핑
            Map<String, Object> result = new HashMap<>();
            result.put("observatoryCode", observatoryCode);
            result.put("observatoryName", observatoryName);
            result.put("latitude", latitude);
            result.put("longitude", longitude);

            if (latestData != null) {
                result.put("tideLevel", latestData.path("tide_level").asText());
                result.put("recordTime", latestTime);
            } else {
                result.put("error", "데이터를 찾을 수 없습니다");
            }

            return result;

        } catch (Exception e) {
            e.printStackTrace();
            Map<String, Object> errorResult = new HashMap<>();
            errorResult.put("error", "조위 데이터를 가져오는 중 오류가 발생했습니다: " + e.getMessage());
            return errorResult;
        }
    }
}