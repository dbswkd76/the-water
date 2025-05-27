package fishermanjoeandchildren.thewater.service;

import fishermanjoeandchildren.thewater.db.entity.Member;
import fishermanjoeandchildren.thewater.db.repository.MemberRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.ArrayList;

@Service
public class MemberDetailsService implements UserDetailsService {

    @Autowired
    private MemberRepository memberRepository;

    @Override
    public UserDetails loadUserByUsername(String loginId) throws UsernameNotFoundException {
        // DB에서 사용자를 조회하여 ID를 포함한 모든 정보를 가져옵니다
        Member member = memberRepository.findByLoginId(loginId)
                .orElseThrow(() -> new UsernameNotFoundException("사용자를 찾을 수 없습니다: " + loginId));

        // 탈퇴한 회원인지 확인
        if (member.getHas_deleted()) {
            throw new UsernameNotFoundException("탈퇴한 회원입니다: " + loginId);
        }

        return new User(member.getLoginId(), member.getPassword(), new ArrayList<>());
    }
}