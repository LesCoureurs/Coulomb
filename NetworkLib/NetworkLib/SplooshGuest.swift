//
//  SplooshGuest.swift
//  NetworkLib
//
//  Created by Ian Ngiaw on 3/17/16.
//  Copyright © 2016 nus.cs3217.group5. All rights reserved.
//

import MultipeerConnectivity

public protocol SplooshGuestDelegate: class {
    func hostsFoundChanged(hosts: [MCPeerID])
    
    func connectedToHost(host: MCPeerID)
    
    func connectionsChanged(peers: [MCPeerID])
    
    func handleDataPacket(data: NSData, peerID: MCPeerID)
}

public class SplooshGuest: NSObject {
    static let defaultTimeout: NSTimeInterval = 30
    let serviceType: String
    let myPeerId: MCPeerID
    
    weak var delegate: SplooshGuestDelegate?
    
    private var serviceBrowser: MCNearbyServiceBrowser?
    private var hostsFound = [MCPeerID]()
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
    
    public func startSearchingForHosts() {
        if serviceBrowser == nil {
            serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
            serviceBrowser?.delegate = self
        }
        hostsFound = []
        serviceBrowser?.startBrowsingForPeers()
    }
    
    public func stopSearchingForHosts() {
        guard let browser = serviceBrowser else {
            return
        }
        browser.stopBrowsingForPeers()
        hostsFound = []
    }
    
    public func connectToHost(host: MCPeerID, context: NSData? = nil, timeout: NSTimeInterval = defaultTimeout) {
        guard hostsFound.contains(host) else {
            return
        }
        
        guard let browser = serviceBrowser else {
            return
        }
        
        browser.invitePeer(host, toSession: session, withContext: context, timeout: timeout)
    }
    
    public func getFoundHosts() -> [MCPeerID] {
        return hostsFound
    }
    
    public func getFoundHostAtTableRow(rowNum: Int) -> MCPeerID? {
        return hostsFound[rowNum]
    }
    
    // MARK: Sending data to other peers in the session
    
    public func sendData(data: NSData, mode: MCSessionSendDataMode) -> Bool {
        do {
            try session.sendData(data, toPeers: session.connectedPeers, withMode: mode)
        } catch {
            return false
        }
        
        return true
    }
}

extension SplooshGuest: MCNearbyServiceBrowserDelegate {
    // Peer is found in browser
    public func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String : String]?) {
        
            guard let discoveryInfo = info else {
                return
            }
            guard discoveryInfo["peerType"] == "host" else {
                return
            }
            
            hostsFound.append(peerID)
            delegate?.hostsFoundChanged(hostsFound)
    }
    
    // Peer is lost in browser
    public func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        guard hostsFound.contains(peerID) else {
            return
        }
        
        let index = hostsFound.indexOf(peerID)!
        hostsFound.removeAtIndex(index)
        delegate?.hostsFoundChanged(hostsFound)
    }
}

extension SplooshGuest: MCSessionDelegate {
    // Handles MCSessionState changes: NotConnected, Connecting and Connected.
    public func session(session: MCSession, peer peerID: MCPeerID,
        didChangeState state: MCSessionState) {
            if state != .Connecting {
                if state == .Connected {
                    serviceBrowser?.stopBrowsingForPeers()
                    delegate?.connectedToHost(peerID)
                }
                delegate?.connectionsChanged(session.connectedPeers)
            }
    }
    
    // Handles incomming NSData
    public func session(session: MCSession, didReceiveData data: NSData,
        fromPeer peerID: MCPeerID) {
            delegate?.handleDataPacket(data, peerID: peerID)
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