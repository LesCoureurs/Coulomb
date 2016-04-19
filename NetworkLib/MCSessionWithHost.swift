//
//  MCSessionWithHost.swift
//  Coulomb
//
//  Created by Hieu Giang on 25/3/16.
//  Copyright © 2016 nus.cs3217.group5. All rights reserved.
//
// Used in version 0.0.6 and below
// Deprecated

import MultipeerConnectivity
class MCSessionWithHost: MCSession {
    var host: MCPeerID?
    // A set of all peers in the session.
    // We need this since session.connectedPeers only contains peers except self.
    // Useful for discovering disconnection.
    var peersInSession = Set<MCPeerID>()
}
