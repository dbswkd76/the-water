package com.water.water.db.entity;

import jakarta.persistence.*;
import lombok.*;

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
    private long id;

    @ManyToOne
    @JoinColumn(name="member_id")
    private Member member;

    @ManyToOne
    @JoinColumn(name = "aquarium_id", nullable = false)
    private Aquarium aquarium;

    @ManyToOne
    @JoinColumn(name="point_id", nullable = false)
    private MemberFishingPoint fishingPoint;

    @ManyToOne
    @JoinColumn(name="fish_id", nullable = false)
    private Fish fish;

    @Column(name = "has_visible")
    private Boolean hasVisible=false;

    @Column(name="real_size")
    private Double realSize;

    //기온
    @Column
    private Integer temperature;

    //수온
    @Column(name="water_temperature")
    private Integer waterTemperature;

    //조류
    @Column
    private Integer tide;

    @Column(columnDefinition = "TEXT")
    private String comment;

    @Column(name="has_deleted")
    private Boolean hasDeleted=false;

    @Column(name="card_img", nullable = false)
    private String cardImg;



}
