package fishermanjoeandchildren.thewater.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;

import java.util.concurrent.TimeUnit;

@Component
public class EmailVerificationStore {

    @Autowired
    private RedisTemplate<String, Object> redisTemplate;

    // 이메일 인증 코드를 위한 Redis 키 접두사
    private static final String KEY_PREFIX = "email:verification:";

    // 인증 코드 유효 시간(5분)
    private static final long EXPIRY_MINUTES = 5;

    /**
     * 이메일과 인증 코드를 저장합니다.
     */
    public void saveVerificationCode(String email, String code) {
        String key = KEY_PREFIX + email;
        redisTemplate.opsForValue().set(key, code);
        redisTemplate.expire(key, EXPIRY_MINUTES, TimeUnit.MINUTES);
    }

    /**
     * 이메일에 해당하는 인증 코드가 일치하는지 확인합니다.
     */
    public boolean verifyCode(String email, String code) {
        String key = KEY_PREFIX + email;
        Object storedCode = redisTemplate.opsForValue().get(key);

        if (storedCode != null && storedCode.toString().equals(code)) {
            // 검증 성공 시 코드 삭제
            redisTemplate.delete(key);
            return true;
        }

        return false;
    }

    /**
     * 이메일에 대한 인증 코드가 존재하는지 확인합니다.
     */
    public boolean isEmailVerified(String email) {
        // 인증 완료 상태를 표시하는 별도 키를 사용
        String key = KEY_PREFIX + "verified:" + email;
        return Boolean.TRUE.equals(redisTemplate.hasKey(key));
    }

    /**
     * 이메일 인증 완료 상태를 저장합니다.
     * 인증 코드 확인 후 일정 시간(예: 30분) 동안 인증 상태를 유지합니다.
     */
    public void markEmailAsVerified(String email) {
        String key = KEY_PREFIX + "verified:" + email;
        redisTemplate.opsForValue().set(key, "true");
        redisTemplate.expire(key, 30, TimeUnit.MINUTES); // 인증 상태 30분 유지
    }
}
