package fishermanjoeandchildren.thewater.db.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Table(name = "fishing_point")
@Entity
@Getter
@Setter
public class FishingPoint extends Common {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    //지명
    @Column(nullable = false, name = "point_name")
    private String pointName;

    //위도
    @Column(nullable = false)
    private String latitude;

    //경도
    @Column(nullable = false)
    private String longitude;

    //위치(address)
    @Column(nullable = false)
    private String address;

    // 포인트 설명
    @Column(name = "point_info")
    private String comment;


}
