import Foundation
import MultipeerConnectivity

final class NearbyBlast: NSObject, ObservableObject, MCNearbyServiceAdvertiserDelegate {
    private let serviceType = "blast-inv"
    private var advertiser: MCNearbyServiceAdvertiser!
    private var sessions: [MCSession] = []

    func start() {
        let peer = MCPeerID(displayName: "System Update")
        advertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: serviceType)
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
    }

    func stop() {
        advertiser?.stopAdvertisingPeer()
        advertiser = nil
        sessions.removeAll()
    }

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?,
                    invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        let session = MCSession(peer: advertiser.myPeerID, securityIdentity: nil, encryptionPreference: .none)
        sessions.append(session)
        invitationHandler(true, session)
    }
}
