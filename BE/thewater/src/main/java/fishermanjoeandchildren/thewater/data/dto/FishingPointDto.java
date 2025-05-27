package fishermanjoeandchildren.thewater.data.dto;

import fishermanjoeandchildren.thewater.db.entity.FishingPoint;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FishingPointDto {
    private Long id;
    private String pointName;
    private String latitude;
    private String longitude;
    private String address;
    private String comment;

    public static FishingPointDto fromEntity(FishingPoint FishingPoint) {
        return FishingPointDto.builder()
                .id(FishingPoint.getId())
                .pointName(FishingPoint.getPointName())
                .latitude(FishingPoint.getLatitude())
                .longitude(FishingPoint.getLongitude())
                .address(FishingPoint.getAddress())
                .comment(FishingPoint.getComment())
                .build();
    }
}