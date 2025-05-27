package com.water.water.db.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "member_fishing_point")
@Getter
@AllArgsConstructor
@NoArgsConstructor
@Builder
@IdClass(MemberFishingPointId.class)
public class MemberFishingPoint extends Common{
    @Id
    @Column(name="member_id")
    private Long memberId;

    @Id
    @Column(name="fishing_point_id")
    private Long fishingPointId;

    @Column(name="has_public")
    private boolean hasPublic=false;

    private String description;


    // ManyToOne으로 멤버와 낚시 포인트 연결 가능
    @ManyToOne
    @JoinColumn(name = "memberId", insertable = false, updatable = false)
    private Member member;

    @ManyToOne
    @JoinColumn(name = "fishingPointId", insertable = false, updatable = false)
    private FishingPoint fishingPoint;

}
