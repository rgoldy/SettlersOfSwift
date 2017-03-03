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
    func invitationWasReceived(fromPeer: MCPeerID)
    func connectedWithPeer(peerID: MCPeerID)
    func lostConnectionWith(peerID: MCPeerID)
    func recievedData(data: String)
}

class NetworkConnection : NSObject {
    
    // Identifies who is using the game
    private var myServiceType = "settlersofswift"
    
    public var isHost: Bool
    
    // List of all users you can see
    var nearbyUsers = [MCPeerID]()
    var delegate: NetworkDelegate?
    
    private var myPeerId : MCPeerID!
    var serviceAdvertiser : MCNearbyServiceAdvertiser!
    var advertiser : MCAdvertiserAssistant!
    var serviceBrowser : MCNearbyServiceBrowser!
    var invitationHandler: ((Bool, MCSession?)->Void)!
    var session : MCSession!
    
    init(username: String) {
        isHost = true
        super.init()
        
        self.myPeerId = MCPeerID(displayName: username)
        
        self.session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: MCEncryptionPreference.optional)
        
        self.session.delegate = self
        
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: self.myPeerId, discoveryInfo: nil, serviceType: myServiceType)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: self.myPeerId, serviceType: myServiceType)
        
        //self.advertiser = MCAdvertiserAssistant(serviceType: myServiceType, discoveryInfo: nil, session: self.session)
        
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
    
    // SET SELF TO BE DISCOVERABLE BY OTHERS
    func setVisible()
    {
        self.serviceAdvertiser.startAdvertisingPeer()
    }
    // SET SELF TO BE INVISIBLE TO OTHERS
    func setInvisible()
    {
        self.serviceAdvertiser.stopAdvertisingPeer()
    }
    
    // START LOOKING FOR OTHERS
    func startBrowsing()
    {
        self.serviceBrowser.startBrowsingForPeers()
    }
    // STOP LOOKING FOR OTHERS
    func stopBrowsing()
    {
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    // DISCONNECT FROM THE SESSION
    func disconnect() {
        self.session.disconnect()
    }
    
    // When an invitation is recieved
    func advertiser(advertiser: MCNearbyServiceAdvertiser!, didReceiveInvitationFromPeer peerID: MCPeerID!, withContext context: NSData!, invitationHandler: ((Bool, MCSession?) -> Void)!) {
        print("INVITE FROM \(peerID.displayName)")
        
        self.invitationHandler = invitationHandler
        delegate?.invitationWasReceived(fromPeer: peerID)
    }
    
    func getName() -> String
    {
        return myPeerId.displayName
    }
    
    func sendData(data: String) -> Bool
    {
        do {
            let c_data = data.data(using: .utf8, allowLossyConversion: false)
            if (c_data == nil) {
                print("DATA UNINITIALIZED")
                return false
            }
            
            try self.session.send(c_data! as Data, toPeers: self.session.connectedPeers, with: MCSessionSendDataMode.reliable)
        }
        catch {
            return false
        }
        return true
    }
    
    func sendDataTo(data: String, player: MCPeerID) -> Bool
    {
        do {
            let c_data = data.data(using: .utf8, allowLossyConversion: false)
            if (c_data == nil) {
                print("DATA UNINITIALIZED")
                return false
            }
            
            try self.session.send(c_data! as Data, toPeers: [player], with: MCSessionSendDataMode.reliable)
        }
        catch {
            return false
        }
        return true

    }

}

extension NetworkConnection : MCNearbyServiceAdvertiserDelegate {
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping ((Bool, MCSession?) -> Void)) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        
        print("Invite from \(peerID.displayName)");
        self.invitationHandler = invitationHandler
        delegate?.invitationWasReceived(fromPeer: peerID)
    }
}

extension NetworkConnection : MCNearbyServiceBrowserDelegate {
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

extension NetworkConnection : MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state.stringValue())")
        switch state{
        case MCSessionState.connected:
            print("Connected to session: \(session)")
            NSLog("%@", "CONNECTED WITH \(peerID.displayName)")
            delegate?.connectedWithPeer(peerID: peerID)
            
        case MCSessionState.connecting:
            print("Connecting to session: \(session)")
            
        default:
            print("Did not connect to session: \(session)")
            delegate?.lostConnectionWith(peerID: peerID);
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveData: \(data)")
        let datastring = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        delegate?.recievedData(data: datastring as! String)
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
    
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void)
    {
        certificateHandler(true)
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
