package fishermanjoeandchildren.thewater.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.json.JSONArray;
import org.json.JSONObject;

import java.util.regex.Pattern;

@Service
public class ReverseGeocodingService {

    @Value("${google.api}")
    private String googleApiUrl;

    @Value("${google.api.key}")
    private String apiKey;

    private final RestTemplate restTemplate;

    public ReverseGeocodingService(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    public String getAddressFromCoordinates(double latitude, double longitude) {
        String url = googleApiUrl
                + "?latlng=" + latitude
                + "," + longitude
                + "&key=" + apiKey
                + "&language=ko";

        try {
            // API 호출
            String response = restTemplate.getForObject(url, String.class);

            // JSON 파싱
            JSONObject jsonResponse = new JSONObject(response);

            // 상태 확인
            if (!"OK".equals(jsonResponse.getString("status"))) {
                return null;
            }

            // results 배열 가져오기
            JSONArray results = jsonResponse.getJSONArray("results");

            if (results.length() > 0) {
                for (int i = 0; i < results.length(); i++) {
                    JSONObject result = results.getJSONObject(i);

                    // formatted_address 가져오기
                    String formattedAddress = result.getString("formatted_address");

                    Pattern pattern = Pattern.compile("\\d+");

                    // 상세 주소를 포함하는 결과인지 확인 (보통 상세 주소가 포함된 결과가 위에 나옴)
                    if (pattern.matcher(formattedAddress).find()) {
                        return formattedAddress;
                    }
                }

                // 상세 주소가 없으면 첫 번째 결과 반환
                return results.getJSONObject(0).getString("formatted_address");
            }

            return null;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    // 주소에서 간단한 이름 추출 (pointName 기본값으로 사용)
    public String extractLocationNameFromAddress(String address) {
        if (address == null) {
            return "내가 찾은 레전드 낚시 포인트";
        }

        // 주소에서 마지막 부분 추출 (동, 리 등)
        String[] parts = address.split(" ");
        if (parts.length > 0) {
            // 마지막 부분에 숫자가 있으면 그 앞부분까지 포함
            String lastPart = parts[parts.length - 1];
            if (lastPart.matches(".*\\d+.*") && parts.length > 1) {
                return parts[parts.length - 2] + " " + lastPart;
            }
            return lastPart;
        }

        return "내가 찾은 레전드 낚시 포인트";
    }
}