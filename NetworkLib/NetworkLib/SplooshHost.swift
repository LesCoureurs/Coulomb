//
//  SplooshHost.swift
//  NetworkLib
//
//  Created by Ian Ngiaw on 3/17/16.
//  Copyright © 2016 nus.cs3217.group5. All rights reserved.
//

import MultipeerConnectivity

public protocol SplooshHostDelegate: class {
    func connectedGuestsChanged(guests: [MCPeerID])
    
    func guestRequestingJoin(guest: MCPeerID, acceptGuest: (Bool) -> Void)
    
    func handleDataPacket(data: NSData, peerID: MCPeerID)
}

public class SplooshHost: SplooshCommon {
    var autoAcceptGuests = true
    weak var delegate: SplooshHostDelegate?
    
    private var serviceAdvertiser: MCNearbyServiceAdvertiser?
    
    public func startSearchingForGuests() {
        if serviceAdvertiser == nil {
            serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId,
                discoveryInfo: ["peerType": "host"], serviceType: serviceType)
            serviceAdvertiser?.delegate = self
        }
        serviceAdvertiser?.startAdvertisingPeer()
    }
    
    public func stopSearchingForGuests() {
        guard let advertiser = serviceAdvertiser else {
            return
        }
        advertiser.stopAdvertisingPeer()
    }
    
    public func getConnectedPeers() -> [MCPeerID] {
        return session.connectedPeers
    }
}

extension SplooshHost: MCNearbyServiceAdvertiserDelegate {
    // Invitation is received from peer
    public func advertiser(advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        
            let acceptGuest = {
                (accepted: Bool) -> Void in
                invitationHandler(accepted, self.session)
            }
            
            if autoAcceptGuests {
                acceptGuest(true)
            } else {
                delegate?.guestRequestingJoin(peerID, acceptGuest: acceptGuest)
            }
    }
}

// MARK: MCSessionDelegate methods override
extension SplooshHost {
    // Handles MCSessionState changes: NotConnected, Connecting and Connected.
    public override func session(session: MCSession, peer peerID: MCPeerID,
        didChangeState state: MCSessionState) {
            if state != .Connecting {
                delegate?.connectedGuestsChanged(session.connectedPeers)
            }
    }
    
    // Handles incomming NSData
    public override func session(session: MCSession, didReceiveData data: NSData,
        fromPeer peerID: MCPeerID) {
            delegate?.handleDataPacket(data, peerID: peerID)
    }
}