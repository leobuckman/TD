//
//  GameLogic.swift
//  TD
//
//  Created by Leo Buckman on 12/14/23.
//


class GameLogic {
    var tdSession: TDMultipeerSession

    init(tdSession: TDMultipeerSession) {
        self.tdSession = tdSession
    }

    // Call this method when a participant completes their task
    func participantDidComplete(participantIndex: Int, participantName: String) {
           guard participantIndex < tdSession.participantStatuses.count else {
               print("Error: Participant index out of bounds")
               return
           }
           
           tdSession.participantStatuses[participantIndex] = participantName
           tdSession.broadcastParticipantStatuses()
       }

    // Update the participant status in the session's participantStatuses array
    private func updateParticipantStatus(participantIndex: Int, participantName: String) {
        // Ensure the index is within bounds
        guard participantIndex < tdSession.participantStatuses.count else { return }

        tdSession.participantStatuses[participantIndex] = participantName
    }
}
