package fishermanjoeandchildren.thewater.service;

import fishermanjoeandchildren.thewater.data.ResponseMessage;
import fishermanjoeandchildren.thewater.data.ResponseStatus;
import fishermanjoeandchildren.thewater.data.dto.ApiResponse;
import fishermanjoeandchildren.thewater.data.dto.GuestBookRequestDto;
import fishermanjoeandchildren.thewater.data.dto.GuestBookResponseDto;
import fishermanjoeandchildren.thewater.db.entity.Aquarium;
import fishermanjoeandchildren.thewater.db.entity.GuestBook;
import fishermanjoeandchildren.thewater.db.entity.Member;
import fishermanjoeandchildren.thewater.db.repository.AquariumRepository;
import fishermanjoeandchildren.thewater.db.repository.GuestBookRepository;
import fishermanjoeandchildren.thewater.db.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class GuestBookService {

    private final GuestBookRepository guestBookRepository;
    private final MemberRepository memberRepository;
    private final AquariumRepository aquariumRepository;

    public ApiResponse<?> getComments(Long aquariumId, Long currentMemberId){
        List<GuestBook> guestBook = guestBookRepository.findByAquariumId(aquariumId);

        List<GuestBookResponseDto> guestBookResponseDtos = guestBook.stream()
                .map(gb-> GuestBookResponseDto.fromEntity(gb,currentMemberId))
                .collect(Collectors.toList());

        return ApiResponse.builder()
                .status(ResponseStatus.SUCCESS)
                .message(ResponseMessage.SUCCESS)
                .data(guestBookResponseDtos)
                .build();
    }

    public ApiResponse<?> getMyGeustBookComments(Long currentMemberId){
        Long aquariumId = aquariumRepository.findByMemberId(currentMemberId).get().getId();
        List<GuestBook> guestBook = guestBookRepository.findByAquariumId(aquariumId);

        List<GuestBookResponseDto> guestBookResponseDtos = guestBook.stream()
                .map(gb-> GuestBookResponseDto.fromEntity(gb,currentMemberId))
                .collect(Collectors.toList());

        return ApiResponse.builder()
                .status(ResponseStatus.SUCCESS)
                .message(ResponseMessage.SUCCESS)
                .data(guestBookResponseDtos)
                .build();
    }

    public ApiResponse<?> writeComment(GuestBookRequestDto guestBookRequestDto, Long aquariumId, Long currentMemberId){
        Member guest = memberRepository.findById(currentMemberId).orElse(null);

        if(guest == null){
            ApiResponse.builder()
                    .status(ResponseStatus.NOT_FOUND)
                    .message(ResponseMessage.NOT_FOUND)
                    .data("사용자 정보를 가져올 수 없습니다.")
                    .build();
        }

        Aquarium aquarium = aquariumRepository.findById(aquariumId).orElse(null);

        if(aquarium == null){
            ApiResponse.builder()
                    .status(ResponseStatus.NOT_FOUND)
                    .message(ResponseMessage.NOT_FOUND)
                    .data("어항 정보를 가져올 수 없습니다.")
                    .build();
        }

        GuestBook guestBook = GuestBook.builder()
                .guest(guest)
                .aquarium(aquarium)
                .comment(guestBookRequestDto.getGuestBookComment())
                .build();

        guestBookRepository.save(guestBook);
        return ApiResponse.builder()
                .status(ResponseStatus.SUCCESS)
                .message(ResponseMessage.SUCCESS)
                .data("성공적으로 방명록을 등록했습니다.")
                .build();
    }

    public ApiResponse<?> editComment(Long guestBookId, Long currentMemberId, GuestBookRequestDto requestDto) {
        GuestBook guestBook = guestBookRepository.findById(guestBookId).orElse(null);

        if (guestBook == null) {
            return ApiResponse.builder()
                    .status(ResponseStatus.NOT_FOUND)
                    .message(ResponseMessage.NOT_FOUND)
                    .data("해당 방명록을 찾을 수 없습니다.")
                    .build();
        }

        if (!guestBook.getGuest().getId().equals(currentMemberId)) {
            return ApiResponse.builder()
                    .status(ResponseStatus.AUTHROIZATION_FAILED)
                    .message(ResponseMessage.AUTHROIZATION_FAILED)
                    .data("방명록 수정 권한이 없습니다.")
                    .build();
        }

        guestBook.setComment(requestDto.getGuestBookComment());
        guestBookRepository.save(guestBook);

        return ApiResponse.builder()
                .status(ResponseStatus.SUCCESS)
                .message(ResponseMessage.SUCCESS)
                .data("방명록이 수정되었습니다.")
                .build();
    }

    public ApiResponse<?> deleteComment(Long guestBookId, Long currentMemberId) {
        GuestBook guestBook = guestBookRepository.findById(guestBookId).orElse(null);

        if (guestBook == null) {
            return ApiResponse.builder()
                    .status(ResponseStatus.NOT_FOUND)
                    .message(ResponseMessage.NOT_FOUND)
                    .data("해당 방명록을 찾을 수 없습니다.")
                    .build();
        }

        if (!guestBook.getGuest().getId().equals(currentMemberId)) {
            return ApiResponse.builder()
                    .status(ResponseStatus.AUTHROIZATION_FAILED)
                    .message(ResponseMessage.AUTHROIZATION_FAILED)
                    .data("방명록 삭제 권한이 없습니다.")
                    .build();
        }

        guestBookRepository.delete(guestBook);

        return ApiResponse.builder()
                .status(ResponseStatus.SUCCESS)
                .message(ResponseMessage.SUCCESS)
                .data("방명록이 삭제되었습니다.")
                .build();
    }

}
