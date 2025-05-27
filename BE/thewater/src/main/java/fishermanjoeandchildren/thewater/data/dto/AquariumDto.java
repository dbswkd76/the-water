package fishermanjoeandchildren.thewater.data.dto;

import fishermanjoeandchildren.thewater.db.entity.Aquarium;
import fishermanjoeandchildren.thewater.db.entity.AquariumLike;
import fishermanjoeandchildren.thewater.db.entity.FishCard;
import fishermanjoeandchildren.thewater.db.entity.Member;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.util.List;
import java.util.stream.Collectors;

@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString
@Builder
public class AquariumDto {

    @NotNull
    private Long id;

    @NotNull
    @Min(value = 0)
    @Max(value = 2100000000)
    private int visitorCnt;

    @NotNull
    @Min(value = 0)
    @Max(value = 2100000000)
    private int likeCnt;


    @NotNull
    @Min(value = 0)
    @Max(value = 2100000000)
    private int fishCnt;

    @NotNull
    @Min(value = 0)
    @Max(value = 2100000000)
    private int totalPrice;

    @NotNull
    private boolean open = true;

    @NotNull
    private Long member_id;

    private List<AquariumFishCardDto> visibleFishCards;

    @NotNull
    private boolean likedByMe;

    public Aquarium toEntity(Member owner){
        Aquarium aquarium = Aquarium.builder()
                .id(id)
                .visitorCnt(visitorCnt)
                .likeCnt(likeCnt)
                .fishCnt(fishCnt)
                .totalPrice(totalPrice)
                .open(open)
                .member(owner)
                .build();
        return aquarium;
    }

    public static AquariumDto fromEntity(Aquarium aquarium, Long currentMemberId) {
        boolean likedByMe = aquarium.getAquariumLikes() != null &&
                aquarium.getAquariumLikes().stream()
                        .anyMatch(like -> like.getMemberId().equals(currentMemberId));

        List<AquariumFishCardDto> aquariumFishes = aquarium.getFishCard().stream()
                .filter(f -> Boolean.TRUE.equals(f.getHasVisible()))
                .map(AquariumFishCardDto::fromEntity)
                .collect(Collectors.toList());

        return AquariumDto.builder()
                .id(aquarium.getId())
                .visitorCnt(aquarium.getVisitorCnt())
                .likeCnt(aquarium.getLikeCnt())
                .fishCnt(aquarium.getFishCnt())
                .totalPrice(aquarium.getTotalPrice())
                .open(aquarium.isOpen())
                .member_id(aquarium.getMember().getId())
                .visibleFishCards(aquariumFishes)
                .likedByMe(likedByMe)
                .build();
    }


}
