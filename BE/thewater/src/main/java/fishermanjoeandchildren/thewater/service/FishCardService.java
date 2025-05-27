package fishermanjoeandchildren.thewater.service;
import fishermanjoeandchildren.thewater.data.ResponseMessage;
import fishermanjoeandchildren.thewater.data.ResponseStatus;
import fishermanjoeandchildren.thewater.data.dto.ApiResponse;
import fishermanjoeandchildren.thewater.data.dto.FishCardDto;
import fishermanjoeandchildren.thewater.db.entity.*;
import fishermanjoeandchildren.thewater.db.repository.*;
import fishermanjoeandchildren.thewater.util.FileUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;



@Service
@RequiredArgsConstructor
public class FishCardService {
    private final FishCardRepository fishCardRepository;
    private final FishRepository fishRepository;
    private final MemberRepository memberRepository;
    private final FishingPointRepository fishingPointRepository;
    private final FileUtil fileUtil;

    @Value("${file.upload-dir}")
    private String uploadDir;

    public ApiResponse<?> getAllFishCards(Long memberId) {
        Member member = memberRepository.findById(memberId).orElse(null);
        if (member == null) {
            return ApiResponse.builder()
                    .status(ResponseStatus.NOT_FOUND)
                    .message(ResponseMessage.NOT_FOUND)
                    .data("회원 정보가 없습니다.")
                    .build();
        }

        List<FishCard> fishCards = fishCardRepository.findFishCardExceptDeleted(member.getId());

        List<FishCardDto> fishCardDtos = fishCards.stream()
                .map(FishCardDto::fromEntity)
                .toList();

        return ApiResponse.builder()
                .status(ResponseStatus.SUCCESS)
                .message(ResponseMessage.SUCCESS)
                .data(fishCardDtos)
                .build();
    }


    public ApiResponse<?> addFishCard(FishCardDto fishCardDto, Long memberId, MultipartFile imageFile) {
        Member member = memberRepository.findById(memberId).orElse(null);
        if (member == null) {
            return ApiResponse.builder()
                    .status(ResponseStatus.NOT_FOUND)
                    .message(ResponseMessage.NOT_FOUND)
                    .data("회원 정보가 없습니다.")
                    .build();
        }

        Fish fish = fishRepository.findByFishname(fishCardDto.getFishName()).orElse(null);
        if (fish == null) {
            return ApiResponse.builder()
                    .status(ResponseStatus.NOT_FOUND)
                    .message(ResponseMessage.NOT_FOUND)
                    .data("물고기 정보가 없습니다.")
                    .build();
        }

        Aquarium aquarium = member.getAquarium();

        String imagePath = fileUtil.saveImage(imageFile);

        FishCard fishcard = fishCardDto.toEntity(member, fish, aquarium);
        fishcard.setCardImg(imagePath);
        fishCardRepository.save(fishcard);

        return ApiResponse.builder()
                .data(fishCardDto)
                .status(ResponseStatus.SUCCESS)
                .message(ResponseMessage.SUCCESS)
                .data("물고기가 도감에 성공적으로 등록되었습니다.")
                .build();
    }

    public ApiResponse<?> deleteFishCard(Long fishCardId, Long memberId) {
        FishCard fishCard = fishCardRepository.findById(fishCardId).orElse(null);
        if (fishCard == null) {
            return ApiResponse.builder()
                    .status(ResponseStatus.NOT_FOUND)
                    .message(ResponseMessage.NOT_FOUND)
                    .data("삭제할 물고기 카드를 찾을 수 없습니다.")
                    .build();
        }

        // 소유자 확인
        if (!fishCard.getMember().getId().equals(memberId)) {
            return ApiResponse.builder()
                    .status(ResponseStatus.AUTHROIZATION_FAILED)
                    .message(ResponseMessage.AUTHROIZATION_FAILED)
                    .data("접근할 수 없는 물고기 카드입니다.")
                    .build();
        }

        // soft delete 처리
        fishCard.setHasDeleted(true);
        fishCardRepository.save(fishCard);
        return ApiResponse.builder()
                .status(ResponseStatus.SUCCESS)
                .message(ResponseMessage.SUCCESS)
                .data("물고기 카드 삭제 완료")
                .build();
    }


}