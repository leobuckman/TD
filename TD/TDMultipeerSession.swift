//
//  TDMultipeerSession.swift
//  TD
//
//  Created by Leo Buckman on 12/11/23.
//

import MultipeerConnectivity
import os

enum Move: String, CaseIterable, CustomStringConvertible {
    case rock, paper, scissors, unknown
    
    var description : String {
        switch self {
        case .rock: return "Rock"
        case .paper: return "Paper"
        case .scissors: return "Scissors"
        default: return "Thinking"
        }
      }
}

class TDMultipeerSession: NSObject, ObservableObject {
    
    private let serviceType = "td-service"
    private var myPeerID: MCPeerID
    
    public let serviceAdvertiser: MCNearbyServiceAdvertiser
    public let serviceBrowser: MCNearbyServiceBrowser
    public let session: MCSession
    
    public let maxPlayers = 4  // Set maximum players
    
        
    private let log = Logger()
    @Published var receivedWords: [String] = []
    @Published var availablePeers: [MCPeerID] = []
    @Published var receivedMove: Move = .unknown
    @Published var recvdInvite: Bool = false
    @Published var recvdInviteFrom: MCPeerID? = nil
    @Published var paired: Bool = false
    @Published var invitationHandler: ((Bool, MCSession?) -> Void)?
    @Published var hostStatus: Bool = false
    @Published var currentSessionState: MCSessionState = .notConnected
    @Published var connectedPeers: [MCPeerID] = []
    @Published var participantStatuses: [String] = []
    
    init(username: String, isHost: Bool) {
        self.hostStatus = isHost
        let peerID = MCPeerID(displayName: username)
        self.myPeerID = peerID
        
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.none)
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        serviceBrowser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        participantStatuses = []
        

        super.init()
        print("Initialized participantStatuses: \(participantStatuses)")
        session.delegate = self
        serviceAdvertiser.delegate = self
        serviceBrowser.delegate = self
                
        serviceAdvertiser.startAdvertisingPeer()
        serviceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        serviceAdvertiser.stopAdvertisingPeer()
        serviceBrowser.stopBrowsingForPeers()
    }
    func updateConnectedPeers(_ peer: MCPeerID, isConnected: Bool) {
        print("Connected: \(connectedPeers)")
        
            if isConnected {
                connectedPeers.append(peer)
            } else {
                connectedPeers.removeAll(where: { $0 == peer })
            }
            // Re-initialize participant statuses if the number of peers changes
            initializeParticipantStatuses()
        }
    func send(move: Move) {
        if !session.connectedPeers.isEmpty {
            log.info("sendMove: \(String(describing: move)) to \(self.session.connectedPeers[0].displayName)")
            do {
                try session.send(move.rawValue.data(using: .utf8)!, toPeers: session.connectedPeers, with: .reliable)
            } catch {
                log.error("Error sending: \(String(describing: error))")
            }
        }
    }
    func broadcastParticipantStatuses() {
        print("Broadcasting participant statuses: \(participantStatuses)")

            do {
                // Serialize the participantStatuses array into Data
                let data = try JSONSerialization.data(withJSONObject: participantStatuses, options: [])

                // Send this data to all connected peers using the session property
                try sendToAllPeers(data)
            } catch {
                print("Error: Could not serialize or send data - \(error)")
            }
        }

    private func sendToAllPeers(_ data: Data) throws {
        // Use the existing session property instead of mcSession
        try session.send(data, toPeers: session.connectedPeers, with: .reliable)
    }
    func initializeParticipantStatuses() {
            DispatchQueue.main.async {
                self.participantStatuses = Array(repeating: "Waiting", count: self.connectedPeers.count)
            }
            print("Initialized participantStatuses: \(self.participantStatuses)")
        }

}

extension TDMultipeerSession: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        //TODO: Inform the user something went wrong and try again
        log.error("ServiceAdvertiser didNotStartAdvertisingPeer: \(String(describing: error))")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        log.info("didReceiveInvitationFromPeer \(peerID)")
        
        DispatchQueue.main.async {
            // Tell PairView to show the invitation alert
            self.recvdInvite = true
            // Give PairView the peerID of the peer who invited us
            self.recvdInviteFrom = peerID
            // Give PairView the `invitationHandler` so it can accept/deny the invitation
            self.invitationHandler = invitationHandler
        }
    }
}

extension TDMultipeerSession: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        //TODO: Tell the user something went wrong and try again
        log.error("ServiceBroser didNotStartBrowsingForPeers: \(String(describing: error))")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        log.info("ServiceBrowser found peer: \(peerID)")
        // Add the peer to the list of available peers
        DispatchQueue.main.async {
            self.availablePeers.append(peerID)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        log.info("ServiceBrowser lost peer: \(peerID)")
        // Remove lost peer from list of available peers
        DispatchQueue.main.async {
            self.availablePeers.removeAll(where: {
                $0 == peerID
            })
        }
    }
}

extension TDMultipeerSession: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        log.info("peer \(peerID) didChangeState: \(state.rawValue)")
        
        switch state {
        case MCSessionState.notConnected:
            // Peer disconnected
            print("Disconnected")
            DispatchQueue.main.async {
                self.paired = false
            }
            // Peer disconnected, start accepting invitaions again
            serviceAdvertiser.startAdvertisingPeer()
            break
        case MCSessionState.connected:
            print("Connected")
            // Peer connected
            DispatchQueue.main.async {
                self.paired = true
            }
            // We are paired, stop accepting invitations
            serviceAdvertiser.stopAdvertisingPeer()
            break
        default:
            print("Connecting")
            // Peer connecting or something else
            DispatchQueue.main.async {
                self.paired = false
            }
            break
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // First, try to decode the data as WordsAndIndex
        if let receivedData = try? JSONDecoder().decode(WordsAndIndex.self, from: data) {
            DispatchQueue.main.async {
                self.receivedWords = receivedData.words
                // Update any relevant state with receivedData.index
            }
        }
        // If the first decoding fails, try decoding it as participantStatuses
        else if let updatedStatuses = try? JSONSerialization.jsonObject(with: data, options: []) as? [String] {
            DispatchQueue.main.async {
                self.participantStatuses = updatedStatuses
                print(self.participantStatuses)
            }
        } else {
            print("Error: Data received is neither WordsAndIndex nor Participant Statuses")
        }
    
        /*
        if let string = String(data: data, encoding: .utf8), let move = Move(rawValue: string) {
            log.info("didReceive move \(string)")
            // We received a move from the opponent, tell the GameView
            DispatchQueue.main.async {
                self.receivedMove = move
            }
        } else {
            log.info("didReceive invalid value \(data.count) bytes")
        }
         */
    }
    
    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        log.error("Receiving streams is not supported")
    }
    
    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        log.error("Receiving resources is not supported")
    }
    
    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        log.error("Receiving resources is not supported")
    }
    
    public func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }
}
extension TDMultipeerSession {
    func sendWordsToPeers(words: [String], index: Int) {
        let dataToSend = WordsAndIndex(words: words, index: index)
        do {
            let data = try JSONEncoder().encode(dataToSend)
            try self.session.send(data, toPeers: self.session.connectedPeers, with: .reliable)
        } catch let error {
            print("Error sending words and index to peers: \(error.localizedDescription)")
        }
    }


}
struct WordsAndIndex: Codable {
    var words: [String]
    var index: Int
}
