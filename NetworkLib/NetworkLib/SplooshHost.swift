//
//  SplooshHost.swift
//  NetworkLib
//
//  Created by Ian Ngiaw on 3/17/16.
//  Copyright © 2016 nus.cs3217.group5. All rights reserved.
//

import UIKit
import MultipeerConnectivity

public protocol SplooshHostDelegate: class {
    func connectedGuestsChanged(guests: [MCPeerID])
    
    func guestRequestingJoin(guest: MCPeerID, acceptGuest: (Bool) -> Void)
}

public class SplooshHost: NSObject {
    let serviceType: String
    let myPeerId: MCPeerID
    
    var autoAcceptGuests = true
    weak var delegate: SplooshHostDelegate?
    
    private var serviceAdvertiser: MCNearbyServiceAdvertiser?
    private lazy var session: MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil,
            encryptionPreference: .Required)
        session.delegate = self
        return session
    }()
    
    public init(serviceType: String, peerId: String) {
        self.serviceType = serviceType
        myPeerId = MCPeerID(displayName: peerId)
    }
    
    public convenience init(serviceType: String) {
        let myDeviceId = UIDevice.currentDevice().name
        self.init(serviceType: serviceType, peerId: myDeviceId)
    }
    
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

extension SplooshHost: MCSessionDelegate {
    // Handles MCSessionState changes: NotConnected, Connecting and Connected.
    public func session(session: MCSession, peer peerID: MCPeerID,
        didChangeState state: MCSessionState) {
            delegate?.connectedGuestsChanged(session.connectedPeers)
    }
    
    // Handles incomming NSData
    public func session(session: MCSession, didReceiveData data: NSData,
        fromPeer peerID: MCPeerID) {
            
    }
    
    // Handles incoming NSInputStream
    public func session(session: MCSession, didReceiveStream stream: NSInputStream,
        withName streamName: String, fromPeer peerID: MCPeerID) {
            
    }
    
    // Handles finish receiving resource
    public func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
            
    }
    
    // Handles start receiving resource
    public func session(session: MCSession, didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
            
    }
}