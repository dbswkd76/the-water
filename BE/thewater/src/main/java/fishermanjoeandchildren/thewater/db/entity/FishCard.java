package fishermanjoeandchildren.thewater.db.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

@Entity
@Table(name="fish_card")
@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FishCard extends Common{
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "fish_card_id")
    private Long id;

    @ManyToOne
    @JoinColumn(name="member_id")
    private Member member;

    @ManyToOne
    @JoinColumn(name = "aquarium_id", nullable = false)
    private Aquarium aquarium;

    @ManyToOne
    @JoinColumn(name="fish_id", nullable = false)
    private Fish fish;

    @Column(name = "fish_name", length = 50)
    private String fishName;

    @Column(name = "fish_size", nullable = false)
    private Double fishSize;

    @Column(name = "collect_date", nullable = false)
    private LocalDate collectDate;

    //날씨
    @Column(nullable = false)
    private Integer sky;

    //기온
    @Column
    private Double temperature;

    //수온
    @Column(name = "water_temp", nullable = false)
    private Double waterTemperature;

    //조류
    @Column
    private Integer tide;

    @Column(name = "user_comment", nullable = false)
    private String comment;

    @Column(name="has_deleted")
    private Boolean hasDeleted=false;

    @Column(name="card_img", nullable = false)
    private String cardImg;

    @Column(name = "has_visible")
    private Boolean hasVisible=false;

    @Column
    private Double latitude;

    @Column
    private Double longitude;


    public boolean changeFishVisible(){
        hasVisible = !hasVisible;
        return hasVisible;
    }
}
