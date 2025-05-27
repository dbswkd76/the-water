package fishermanjoeandchildren.thewater.service;

import fishermanjoeandchildren.thewater.data.dto.FishingPointDto;
import fishermanjoeandchildren.thewater.data.dto.MemberFishingPointDto;
import fishermanjoeandchildren.thewater.db.entity.MemberFishingPoint;
import fishermanjoeandchildren.thewater.db.repository.FishingPointRepository;
import fishermanjoeandchildren.thewater.db.repository.MemberFishingPointRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import fishermanjoeandchildren.thewater.data.dto.MemberFishingPointRequestDto;
import org.springframework.util.StringUtils;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FishingPointService {

    // 레포지토리 의존성 주입
    private final FishingPointRepository fishingPointRepository;
    private final MemberFishingPointRepository memberFishingPointRepository;
    private final ReverseGeocodingService reverseGeocodingService;

    public List<FishingPointDto> getAllFishingPoints() {
        return fishingPointRepository.findAll() // 소문자로 변경(인스턴스 메서드)
                .stream()
                .map(FishingPointDto::fromEntity)
                .collect(Collectors.toList());
    }

    // 회원 낚시 포인트 가져오기
    public List<MemberFishingPointDto> getMemberFishingPoints(Long memberId) {
        return memberFishingPointRepository.findByMemberId(memberId)
                .stream()
                .map(MemberFishingPointDto::fromEntity)
                .collect(Collectors.toList());
    }

    // 회원 낚시 포인트 추가 - 주소 자동 파싱 추가
    public MemberFishingPoint addMemberFishingPoint(
            Long memberId,
            String pointName,
            Double latitude,
            Double longitude,
            String comment) {
        // 구글 API로 주소 가져오기
        String address = null;
        if (latitude != null && longitude != null) {
            address = reverseGeocodingService.getAddressFromCoordinates(latitude, longitude);
        }

        // 주소를 가져오지 못했다면 기본값 설정
        if (!StringUtils.hasText(address)) {
            address = "위치 정보 없음";
        }

        // pointName이 비어있다면 주소에서 이름 추출하여 기본값으로 설정
        if (pointName == null || pointName.trim().isEmpty()) {
            pointName = reverseGeocodingService.extractLocationNameFromAddress(address);
        }
        // 낚시 포인트 생성
        MemberFishingPoint memberFishingPoint = MemberFishingPoint.builder()
                .memberId(memberId)
                .pointName(pointName)
                .latitude(latitude)
                .longitude(longitude)
                .address(address) // 파싱된 주소 사용
                .comment(comment)
                .build();

        return memberFishingPointRepository.save(memberFishingPoint);
    }

    // 회원 낚시 포인트 부분 수정 (이름, 코멘트만)
    public MemberFishingPoint patchMemberFishingPoint(
            Long pointId,
            Long memberId,
            String pointName,
            String comment) {
        // 포인트 존재 여부와 소유자 확인
        MemberFishingPoint existingPoint = memberFishingPointRepository.findById(pointId)
                .orElseThrow(() -> new IllegalArgumentException("낚시 포인트를 찾을 수 없습니다."));

        // 소유자 확인
        if (!existingPoint.getMemberId().equals(memberId)) {
            throw new IllegalArgumentException("해당 낚시 포인트에 접근 권한이 없습니다.");
        }

        // 전달된 필드만 업데이트
        if (pointName != null) {
            existingPoint.setPointName(pointName);
        }

        if (comment != null) {
            existingPoint.setComment(comment);
        }

        // 저장 및 반환
        return memberFishingPointRepository.save(existingPoint);
    }

    // 회원 낚시 포인트 삭제
    public void deleteMemberFishingPoint(Long pointId, Long memberId) {
        // 포인트 존재 여부와 소유자 확인
        MemberFishingPoint existingPoint = memberFishingPointRepository.findById(pointId)
                .orElseThrow(() -> new IllegalArgumentException("낚시 포인트를 찾을 수 없습니다."));

        // 소유자 확인
        if (!existingPoint.getMemberId().equals(memberId)) {
            throw new IllegalArgumentException("해당 낚시 포인트에 접근 권한이 없습니다.");
        }

        // 삭제
        memberFishingPointRepository.deleteById(pointId);
    }
}