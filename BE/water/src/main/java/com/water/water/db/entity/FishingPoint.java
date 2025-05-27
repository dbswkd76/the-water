package com.water.water.db.entity;

import jakarta.persistence.*;

import java.util.List;

@Table(name = "fishing_point")
@Entity
public class FishingPoint {

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

    //위치(시/도)
    @Column(nullable = false)
    private String province;

    //위치(시. 군, 구)
    @Column(nullable = false)
    private String city;

    //위치(읍, 면, 동)
    @Column(nullable = false)
    private String town;
}
