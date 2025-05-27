package fishermanjoeandchildren.thewater.data.dto;

import fishermanjoeandchildren.thewater.db.entity.Member;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MemberDto {
    private Long id;
    private String loginId;
    private String email;
    private String nickname;
    private Date birthday;
    private Character loginType;
    private String comment;

    public static MemberDto fromEntity(Member member) {
        return MemberDto.builder()
                .id(member.getId())
                .loginId(member.getLoginId())
                .email(member.getEmail())
                .nickname(member.getNickname())
                .birthday(member.getBirthday())
                .comment(member.getComment())
                .loginType(member.getLoginType())
                .build();
    }

    public Member toEntity() {
        return Member.builder()
                .id(this.id)
                .loginId(this.loginId)
                .email(this.email)
                .nickname(this.nickname)
                .birthday(this.birthday)
                .comment(this.comment)
                .loginType(this.loginType)
                .build();
    }
}