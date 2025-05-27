package fishermanjoeandchildren.thewater.controller;

import fishermanjoeandchildren.thewater.data.ResponseMessage;
import fishermanjoeandchildren.thewater.data.ResponseStatus;
import fishermanjoeandchildren.thewater.data.dto.ApiResponse;
import fishermanjoeandchildren.thewater.data.dto.LoginRequest;
import fishermanjoeandchildren.thewater.data.dto.LoginResponse;
import fishermanjoeandchildren.thewater.db.entity.Member;
import fishermanjoeandchildren.thewater.security.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import fishermanjoeandchildren.thewater.db.repository.MemberRepository;

@RestController
@RequestMapping("/api/users")
public class AuthLoginController {

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private JwtUtil jwtUtil;
    
    @Autowired
    private MemberRepository memberRepository;

    @PostMapping("/login")
    public ApiResponse<?> login(@RequestBody LoginRequest loginRequest) {
        try {
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(loginRequest.getLoginId(), loginRequest.getPassword())
            );

            UserDetails userDetails = (UserDetails) authentication.getPrincipal();
            // 로그인한 사용자의 정보를 DB에서 조회하여 ID 가져오기
            Member member = memberRepository.findByLoginId(userDetails.getUsername())
                    .orElseThrow(() -> new UsernameNotFoundException("사용자를 찾을 수 없습니다."));

            final String jwt = jwtUtil.generateToken(userDetails, member.getId());

            LoginResponse loginResponse = new LoginResponse(true, "로그인 성공", jwt);

            return ApiResponse.builder()
                    .status(ResponseStatus.SUCCESS)
                    .message(ResponseMessage.SUCCESS)
                    .data(loginResponse)
                    .build();
        } catch (UsernameNotFoundException e) {
            // UsernameNotFoundException은 사용자를 찾을 수 없거나 탈퇴한 경우
            LoginResponse errorResponse = new LoginResponse(false, "탈퇴한 회원입니다." + e.getMessage(), null);

            return ApiResponse.builder()
                    .status(ResponseStatus.AUTHROIZATION_FAILED)
                    .message(ResponseMessage.AUTHROIZATION_FAILED)
                    .data(errorResponse)
                    .build();
        } catch (Exception e) {
            LoginResponse errorResponse = new LoginResponse(false, "아이디 또는 비밀번호가 올바르지 않습니다.", null);

            return ApiResponse.builder()
                    .status(ResponseStatus.AUTHROIZATION_FAILED)
                    .message(ResponseMessage.AUTHROIZATION_FAILED)
                    .data(errorResponse)
                    .build();
        }
    }
}