//
//  TranscriptionManager.swift
//  challenge 2
//
//  Created by Chaima Ait Chafaai on 09/11/25.
//

import Speech
import AVFoundation
import Foundation
import Combine

class TranscriptionManager: ObservableObject {
    @Published var isTranscribing = false
    @Published var transcriptionError: String?
    
    private var authorizationStatus: SFSpeechRecognizerAuthorizationStatus?
    
    func requestAuthorization() async -> SFSpeechRecognizerAuthorizationStatus {
        if let cachedStatus = authorizationStatus {
            return cachedStatus
        }
        
        let status = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        authorizationStatus = status
        return status
    }
    
    func transcribeAudio(url: URL, locale: Locale = Locale(identifier: "fr-FR")) async throws -> String {
        await MainActor.run {
            isTranscribing = true
            transcriptionError = nil
        }
        
        defer {
            Task { @MainActor in
                isTranscribing = false
            }
        }
        
        // Vérifier l'autorisation
        let authStatus = await requestAuthorization()
        guard authStatus == .authorized else {
            let error = "Autorisation de reconnaissance vocale refusée"
            await MainActor.run {
                transcriptionError = error
            }
            throw TranscriptionError.authorizationDenied
        }
        
        // Vérifier que le recognizer est disponible
        guard let recognizer = SFSpeechRecognizer(locale: locale),
              recognizer.isAvailable else {
            let error = "Reconnaissance vocale non disponible"
            await MainActor.run {
                transcriptionError = error
            }
            throw TranscriptionError.recognizerNotAvailable
        }
        
        // Créer la requête
        let request = SFSpeechURLRecognitionRequest(url: url)
        request.shouldReportPartialResults = false
        request.taskHint = .dictation
        request.requiresOnDeviceRecognition = false
        
        // Effectuer la transcription
        return try await withCheckedThrowingContinuation { continuation in
            var hasResumed = false
            var task: SFSpeechRecognitionTask?
            
            task = recognizer.recognitionTask(with: request) { result, error in
                guard !hasResumed else { return }
                
                if let error = error {
                    let nsError = error as NSError
                    // Code 216 = tâche annulée, on peut l'ignorer si on a un résultat
                    if nsError.code == 216 {
                        return
                    }
                    hasResumed = true
                    continuation.resume(throwing: error)
                    return
                }
                
                if let result = result, result.isFinal {
                    let transcription = result.bestTranscription.formattedString
                    if !transcription.isEmpty {
                        hasResumed = true
                        continuation.resume(returning: transcription)
                        task?.cancel()
                    }
                }
            }
            
            // Timeout de sécurité
            Task {
                let duration = await getAudioDuration(url: url)
                let timeout = min(max(duration * 2 + 10, 20), 180)
                
                try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                
                if !hasResumed {
                    hasResumed = true
                    task?.cancel()
                    continuation.resume(throwing: TranscriptionError.transcriptionFailed)
                }
            }
        }
    }
    
    func getAudioDuration(url: URL) async -> TimeInterval {
        let asset = AVURLAsset(url: url)
        do {
            let duration = try await asset.load(.duration)
            return CMTimeGetSeconds(duration)
        } catch {
            return 0
        }
    }
}

enum TranscriptionError: LocalizedError {
    case authorizationDenied
    case recognizerNotAvailable
    case transcriptionFailed
    
    var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            return "Autorisation de reconnaissance vocale refusée"
        case .recognizerNotAvailable:
            return "Reconnaissance vocale non disponible"
        case .transcriptionFailed:
            return "Échec de la transcription"
        }
    }
}
