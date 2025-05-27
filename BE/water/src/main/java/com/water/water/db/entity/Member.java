package com.water.water.db.entity;

import jakarta.persistence.*;
import lombok.*;
import org.springframework.format.annotation.DateTimeFormat;

import java.util.Date;
import java.util.List;

@Entity
@Table(name="member")
@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Member extends Common {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name="login_id", length = 40, nullable = false, unique = true)
    private String loginId;

    @Column(length = 60)
    private String password;

    @Column(length = 100, unique = true, nullable = false)
    private String email;

    @Column(length = 20, unique = true, nullable = false)
    private String nickname;

    @Column(nullable = false)
    @DateTimeFormat
    private Date birthday;

    @Column(nullable=false, columnDefinition ="CHAR(1) DEFAULT 'E'")
    private Character loginType;

    @Column(nullable = false)
    private Boolean isDeleted=false;

    @OneToOne
    @JoinColumn(name="aquarium_id")
    private Aquarium aquarium;

    @OneToMany(mappedBy = "member")
    private List<FishCard> card;




}