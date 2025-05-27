package fishermanjoeandchildren.thewater.db.repository;

import fishermanjoeandchildren.thewater.db.entity.Member;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface MemberRepository extends JpaRepository<Member, Long> {
    boolean existsByLoginId(String loginId);
    boolean existsByEmail(String email);
    boolean existsByNickname(String nickname);
    Optional<Member> findByLoginId(String loginId);

    List<Member> findByNicknameContaining(String nickname);

    @Query("SELECT m.nickname FROM Member m WHERE m.has_deleted = false")
    List<String> findAllActiveNicknames();

    @Query("SELECT m FROM Member m JOIN m.aquarium a WHERE m.nickname LIKE %:nickname% AND a.open = true AND m.has_deleted = false")
    List<Member> findByNicknameContainingAndAquariumOpenTrue(@Param("nickname") String nickname);

    @Query("SELECT m.nickname FROM Member m JOIN m.aquarium a WHERE m.has_deleted = false AND a.open = true")
    List<String> findAllActiveNicknamesWithOpenAquarium();
}
