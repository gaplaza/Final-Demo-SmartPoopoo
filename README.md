# 💩 Smart Poopoo

## About the Project
스마트푸푸는 시각장애인 양육자를 위해 만들어졌습니다. YOLO와 Multimodal LLM을 활용한 아기변 분류 기반의 건강 상태를 모니터링 서비스입니다. 

### Features
- **실시간 객체 탐지 카메라** 
- **아기 변 분석** 
- **임신테스트기 분석**
- **챗봇**

## 실행방법
1. Visual Studio Code(또는 그 밖의 편한 IDE)와 Xcode를 설치한다.
2. Extension에서 Flutter, Dart를 설치한다. 
3. 이때, 실시간 객체 탐지 카메라 때문에 애뮬레이터는 사용이 어려우므로 실제 기기를 유선으로 연결한다. 아이폰에서 설정 - 개인정보 보호 및 보안 - 개발자모드를 눌러 활성화 시킨다.
4. 개발자 모드가 켜져 있는 아이폰을 유선 연결하여 device 목록에 뜨는지 확인한 후, ios 폴더를 우클릭하여 'Open in Xcode'를 클릭하여 실행한다.
5. 좌측 Runner -> Signing & Capablities -> TARGETS에서 Team과 Bundle Identifier를 올바르게 지정해준다. 
6. Xcode 또는 Vscode에서 실행 버튼을 누른다. 어플이 실행되기를 기다린다.
