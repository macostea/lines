//
//  GameKitHelper.swift
//  Lines
//
//  Created by Mihai Costea on 24/09/14.
//  Copyright (c) 2014 mcostea. All rights reserved.
//

import UIKit
import GameKit

let PresentAuthenticationViewControllerNotification = "PresentAuthenticationViewControllerNotification"

private let _sharedGameKitHelper = GameKitHelper()

class GameKitHelper: NSObject {
    var authenticationViewController: UIViewController! {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName(PresentAuthenticationViewControllerNotification, object: nil)
        }
    }
    var lastError: NSError! {
        willSet {
            println(newValue)
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
        let localPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(viewController, error) in
            if error != nil {
                self.lastError = error
                return
            }
            
            if viewController != nil {
                self.authenticationViewController = viewController
            }
            
            self.enableGameCenter = GKLocalPlayer.localPlayer().authenticated
            
            GKLocalPlayer.localPlayer().loadDefaultLeaderboardIdentifierWithCompletionHandler({ (leaderboardID, error) -> Void in
                if error != nil {
                    self.lastError = error
                }
                
                self.leaderboard = leaderboardID
            })
        }
    }
    
    func reportScore(value: Int64) {
        if let leaderboard = self.leaderboard {
            let score = GKScore(leaderboardIdentifier: self.leaderboard)
            score.value = value
            
            GKScore.reportScores([score], withCompletionHandler: { (error) -> Void in
                if error != nil {
                    self.lastError = error
                }
            })
        }
    }
   
}
