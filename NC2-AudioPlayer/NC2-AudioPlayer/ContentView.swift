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
                Button(action: {
                    self.initialiseAudioPlayer()
                }) {
                    Text("Select Audio File")
                }
                .padding()

                if let audioPlayer = audioPlayer {
                    Text("Selected file: \(audioPlayer.url?.lastPathComponent ?? "None")")
                }

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
                        .frame(width: 50)
                }
                .padding()
                .disabled(audioPlayer == nil) // 파일이 선택되지 않으면 버튼 비활성화

                Slider(value: Binding(get: {
                                self.progress
                            }, set: { newValue in
                                self.progress = newValue
                                let newTime = TimeInterval(newValue) * self.duration
                                self.audioPlayer.currentTime = newTime
                                self.currentTime = newTime
                                self.formattedProgress = self.formattedTime(newTime)
                            }), in: 0...1)
                            .padding()
                            .disabled(audioPlayer == nil)
                

                HStack {
                    Text("\(self.formattedProgress)")
                    Spacer()
                    Text("\(self.formattedDuration)")
                }
                .padding()


                Button(action: {
                    self.markers.append(self.audioPlayer.currentTime) // 현재 시간을 마커로 추가
                }) {
                    Text("Add Marker")
                }
                .padding()
                .disabled(audioPlayer == nil) // 파일이 선택되지 않으면 버튼 비활성화

                HStack {
                    Text("Playback Speed")
                    Spacer()
                    
                    Button(action: {
                        if self.playbackRate > 0.5 {
                            self.playbackRate -= 0.1
                            self.audioPlayer.rate = self.playbackRate
                            self.audioPlayer.enableRate = true
                        }
                    }) {
                        Image(systemName: "minus")
                    }
                    .padding(.horizontal, 10)
                    
                    Text(String(format: "%.1fx", self.playbackRate))
                    
                    Button(action: {
                        if self.playbackRate < 2.0 {
                            self.playbackRate += 0.1
                            self.audioPlayer.rate = self.playbackRate
                            self.audioPlayer.enableRate = true
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                    .padding(.horizontal, 10)
                }
                .padding()
                .disabled(audioPlayer == nil)

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
            }
        }
        
    func initialiseAudioPlayer() {
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
