
https://github.com/user-attachments/assets/5cf1684a-14e5-48c3-a232-08964e5cb363

Overview
VoiceMemo is an iOS application designed to make audio recording and automatic speech transcription simple, fast, and reliable. Built with SwiftUI and powered by a custom audio engine, the app allows users to capture voice notes, instantly convert them into text, and manage them in an elegant dark-themed interface.
Key Features
One-tap audio recording
The user can start and stop a recording instantly with a central record button.
Real-time recording indicator
Visual feedback ensures that the user always knows when the device is capturing audio.
Automatic transcription
Each memo is transcribed using a speech-to-text engine and displayed beneath the audio entry.
Memo management
Users can view, delete, and reorder their stored recordings.
Persistent storage
Recordings, durations, dates, and transcriptions are stored locally via UserDefaults and the Documents directory.
Error handling
Friendly error messages are shown when recording fails or files are missing.
Architecture Summary
The application follows a clean MVVM structure:
ViewModel (VoiceMemosViewModel)
Manages state (isRecording, isTranscribing, list of memos).
Handles audio recording via AudioRecorder.
Runs transcription asynchronously with TranscriptionManager.
Stores and reloads memos using local persistence.
Updates the UI reactively using @Published properties.
Model (VoiceMemo)
Stores memo metadata: ID, URL, date, transcription, duration.
View (SwiftUI)
Displays memo list, recording button, live timer, and transcription results.
Adapts to dark mode with a red/gray/black palette consistent with the visual identity.
User Interface Preview
Home Screen
Shows the list of recordings, including the date, duration, and transcription:
Screenshots :
Screen 1 — Memo List
<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 Pro - 2025-11-17 at 16 46 47" src="https://github.com/user-attachments/assets/148dabd2-63d6-4ae4-9b07-e2863c5d0491" />
Screen 2 — Recording State
<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 Pro - 2025-11-17 at 16 22 45" src="https://github.com/user-attachments/assets/46270b6b-3b82-43ba-a262-1c653bea99a8" />
Screen 3 — Displayed Transcription
<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 Pro - 2025-11-17 at 16 46 47" src="https://github.com/user-attachments/assets/8d40135a-a61e-47b1-8fd6-bda5ccb0cf2a" />
<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 Pro - 2025-11-17 at 16 47 00" src="https://github.com/user-attachments/assets/ac47feca-e546-4dd4-ab2f-f07cc8e4f467" />

recording screenshot :

https://github.com/user-attachments/assets/ddf0a4a0-a784-4b5c-96c8-7e5c1235a68f



transcribing audio on iOS devices. Its simple interaction model and automatic transcription capabilities make it ideal for quick notes, interviews, reminders, and voice-based productivity workflows.
