//
//  SplooshCommon.swift
//  NetworkLib
//
//  Created by Hieu Giang on 18/3/16.
//  Copyright © 2016 nus.cs3217.group5. All rights reserved.
//

import MultipeerConnectivity

public class SplooshCommon: NSObject {
    let serviceType: String
    let myPeerId: MCPeerID
    
    internal lazy var session: MCSession = {
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
    
    // MARK: Sending data to other peers in the session
    // This method is async
    public func sendData(data: NSData, mode: MCSessionSendDataMode) -> Bool {
        do {
            NSLog("%@", "send data to host: \(data)")
            try session.sendData(data, toPeers: session.connectedPeers, withMode: mode)
        } catch {
            NSLog("%@", "send data failed: \(data)")
            return false
        }
        
        return true
    }
}

extension SplooshCommon: MCSessionDelegate {
    // Handles MCSessionState changes: NotConnected, Connecting and Connected.
    public func session(session: MCSession, peer peerID: MCPeerID,
        didChangeState state: MCSessionState) {
            
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

extension MCSessionState {
    func stringValue() -> String {
        switch(self) {
        case .NotConnected: return "NotConnected"
        case .Connecting: return "Connecting"
        case .Connected: return "Connected"
        }
    }    
}
