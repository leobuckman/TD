//
//  StartView.swift
//  TD
//
//  Created by Leo Buckman on 12/11/23.
//

import SwiftUI

struct StartView: View {
    @State var tdSession: TDMultipeerSession?
    @State var currentView: Int = 0
    @State var username = ""
    @State var selectedHost = false
    @FocusState private var editTextFieldFocus: Bool
    var body: some View {
        switch currentView {
        case 1:
            PairView(currentView: $currentView)
                .environmentObject(tdSession!)
        default:
            startViewBody
        }
    }
    
    var startViewBody: some View {
        ZStack{
            Color(.black)
                .ignoresSafeArea(.all)
            VStack {
                Spacer()
                VStack{
                    TextField("Enter your name", text: $username)
                        .font(.system(size: 25))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .disableAutocorrection(true)
                        .frame(height: 60)
                        .background(Color(red: 0.2, green: 0.2, blue: 0.2, opacity: 1.0))
                        .cornerRadius(8)
                        .padding(.bottom)
                        .focused($editTextFieldFocus)
                        .onAppear {
                            editTextFieldFocus = true
                        }
                        
                    Button{
                        selectedHost.toggle()
                        tdSession = TDMultipeerSession(username: username, isHost: selectedHost)
                        currentView = 1
                    } label:{
                        ZStack{
                            RoundedRectangle(cornerRadius: 8)
                                .frame(height: 60)
                                .foregroundStyle(.blue)
                            Text("Create Game")
                                .font(.custom("Avenir-Heavy", size: 18))
                                .foregroundStyle(.white)
                            
                        }
                    }
                    Button{
                        tdSession = TDMultipeerSession(username: username, isHost: selectedHost)
                        currentView = 1
                    } label:{
                        ZStack{
                            RoundedRectangle(cornerRadius: 8)
                                .frame(height: 60)
                                .foregroundStyle(Color(red: 0.2, green: 0.2, blue: 0.2, opacity: 1.0))
                            Text("Join Game")
                                .font(.custom("Avenir-Heavy", size: 18))
                                .foregroundStyle(.white)
                        }
                        
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .preferredColorScheme(.dark)
        }
    }
}
#Preview {
    StartView()
        .environmentObject(TDMultipeerSession(username: "\(UIDevice.current.name)", isHost: false))
}
