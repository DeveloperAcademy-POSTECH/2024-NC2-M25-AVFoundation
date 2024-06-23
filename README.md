# 2024-NC2-M25-AVFoundation

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
<details>
  <summary>오디오 객체 생성</summary>
  
  ```swift 
  @State var audioPlayer: AVAudioPlayer!
  ```
</details>

<details>
  <summary>음원 불러오기 및 제어</summary>

  ### 음원 불러오기
    
  ```swift 
  private func initAudioPlayer()
  ```

  ```swift 
  guard let path = Bundle.main.path(forResource: "Supernova.mp3", ofType: nil) else {
            print("File not found")
            return
        }
  ```

  ### 상태 설정

  ```swift 
  do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)

            self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            self.audioPlayer.prepareToPlay()
            self.audioPlayer.enableRate = true

            extractMetadata(from: path)

            formattedDuration = formatter.string(from: TimeInterval(self.audioPlayer.duration))!
            duration = self.audioPlayer.duration

            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                if !self.audioPlayer.isPlaying {
                    self.isPlaying = false
                }

                if !self.isDragging {
                    self.currentTime = self.audioPlayer.currentTime
                    self.progress = CGFloat(self.audioPlayer.currentTime / self.audioPlayer.duration)
                    self.formattedProgress = formatter.string(from: TimeInterval(self.audioPlayer.currentTime))!
                }
            }

            setupControlCenterControls()
            remoteControlCenterInfo()
        }
  ```

</details>

<details>
  <summary>제어센터 내 버튼 구현</summary>
  
```MPRemoteCommandCenter```

  ``` swift
  private func setupControlCenterControls() {
        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.addTarget { (commandEvent) -> MPRemoteCommandHandlerStatus in
            self.audioPlayer.play()
            return MPRemoteCommandHandlerStatus.success
        }

        commandCenter.pauseCommand.addTarget { (commandEvent) -> MPRemoteCommandHandlerStatus in
            self.audioPlayer.pause()
            return MPRemoteCommandHandlerStatus.success
        }

        commandCenter.skipBackwardCommand.addTarget { (commandEvent) -> MPRemoteCommandHandlerStatus in
            self.backward5Sec()
            return .success
        }

        commandCenter.skipForwardCommand.addTarget { (commandEvent) -> MPRemoteCommandHandlerStatus in
            self.forward5Sec()
            return .success
        }

        commandCenter.skipBackwardCommand.preferredIntervals = [5]
        commandCenter.skipForwardCommand.preferredIntervals = [5]
    }
  ```
  - MediaPlayer의 ```MPRemoteCommandCenter```를 사용하여 제어센터의 버튼을 눌렀을 때 어떤 이벤트를 발생시킬건지 지정해줍니다.  
  재생, 정지, 5초 앞으로, 뒤로 가는 기능을 구현하였습니다.

</details>

<details>
  <summary>제어센터 내 음원 정보 표시</summary>

  ```MPNowPlayingInfoCenter```
  ``` swift
  private func remoteControlCenterInfo() {
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo ?? [String: Any]()

        guard let path = Bundle.main.path(forResource: "Supernova", ofType: "mp3") else {
            print("Audio file not found")
            return
        }

        if let albumArtwork = albumArtwork {
            let artwork = MPMediaItemArtwork(boundsSize: albumArtwork.size, requestHandler: { size in
                return albumArtwork
            })
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }

        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = audioPlayer.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = audioPlayer.currentTime

        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }
  ```
  - 현재 재생 중인 미디어의 커버 사진이나 노래 제목, 아티스트와 같은 정보들을 제어센터 객체에 초기화 하여 보여줍니다.
</details>

<details>
  <summary>마커 기능</summary>
  
  ### 마커 추가하기 버튼

  ```swift
  @State private var markers: [TimeInterval] = []
  ```

  - ```TimeInterval```을 마커배열에 저장합니다.

  ### 마커 리스트

  ```swift
  private var markerListView: some View {
        ScrollView {
            VStack {
                ForEach(markers, id: \.self) { marker in
                    markerButton(marker: marker)
                        .padding(.horizontal)
                        .contextMenu {
                            markerContextMenu(marker: marker)
                        }
                }
            }
        }
        .disabled(audioPlayer == nil)
    }
  ```
  - 등록한 마커를 리스트 형태로 보여줍니다.

  ### 마커
 ```swift
private func markerButton(marker: TimeInterval) -> some View {
        Button(action: {
            self.audioPlayer.currentTime = marker
            self.progress = CGFloat(marker / self.duration)
            self.formattedProgress = self.formattedTime(marker)
            self.audioPlayer.play()
            self.isPlaying = true
        }) {
            Text("Marker at \(self.formattedTime(marker))")
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.vertical, 2)
        }
    }
 ```
 - 생성된 마커를 누르면 음원의 현재시간과 프로그래스 바 위치를 업데이트 하여 해당 시간으로 이동함과 동시에 재생됩니다.

</details>