package fishermanjoeandchildren.thewater.service;

import org.springframework.stereotype.Service;
import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import jakarta.annotation.PostConstruct;

@Service
public class ObservatoryService {

    // 관측소 정보를 저장할 클래스
    private static class Observatory {
        String code;
        String name;
        double latitude;
        double longitude;

        public Observatory(String code, String name, double latitude, double longitude) {
            this.code = code;
            this.name = name;
            this.latitude = latitude;
            this.longitude = longitude;
        }
    }

    // 각 용도별 관측소 목록
    private List<Observatory> predictObservatories = new ArrayList<>();  // 예측용
    private List<Observatory> realTimeObservatories = new ArrayList<>(); // 실측용
    private List<Observatory> waterTempObservatories = new ArrayList<>(); // 수온용

    // 각 용도별 관측소 맵
    private Map<String, Observatory> predictObservatoryMap = new HashMap<>();
    private Map<String, Observatory> realTimeObservatoryMap = new HashMap<>();
    private Map<String, Observatory> waterTempObservatoryMap = new HashMap<>();

    // 서비스 초기화 시 관측소 데이터 로드
    @PostConstruct
    public void init() {
        // 기존 관측소 데이터 로드
        loadObservatoryData("/observatories.txt", predictObservatories, predictObservatoryMap, "예측용");
        loadObservatoryData("/tide_obs_stations.txt", realTimeObservatories, realTimeObservatoryMap, "실측용");

        // 수온 관측소 데이터 로드
        loadObservatoryData("/water_temp_stations.txt", waterTempObservatories, waterTempObservatoryMap, "수온용");
    }

    /**
     * 지정된 파일에서 관측소 데이터를 로드합니다.
     */
    private void loadObservatoryData(String filePath, List<Observatory> observatoryList,
                                     Map<String, Observatory> observatoryMap, String typeName) {
        try {
            // 클래스패스에서 관측소 데이터 파일 로드
            InputStream is = getClass().getResourceAsStream(filePath);
            if (is == null) {
                System.err.println(typeName + " 관측소 데이터 파일을 찾을 수 없습니다: " + filePath);
                return;
            }

            BufferedReader reader = new BufferedReader(new InputStreamReader(is));

            // 헤더 스킵
            String line = reader.readLine();

            while ((line = reader.readLine()) != null) {
                String[] parts = line.split("\\t");
                if (parts.length >= 4) {
                    String code = parts[0].trim();
                    String name = parts[1].trim();
                    double latitude = Double.parseDouble(parts[2].trim());
                    double longitude = Double.parseDouble(parts[3].trim());

                    Observatory observatory = new Observatory(code, name, latitude, longitude);
                    observatoryList.add(observatory);
                    observatoryMap.put(code, observatory);
                }
            }

            reader.close();
            System.out.println(typeName + " 관측소 " + observatoryList.size() + "개 로드 완료");
        } catch (Exception e) {
            System.err.println(typeName + " 관측소 데이터 로드 실패: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * 하버사인 공식(Haversine formula)을 사용하여 두 지점 간의 거리를 계산
     */
    private double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        // 지구 반경 (km)
        final double R = 6371.0;

        // 라디안으로 변환
        double lat1Rad = Math.toRadians(lat1);
        double lon1Rad = Math.toRadians(lon1);
        double lat2Rad = Math.toRadians(lat2);
        double lon2Rad = Math.toRadians(lon2);

        // 위도 및 경도 차이
        double dLat = lat2Rad - lat1Rad;
        double dLon = lon2Rad - lon1Rad;

        // 하버사인 공식
        double a = Math.pow(Math.sin(dLat / 2), 2) +
                Math.cos(lat1Rad) * Math.cos(lat2Rad) *
                        Math.pow(Math.sin(dLon / 2), 2);

        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        double distance = R * c;

        return distance;
    }

    /**
     * 가장 가까운 관측소 찾기 (일반 메서드)
     */
    private String findNearestObservatory(double latitude, double longitude, List<Observatory> observatoriesList) {
        if (observatoriesList.isEmpty()) {
            throw new IllegalStateException("관측소 데이터가 로드되지 않았습니다.");
        }

        Observatory nearest = null;
        double minDistance = Double.MAX_VALUE;

        for (Observatory obs : observatoriesList) {
            double distance = calculateDistance(latitude, longitude, obs.latitude, obs.longitude);
            if (distance < minDistance) {
                minDistance = distance;
                nearest = obs;
            }
        }

        if (nearest != null) {
            System.out.println("가장 가까운 관측소: " + nearest.name + " (" + nearest.code + "), 거리: " + minDistance + "km");
            return nearest.code;
        } else {
            throw new IllegalStateException("가장 가까운 관측소를 찾을 수 없습니다.");
        }
    }

    // 각 용도별 관측소 찾기 메서드
    public String findNearestPredictObservatory(double latitude, double longitude) {
        return findNearestObservatory(latitude, longitude, predictObservatories);
    }

    public String findNearestRealTimeObservatory(double latitude, double longitude) {
        return findNearestObservatory(latitude, longitude, realTimeObservatories);
    }

    public String findNearestWaterTempObservatory(double latitude, double longitude) {
        return findNearestObservatory(latitude, longitude, waterTempObservatories);
    }

    // 각 용도별 관측소 이름 조회 메서드
    public String getPredictObservatoryName(String code) {
        Observatory observatory = predictObservatoryMap.get(code);
        return observatory != null ? observatory.name : "알 수 없는 관측소";
    }

    public String getRealTimeObservatoryName(String code) {
        Observatory observatory = realTimeObservatoryMap.get(code);
        return observatory != null ? observatory.name : "알 수 없는 관측소";
    }

    public String getWaterTempObservatoryName(String code) {
        Observatory observatory = waterTempObservatoryMap.get(code);
        return observatory != null ? observatory.name : "알 수 없는 관측소";
    }

    // 기존 메서드 호환성 유지
    public String findNearestObservatory(double latitude, double longitude) {
        return findNearestPredictObservatory(latitude, longitude);
    }

    public String getObservatoryName(String code) {
        return getPredictObservatoryName(code);
    }
}