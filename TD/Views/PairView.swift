//
//  PairView.swift
//  TD
//
//  Created by Leo Buckman on 12/11/23.
//

import SwiftUI
import os

struct PairView: View {
    @EnvironmentObject var tdSession: TDMultipeerSession
    @Binding var currentView: Int
    @State private var waitingForHost = false
    var logger = Logger()
    
    var body: some View {
        
        if (!tdSession.paired) {
            //Show if user chose create
            
                
            if tdSession.hostStatus{
                ZStack{
                    Color.black
                        .ignoresSafeArea(.all)
                    VStack {
                        if tdSession.availablePeers.count == 0{
                            VStack{
                                Spacer()
                                Text("Waiting for players")
                                    .font(.title3)
                                    .bold()
                                    .foregroundStyle(.white)
                                Spacer()
                                
                            }
                        }
                        List(tdSession.availablePeers, id: \.self) { peer in
                            Button(peer.displayName) {
                                tdSession.serviceBrowser.invitePeer(peer, to: tdSession.session, withContext: nil, timeout: 30)
                            }
                        }
                        
                        .frame(height: 250)
                        //   StrikesView()
                        Spacer()
                        
                    }
                    
                }
                .preferredColorScheme(.dark)
            }
            //Show if user chose join
                else if !tdSession.hostStatus {
                    ZStack{
                        Color.black
                            .ignoresSafeArea(.all)
                        switch tdSession.currentSessionState {
                        case .connecting:
                            Text("Connecting to \(tdSession.recvdInviteFrom?.displayName ?? "host")...")
                                .foregroundStyle(.green)
                        case .connected:
                            Text("Connected. Waiting for \(tdSession.recvdInviteFrom?.displayName ?? "host") to start the race...")
                                .foregroundStyle(.green)
                        case .notConnected:
                            HStack {
                                Text("Waiting for invite from host")
                                    .font(.title3)
                                    .bold()
                                    .foregroundStyle(.white)
                            }
                            .alert("Received an invite from \(tdSession.recvdInviteFrom?.displayName ?? "ERR")!", isPresented: $tdSession.recvdInvite) {
                                Button("Reject invite") {
                                    if (tdSession.invitationHandler != nil) {
                                        tdSession.invitationHandler!(false, nil)
                                    }
                                    
                                }
                                Button("Accept invite") {
                                    if (tdSession.invitationHandler != nil) {
                                        tdSession.invitationHandler!(true, tdSession.session)
                                        tdSession.initializeParticipantStatuses()
                                        print("Updated participant statuses: \(tdSession.participantStatuses)")
                                        
                                    }
                                }
                            }
                            
                        default:
                            Text("Connection status: Unknown")
                                .foregroundStyle(.green)
                        }
                    }
                        
        }
            
        } else {
            
            TypingView()
            //GameView(currentView: $currentView)
            //    .environmentObject(tdSession)
        }
    }
}

#Preview {
        PairView(currentView: .constant(1))
            .environmentObject(TDMultipeerSession(username: "\(UIDevice.current.name)", isHost: true))
    }

