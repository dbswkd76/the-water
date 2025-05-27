# TIL (Today I Learned) - 2025-03-05

## Flutter와 Dart

### 📝 Flutter란?
- **Flutter**는 Google에서 개발한 **오픈 소스 UI 프레임워크**로, 단일 코드베이스로 **iOS, Android, 웹, 데스크톱** 앱을 개발할 수 있다.
- **Dart 언어**를 사용하며, **빠른 개발(Hot Reload), 아름다운 UI, 높은 성능**이 특징이다.
- **Flutter의 주요 구성 요소:**
  - **Widget**: Flutter의 UI 요소 (StatelessWidget, StatefulWidget)
  - **Flutter Engine**: Dart로 작성된 렌더링 엔진
  - **Packages & Plugins**: 다양한 기능 확장을 위한 라이브러리

### 🔤 Dart란?
- **Dart**는 Google이 개발한 **프로그래밍 언어**로, Flutter의 기본 언어이다.
- **객체 지향 언어(OOP)**이며, JavaScript와 비슷한 문법을 가지고 있다.
- **JIT(Just-In-Time)과 AOT(Ahead-Of-Time) 컴파일**을 지원해, 빠른 개발과 최적화된 성능을 제공한다.
- 주요 문법 특징:
  - **변수 선언**: `var`, `final`, `const`
  - **함수**: `void`, `return` 키워드 사용
  - **클래스와 객체**: `class`, `this`, `new` 키워드 사용 가능 (new는 선택적)
  - **비동기 프로그래밍**: `async`, `await`, `Future` 지원

### ✨ 오늘의 배운 점
- Flutter는 **크로스 플랫폼 개발**에 유용하다.
- Dart는 **객체 지향 언어**이며, JavaScript와 문법이 유사하다.
- **Hot Reload 기능**을 사용하면 UI 변경 사항을 즉시 확인할 수 있다.

- <br>
# TIL (Today I Learned) - 2025-03-06

## Figma 로 어항구조를 잡았고, 앱 제작에있어 필요한 물고기들의 이미지를 AI를 활용해 제작함.
- Adobe **FireFly 라는 AI 이미지 생성 페이지** 를 이용해 asset 제작 가능하다.

<br><br>
- 
# TIL (Today I Learned) - 2025-03-07
**Flutter 환경세팅**

Flutter 3.29.0 • channel stable • https://github.com/flutter/flutter.git
Framework • revision 35c388afb5 (3 weeks ago) • 2025-02-10 12:48:41 -0800
Engine • revision f73bfc4522
Tools • Dart 3.7.0 • DevTools 2.42.2

처음 flutter 3.29.0 다운받고 documents 위치에 압축해제를 한 후 bin 폴더 들어가 경로를 복사 후 윈도우 환경변수 path 세팅에 들어가 새로만들기 후 주소를 붙여넣기 하였으나,

설치가 완료되지않아, 문제 분석중 발견된 문제는 , OneDrive 가 실행되고있을 경우 환경변수 세팅에 영향을 끼치는것으로 보여, OneDrive 종료 후 재부팅 후 압축해제를 다시 해보니 해결이 되었다.

Android Studio Meerkat 설치완료 후
flutter 연결 완료