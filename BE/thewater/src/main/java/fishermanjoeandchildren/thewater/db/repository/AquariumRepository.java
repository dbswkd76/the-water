package fishermanjoeandchildren.thewater.db.repository;

import fishermanjoeandchildren.thewater.db.entity.Aquarium;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface AquariumRepository extends JpaRepository<Aquarium, Long>{

    @Query("SELECT a FROM Aquarium a WHERE a.open = true ORDER BY a.totalPrice DESC")
    List<Aquarium> findTopByOrderByTotalPriceDesc(Pageable pageable);

    default List<Aquarium> findTopByOrderByTotalPriceDesc(int limit) {
        return findTopByOrderByTotalPriceDesc(PageRequest.of(0, limit));
    }

    Optional<Aquarium> findByMemberId(Long memberId);

    @Query("SELECT a.id From Aquarium a WHERE a.open = true")
    List<Long> findAllIds();
}
