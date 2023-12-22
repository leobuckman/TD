//
//  VotingView.swift
//  TD
//
//  Created by Leo Buckman on 12/14/23.
//

import SwiftUI

struct VotingView: View {
    @State private var loser = "Jack"
    @State private var tords: [(isTruth: Bool, description: String, votes: Int)] = [
        (isTruth: true, description: "What is your favorite color?", votes: 0),
        (isTruth: false, description: "Lick your shoe", votes: 2),
        (isTruth: false, description: "Call your mom", votes: 1)
    ]

    var body: some View {
        VStack {
            Text("\(loser)'s punishment")
                .font(.headline)
                .padding()

            List {
                ForEach(tords.indices, id: \.self) { index in
                    HStack{
                        ZStack{
                            Rectangle()
                                .foregroundStyle(.black)
                                .frame(width: 25, height: 25)
                                .cornerRadius(4)
                            if tords[index].isTruth{
                                Text("T")
                                    .bold()
                                    .foregroundStyle(.white)
                            }else{
                                Text("D")
                                    .bold()
                                    .foregroundStyle(.white)
                            }
                        }
                        Text("\(tords[index].description)")
                        Spacer()
                        Text("\(tords[index].votes)")
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct VotingView_Previews: PreviewProvider {
    static var previews: some View {
        VotingView()
    }
}
