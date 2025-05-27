package fishermanjoeandchildren.thewater.service;


import fishermanjoeandchildren.thewater.data.ResponseMessage;
import fishermanjoeandchildren.thewater.data.ResponseStatus;
import fishermanjoeandchildren.thewater.data.dto.*;
import fishermanjoeandchildren.thewater.db.entity.*;
import fishermanjoeandchildren.thewater.db.repository.AquariumLikeRepository;
import fishermanjoeandchildren.thewater.db.repository.AquariumRepository;
import fishermanjoeandchildren.thewater.db.repository.FishCardRepository;
import fishermanjoeandchildren.thewater.db.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AquariumService {

    private final AquariumRepository aquariumRepository;
    private final MemberRepository memberRepository;
    private final AquariumLikeRepository aquariumLikeRepository;
    private final FishCardRepository fishCardRepository;

    public AquariumDto saveAquarium(AquariumDto aquariumDto, Long currentMemberId){

        Member member = memberRepository.findById(aquariumDto.getMember_id()).orElseThrow(() -> new IllegalArgumentException("존재하지 않는 멤버입니다."));

        Aquarium aquarium = aquariumDto.toEntity(member);
        Aquarium savedAquarium = aquariumRepository.save(aquarium);


        return AquariumDto.fromEntity(savedAquarium, currentMemberId);
    }


    public ApiResponse<?> getAquarium(Long aquariumId, Long currentMemberId){
        Aquarium aquarium = aquariumRepository.findById(aquariumId).orElse(null);
        if(aquarium == null){
            return ApiResponse.builder()
                    .status(ResponseStatus.NOT_FOUND)
                    .message(ResponseMessage.NOT_FOUND)
                    .data("어항이 존재하지 않습니다.")
                    .build();

        }

        if(!currentMemberId.equals(aquarium.getMember().getId()) &&!aquarium.isOpen()){
            return ApiResponse.builder()
                    .status(ResponseStatus.AUTHROIZATION_FAILED)
                    .message(ResponseMessage.AUTHROIZATION_FAILED)
                    .data("어항 접근 권한이 없습니다.")
                    .build();
        }

        AquariumDto aquariumDto = AquariumDto.fromEntity(aquarium,currentMemberId);
        return ApiResponse.builder()
                .status(ResponseStatus.SUCCESS)
                .message(ResponseMessage.SUCCESS)
                .data(aquariumDto)
                .build();
    }

    public ApiResponse<?> getMyAquarium(Long currentMemberId){
        Aquarium aquarium = aquariumRepository.findByMemberId(currentMemberId).orElse(null);
        if(aquarium == null){
            return ApiResponse.builder()
                    .status(ResponseStatus.NOT_FOUND)
                    .message(ResponseMessage.NOT_FOUND)
                    .data("어항이 존재하지 않습니다.")
                    .build();

        }

        AquariumDto aquariumDto = AquariumDto.fromEntity(aquarium,currentMemberId);
        return ApiResponse.builder()
                .status(ResponseStatus.SUCCESS)
                .message(ResponseMessage.SUCCESS)
                .data(aquariumDto)
                .build();
    }

    public ApiResponse<?> updateVisitorCount(Long aquariumId){
        Aquarium aquarium = aquariumRepository.findById(aquariumId).orElse(null);
        if(aquarium == null){
            return ApiResponse.builder()
                    .status(ResponseStatus.NOT_FOUND)
                    .message(ResponseMessage.NOT_FOUND)
                    .data("해당 어항을 찾을 수 없습니다.")
                    .build();
        }

        aquarium.incrementVisitors();
        aquariumRepository.save(aquarium);
        return ApiResponse.builder()
                .status(ResponseStatus.SUCCESS)
                .message(ResponseMessage.SUCCESS)
                .data("어항 방문자 수가 업데이트되었습니다.")
                .build();
    }

    public ApiResponse<?> likeAquarium(Long aquariumId, Long currentMemberId){
        Aquarium aquarium = aquariumRepository.findById(aquariumId).orElse(null);

        if(aquarium == null){
            return ApiResponse.builder()
                    .status(ResponseStatus.NOT_FOUND)
                    .message(ResponseMessage.NOT_FOUND)
                    .data("해당 어항을 찾을 수 없습니다.")
                    .build();
        }

        if(aquariumLikeRepository.existsByAquariumIdAndMemberId(aquariumId, currentMemberId)){
            return ApiResponse.builder()
                    .status(ResponseStatus.CONFLICT)
                    .message(ResponseMessage.CONFLICT)
                    .data("이미 좋아요를 누른 어항입니다.")
                    .build();
        }

        AquariumLike like = AquariumLike.builder()
                . aquariumId(aquariumId)
                .memberId(currentMemberId)
                .build();
        aquariumLikeRepository.save(like);

        aquarium.incrementLikes();
        aquariumRepository.save(aquarium);

        return ApiResponse.builder()
                .status(ResponseStatus.SUCCESS)
                .message(ResponseMessage.SUCCESS)
                .data("어항에 좋아요를 눌렀습니다.")
                .build();
    }

    public ApiResponse<?> unlikeAquarium(Long aquariumId, Long memberId) {
        Aquarium aquarium = aquariumRepository.findById(aquariumId).orElse(null);
        if (aquarium == null) {
            return ApiResponse.builder()
                    .status(ResponseStatus.NOT_FOUND)
                    .message(ResponseMessage.NOT_FOUND)
                    .data("존재하지 않는 어항입니다.")
                    .build();
        }

        AquariumLikeId likeId = new AquariumLikeId(aquariumId, memberId);

        if (!aquariumLikeRepository.existsByAquariumIdAndMemberId(aquariumId,memberId)) {
            return ApiResponse.builder()
                    .status(ResponseStatus.NOT_FOUND)
                    .message(ResponseMessage.NOT_FOUND)
                    .data("좋아요 기록이 없습니다.")
                    .build();
        }

        aquariumLikeRepository.deleteById(new AquariumLikeId(aquariumId,memberId));
        aquarium.decrementLikes();
        aquariumRepository.save(aquarium);

        return ApiResponse.builder()
                .status(ResponseMessage.SUCCESS)
                .message(ResponseMessage.SUCCESS)
                .data("좋아요가 취소되었습니다.")
                .build();
    }

    public ApiResponse<?> changeAquariumFishVisible(Long memberId, Long fishCardId){
        Aquarium aquarium = aquariumRepository.findByMemberId(memberId).orElse(null);
        FishCard fishCard = fishCardRepository.findById(fishCardId).orElse(null);

        if (aquarium == null) {
            return ApiResponse.builder()
                    .status(ResponseStatus.NOT_FOUND)
                    .message(ResponseMessage.NOT_FOUND)
                    .data("존재하지 않는 어항입니다.")
                    .build();
        } else if (fishCard == null) {
            return ApiResponse.builder()
                    .status(ResponseStatus.NOT_FOUND)
                    .message(ResponseMessage.NOT_FOUND)
                    .data("물고기 정보가 없습니다.")
                    .build();
        }else if (!memberId.equals(aquarium.getMember().getId())) {
            return ApiResponse.builder()
                    .status(ResponseStatus.AUTHROIZATION_FAILED)
                    .message(ResponseMessage.AUTHROIZATION_FAILED)
                    .data("어항 접근 권한이 없습니다.")
                    .build();
        }else if (!fishCard.getMember().getId().equals(memberId)) {
            return ApiResponse.builder()
                    .status(ResponseStatus.AUTHROIZATION_FAILED)
                    .message(ResponseMessage.AUTHROIZATION_FAILED)
                    .data("물고기 접근 권한이 없습니다.")
                    .build();
        }

        boolean visible = fishCard.changeFishVisible();
        String responseData;
        if(visible){
            aquarium.makeFishVisible(fishCard.getFish().getPrice());
            responseData = "어항 물고기 등록이 완료되었습니다.";
        }else{
            aquarium.makeFishInvisible(fishCard.getFish().getPrice());
            responseData = "어항 물고기 삭제가 완료되었습니다.";

        }
        fishCardRepository.save(fishCard);
        aquariumRepository.save(aquarium);

        return ApiResponse.builder()
                .status(ResponseStatus.SUCCESS)
                .message(ResponseMessage.SUCCESS)
                .data(responseData)
                .build();
    }

    public ApiResponse<List<AquariumRankingDto>> getTopAquariums(int number){
        List<Aquarium> topAquariums = aquariumRepository.findTopByOrderByTotalPriceDesc(number);
        List<AquariumRankingDto> aquariumRankingDtos = topAquariums.stream()
                .map(AquariumRankingDto::fromEntity)
                .collect(Collectors.toList());

        return ApiResponse.<List<AquariumRankingDto>>builder()
                .status(ResponseStatus.SUCCESS)
                .message(ResponseMessage.SUCCESS)
                .data(aquariumRankingDtos)
                .build();
    }

    public ApiResponse<List<AquariumRankingDto>> getRandomAquariums(int number){

        List<Long> allIds = aquariumRepository.findAllIds();
        Collections.shuffle(allIds);
        int end = Math.min(number, allIds.size());
        List<Long> selectedIds = allIds.subList(0, end);
        List<Aquarium> randomAquariums = aquariumRepository.findAllById(selectedIds);


        List<AquariumRankingDto> randomAquariumRankingDtos = randomAquariums.stream()
                .map(AquariumRankingDto::fromEntity)
                .collect(Collectors.toList());

        return ApiResponse.<List<AquariumRankingDto>>builder()
                .status(ResponseStatus.SUCCESS)
                .message(ResponseMessage.SUCCESS)
                .data(randomAquariumRankingDtos)
                .build();
    }


    public ApiResponse<?> changeAquariumOpen(Long memberId) {
        Aquarium aquarium = aquariumRepository.findByMemberId(memberId).orElse(null);

        if (aquarium == null) {
            return ApiResponse.builder()
                    .status(ResponseStatus.NOT_FOUND)
                    .message(ResponseMessage.NOT_FOUND)
                    .data("존재하지 않는 어항입니다.")
                    .build();
        }

        boolean open = aquarium.changeOpen();
        String responseData;
        if (open) {
            responseData = "어항이 공개 모드로 변경되었습니다.";
        } else {
            responseData = "어항이 비공개 모드로 변경되었습니다.";

        }
        aquariumRepository.save(aquarium);

        return ApiResponse.builder()
                .status(ResponseStatus.SUCCESS)
                .message(ResponseMessage.SUCCESS)
                .data(responseData)
                .build();


    }
}
