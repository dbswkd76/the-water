package fishermanjoeandchildren.thewater.db.repository;

import fishermanjoeandchildren.thewater.data.dto.FishCardDto;
import fishermanjoeandchildren.thewater.db.entity.FishCard;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FishCardRepository extends JpaRepository<FishCard, Long> {
    @Query("SELECT f FROM FishCard f WHERE f.member.id = :memberId AND f.hasDeleted = false")
    List<FishCard> findFishCardExceptDeleted(@Param("memberId") Long memberId);



}
