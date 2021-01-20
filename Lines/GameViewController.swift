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
    var tutorial: TutorialScene!
    var game: Game!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.subscribeToNotifications()
//        GameKitHelper.sharedGameKitHelper.authenticateLocalPlayer()
            
        // Configure the view.
        let skView = self.view as! SKView
        skView.isMultipleTouchEnabled = false
        skView.backgroundColor = UIColor.linesWhiteColor()
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
//        self.scene = TutorialScene(size: skView.bounds.size)
        self.scene = GameScene(size: skView.bounds.size)

        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .aspectFill
        scene.backgroundColor = SKColor.linesWhiteColor()
        
        skView.presentScene(scene)
        
        self.game = Game()
        self.game.delegate = self
        self.scene.game = self.game
        self.scene.addTiles()
        
        self.beginGame()
//        self.startTutorial()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.unsubscribeFromNotifications()
    }
    
    // MARK: - Notifications
    
    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: Selector(("showAuthenticationViewController:")), name: NSNotification.Name(rawValue: PresentAuthenticationViewControllerNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UIApplicationDelegate.applicationDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UIApplicationDelegate.applicationWillTerminate(_:)), name: UIApplication.willTerminateNotification, object: nil)
    }
    
    private func unsubscribeFromNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: PresentAuthenticationViewControllerNotification), object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willTerminateNotification, object: nil)
    }
    
    func showAuthenticationViewController(notification: NSNotification) {
        self.present(GameKitHelper.sharedGameKitHelper.authenticationViewController, animated: true, completion: nil)
    }
    
    func applicationDidEnterBackground(notification: NSNotification) {
        GameKitHelper.sharedGameKitHelper.reportScore(value: Int64(self.game.score))
    }
    
    func applicationWillTerminate(notification: NSNotification) {
        GameKitHelper.sharedGameKitHelper.reportScore(value: Int64(self.game.score))
    }
    
    // MARK: - Private methods
    
    private func beginGame() {
        let newBoxes = self.game.createInitialBoxes()
        self.scene.addSpritesForBoxes(boxes: newBoxes)
    }
    
    private func startTutorial() {
        let newBoxes = self.game.createTutorialBoxes()
        self.scene.addSpritesForBoxes(boxes: newBoxes)
    }
    
    // MARK: - Overridden

//    override func shouldAutorotate() -> Bool {
//        return true
//    }
//
//    override func supportedInterfaceOrientations() -> Int {
//        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
//            return Int(UIInterfaceOrientationMask.Portrait.toRaw())
//        } else {
//            return Int(UIInterfaceOrientationMask.Portrait.toRaw())
//        }
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Release any cached data, images, etc that aren't in use.
//    }
//
//    override func prefersStatusBarHidden() -> Bool {
//        return true
//    }
    
    // MARK: - GameDelegate
    
    func game(game: Game, didUpdateScore score: Int) {
        self.scene.updateScore(score: score)
    }
    
    func game(game: Game, didUpdateMultiplier multiplier: Int) {
//        self.scene.updateScore(score)
    }
    
    func game(game: Game, didUpdateLevel level: Int) {
        
    }
    
    func gameDidFinish(game: Game) {
        
    }
}
