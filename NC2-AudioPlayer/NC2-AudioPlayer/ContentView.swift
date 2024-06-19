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
    @State private var markers: [TimeInterval] = []
    @State private var currentTime: TimeInterval = 0.0
    @State private var duration: TimeInterval = 0.0
    @State private var isDragging: Bool = false
    @State private var progress: CGFloat = 0.0
    @State private var formattedDuration: String = "00:00"
    @State private var formattedProgress: String = "00:00"
    @State private var albumArtwork: UIImage?
    @State private var title: String = ""
    @State private var artist: String = ""

    var body: some View {
        VStack {
            audioFileSelector
            Spacer().frame(height: 20)
            addMarkerButton
            Divider()
            markerList
            Spacer()
            playbackRateControl
            progressSlider
            playbackControls
        }
    }

    // MARK: - Subviews
    private var audioFileSelector: some View {
        VStack {
            Button(action: initialiseAudioPlayer) {
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

                        VStack(alignment: .leading) {
                            Text("\(title)")
                                .font(.body)
                                .bold()
                            Text("\(artist)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(.horizontal, 10)
                        Spacer()
                    }
                } else {
                    defaultAudioPlaceholder
                }
            }
            .frame(height: 100)
            .padding()
        }
        .frame(maxWidth: .infinity)
    }

    private var addMarkerButton: some View {
        Button(action: {
            self.markers.append(self.audioPlayer.currentTime)
        }) {
            Text("Add Marker")
        }
        .padding()
        .disabled(audioPlayer == nil)
    }

    private var markerList: some View {
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

    private var playbackRateControl: some View {
        HStack {
            Button(action: decreasePlaybackRate) {
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

            Button(action: increasePlaybackRate) {
                Image(systemName: "plus")
            }
            .padding(.horizontal, 10)
        }
        .padding()
        .disabled(audioPlayer == nil)
    }

    private var progressSlider: some View {
        VStack {
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
        }
    }

    private var playbackControls: some View {
        HStack {
            Button(action: backward5Sec) {
                Image(systemName: "gobackward.5")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40)
            }
            .padding(.horizontal, 20)
            Spacer()

            Button(action: togglePlayback) {
                Image(systemName: self.isPlaying ? "pause.circle" : "play.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80)
            }
            Spacer()

            Button(action: forward5Sec) {
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

    private var defaultAudioPlaceholder: some View {
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

            VStack(alignment: .leading) {
                Text("Title")
                    .font(.body)
                    .bold()
                Text("Artist")
                    .font(.footnote)
                Spacer()
            }
            .padding(.horizontal, 10)
            .foregroundStyle(.secondary)
            Spacer()
        }
    }

    // MARK: - Helper Views
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

    private func markerContextMenu(marker: TimeInterval) -> some View {
        Group {
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

    // MARK: - Audio Player Functions
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
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)

            self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            self.audioPlayer.prepareToPlay()

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

    private func seekToTime(to time: TimeInterval) {
        guard let player = audioPlayer else { return }
        player.currentTime = time
        progress = CGFloat(time / player.duration)
        formattedProgress = formattedTime(time)
    }

    private func backward5Sec() {
        guard let player = audioPlayer else { return }
        let newTime = max(player.currentTime - 5, 0)
        seekToTime(to: newTime)
    }

    private func forward5Sec() {
        guard let player = audioPlayer else { return }
        let newTime = min(player.currentTime + 5, player.duration)
        seekToTime(to: newTime)
    }

    private func togglePlayback() {
        if self.isPlaying {
            self.audioPlayer.pause()
        } else {
            self.audioPlayer.play()
        }
        self.isPlaying.toggle()
    }

    private func decreasePlaybackRate() {
        if self.playbackRate > 0.5 {
            self.playbackRate -= 0.1
            self.updatePlaybackRate()
        }
    }

    private func increasePlaybackRate() {
        if self.playbackRate < 2.0 {
            self.playbackRate += 0.1
            self.updatePlaybackRate()
        }
    }

    // MARK: - Remote Control Center Functions
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

        commandCenter.skipBackwardCommand.preferredIntervals = [5]
        commandCenter.skipForwardCommand.preferredIntervals = [5]
    }

    private func remoteCommandInfoCenterSetting() {
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo ?? [String: Any]()

        guard let path = Bundle.main.path(forResource: "Supernova", ofType: "mp3") else {
            print("Audio file not found")
            return
        }

        extractMetadata(from: path)

        if let albumArtwork = albumArtwork {
            let artwork = MPMediaItemArtwork(boundsSize: albumArtwork.size, requestHandler: { size in
                return albumArtwork
            })
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        }

        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = audioPlayer.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = audioPlayer.rate
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = audioPlayer.currentTime

        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }

    private func extractMetadata(from path: String) {
        let url = URL(fileURLWithPath: path)
        let asset = AVAsset(url: url)

        if let artworkData = extractArtworkData(from: asset) {
            albumArtwork = UIImage(data: artworkData)
        }

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
