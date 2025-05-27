package fishermanjoeandchildren.thewater.data.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
public class SignupResponse {
    private boolean success;
    private String message;
    private Long userId;
}