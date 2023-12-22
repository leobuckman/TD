//
//  TypingView.swift
//  TD
//
//  Created by Leo Buckman on 12/12/23.
//
import SwiftUI

struct TypingView: View {
    @State private var allWords: [String] = []
    @State private var randomWord = ""
    @State private var userInput = ""
    @State private var currentWordIndex = 0
    @FocusState private var editTextFieldFocus: Bool
    @EnvironmentObject var tdSession: TDMultipeerSession
    @State private var isGameOver = false
    @State private var winner = ""
    let maxWords = 5


    var body: some View {
        if isGameOver {
           ResultsView(tdSession: tdSession)
        } else {
        
        ZStack{
            Color.black
                .ignoresSafeArea(.all)
            VStack {
                //   StrikeStatusView()
                // Horizontal bar indicator
                
                ProgressView(value: Double(currentWordIndex), total: Double(maxWords))
                    .animation(.easeInOut, value: currentWordIndex)
                    .padding()
                
                // Display random word
                Text(randomWord)
                    .foregroundStyle(.white)
                    .font(.largeTitle)
                    .padding(.bottom, -10)
                
                TextField("", text: $userInput)
                    .font(.largeTitle)
                    .foregroundStyle(.blue)
                    .multilineTextAlignment(.center)
                   // .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .frame(height: 60)
                    .background(Color(red: 0.2, green: 0.2, blue: 0.2, opacity: 1.0))
                    .cornerRadius(8)
                    .padding()
                    .onChange(of: userInput) { _ in
                        checkWord()
                    }
                    .focused($editTextFieldFocus)
                //become first responder
                    .onAppear {
                        editTextFieldFocus = true
                    }
                Spacer()
            }
            .onAppear(perform: loadWords)
            .onReceive(tdSession.$receivedWords) { newWords in
                if !newWords.isEmpty {
                    self.allWords = newWords  // Use the words as received
                    fetchNewWord()
                    tdSession.initializeParticipantStatuses()
                }
            }
        }
        .preferredColorScheme(.dark)
    }
        
    }
    func loadWords() {
        if tdSession.hostStatus {
            // Load and send words if this device is the host
            if let fileURL = Bundle.main.url(forResource: "MITRandomWords", withExtension: "txt") {
                if let wordContents = try? String(contentsOf: fileURL) {
                    allWords = wordContents.components(separatedBy: "\n").filter { !$0.isEmpty }
                    allWords.shuffle()  // Shuffle the words
                    fetchNewWord()
                    tdSession.sendWordsToPeers(words: allWords, index: currentWordIndex)
                }
            }
        }
    }
    func printConnectedPeers() {
        let connectedPeersNames = tdSession.connectedPeers.map { $0.displayName }
        print("Connected peers: \(connectedPeersNames)")
    }

    func fetchNewWord() {
            if currentWordIndex < allWords.count {
                randomWord = allWords[currentWordIndex]
                userInput = ""
            } else {
                // Handle case when all words are used
            }
        }

    func checkWord() {
        if userInput.lowercased() == randomWord.lowercased() {
            userInput = ""
            if currentWordIndex < maxWords {
                currentWordIndex += 1
                if currentWordIndex < maxWords {
                    fetchNewWord()
                } else {
                    //print connected peers
                    printConnectedPeers()
                    isGameOver = true
                }
            }
        }
    }
}

#Preview {
        TypingView()
    }
