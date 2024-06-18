//
//  ContentView.swift
//  NC2-AudioPlayer
//
//  Created by Woowon Kang on 6/17/24.
//

import SwiftUI
import AVFoundation

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
                        Text("Selected file: \(audioPlayer.url?.lastPathComponent ?? "None")")
                    } else {
                        Text("Selected file: None")
                            .opacity(0)
                    }
                }
                .frame(height: 20)
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
            List {
                ForEach(markers, id: \.self) { marker in
                    Button(action: {
                        self.audioPlayer.currentTime = marker // 마커로 이동
                        self.progress = CGFloat(marker / self.duration)
                        self.formattedProgress = self.formattedTime(marker)
                        self.audioPlayer.play() // 이동 후 재생
                        self.isPlaying = true
                    }) {
                        Text("Marker at \(self.formattedTime(marker))")
                    }
                }
            }
            .disabled(audioPlayer == nil)
            
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
                    let newTime = max(self.audioPlayer.currentTime - 5, 0)
                    self.audioPlayer.currentTime = newTime
                    self.progress = CGFloat(newTime / self.duration)
                    self.formattedProgress = self.formattedTime(newTime)
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
                    let newTime = min(self.audioPlayer.currentTime + 5, self.duration)
                    self.audioPlayer.currentTime = newTime
                    self.progress = CGFloat(newTime / self.duration)
                    self.formattedProgress = self.formattedTime(newTime)
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
            
            Spacer()
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
            self.audioPlayer.enableRate = true // 배속 설정 가능하도록 함

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
}


#Preview {
    ContentView()
}
