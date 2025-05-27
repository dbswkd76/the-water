// src/main/java/fishermanjoeandchildren/thewater/util/LunarCalendarUtil.java (수정)

package fishermanjoeandchildren.thewater.util;

import com.ibm.icu.util.ChineseCalendar;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.ZoneId;
import java.util.Calendar;
import java.util.Date;

@Component
public class LunarCalendarUtil {

    /**
     * 양력 날짜를 음력 날짜로 변환합니다.
     * @param solarDate 양력 날짜
     * @return 음력 날짜 [year, month, day] 형태의 배열
     */
    public int[] solarToLunar(LocalDate solarDate) {
        Date date = Date.from(solarDate.atStartOfDay(ZoneId.systemDefault()).toInstant());
        Calendar cal = Calendar.getInstance();
        cal.setTime(date);

        ChineseCalendar cc = new ChineseCalendar();
        cc.setTimeInMillis(cal.getTimeInMillis());

        int year = cc.get(ChineseCalendar.YEAR);
        int month = cc.get(ChineseCalendar.MONTH) + 1; // ChineseCalendar.MONTH는 0부터 시작
        int day = cc.get(ChineseCalendar.DAY_OF_MONTH);

        return new int[] {year, month, day};
    }

    /**
     * 오늘 날짜의 음력 일(day)을 반환합니다.
     * @return 오늘의 음력 일(day)
     */
    public int getTodayLunarDay() {
        LocalDate today = LocalDate.now();
        int[] lunarDate = solarToLunar(today);
        return lunarDate[2]; // 배열의 3번째 요소가 day
    }
}