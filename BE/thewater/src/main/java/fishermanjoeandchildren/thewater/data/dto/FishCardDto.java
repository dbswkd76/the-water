package fishermanjoeandchildren.thewater.data.dto;

import fishermanjoeandchildren.thewater.db.entity.*;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.persistence.Column;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;


@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "물고기 카드 DTO")
public class FishCardDto {
    private Long id;
    private String fishName;
    private Double fishSize;
    private Integer sky;
    private Double temperature;
    private Double waterTemperature;
    private Integer tide;
    private String comment;
    private String cardImg;
    private Double latitude;
    private Double longitude;
    private LocalDate collectDate;
    private Boolean hasVisible = false;


    public FishCard toEntity(Member member, Fish fish , Aquarium aquarium) {
        return FishCard.builder()
                .member(member)
                .aquarium(aquarium)
                .fish(fish)
                .fishSize(this.fishSize)
                .sky(this.sky)
                .temperature(this.temperature)
                .waterTemperature(this.waterTemperature)
                .tide(this.tide)
                .comment(this.comment)
                .hasDeleted(false)
                .cardImg(this.cardImg)
                .hasVisible(this.hasVisible)
                .latitude(this.latitude)
                .longitude(this.longitude)
                .collectDate(LocalDate.now())
                .build();
    }

    public static FishCardDto fromEntity(FishCard fishCard){
        String fishName = fishCard.getFish().getFishName();
        return FishCardDto.builder()
                .id(fishCard.getId())
                .fishName(fishName)
                .fishSize(fishCard.getFishSize())
                .sky(fishCard.getSky())
                .temperature(fishCard.getTemperature())
                .waterTemperature(fishCard.getWaterTemperature())
                .tide(fishCard.getTide())
                .comment(fishCard.getComment())
                .cardImg(fishCard.getCardImg())
                .hasVisible(fishCard.getHasVisible())
                .latitude(fishCard.getLatitude())
                .longitude(fishCard.getLongitude())
                .collectDate(fishCard.getCollectDate())
                .build();
    }

}