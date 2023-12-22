//
//  ResultsView.swift
//  TD
//
//  Created by Leo Buckman on 12/13/23.
//

import SwiftUI

struct ResultsView: View {
    @ObservedObject var tdSession: TDMultipeerSession

    var body: some View {
        ZStack{
            Color.black
                .ignoresSafeArea(.all)
            VStack {
                StrikeStatusView()
                    .padding(.vertical)
                Text("Race results")
                    .font(.title3)
                    .bold()
                    .foregroundStyle(.white)
                Text("\(UIDevice.current.name)")
                    .foregroundStyle(.white)
                ForEach(tdSession.participantStatuses, id: \.self) { status in
                    VStack{
                        Text(status)
                            .foregroundStyle(.white)
                    }
                }
                Spacer()
            }
        }
    }
}



#Preview {
    ResultsView(tdSession: TDMultipeerSession(username: "\(UIDevice.current.name)", isHost: true))
}


