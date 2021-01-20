//
//  GameKitHelper.swift
//  Lines
//
//  Created by Mihai Costea on 24/09/14.
//  Copyright (c) 2014 mcostea. All rights reserved.
//

import UIKit
import GameKit

import os.log

@available(iOS 10.0, *)
let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "gamekit")

let PresentAuthenticationViewControllerNotification = "PresentAuthenticationViewControllerNotification"

private let _sharedGameKitHelper = GameKitHelper()

class GameKitHelper: NSObject {
    var authenticationViewController: UIViewController! {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: PresentAuthenticationViewControllerNotification), object: nil)
        }
    }
    var lastError: NSError! {
        willSet {
            os_log("error = %@", type: .error, newValue)
        }
    }
    
    private var leaderboard: String?
    
    private var enableGameCenter: Bool
    
    class var sharedGameKitHelper: GameKitHelper {
        return _sharedGameKitHelper
    }
    
    override init() {
        self.enableGameCenter = true
    }
    
    func authenticateLocalPlayer() {
        let localPlayer = GKLocalPlayer.local
        
        localPlayer.authenticateHandler = {(viewController, error) in
            if error != nil {
                self.lastError = error as NSError?
                return
            }
            
            if viewController != nil {
                self.authenticationViewController = viewController
            }
            
            self.enableGameCenter = GKLocalPlayer.local.isAuthenticated
            
            GKLocalPlayer.local.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardID, error) -> Void in
                if error != nil {
                    self.lastError = error as NSError?
                }
                
                self.leaderboard = leaderboardID
            })
        }
    }
    
    func reportScore(value: Int64) {
        if self.leaderboard != nil {
            let score = GKScore(leaderboardIdentifier: self.leaderboard!)
            score.value = value
            
            GKScore.report([score], withCompletionHandler: { (error) -> Void in
                if error != nil {
                    self.lastError = error as NSError?
                }
            })
        }
    }
   
}
