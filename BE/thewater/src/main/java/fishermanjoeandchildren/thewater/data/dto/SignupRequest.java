package fishermanjoeandchildren.thewater.data.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;

@Getter
@Setter
public class SignupRequest {
    private String loginId;
    private String password;
    private String email;
    private String nickname;
    private Date birthday;
    private Character loginType = 'E'; // 기본값 'E' (로그인 소셜x)
    private Boolean has_deleted=false; // 기본값 'false'
}