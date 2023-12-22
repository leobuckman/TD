//
//  StrikeStatusView.swift
//  TD
//
//  Created by Leo Buckman on 12/12/23.
//

import SwiftUI

struct StrikeStatusView: View {
    // Combine player names with their respective strike counts into a single array
    @State var playersWithStrikes = [("Jack", 2), ("Lizzy", 0), ("Sarah", 1), ("Paul", 2)]
    @State var maxStrikes: Int = 3

    var body: some View {
       
            HStack(spacing: 30) { 
                ForEach(playersWithStrikes, id: \.0) { player, strikes in
                    VStack {
                        Text("\(player)")
                            .bold()
                            .font(.system(size: 16))
                            .foregroundColor(.white)

                        HStack {
                            // Iterate up to maxStrikes to create the circles
                            ForEach(0..<maxStrikes, id: \.self) { index in
                                Circle()
                                    .frame(width: 10)
                                    .foregroundColor(index < strikes ? .blue : .gray) // Filled if index is less than strikes
                            }
                        }
                    }
                }
            }
        
    }
}

#Preview {
        StrikeStatusView()
    }

