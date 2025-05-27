package fishermanjoeandchildren.thewater.db.repository;

import fishermanjoeandchildren.thewater.db.entity.AquariumLike;
import fishermanjoeandchildren.thewater.db.entity.AquariumLikeId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AquariumLikeRepository extends JpaRepository<AquariumLike, AquariumLikeId> {
    boolean existsByAquariumIdAndMemberId(Long aquariumId, Long memberId);

}
