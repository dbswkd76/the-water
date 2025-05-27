package fishermanjoeandchildren.thewater.config;

import fishermanjoeandchildren.thewater.security.JwtAuthenticationFilter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Autowired
    private JwtAuthenticationFilter jwtAuthenticationFilter;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                .csrf(csrf -> csrf.disable())
                .authorizeHttpRequests(auth -> auth
                        // user관련
                        .requestMatchers(
                                "/api/users/**").permitAll()
                        // 낚시 포인트 관련 API 추가
                        .requestMatchers("/api/fishing-points/**").authenticated()
                        .requestMatchers("/api/env-info/**").permitAll()

                        // aquarium 관련 경로
                        .requestMatchers("/api/aquarium/stats/**", "/api/aquarium/info/**", "/api/aquarium/like/**", "/api/aquarium/visible/**", "/api/aquarium/visit/**", "/api/aquarium/open").authenticated()

                        // aquarium ranking 관련 경로
                        .requestMatchers("/api/aquarium/ranking/top/**", "/api/aquarium/ranking/random/**").permitAll()

                        // guest book 관련 경로
                        .requestMatchers("/api/guest-book/read/**").permitAll()
                        .requestMatchers("/api/guest-book/write/**", "/api/guest-book/edit/**", "/api/guest-book/remove/**").authenticated()


                        // collection 관련 정보
                        .requestMatchers("/api/collection/myfish/add", "/api/collection/myfish/all", "/api/collection/myfish/delete/**", "/api/collection/myfish/image/**").authenticated()

                        // Swagger UI 관련 경로 허용
                        .requestMatchers("/swagger-ui/**", "/v3/api-docs/**", "/swagger-ui.html").permitAll()
                )
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration authenticationConfiguration) throws Exception {
        return authenticationConfiguration.getAuthenticationManager();
    }
}