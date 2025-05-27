package fishermanjoeandchildren.thewater.db.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name="fish")
@Getter
@Data
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Fish {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;

    @Column(name="fish_name", unique=true, nullable=false,length = 50)
    private String fishName;

    @Column(name="breeding_season", nullable = false,length = 20)
    private String breedingSeason;

    @Column(name="ban_season", length = 50)
    private String banSeason;

    @Column(name="average_size", nullable = false)
    private Double averageSize;

    //시세-> redis가 나으려나용?
    @Column(nullable = false)
    private Integer price;

    //특징
    @Column(columnDefinition = "TEXT")
    private String characteristic;

    @Column(nullable = false)
    private String habitat;

    @Column(name="ban_size")
    private Double banSize;

}
