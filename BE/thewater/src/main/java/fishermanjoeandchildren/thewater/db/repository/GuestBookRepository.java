package fishermanjoeandchildren.thewater.db.repository;

import fishermanjoeandchildren.thewater.db.entity.GuestBook;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface GuestBookRepository extends JpaRepository<GuestBook, Long> {

    @Query("SELECT g FROM GuestBook g WHERE g.aquarium.id=:aquariumId")
    List<GuestBook> findByAquariumId(Long aquariumId);


}
