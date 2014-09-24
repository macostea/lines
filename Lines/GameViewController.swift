//
//  GameViewController.swift
//  Lines
//
//  Created by Mihai Costea on 22/09/14.
//  Copyright (c) 2014 mcostea. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController, GameDelegate {
    var scene: GameScene!
    var game: Game!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.subscribeToNotifications()
        GameKitHelper.sharedGameKitHelper.authenticateLocalPlayer()
            
        // Configure the view.
        let skView = self.view as SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.multipleTouchEnabled = false
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        self.scene = GameScene(size: skView.bounds.size)

        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill
        
        
        skView.presentScene(scene)
        
        self.game = Game()
        self.game.delegate = self
        self.scene.game = self.game
        self.scene.addTiles()
        
        self.beginGame()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.unsubscribeFromNotifications()
    }
    
    // MARK: - Notifications
    
    private func subscribeToNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("showAuthenticationViewController:"), name: PresentAuthenticationViewControllerNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("applicationDidEnterBackground:"), name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("applicationWillTerminate:"), name: UIApplicationWillTerminateNotification, object: nil)
    }
    
    private func unsubscribeFromNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: PresentAuthenticationViewControllerNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillTerminateNotification, object: nil)
    }
    
    func showAuthenticationViewController(notification: NSNotification) {
        self.presentViewController(GameKitHelper.sharedGameKitHelper.authenticationViewController, animated: true, completion: nil)
    }
    
    func applicationDidEnterBackground(notification: NSNotification) {
        GameKitHelper.sharedGameKitHelper.reportScore(Int64(self.game.score))
    }
    
    func applicationWillTerminate(notification: NSNotification) {
        GameKitHelper.sharedGameKitHelper.reportScore(Int64(self.game.score))
    }
    
    // MARK: - Private methods
    
    private func beginGame() {
        let newBoxes = self.game.createInitialBoxes()
        self.scene.addSpritesForBoxes(newBoxes)
    }
    
    // MARK: - Overridden

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.Portrait.toRaw())
        } else {
            return Int(UIInterfaceOrientationMask.Portrait.toRaw())
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - GameDelegate
    
    func game(game: Game, didUpdateScore score: Int) {
        self.scene.updateScore(score)
    }
}
