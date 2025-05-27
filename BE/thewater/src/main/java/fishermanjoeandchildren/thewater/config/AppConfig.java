package fishermanjoeandchildren.thewater.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.converter.StringHttpMessageConverter;
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter;
import org.springframework.http.converter.xml.MappingJackson2XmlHttpMessageConverter;
import org.springframework.web.client.RestTemplate;

import java.nio.charset.StandardCharsets;

@Configuration
public class AppConfig {

    @Bean
    public RestTemplate restTemplate() {
        RestTemplate restTemplate = new RestTemplate();

        // XML 변환기 추가
        restTemplate.getMessageConverters().add(new MappingJackson2XmlHttpMessageConverter());

        // JSON 변환기 추가
        restTemplate.getMessageConverters().add(new MappingJackson2HttpMessageConverter());

        // 문자열 변환기 UTF-8 설정
        restTemplate.getMessageConverters()
                .add(0, new StringHttpMessageConverter(StandardCharsets.UTF_8));

        return restTemplate;
    }
}