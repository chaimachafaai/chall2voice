//
//  VoiceMemosViewModel.swift
//  challenge 2
//
//  Created by Chaima Ait Chafaai on 09/11/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class VoiceMemosViewModel: ObservableObject {
    @Published var voiceMemos: [VoiceMemo] = []
    @Published var isRecording = false
    @Published var isTranscribing = false
    @Published var errorMessage: String?
    
    private let audioRecorder = AudioRecorder()
    private let transcriptionManager = TranscriptionManager()
    private let userDefaults = UserDefaults.standard
    private let voiceMemosKey = "savedVoiceMemos"
    
    init() {
        loadVoiceMemos()
    }
    
    func startRecording() {
        guard audioRecorder.startRecording() != nil else {
            errorMessage = "Impossible de démarrer l'enregistrement"
            return
        }
        isRecording = true
        errorMessage = nil
    }
    
    func stopRecording() {
        guard let url = audioRecorder.stopRecording() else {
            errorMessage = "Aucun enregistrement à arrêter"
            isRecording = false
            return
        }
        
        isRecording = false
        
        // Créer un nouveau VoiceMemo
        let fileName = url.lastPathComponent
        Task {
            let duration = await transcriptionManager.getAudioDuration(url: url)
            let newMemo = VoiceMemo(fileName: fileName, url: url, duration: duration)
            
            // Ajouter à la liste
            voiceMemos.insert(newMemo, at: 0)
            saveVoiceMemos()
            
            // Démarrer la transcription
            await transcribeMemo(newMemo)
        }
    }
    
    func transcribeMemo(_ memo: VoiceMemo) async {
        isTranscribing = true
        errorMessage = nil
        
        guard FileManager.default.fileExists(atPath: memo.url.path) else {
            errorMessage = "Le fichier audio n'existe plus"
            isTranscribing = false
            return
        }
        
        do {
            let transcription = try await transcriptionManager.transcribeAudio(url: memo.url)
            
            if let index = voiceMemos.firstIndex(where: { $0.id == memo.id }) {
                voiceMemos[index].transcription = transcription
                saveVoiceMemos()
            }
        } catch {
            errorMessage = "Erreur: \(error.localizedDescription)"
        }
        
        isTranscribing = false
    }
    
    func deleteMemo(_ memo: VoiceMemo) {
        try? FileManager.default.removeItem(at: memo.url)
        voiceMemos.removeAll { $0.id == memo.id }
        saveVoiceMemos()
    }
    
    func getRecordingTime() -> String {
        audioRecorder.formatTime(audioRecorder.recordingTime)
    }
    
    private func saveVoiceMemos() {
        let memosData = voiceMemos.map { memo in
            [
                "id": memo.id.uuidString,
                "fileName": memo.fileName,
                "date": memo.date.timeIntervalSince1970,
                "transcription": memo.transcription ?? "",
                "duration": memo.duration
            ] as [String: Any]
        }
        userDefaults.set(memosData, forKey: voiceMemosKey)
    }
    
    private func loadVoiceMemos() {
        guard let memosData = userDefaults.array(forKey: voiceMemosKey) as? [[String: Any]] else {
            return
        }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        voiceMemos = memosData.compactMap { data in
            guard let idString = data["id"] as? String,
                  let id = UUID(uuidString: idString),
                  let fileName = data["fileName"] as? String,
                  let dateInterval = data["date"] as? TimeInterval,
                  let duration = data["duration"] as? TimeInterval else {
                return nil
            }
            
            let url = documentsPath.appendingPathComponent(fileName)
            let date = Date(timeIntervalSince1970: dateInterval)
            let transcription = data["transcription"] as? String
            
            guard FileManager.default.fileExists(atPath: url.path) else {
                return nil
            }
            
            return VoiceMemo(
                id: id,
                fileName: fileName,
                url: url,
                date: date,
                transcription: transcription?.isEmpty == false ? transcription : nil,
                duration: duration
            )
        }
    }
}
