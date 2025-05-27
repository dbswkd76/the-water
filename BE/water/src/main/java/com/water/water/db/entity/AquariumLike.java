package com.water.water.db.entity;


import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "aquarium_like")
@Getter
@AllArgsConstructor
@NoArgsConstructor
@Builder
@IdClass(AquariumLikeId.class)
public class AquariumLike extends Common{
    @Id
    @Column(name="aquarium_id")
    private Long aquariumId;

    @Id
    @Column(name="member_id")
    private Long memberId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name="aquarium_id", insertable = false, updatable = false)
    private Aquarium aquarium;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", insertable = false, updatable = false)
    private Member member;
}
