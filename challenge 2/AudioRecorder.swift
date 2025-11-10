//
//  AudioRecorder.swift
//  challenge 2
//
//  Created by Chaima Ait Chafaai on 09/11/25.
//

import AVFoundation
import Foundation
import Combine

class AudioRecorder: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var recordingTime: TimeInterval = 0
    
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    private var startTime: Date?
    
    var currentRecordingURL: URL?
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            print("Erreur lors de la configuration de la session audio: \(error)")
        }
    }
    
    func startRecording() -> URL? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("\(UUID().uuidString).m4a")
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            isRecording = true
            startTime = Date()
            currentRecordingURL = audioFilename
            
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                self?.updateRecordingTime()
            }
            
            return audioFilename
        } catch {
            print("Erreur lors du démarrage de l'enregistrement: \(error)")
            return nil
        }
    }
    
    func stopRecording() -> URL? {
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false
        timer?.invalidate()
        timer = nil
        
        let url = currentRecordingURL
        currentRecordingURL = nil
        recordingTime = 0
        startTime = nil
        
        return url
    }
    
    private func updateRecordingTime() {
        if let startTime = startTime {
            recordingTime = Date().timeIntervalSince(startTime)
        }
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

extension AudioRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("L'enregistrement s'est terminé avec une erreur")
        }
    }
}
