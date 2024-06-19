//
//  ContentView.swift
//  NC2-AudioPlayer
//
//  Created by Woowon Kang on 6/17/24.
//

import SwiftUI
import AVFoundation
import MediaPlayer

struct ContentView: View {
    @State var audioPlayer: AVAudioPlayer!
    @State private var isPlaying = false
    @State private var playbackRate: Float = 1.0
    @State private var markers: [TimeInterval] = [] // 마커를 저장할 배열
    @State private var currentTime: TimeInterval = 0.0 // 현재 시간을 저장할 변수
    @State private var duration: TimeInterval = 0.0 // 총 재생 시간을 저장할 변수
    @State private var isDragging: Bool = false // 슬라이더를 드래그 중인지 여부
    @State private var progress: CGFloat = 0.0 // 슬라이더 진행률
    @State private var formattedDuration: String = "00:00" // 포맷된 총 재생 시간
    @State private var formattedProgress: String = "00:00" // 포맷된 현재 재생 시간
    
    @State private var albumArtwork: UIImage?
    @State private var title: String = ""
    @State private var artist: String = ""

    var body: some View {
        VStack {
            //MARK: - 음원 추가
            VStack {
                Button(action: {
                    self.initialiseAudioPlayer()
                }) {
                    Text("Select Audio File")
                }
                .padding()
                
                ZStack {
                    if let audioPlayer = audioPlayer {
                        HStack {
                            if let albumArtwork = albumArtwork {
                                Image(uiImage: albumArtwork)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(10)
                            }
                            
                            VStack (alignment: .leading) {
                                Text("\(title)")
                                    .font(.subheadline)
                                Text("\(artist)")
                                    .font(.caption)
                                Spacer()
                            }
                            .padding(.horizontal, 10)
                            Spacer()
                            
                        }
                    } else {
                        HStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray)
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Image(systemName: "music.note")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.white)
                                )
                            
                            VStack (alignment: .leading) {
                                Text("노래 제목")
                                    .font(.subheadline)
                                Text("아티스트")
                                    .font(.caption)
                                Spacer()
                            }
                            .padding(.horizontal, 10)
                            
                            .foregroundStyle(.secondary)
                            Spacer()
                        }
                    }
                }
                .frame(height: 100)
                .padding()
            }
            .frame(maxWidth: .infinity)
            
            Spacer().frame(height: 20)

            //MARK: - 현재 시간을 마커로 추가
            Button(action: {
                self.markers.append(self.audioPlayer.currentTime)
            }) {
                Text("Add Marker")
            }
            .padding()
            .disabled(audioPlayer == nil) // 파일이 선택되지 않으면 버튼 비활성화
            
            Divider()

            //MARK: - 마커 리스트
            ScrollView {
                VStack {
                    ForEach(markers, id: \.self) { marker in
                        Button(action: {
                            self.audioPlayer.currentTime = marker // 마커로 이동
                            self.progress = CGFloat(marker / self.duration)
                            self.formattedProgress = self.formattedTime(marker)
                            self.audioPlayer.play() // 이동 후 재생
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
                        .padding(.horizontal)
                        .contextMenu {
                            Button(role: .destructive, action: {
                                if let index = self.markers.firstIndex(of: marker) {
                                    self.markers.remove(at: index)
                                }
                            }) {
                                Text("Delete")
                                Image(systemName: "trash")
                            }
                            Button(action: {
                                // 수정 기능
                            }) {
                                Text("Edit")
                                Image(systemName: "pencil")
                            }
                        }
                    }
                }
            }
            .disabled(audioPlayer == nil)
            Spacer()
            
            //MARK: - 배속 조절
            HStack {
                Button(action: {
                    if self.playbackRate > 0.5 {
                        self.playbackRate -= 0.1
                        self.updatePlaybackRate()
                    }
                }) {
                    Image(systemName: "minus")
                }
                .padding(.horizontal, 10)
                
                ZStack {
                    if self.playbackRate != 1.0 {
                        Capsule()
                            .fill(Color.gray)
                    }
                    
                    Text(String(format: "%.1fx", self.playbackRate))
                        .onTapGesture {
                            self.playbackRate = 1.0
                            self.updatePlaybackRate()
                        }
                }
                .frame(width: 60, height: 30)
                
                Button(action: {
                    if self.playbackRate < 2.0 {
                        self.playbackRate += 0.1
                        self.updatePlaybackRate()
                    }
                }) {
                    Image(systemName: "plus")
                }
                .padding(.horizontal, 10)
            }
            .padding()
            .disabled(audioPlayer == nil)
            
            //MARK: - 슬라이더를 이용한 현재 음원의 진행도
            Slider(value: Binding(get: {
                self.progress
            }, set: { newValue in
                self.progress = newValue
                let newTime = TimeInterval(newValue) * self.duration
                self.audioPlayer.currentTime = newTime
                self.currentTime = newTime
                self.formattedProgress = self.formattedTime(newTime)
            }), in: 0...1)
            .padding(.horizontal)
            .disabled(audioPlayer == nil)
            
            HStack {
                Text("\(self.formattedProgress)")
                Spacer()
                Text("\(self.formattedDuration)")
            }
            .padding(.horizontal)
            
            //MARK: - 음원 재생, 정지, 5초전, 후
            HStack {
                Button(action: {
                    backward5Sec()
                }) {
                    Image(systemName: "gobackward.5")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40)
                }
                .padding(.horizontal, 20)
                Spacer()
                
                Button(action: {
                    if self.isPlaying {
                        self.audioPlayer.pause()
                    } else {
                        self.audioPlayer.play()
                    }
                    self.isPlaying.toggle()
                }) {
                    Image(systemName: self.isPlaying ? "pause.circle" : "play.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80)
                }
                Spacer()
                
                Button(action: {
                    forward5Sec()
                }) {
                    Image(systemName: "goforward.5")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40)
                }
                .padding(.horizontal, 20)
            }
            .padding()
            .disabled(audioPlayer == nil)
            
        }
    }

    private func initialiseAudioPlayer() {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = [.pad]
        
        guard let path = Bundle.main.path(forResource: "Supernova.mp3", ofType: nil) else {
            print("File not found")
            return
        }
        
        do {
            // AVAudioSession 설정
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
            
            self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            self.audioPlayer.prepareToPlay()
            
            // MetaData 가져오기
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
            
            setupRemoteTransportControls()
            remoteCommandInfoCenterSetting()
            
        } catch {
            print("Error initializing audio player: \(error.localizedDescription)")
        }
    }

    private func updatePlaybackRate() {
        guard let audioPlayer = audioPlayer else { return }
        audioPlayer.rate = playbackRate
        audioPlayer.enableRate = true
    }

    private func formattedTime(_ time: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = [.pad]
        return formatter.string(from: time)!
    }
    
    func seekToTime(to time: TimeInterval) {
            guard let player = audioPlayer else { return }
            player.currentTime = time
            progress = CGFloat(time / player.duration)
            formattedProgress = formattedTime(time)
        }
    
    func backward5Sec() {
            guard let player = audioPlayer else { return }
            let newTime = max(player.currentTime - 5, 0)
            seekToTime(to: newTime)
        }
        
        func forward5Sec() {
            guard let player = audioPlayer else { return }
            let newTime = min(player.currentTime + 5, player.duration)
            seekToTime(to: newTime)
        }
    
    //MARK: - 백그라운드 Control Center에서 조작
    private func setupRemoteTransportControls() {
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
                
                // 커맨드 센터에 5초 간격 설정
                commandCenter.skipBackwardCommand.preferredIntervals = [5]
                commandCenter.skipForwardCommand.preferredIntervals = [5]
    }
    
    //MARK: - Control Center에 앨범커버, 재생시간 정보, 보여주기
    private func remoteCommandInfoCenterSetting() {
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo ?? [String: Any]()
        
        guard let url = Bundle.main.url(forResource: "Supernova", withExtension: "mp3") else {
            print("Audio file not found")
            return
        }

        let asset = AVAsset(url: url)
        
        // 앨범 커버 이미지 추출
        if let artworkData = extractArtworkData(from: asset) {
            let artworkImage = UIImage(data: artworkData)
            let artwork = MPMediaItemArtwork(boundsSize: artworkImage?.size ?? CGSize.zero, requestHandler: { size in
                return artworkImage ?? UIImage()
            })
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }
        
        nowPlayingInfo[MPMediaItemPropertyTitle] = "Supernova"
        nowPlayingInfo[MPMediaItemPropertyArtist] = "aespa"
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = audioPlayer.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = audioPlayer.rate
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = audioPlayer.currentTime
        
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }
    
    private func extractMetadata(from path: String) {
        let url = URL(fileURLWithPath: path)
        let asset = AVAsset(url: url)
        
        // 앨범 커버 가져오기
        if let artworkData = extractArtworkData(from: asset) {
            albumArtwork = UIImage(data: artworkData)
        }
        
        // 노래 제목, 아티스트 이름 가져오기
        let metadata = asset.metadata
        for item in metadata {
            if let commonKey = item.commonKey,
               let stringValue = item.stringValue {
                switch commonKey {
                case .commonKeyTitle:
                    title = stringValue
                case .commonKeyArtist:
                    artist = stringValue
                default:
                    break
                }
            }
        }
    }

    private func extractArtworkData(from asset: AVAsset) -> Data? {
        for metadata in asset.commonMetadata {
            if metadata.commonKey == .commonKeyArtwork, let data = metadata.value as? Data {
                return data
            }
        }
        return nil
    }

}


#Preview {
    ContentView()
}
