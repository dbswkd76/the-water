package fishermanjoeandchildren.thewater.service;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import java.util.Random;

@Service
public class EmailService {

    @Autowired
    private JavaMailSender mailSender;

    @Autowired
    private EmailVerificationStore verificationStore;

    // 난수 생성기
    private final Random random = new Random();

    // 6자리 인증 코드 생성
    public String generateVerificationCode() {
        // 100000부터 999999까지의 난수 생성
        return String.format("%06d", random.nextInt(900000) + 100000);
    }

    // 이메일 인증 코드 발송
    public void sendVerificationEmail(String to) throws MessagingException {
        String code = generateVerificationCode();

        // Redis에 인증 코드 저장
        verificationStore.saveVerificationCode(to, code);

        // 이메일 메시지 생성
        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

        helper.setTo(to);
        helper.setSubject("이메일 인증 코드");
        helper.setText("안녕하세요!\n '그물' 회원가입을 위한 인증 코드입니다: " + code +
                "\n이 코드는 5분 동안 유효합니다.", false);

        // 이메일 발송
        mailSender.send(message);
    }

    // 인증 코드 검증
    public boolean verifyCode(String email, String code) {
        boolean isValid = verificationStore.verifyCode(email, code);
        if (isValid) {
            // 인증 성공 시 이메일을 인증 완료 상태로 표시
            verificationStore.markEmailAsVerified(email);
        }
        return isValid;
    }

    // 이메일 인증 여부 확인
    public boolean isEmailVerified(String email) {
        return verificationStore.isEmailVerified(email);
    }
}