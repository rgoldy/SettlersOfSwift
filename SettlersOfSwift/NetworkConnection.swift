//
//  MultipeerNetworkManager.swift
//  SettlersOfSwift
//
//  Created by Riley Goldman on 1/26/17.
//  Copyright © 2017 Comp361. All rights reserved.
//

import Foundation
import MultipeerConnectivity

protocol NetworkDelegate {
    func foundPeer()
    func lostPeer()
    func invitationWasReceived(fromPeer: String)
    func connectedWithPeer(peerID: MCPeerID)
}

class MultipeerNetworkManager : NSObject {
    
    // Identifies who is using the game
    private var myServiceType = "settlersofswift"
    
    // List of all users you can see
    var nearbyUsers = [MCPeerID]()
    var delegate: NetworkDelegate?
    
    private var myPeerId : MCPeerID!
    var serviceAdvertiser : MCNearbyServiceAdvertiser!
    var serviceBrowser : MCNearbyServiceBrowser!
    
    init(username: String) {
        myPeerId = MCPeerID(displayName: username)
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: myServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: myServiceType)
        
        super.init()
        
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    convenience override init() {
        self.init(username: UIDevice.current.name)
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    func getNearbyUsers() -> [String] {
        var users = [String]()
        for (_, peer) in nearbyUsers.enumerated() {
            users.append(peer.displayName)
        }
        return users
    }
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.required)
        session.delegate = self
        return session
    }()
    
    func peerFound(peer: MCPeerID) {
        nearbyUsers.append(peer)
    }
    
    func peerLost(peer: MCPeerID) {
        for (index, aPeer) in nearbyUsers.enumerated() {
            if aPeer == peer {
                nearbyUsers.remove(at: index)
                break
            }
        }
    }
    
    func setVisible()
    {
        self.serviceAdvertiser.startAdvertisingPeer()
    }
    func setInvisible()
    {
        self.serviceAdvertiser.stopAdvertisingPeer()
    }
    
    func countNearbyUsers() -> Int {
        return nearbyUsers.count
    }
    
    func getNearbyPeer(index: Int) -> String {
        return nearbyUsers[index].displayName
    }
    
}

extension MultipeerNetworkManager : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping ((Bool, MCSession?) -> Void)) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
    }
}

extension MultipeerNetworkManager : MCNearbyServiceBrowserDelegate {
    @available(iOS 7.0, *)
    public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        
        // Add found users to the list
        peerFound(peer: peerID)
        delegate?.foundPeer()
    }

    
    func browser(_: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(_: MCNearbyServiceBrowser, lostPeer: MCPeerID) {
        NSLog("%@", "lostPeer: \(lostPeer)")
        
        // Remove user from list
        peerLost(peer: lostPeer)
        delegate?.lostPeer()
    }
    
}

extension MCSessionState {
    
    func stringValue() -> String {
        switch(self) {
        case .notConnected: return "NotConnected"
        case .connecting: return "Connecting"
        case .connected: return "Connected"
        }
    }
    
}

extension MultipeerNetworkManager : MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.stringValue())")
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
}
/*
 *
 *
 *
 *
 *
 *
 *
 *
 *
 */
