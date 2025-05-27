package fishermanjoeandchildren.thewater.controller;

import fishermanjoeandchildren.thewater.data.ResponseStatus;
import fishermanjoeandchildren.thewater.data.ResponseMessage;
import fishermanjoeandchildren.thewater.data.dto.*;
import fishermanjoeandchildren.thewater.db.repository.FishCardRepository;
import fishermanjoeandchildren.thewater.db.repository.MemberRepository;
import fishermanjoeandchildren.thewater.security.JwtUtil;
import fishermanjoeandchildren.thewater.service.EmailService;
import fishermanjoeandchildren.thewater.service.MemberService;
import fishermanjoeandchildren.thewater.db.entity.Member;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import jakarta.mail.MessagingException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
public class MemberController {

    private final MemberService memberService;
    private EmailService emailService;

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private MemberRepository memberRepository;

    @Autowired
    private FishCardRepository fishCardRepository;

    @Autowired
    public MemberController(MemberService memberService,
                            EmailService emailService) {
        this.emailService = emailService;
        this.memberService = memberService;
    }

    // 아이디 중복 확인
    @GetMapping("/check-id")
    public ApiResponse<?> checkLoginIdDuplicate(@RequestParam String login_id) {
        boolean isDuplicate = memberService.checkLoginIdDuplicate(login_id);
        if (isDuplicate) {
            return ApiResponse.builder().
                    status(ResponseStatus.VALIDATION_FAILED).
                    message(ResponseMessage.VALIDATION_FAILED).
                    data("이미 사용중인 아이디입니다.").build();
        }

        return ApiResponse.builder().
                status(ResponseStatus.SUCCESS).
                message(ResponseMessage.SUCCESS).
                data("사용 가능한 아이디입니다.").build();
    }

    // 이메일 인증 코드 요청
    @PostMapping("/request-verification")
    public ApiResponse<?> requestVerification(@RequestBody EmailVerificationRequest request) {
        try {
            // 이미 가입된 이메일인지 확인
            if (memberService.checkEmailDuplicate(request.getEmail())) {
                return ApiResponse.builder()
                        .status(ResponseStatus.VALIDATION_FAILED)
                        .message(ResponseMessage.VALIDATION_FAILED)
                        .data("이미 가입된 이메일입니다.")
                        .build();
            }

            // 인증 이메일 발송
            emailService.sendVerificationEmail(request.getEmail());

            return ApiResponse.builder()
                    .status(ResponseStatus.SUCCESS)
                    .message(ResponseMessage.SUCCESS)
                    .data(Map.of(
                            "success", true,
                            "message", "인증번호가 이메일로 전송되었습니다.",
                            "expires_in", 300  // 5분(초 단위)
                    ))
                    .build();
        } catch (MessagingException e) {
            return ApiResponse.builder()
                    .status(ResponseStatus.SERVER_ERROR)
                    .message(ResponseMessage.SERVER_ERROR)
                    .data("이메일 전송 중 오류가 발생했습니다: " + e.getMessage())
                    .build();
        }
    }

    // 인증 코드 확인
    @PostMapping("/verify-code")
    public ApiResponse<?> verifyCode(@RequestBody VerifyCodeRequest request) {
        boolean isValid = emailService.verifyCode(request.getEmail(), request.getCode());

        if (isValid) {
            return ApiResponse.builder()
                    .status(ResponseStatus.SUCCESS)
                    .message(ResponseMessage.SUCCESS)
                    .data(Map.of(
                            "success", true,
                            "message", "이메일 인증이 완료되었습니다."
                    ))
                    .build();
        } else {
            return ApiResponse.builder()
                    .status(ResponseStatus.VALIDATION_FAILED)
                    .message(ResponseMessage.VALIDATION_FAILED)
                    .data(Map.of(
                            "success", false,
                            "message", "인증번호가 올바르지 않거나 만료되었습니다."
                    ))
                    .build();
        }
    }

    // 닉네임 중복 확인
    @GetMapping("/check-nickname")
    public ApiResponse<?> checkNicknameDuplicate(@RequestParam String nickname) {
        boolean isDuplicate = memberService.checkNicknameDuplicate(nickname);
        if (isDuplicate) {
            return ApiResponse.builder()
                    .status(ResponseStatus.VALIDATION_FAILED)
                    .message(ResponseMessage.VALIDATION_FAILED)
                    .data("이미 사용중인 닉네임입니다.").build();
        }
        return ApiResponse.builder()
                .status(ResponseStatus.SUCCESS)
                .message(ResponseMessage.SUCCESS)
                .data("사용 가능한 닉네임입니다.").build();
    }

