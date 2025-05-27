package fishermanjoeandchildren.thewater.data.dto;

import fishermanjoeandchildren.thewater.db.entity.Aquarium;
import fishermanjoeandchildren.thewater.db.entity.GuestBook;
import fishermanjoeandchildren.thewater.db.entity.Member;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@ToString
@Builder
public class GuestBookResponseDto {
    private Long guestBookId;

    @NotNull
    private String guestNickname;

    @NotNull
    private String guestBookComment;

    private Boolean wroteByMe;

    public static GuestBookResponseDto fromEntity(GuestBook guestBook, Long currentMember){

        boolean myCommnet = guestBook.getGuest().getId().equals(currentMember);

        return GuestBookResponseDto.builder()
                .guestBookId(guestBook.getId())
                .guestNickname(guestBook.getGuest().getNickname())
                .guestBookComment(guestBook.getComment())
                .wroteByMe(myCommnet)
                .build();
    }

    public static GuestBook toEntity(GuestBookResponseDto guestBookDto, Aquarium aquarium , Member member){

        return GuestBook.builder()
                .comment(guestBookDto.getGuestBookComment())
                .aquarium(aquarium)
                .guest(member)
                .build();
    }
}
