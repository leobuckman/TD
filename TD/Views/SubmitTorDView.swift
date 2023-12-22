//
//  SubmitTorD.swift
//  TD
//
//  Created by Leo Buckman on 12/11/23.
//

import SwiftUI
//import SwiftUIIntrospect

struct SubmitTorDView: View {
    @State private var tord: String = ""
    enum choiceCount: Int {
        case zero, one
    }

    // Single source of truth for the active strike count
    @State private var activeChoiceCount: choiceCount?
    @FocusState private var isFocused: Bool
    var body: some View {
        ZStack{
            Color.black
                .ignoresSafeArea(.all)
            VStack(alignment: .leading){
                Text("Enter your truth or dare")
                    .font(.title)
                    .bold()
                    .foregroundStyle(.white)
                    .padding(.vertical)
                HStack {

                    Toggle("", isOn: Binding(
                        get: { self.activeChoiceCount == .zero },
                        set: { if $0 { self.activeChoiceCount = .zero } else if self.activeChoiceCount == .zero { self.activeChoiceCount = nil } }
                    ))
                    .toggleStyle(ButtonToggleStyle(title: "Truth", square: false))

                    Spacer() // Adds space between toggles

                    Toggle("", isOn: Binding(
                        get: { self.activeChoiceCount == .one },
                        set: { if $0 { self.activeChoiceCount = .one } else if self.activeChoiceCount == .one { self.activeChoiceCount = nil } }
                    ))
                    .toggleStyle(ButtonToggleStyle(title: "Dare", square: false))
                }

                TextEditor(text: $tord)
                    .font(.system(size: 20))
                    .padding(.leading, 5)
                    .foregroundStyle(.white)
                    .transparentScrolling()
                    .background(Color(red: 0.2, green: 0.2, blue: 0.2, opacity: 1.0))
                    .frame(height: 50)
                    .cornerRadius(8)
                    

                Spacer()
                Button{
                    
                } label:{
                    ZStack{
                        RoundedRectangle(cornerRadius: 8)
                            .frame(height: 60)
                            .foregroundColor((tord != "" && self.activeChoiceCount != nil) ? Color.blue : Color(red: 0.2, green: 0.2, blue: 0.2, opacity: 1.0))

                        Text("Submit")
                            .font(.custom("Avenir-Heavy", size: 18))
                            .foregroundStyle(.white)
                    }
                    
                }
                .padding(.bottom)
                .disabled((tord != "" && self.activeChoiceCount != nil) ?  false : true)
            }
            .padding(.horizontal)
        }
    }
}

public extension View {
    func transparentScrolling() -> some View {
        if #available(iOS 16.0, *) {
            return scrollContentBackground(.hidden)
        } else {
            return onAppear {
                UITextView.appearance().backgroundColor = .clear
            }
        }
    }
}

#Preview {
    SubmitTorDView()
}
