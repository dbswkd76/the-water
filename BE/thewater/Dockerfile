# Step 1: 빌드를 위한 JDK 17 이미지 사용
FROM openjdk:17-jdk-slim AS build

# Step 2: 프로젝트 파일 복사
WORKDIR /app
COPY . .

# Step 3: Maven/Gradle을 이용해 애플리케이션 빌드
# (여기서는 Gradle을 예시로 사용합니다. Maven을 사용하는 경우 Maven 명령어로 변경해 주세요)
RUN ./gradlew build -x test --no-daemon

# Step 4: 최종 이미지 생성
FROM openjdk:17-jdk-slim

# Step 5: 빌드된 애플리케이션 JAR 파일을 복사
WORKDIR /app
COPY --from=build /app/build/libs/*.jar /app/

# Step 6: 애플리케이션 실행
ENTRYPOINT ["java", "-jar", "/app/thewater-0.0.1-SNAPSHOT.jar"]

# Step 7: 컨테이너가 사용할 포트 설정 (여기서는 8080 포트를 예시로 사용)
EXPOSE 8081
