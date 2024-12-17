# 💩 Smart Poopoo

## About the Project
**스마트푸푸**는 시각장애인 양육자를 위해 만들어졌습니다.  
YOLO와 Multimodal LLM을 활용하여 아기 변 분류를 기반으로 건강 상태를 모니터링하는 서비스입니다.

### Features
- **실시간 객체 탐지 카메라**
- **아기 변 분석**
- **임신테스트기 결과 분석**
- **챗봇 기능**

---

## 실행 방법
### 1. 필수 프로그램 설치
1. **IDE 설치**: Visual Studio Code(또는 다른 IDE)와 Xcode를 설치합니다.  
2. **확장 프로그램 설치**: VS Code에서 Flutter와 Dart 확장 프로그램을 설치합니다.  
   <img width="300" alt="Flutter Extension" src="https://github.com/user-attachments/assets/12d70ccd-4da4-493d-a7d4-813bff27c005" />
   <img width="300" alt="Dart Extension" src="https://github.com/user-attachments/assets/d43154cd-e8a2-43d8-9f1a-650844a0e3a3" />

---

### 2. 실시간 객체 탐지 카메라 사용을 위한 준비
1. **실제 기기 연결**:  
   애뮬레이터는 실시간 객체 탐지 카메라 기능을 지원하지 않으므로 **아이폰을 유선으로 연결**합니다.  
2. **개발자 모드 활성화**:  
   아이폰에서 **설정 → 개인정보 보호 및 보안 → 개발자 모드**를 활성화합니다.  
   <img width="300" alt="개발자 모드 활성화" src="https://github.com/user-attachments/assets/4b18d801-38f3-4e97-8e56-3ae0351f7bec" />

---

### 3. Xcode 설정
1. 유선으로 연결된 아이폰이 `device 목록`에 표시되는지 확인합니다.
   <img width="300" alt="스크린샷 2024-12-17 오후 12 36 13" src="https://github.com/user-attachments/assets/5550da83-8498-4118-92a5-16c83c124379" />
2. **iOS 프로젝트 열기**: `ios` 폴더를 우클릭하여 **Open in Xcode**를 선택합니다.  
3. **Signing & Capabilities 설정**:
   - 좌측 **Runner → Signing & Capabilities → TARGETS**에서 **Team**과 **Bundle Identifier**를 올바르게 설정합니다.

---

### 4. 앱 실행
1. **실행 버튼 클릭**:  
   Xcode 또는 VS Code에서 **Run/실행** 버튼을 클릭합니다.  
2. **어플 실행 확인**:  
   기기에서 앱이 실행되기를 기다립니다.

---

## 주의사항
- **실제 기기**를 사용해야 실시간 객체 탐지 카메라가 작동합니다.
- 반드시 **개발자 모드**를 활성화해야 합니다.
