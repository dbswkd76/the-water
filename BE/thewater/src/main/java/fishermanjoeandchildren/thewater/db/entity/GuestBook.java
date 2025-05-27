package fishermanjoeandchildren.thewater.db.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "guest_book")
@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GuestBook extends Common{
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;

    @Column(name="comment")
    String comment;

    @ManyToOne
    @JoinColumn(name="aquarium_id")
    private Aquarium aquarium;

    @ManyToOne
    @JoinColumn(name="guest_id")
    private Member guest;
}
