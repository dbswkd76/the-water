package fishermanjoeandchildren.thewater.db.entity;
import java.io.Serializable;
import java.util.Objects;

public class AquariumLikeId implements Serializable {
    private Long aquariumId;
    private Long memberId;

    public AquariumLikeId() {
    }
    public AquariumLikeId(Long aquariumId, Long memberId) {
        this.aquariumId = aquariumId;
        this.memberId = memberId;
    }
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if(!(o instanceof AquariumLikeId)) return false;
        AquariumLikeId that = (AquariumLikeId) o;
        return Objects.equals(aquariumId, that.aquariumId) &&
                Objects.equals(memberId, that.memberId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(aquariumId, memberId);
    }
}
