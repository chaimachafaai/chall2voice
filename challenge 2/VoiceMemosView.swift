//
//  VoiceMemosView.swift
//  challenge 2
//
//  Created by Chaima Ait Chafaai on 09/11/25.
//

import SwiftUI

struct VoiceMemosView: View {
    @StateObject private var viewModel = VoiceMemosViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fond noir
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Liste des enregistrements
                    if viewModel.voiceMemos.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "mic.slash")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("Aucun enregistrement")
                                .font(.title2)
                                .foregroundColor(.white)
                            Text("Appuyez sur le bouton d'enregistrement pour commencer")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.voiceMemos) { memo in
                                    VoiceMemoRow(memo: memo, viewModel: viewModel)
                                }
                            }
                            .padding()
                        }
                    }
                    
                    // Barre de contrôle d'enregistrement
                    VStack(spacing: 16) {
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        }
                        
                        // Bouton d'enregistrement
                        Button(action: {
                            if viewModel.isRecording {
                                viewModel.stopRecording()
                            } else {
                                viewModel.startRecording()
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(viewModel.isRecording ? Color.red : Color.gray)
                                    .frame(width: 80, height: 80)
                                    .shadow(color: viewModel.isRecording ? .red.opacity(0.5) : .gray.opacity(0.3), radius: 10)
                                
                                if viewModel.isRecording {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.white)
                                        .frame(width: 24, height: 24)
                                } else {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 30, height: 30)
                                }
                            }
                        }
                        .disabled(viewModel.isTranscribing)
                        .padding(.vertical, 20)
                        
                        // Temps d'enregistrement
                        if viewModel.isRecording {
                            Text(viewModel.getRecordingTime())
                                .font(.title)
                                .monospacedDigit()
                                .foregroundColor(.red)
                        }
                        
                        // Indicateur de transcription
                        if viewModel.isTranscribing {
                            HStack(spacing: 8) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                    .scaleEffect(0.8)
                                Text("Transcription en cours...")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.bottom, 10)
                        }
                    }
                    .padding(.bottom, 20)
                    .background(Color.black)
                }
            }
            .navigationTitle("VoiceMemos")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !viewModel.voiceMemos.isEmpty {
                        EditButton()
                            .foregroundColor(.white)
                    }
                }
            }
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

struct VoiceMemoRow: View {
    let memo: VoiceMemo
    let viewModel: VoiceMemosViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Icône
                Image(systemName: "waveform")
                    .foregroundColor(.red)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 4) {
                    // Date
                    Text(formatDate(memo.date))
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    // Durée
                    Text(formatDuration(memo.duration))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Bouton de transcription si pas encore transcrit
                if memo.transcription == nil {
                    Button(action: {
                        Task {
                            await viewModel.transcribeMemo(memo)
                        }
                    }) {
                        Image(systemName: "text.bubble")
                            .foregroundColor(.gray)
                            .font(.title3)
                    }
                }
                
                // Bouton de suppression
                Button(action: {
                    viewModel.deleteMemo(memo)
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.title3)
                }
            }
            
            // Transcription
            if let transcription = memo.transcription, !transcription.isEmpty {
                Text(transcription)
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding(.top, 4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    VoiceMemosView()
}
