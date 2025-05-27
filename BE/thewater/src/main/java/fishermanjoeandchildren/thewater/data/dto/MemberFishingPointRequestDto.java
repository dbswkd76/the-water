package fishermanjoeandchildren.thewater.data.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class MemberFishingPointRequestDto {
    private String pointName;
    private Double latitude;
    private Double longitude;
    private String address;
    private String comment;
}