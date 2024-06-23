# 2024-NC2-M25-AVFoundation
TBU  

## 🎥 Youtube Link
(추후 만들어진 유튜브 링크 추가)

## 💡 About AVFoundation
### 시청각 미디어(음원이나 영상)를 재생 및 생성 해주는 프레임워크

- 카메라와 마이크를 통해 오디오 및 비디오 캡쳐
- 오디오 및 비디오 재생
- 미디어 편집
- 실시간 스트리밍 프로토콜 지원
- 메타 데이터 처리

## 🎯 What we focus on?
AVFoundation: 재생 중인 음원의 시간 대에 마커를 추가하고 원하는 시간대로 바로 돌아갈 수 있게 한다.  
MediaPlayer: 음원 재생은 일반적으로 백그라운드에서도 재생이 기대되므로 백그라운드 제어 기능을 구현한다.  


## 💼 Use Case
> 춤 연습 할 때, 내가 원하는 시간대로 버튼 한 번에 바로 가자!

## 🖼️ Prototype
<details>
  <summary>음원 불러오기, 재생, 일시정지</summary>
  <br>
  <img width="200" alt="image" src="https://github.com/DeveloperAcademy-POSTECH/2024-NC2-M25-AVFoundation/assets/82072195/f4cd6a81-02ec-4da8-aa9f-dea9f21da29a">  
  
  + (임시 음원 파일 자체 내장)  
  + 음원 불러오기  
    - 음원 불러오기 전에는 음원 제어 기능(마커 설정, 재생-정지, 배속, 5초 앞뒤로가기) 비활성화
    - 메타 데이터(앨범 커버, 음원 타이틀, 음원 아티스트)
</details>

<details>
  <summary>5초 앞, 뒤로 가기</summary>
  <br>
  <img width="200" alt="image" src="https://github.com/DeveloperAcademy-POSTECH/2024-NC2-M25-AVFoundation/assets/82072195/0dd6d42e-5417-47ab-8eb6-f74c48a3eedb">
  
  - 재생 or 정지 상태에서 5초 앞, 뒤로 가기 
</details>

<details>
  <summary>배속</summary>
  <br>
  <img width="200" alt="image" src="https://github.com/DeveloperAcademy-POSTECH/2024-NC2-M25-AVFoundation/assets/82072195/f4ed1b71-1b17-430d-8fc4-9967bc2585c2">
  
  - 재생 or 정지 상태에서 적용 가능
  - 0.1배 비율 단위로 음원의 속도 조절 가능
  - 음원 속도가 1.0이 아닐때 해당 배속 텍스트를 누르면 1.0 배속으로 돌아옴
</details>

<details>
  <summary>마커</summary>
  <br>
  <img width="200" alt="image" src="https://github.com/DeveloperAcademy-POSTECH/2024-NC2-M25-AVFoundation/assets/82072195/599c372d-a85b-4b32-8768-aabc9a509df4">

  - 마커 생성 및 삭제
  - 해당 마커로 바로 이동
</details>

<details>
  <summary>백그라운드 재생</summary>
  <br>
  <img width="200" alt="image" src="https://github.com/DeveloperAcademy-POSTECH/2024-NC2-M25-AVFoundation/assets/82072195/72ee63dd-1bce-40c3-8d7a-c2376ac94dda">
  
  - 백그라운드에서 재생, 정지, 5초 앞, 뒤로 가기 가능
  - 앨범 커버, 음원 타이틀, 음원 아티스트 표기
</details>

## 🛠️ About Code
(핵심 코드에 대한 설명 추가)
