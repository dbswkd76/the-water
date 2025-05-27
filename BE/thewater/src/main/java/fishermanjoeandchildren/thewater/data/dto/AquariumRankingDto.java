package fishermanjoeandchildren.thewater.data.dto;

import fishermanjoeandchildren.thewater.db.entity.Aquarium;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString
@Builder
public class AquariumRankingDto {

    @NotNull
    private Long aquariumId;

    @NotNull
    private Long memberId;

    @NotNull
    private String nickname;

    @NotNull
    @Min(value = 0)
    @Max(value = 2100000000)
    private int totalPrice;

    private String memberComment;

    public static AquariumRankingDto fromEntity(Aquarium aquarium){
        return AquariumRankingDto.builder()
                .aquariumId(aquarium.getId())
                .memberId(aquarium.getMember().getId())
                .nickname(aquarium.getMember().getNickname())
                .totalPrice(aquarium.getTotalPrice())
                .memberComment(aquarium.getMember().getComment())
                .build();
    }

}
