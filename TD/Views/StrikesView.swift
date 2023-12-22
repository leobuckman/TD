//
//  StrikesView.swift
//  TD
//
//  Created by Leo Buckman on 12/11/23.
//

import SwiftUI

struct StrikesView: View {
    enum StrikeCount: Int {
        case two, three, four, five
    }

    // Single source of truth for the active strike count
    @State private var activeStrikeCount: StrikeCount?
    var body: some View {
        VStack{
            Text("Choose a strike count")
            HStack {
                Toggle("", isOn: Binding(
                    get: { self.activeStrikeCount == .two },
                    set: { if $0 {
                        self.activeStrikeCount = .two
                    } else if self.activeStrikeCount == .two { self.activeStrikeCount = nil } }
                ))
                .toggleStyle(ButtonToggleStyle(title: "2", square: true))
                
                Toggle("", isOn: Binding(
                    get: { self.activeStrikeCount == .three },
                    set: { if $0 {
                        self.activeStrikeCount = .three
                    }
                        else if self.activeStrikeCount == .three { self.activeStrikeCount = nil } }
                ))
                .toggleStyle(ButtonToggleStyle(title: "3", square: true))
                
                Toggle("", isOn: Binding(
                    get: { self.activeStrikeCount == .four },
                    set: { if $0 { 
                        self.activeStrikeCount = .four
                    } else if self.activeStrikeCount == .four { self.activeStrikeCount = nil } }
                ))
                .toggleStyle(ButtonToggleStyle(title: "4", square: true))
                
                Toggle("", isOn: Binding(
                    get: { self.activeStrikeCount == .five },
                    set: { if $0 { 
                        self.activeStrikeCount = .five
                    } else if self.activeStrikeCount == .five { self.activeStrikeCount = nil } }
                ))
                .toggleStyle(ButtonToggleStyle(title: "5", square: true))
                
            }
            .padding(.horizontal)
        }
        
    }
}

#Preview {
    StrikesView()
}
