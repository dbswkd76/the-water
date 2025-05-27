package fishermanjoeandchildren.thewater.db.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "aquarium")
@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Aquarium extends Common {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;

    @Column(nullable = false, name="visitor_count")
    private int visitorCnt;

    @Column(nullable = false, name="like_count")
    private int likeCnt;

    @Column(name="fish_count")
    private int fishCnt;

    @Column(name="total_price", nullable = false)
    private int totalPrice;

    @Column(name = "open", nullable = false)
    private boolean open = true;

    @OneToOne(mappedBy = "aquarium")
    private Member member;

    @OneToMany(mappedBy = "aquarium")
    private List<FishCard> fishCard;

    @OneToMany(mappedBy = "aquarium", cascade = CascadeType.ALL)
    private List<AquariumLike> aquariumLikes=new ArrayList<>();

    public void incrementVisitors(){
        this.visitorCnt++;
    }

    public void incrementLikes(){
        this.likeCnt++;
    }

    public void decrementLikes() {
        if (this.likeCnt > 0) {
            this.likeCnt--;
        }
    }

    public void setMember(Member member) {
        this.member = member;
    }

    public void makeFishVisible(int price){
        this.fishCnt++;
        this.totalPrice += price;
    }

    public void makeFishInvisible(int price){
        this.fishCnt--;
        this.totalPrice -= price;
    }

    public boolean changeOpen(){
        open = !open;
        return open;
    }

}
