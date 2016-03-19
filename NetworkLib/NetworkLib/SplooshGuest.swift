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

public class SplooshGuest: SplooshCommon {
    static let defaultTimeout: NSTimeInterval = 30
    weak var delegate: SplooshGuestDelegate?
    
    private var serviceBrowser: MCNearbyServiceBrowser?
    private var hostsFound = [MCPeerID]()
    
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
}

extension SplooshGuest: MCNearbyServiceBrowserDelegate {
    // Peer is found in browser
    public func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String : String]?) {
            NSLog("%@", "foundPeer: \(peerID)")
            
            guard let discoveryInfo = info else {
                return
            }
            guard discoveryInfo["peerType"] == "host" else {
                return
            }
            
            NSLog("%@", "invitePeer: \(peerID)")
            hostsFound.append(peerID)
            delegate?.hostsFoundChanged(hostsFound)
    }
    
    // Peer is lost in browser
    public func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")

        guard hostsFound.contains(peerID) else {
            return
        }
        
        let index = hostsFound.indexOf(peerID)!
        hostsFound.removeAtIndex(index)
        delegate?.hostsFoundChanged(hostsFound)
    }
}

// MARK: MCSessionDelegate methods override
extension SplooshGuest {
    // Handles MCSessionState changes: NotConnected, Connecting and Connected.
    public override func session(session: MCSession, peer peerID: MCPeerID,
        didChangeState state: MCSessionState) {
            NSLog("%@", "peer \(peerID) didChangeState: \(state.stringValue())")
            if state != .Connecting {
                if state == .Connected {
                    serviceBrowser?.stopBrowsingForPeers()
                    delegate?.connectedToHost(peerID)
                } else {
                    serviceBrowser?.startBrowsingForPeers()
                }
                delegate?.connectionsChanged(session.connectedPeers)
            }
    }
    
    // Handles incomming NSData
    public override func session(session: MCSession, didReceiveData data: NSData,
        fromPeer peerID: MCPeerID) {
            NSLog("%@", "Data received: \(data)")
            delegate?.handleDataPacket(data, peerID: peerID)
    }
}