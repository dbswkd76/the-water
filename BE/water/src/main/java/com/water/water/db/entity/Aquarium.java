package com.water.water.db.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "aquarium")
@Getter
@Data
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

    @OneToOne(mappedBy="aquarium")
    private Member member;

    @OneToMany(mappedBy = "aquarium")
    private List<FishCard> fishCard;

    @OneToMany(mappedBy = "aquarium", cascade = CascadeType.ALL)
    private List<AquariumLike> aquariumLikes=new ArrayList<>();

}
