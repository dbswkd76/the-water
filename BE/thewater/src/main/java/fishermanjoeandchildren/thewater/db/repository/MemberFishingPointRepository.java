package fishermanjoeandchildren.thewater.db.repository;

import fishermanjoeandchildren.thewater.db.entity.MemberFishingPoint;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MemberFishingPointRepository extends JpaRepository<MemberFishingPoint, Long> {
    // 회원 ID로 낚시 포인트 목록 찾기
    List<MemberFishingPoint> findByMemberId(Long memberId);
}
