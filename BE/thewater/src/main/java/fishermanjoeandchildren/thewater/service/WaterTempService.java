package fishermanjoeandchildren.thewater.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.ResponseEntity;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.HashMap;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

@Service
public class WaterTempService {

    @Value("${waterTemp.api.key}")
    private String waterTempKey;

    @Value("${waterTemp.api}")
    private String waterTempApi;

    private RestTemplate restTemplate = new RestTemplate();

    private final ObservatoryService observatoryService;
    private final ObjectMapper objectMapper;

    @Autowired
    public WaterTempService(RestTemplate restTemplate, ObservatoryService observatoryService, ObjectMapper objectMapper) {
        this.restTemplate = restTemplate;
        this.observatoryService = observatoryService;
        this.objectMapper = objectMapper;
    }

    public String getWaterTemperature(double lat, double lon) {
        String url = waterTempApi +
                "?ServiceKey=" + waterTempKey +
                "&ObsLon=" + lon +
                "&ObsLat=" + lat +
                "&ResultType=json";

        System.out.printf(url);
        ResponseEntity<String> response = restTemplate.getForEntity(url, String.class);
        return response.getBody();
    }

    public List<Map<String, String>> getFilteredWaterTemperature(double lat, double lon) {
        try {
            // API 호출해서 응답 받기
            String responseBody = getWaterTemperature(lat, lon);

            // JSON 파싱
            ObjectMapper mapper = new ObjectMapper();
            JsonNode rootNode = mapper.readTree(responseBody);

            // 데이터 배열 가져오기
            JsonNode dataArray = rootNode.path("result").path("data");

            // 필터링할 시간 배열
            List<String> targetHours = Arrays.asList("0", "3", "6", "9", "12", "15", "18", "21");

            // 결과를 저장할 리스트
            List<Map<String, String>> filteredResults = new ArrayList<>();

            // 데이터 순회하면서 필요한 시간대만 필터링
            for (JsonNode item : dataArray) {
                String hour = item.path("hour").asText();

                // 원하는 시간대인 경우만 추가
                if (targetHours.contains(hour)) {
                    Map<String, String> tempData = new HashMap<>();
                    tempData.put("hour", hour);
                    tempData.put("date", item.path("date").asText());
                    tempData.put("temperature", item.path("temperature").asText());

                    filteredResults.add(tempData);
                }
            }

            return filteredResults;

        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>(); // 오류 발생 시 빈 리스트 반환
        }
    }

    public Map<String, Object> getLatestWaterTempData(double latitude, double longitude) {
        try {
            // 1. 가장 가까운 수온 관측소 찾기
            String observatoryCode = observatoryService.findNearestWaterTempObservatory(latitude, longitude);
            String observatoryName = observatoryService.getWaterTempObservatoryName(observatoryCode);

            // 2. 오늘 날짜 구하기
            LocalDate today = LocalDate.now();
            String dateStr = today.format(DateTimeFormatter.ofPattern("yyyyMMdd"));

            // 3. API URL 구성
            String url = "http://www.khoa.go.kr/api/oceangrid/tideObsTemp/search.do" +
                    "?ServiceKey=" + waterTempKey +
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
                result.put("waterTemp", latestData.path("water_temp").asText());
                result.put("recordTime", latestTime);
            } else {
                result.put("error", "데이터를 찾을 수 없습니다");
            }

            return result;

        } catch (Exception e) {
            e.printStackTrace();
            Map<String, Object> errorResult = new HashMap<>();
            errorResult.put("error", "수온 데이터를 가져오는 중 오류가 발생했습니다: " + e.getMessage());
            return errorResult;
        }
    }
}
