//
//  ContentView.swift
//  lovely-emoji
//
//  Created by Linkai Qi on 2025-03-02.
//

import SwiftUI

struct ContentView: View {
  @State private var inputText = ""
  @State private var emojiText = ""
  @State private var isLoading = false

  var body: some View {
    NavigationView {
      VStack {
        TextField("Enter text here...", text: $inputText)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .padding()

        Button(action: {
          convertTextToEmoji()
        }) {
          Text("Convert to Emoji")
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()

        if isLoading {
          ProgressView()
            .padding()
        }

        Text(emojiText)
          .font(.largeTitle)
          .padding()

        Spacer()
      }
      .navigationTitle("Text to Emoji")
    }
  }

  func convertTextToEmoji() {
    // Ensure the user entered some text
    guard !inputText.isEmpty else { return }
    isLoading = true

    // Configure the request for the OpenAI API
    let apiKey = "YOUR_OPENAI_API_KEY"
    let url = URL(string: "https://api.openai.com/v1/completions")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

    // Create a prompt that instructs the API to convert text to emojis
    let prompt = "Convert the following text to emojis: \(inputText)"
    let json: [String: Any] = [
      "model": "text-davinci-003",
      "prompt": prompt,
      "max_tokens": 60,
      "temperature": 0.7
    ]

    // Serialize the JSON payload
    guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
      isLoading = false
      return
    }
    request.httpBody = jsonData

    // Send the API request
    URLSession.shared.dataTask(with: request) { data, response, error in
      defer {
        DispatchQueue.main.async {
          isLoading = false
        }
      }
      if let error = error {
        print("Error: \(error.localizedDescription)")
        return
      }
      guard let data = data else { return }
      do {
        // Parse the API response
        if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let choices = jsonResponse["choices"] as? [[String: Any]],
           let firstChoice = choices.first,
           let textResult = firstChoice["text"] as? String {
          DispatchQueue.main.async {
            emojiText = textResult.trimmingCharacters(in: .whitespacesAndNewlines)
          }
        }
      } catch {
        print("Error parsing response: \(error.localizedDescription)")
      }
    }.resume()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
