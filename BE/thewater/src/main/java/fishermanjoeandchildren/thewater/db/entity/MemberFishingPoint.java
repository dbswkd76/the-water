package fishermanjoeandchildren.thewater.db.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "member_fishing_point")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MemberFishingPoint extends Common {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "point_id")
    private Long pointId;

    @Column(name = "member_id", nullable = false)
    private Long memberId;

    @Column(name = "point_name", nullable = false)
    private String pointName;

    @Column(nullable = false)
    private Double latitude;

    @Column(nullable = false)
    private Double longitude;

    @Column(nullable = false)
    private String address;

    @Column
    private String comment;

    // 연관 관계 - 읽기 전용
    @JsonIgnore
    @ManyToOne
    @JoinColumn(name = "member_id", insertable = false, updatable = false)
    private Member member;
}