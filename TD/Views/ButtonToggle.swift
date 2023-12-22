//
//  ButtonToggle.swift
//  TD
//
//  Created by Leo Buckman on 12/11/23.
//
import SwiftUI

struct ButtonToggleStyle: ToggleStyle {
    var title: String
    var square: Bool

    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
            let generator = UIImpactFeedbackGenerator(style: .soft)
            generator.impactOccurred(intensity: 1.0)
        } label: {
            Label {
                
            } icon: {
                ZStack{
                    RoundedRectangle(cornerRadius: 8)
                        .frame(height: 60)
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2, opacity: 1.0))

                    Text(title)
                        .font(.custom("Avenir-Heavy", size: 20))
                        .foregroundStyle(.white)
                }
              //  .frame(height: square ? 60 : 50)
                .background(Color(red: 0.2, green: 0.2, blue: 0.2, opacity: 1.0))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(configuration.isOn ? Color.blue : Color.clear, lineWidth: 5)
                )
            }
        }
        .buttonStyle(.plain)
    }
}


// Example view for testing
struct ButtonToggleStyleView: View {
    @State private var isOn = false

    var body: some View {
        Toggle("Switch Me", isOn: $isOn)
            .toggleStyle(ButtonToggleStyle(title: "Truth", square: false))
    }
}

#Preview {
        ButtonToggleStyleView()
    }
