package fishermanjoeandchildren.thewater.data.dto;

import fishermanjoeandchildren.thewater.db.entity.FishCard;
import lombok.*;

import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString
@Builder
public class AquariumFishCardDto {
    private String fishName;
    private Double fishSize;
    private Double waterTemperature;
    private LocalDate collectDate;

    //TODO 잡은 날짜
    public static AquariumFishCardDto fromEntity(FishCard fishCard) {
        return AquariumFishCardDto.builder()
                .fishName(fishCard.getFish().getFishName())
                .fishSize(fishCard.getFishSize())
                .waterTemperature(fishCard.getWaterTemperature())
                .collectDate(fishCard.getCollectDate())
                .build();
    }
}