    // 회원가입
    @PostMapping("/signup")
    public ApiResponse<?> signup(@RequestBody SignupRequest request) {
        try {
            SignupResponse response = memberService.signup(request);
            return ApiResponse.builder()
                    .status(ResponseStatus.SUCCESS)
                    .message(ResponseMessage.SUCCESS)
                    .data(response).build();
        } catch (RuntimeException e) {
            return ApiResponse.builder()
                    .status(ResponseStatus.VALIDATION_FAILED)
                    .message(ResponseMessage.VALIDATION_FAILED)
                    .data(new SignupResponse(false, e.getMessage(), null)).build();
        }
    }

    // 사용자 정보 불러오기
    @SecurityRequirement(name="BearerAuth")
    @GetMapping("/me")
    public ApiResponse<?> getMyInfo(HttpServletRequest request) {
        try {
            // Bearer 토큰에서 JWT 부분만 추출
            String token = jwtUtil.resolveToken(request);
            Long memberId = jwtUtil.extractUserId(token);

            // 로그인 ID로 사용자 정보 조회
            Member member = memberRepository.findById(memberId)
                    .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다."));

            // 사용자 전체 정보 조회
            MemberDto UserInfo = memberService.getUserInfo(member.getId());

            return ApiResponse.builder()
                    .status(ResponseStatus.SUCCESS)
                    .message(ResponseMessage.SUCCESS)
                    .data(UserInfo)
                    .build();
        } catch (Exception e) {
            return ApiResponse.builder()
                    .status(ResponseStatus.AUTHROIZATION_FAILED)
                    .message(ResponseMessage.AUTHROIZATION_FAILED)
                    .data("사용자 인증에 실패했습니다: " + e.getMessage())
                    .build();
        }
    }

    @SecurityRequirement(name="BearerAuth")
    @DeleteMapping("/delete")
    public ApiResponse<?> deleteMember(HttpServletRequest request) {
        // JWT 토큰에서 회원 ID 추출
        String token = jwtUtil.resolveToken(request);
        Long memberId = jwtUtil.extractUserId(token);

        // 회원 탈퇴 처리
        ApiResponse<?> response = memberService.deleteMember(memberId);
        return response;
    }

    // MemberController.java에 추가
    @GetMapping("/search")
    public ApiResponse<?> searchMembers(@RequestParam String nickname) {
        List<MemberDto> members = memberService.searchMembersByNickname(nickname);

        return ApiResponse.builder()
                .status(ResponseStatus.SUCCESS)
                .message(ResponseMessage.SUCCESS)
                .data(members)
                .build();
    }

    @GetMapping("search/all-nickname")
    public ApiResponse<?> getAllNicknames() {
        List<String> nicknames = memberService.getAllActiveNicknames();

        return ApiResponse.builder()
                .status(ResponseStatus.SUCCESS)
                .message(ResponseMessage.SUCCESS)
                .data(nicknames)
                .build();
    }

    @SecurityRequirement(name="BearerAuth")
    @PatchMapping("/update-comment")
    public ApiResponse<?> updateMemberComment(
            @RequestParam String comment,
            HttpServletRequest request) {
        // 토큰에서 사용자 ID 추출
        String token = jwtUtil.resolveToken(request);
        Long memberId = jwtUtil.extractUserId(token);

        // 코멘트 업데이트 및 결과 반환
        return memberService.updateMemberComment(memberId, comment);
    }

    @SecurityRequirement(name="BearerAuth")
    @GetMapping("/mypage")
    public ApiResponse<?> getMyPage(HttpServletRequest request) {
        try {
            // Bearer 토큰에서 JWT 부분만 추출
            String token = jwtUtil.resolveToken(request);
            Long memberId = jwtUtil.extractUserId(token);

            // 마이페이지 정보 조회
            MypageResponseDto mypageInfo = memberService.getUserMypage(memberId);

            return ApiResponse.builder()
                    .status(ResponseStatus.SUCCESS)
                    .message(ResponseMessage.SUCCESS)
                    .data(mypageInfo)
                    .build();
        } catch (Exception e) {
            return ApiResponse.builder()
                    .status(ResponseStatus.AUTHROIZATION_FAILED)
                    .message(ResponseMessage.AUTHROIZATION_FAILED)
                    .data("사용자 인증에 실패했습니다: " + e.getMessage())
                    .build();
        }
    }

    // 사용자 닉네임 변경하기
    @SecurityRequirement(name="BearerAuth")
    @PatchMapping("/update-nickname")
    public ApiResponse<?> updateMemberNickname(@RequestBody String nickname, HttpServletRequest servletRequest){
        String token = jwtUtil.resolveToken(servletRequest);
        Long memberId = jwtUtil.extractUserId(token);

        return memberService.updateNickname(memberId, nickname);
    }
}