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
public class GuestBookRequestDto {
    @NotNull
    private String guestBookComment;


    public static GuestBookRequestDto fromEntity(GuestBook guestBook, Long currentMember){

        return GuestBookRequestDto.builder()
                .guestBookComment(guestBook.getComment())
                .build();
    }

    public static GuestBook toEntity(GuestBookRequestDto guestBookDto, Aquarium aquarium , Member member){

        return GuestBook.builder()
                .comment(guestBookDto.getGuestBookComment())
                .aquarium(aquarium)
                .guest(member)
                .build();
    }
}
