package fishermanjoeandchildren.thewater.service;

import java.util.HashMap;
import java.util.Map;

public class GeoPointConverter {

    public static int[] convertToXY(double lat, double lon) {
        final double RE = 6371.00877; // 지구 반경(km)
        final double GRID = 5.0; // 격자 간격(km)
        final double SLAT1 = 30.0; // 투영 위도1(degree)
        final double SLAT2 = 60.0; // 투영 위도2(degree)
        final double OLON = 126.0; // 기준점 경도(degree)
        final double OLAT = 38.0; // 기준점 위도(degree)
        final double XO = 43; // 기준점 X좌표(GRID)
        final double YO = 136; // 기준점 Y좌표(GRID)

        final double DEGRAD = Math.PI / 180.0;
        final double re = RE / GRID;
        final double slat1 = SLAT1 * DEGRAD;
        final double slat2 = SLAT2 * DEGRAD;
        final double olon = OLON * DEGRAD;
        final double olat = OLAT * DEGRAD;

        double sn = Math.tan(Math.PI * 0.25 + slat2 * 0.5) / Math.tan(Math.PI * 0.25 + slat1 * 0.5);
        sn = Math.log(Math.cos(slat1) / Math.cos(slat2)) / Math.log(sn);
        double sf = Math.tan(Math.PI * 0.25 + slat1 * 0.5);
        sf = Math.pow(sf, sn) * Math.cos(slat1) / sn;
        double ro = Math.tan(Math.PI * 0.25 + olat * 0.5);
        ro = re * sf / Math.pow(ro, sn);

        double ra = Math.tan(Math.PI * 0.25 + lat * DEGRAD * 0.5);
        ra = re * sf / Math.pow(ra, sn);
        double theta = lon * DEGRAD - olon;
        if (theta > Math.PI) theta -= 2.0 * Math.PI;
        if (theta < -Math.PI) theta += 2.0 * Math.PI;
        theta *= sn;

        int x = (int) Math.floor(ra * Math.sin(theta) + XO + 0.5);
        int y = (int) Math.floor(ro - ra * Math.cos(theta) + YO + 0.5);

        return new int[]{x, y};
    }

    public static Map<String, Object> getWeatherForecast(double lat, double lon) {
        int[] xy = convertToXY(lat, lon);
        int nx = xy[0];
        int ny = xy[1];

        Map<String, Object> result = new HashMap<>();
        result.put("nx", nx);
        result.put("ny", ny);
        return result;
    }
}
