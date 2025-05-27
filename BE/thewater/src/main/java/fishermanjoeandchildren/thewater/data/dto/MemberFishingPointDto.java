// src/main/java/fishermanjoeandchildren/thewater/data/dto/MemberFishingPointDto.java
package fishermanjoeandchildren.thewater.data.dto;

import fishermanjoeandchildren.thewater.db.entity.MemberFishingPoint;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MemberFishingPointDto {
    private Long pointId;
    private Long memberId;
    private String pointName;
    private Double latitude;
    private Double longitude;
    private String address;
    private String comment;

    public static MemberFishingPointDto fromEntity(MemberFishingPoint memberFishingPoint) {
        return MemberFishingPointDto.builder()
                .pointId(memberFishingPoint.getPointId())
                .memberId(memberFishingPoint.getMemberId())
                .pointName(memberFishingPoint.getPointName())
                .latitude(memberFishingPoint.getLatitude())
                .longitude(memberFishingPoint.getLongitude())
                .address(memberFishingPoint.getAddress())
                .comment(memberFishingPoint.getComment())
                .build();
    }
}