//
//  Sploosh.swift
//  NetworkLib
//
//  Created by Ian Ngiaw on 3/14/16.
//  Copyright © 2016 nus.cs3217.group5. All rights reserved.
//

import MultipeerConnectivity
import UIKit

public protocol SplooshSearchDelegate: class {
    func foundPeersChanged(foundPeers: [String])
    
    func invitationReceived(peer: String, handleInvitation: (Bool) -> Void)
    
    func connectedPeersChanged(peers: [String])
}

public class SplooshSearch: NSObject {
    private var serviceAdvertiser: MCNearbyServiceAdvertiser?
    private var serviceBrowser: MCNearbyServiceBrowser?
    private var isSearching = false
    private var foundPeers = [String]()
    
    public weak var delegate: SplooshSearchDelegate?
    
    private lazy var session: MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil,
            encryptionPreference: .Required)
        session.delegate = self
        return session
    }()
    
    private let myPeerId: MCPeerID
    private let serviceType: String
    
    public init(serviceType: String, deviceId: String) {
        self.serviceType = serviceType
        myPeerId = MCPeerID(displayName: deviceId)
    }
    
    public convenience init(serviceType: String) {
        let myDeviceId = UIDevice.currentDevice().name
        self.init(serviceType: serviceType, deviceId: myDeviceId)
    }
    
    deinit {
        stopPeerSearch()
    }
    
    public func startPeerSearch() {
        isSearching = true
        if let advertiser = serviceAdvertiser {
            advertiser.startAdvertisingPeer()
        } else {
            serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId,
                discoveryInfo: nil, serviceType: serviceType)
            serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
            
            serviceAdvertiser?.delegate = self
            serviceBrowser?.delegate = self
            
            serviceAdvertiser?.startAdvertisingPeer()
            serviceBrowser?.startBrowsingForPeers()
        }
    }
    
    public func cancelPeerSearch() {
        stopPeerSearch()
        session.disconnect()
    }
    
    public func finishPeerSearch() -> MCSession? {
        stopPeerSearch()
        return session
    }
    
    public func stopPeerSearch() {
        if let advertiser = serviceAdvertiser {
            advertiser.stopAdvertisingPeer()
        }
        if let browser = serviceBrowser {
            browser.stopBrowsingForPeers()
        }
        isSearching = false
    }
    
    public func connectToPeer(peer: String) {
        let peerId = MCPeerID(displayName: peer)
        serviceBrowser?.invitePeer(peerId, toSession: session, withContext: nil, timeout: 30)
    }
}

extension SplooshSearch: MCNearbyServiceAdvertiserDelegate {
    // Invitation is received from peer
    public func advertiser(advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
            
            delegate?.invitationReceived(peerID.displayName) {
                (approved) in
                invitationHandler(approved, self.session)
            }
    }
}

extension SplooshSearch: MCNearbyServiceBrowserDelegate {
    // Peer is found in browser
    public func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String : String]?) {
            foundPeers.append(peerID.displayName)
            delegate?.foundPeersChanged(foundPeers)
    }
    
    // Peer is lost in browser
    public func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        if let index = foundPeers.indexOf(peerID.displayName) {
            foundPeers.removeAtIndex(index)
            delegate?.foundPeersChanged(foundPeers)
        }
    }
}

extension SplooshSearch: MCSessionDelegate {
    // Handles MCSessionState changes: NotConnected, Connecting and Connected.
    public func session(session: MCSession, peer peerID: MCPeerID,
        didChangeState state: MCSessionState) {
            delegate?.connectedPeersChanged(session.connectedPeers.map{$0.displayName})
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