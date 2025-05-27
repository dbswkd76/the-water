package fishermanjoeandchildren.thewater.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;


@Configuration
public class SwaggerConfig {

    private SecurityScheme createAPIKeyScheme() {
        return new SecurityScheme().type(SecurityScheme.Type.HTTP)
                .bearerFormat("JWT")
                .scheme("bearer")
                .bearerFormat("JWT")
                .in(SecurityScheme.In.HEADER)
                .name("Authorization");
    }

    SecurityRequirement securityRequirement = new SecurityRequirement().addList("BearerAuth");
    @Bean
    public OpenAPI openAPI(){
        return new OpenAPI().addSecurityItem(securityRequirement)
                .schemaRequirement("BearerAuth", createAPIKeyScheme())
                .info(new Info().title("TheWater API")
                        .description("This is TheWater API")
                        .version("v0.0.1"));
    }

}
