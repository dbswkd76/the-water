package fishermanjoeandchildren.thewater.data.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MypageResponseDto {
    private String nickname;
    private String loginId;
    private LocalDate latestFishDate;
    private String latestFishLocation;
    private int totalFishCaught;
}