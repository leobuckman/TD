//
//  WordFetcher.swift
//  RPS
//
//  Created by Leo Buckman on 12/12/23.
//

import SwiftUI

// Model for the response
struct RandomWord: Decodable {
    let word: String
}

// Networking manager
class WordFetcher: ObservableObject {
    @Published var randomWord = ""

    func fetchRandomWord() {
        let urlString = "https://random-word-api.herokuapp.com/word?length=5"
        guard let url = URL(string: urlString) else { return }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Check for errors, unwrap data
            guard let data = data, error == nil else { return }

            // Decode JSON
            do {
                let words = try JSONDecoder().decode([RandomWord].self, from: data)
                if let word = words.first?.word {
                    DispatchQueue.main.async {
                        self.randomWord = word
                    }
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }
        task.resume()
    }
}
