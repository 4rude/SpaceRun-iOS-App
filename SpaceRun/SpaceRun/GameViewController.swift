//
//  GameViewController.swift
//  SpaceRun
//
//  Created by Matthew Rude on 4/26/18.
//  Copyright © 2018 CVTC_mrude. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    // Global Variable
    var easyMode: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
            // Configure the view
        let skView = self.view as! SKView
  
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        let blackScene = SKScene(size: skView.bounds.size)
        blackScene.backgroundColor = SKColor.black
        skView.presentScene(blackScene)
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let skView = self.view as! SKView
        
        let openingScene = OpeningScene(size: skView.bounds.size)
        openingScene.scaleMode = .aspectFill
        let transition = SKTransition.fade(withDuration: 1.0)
        skView.presentScene(openingScene, transition: transition)
        
        openingScene.sceneEndCallback = { [weak self] in
            if let weakSelf = self {
                let scene = GameScene(size: skView.bounds.size)
                
                scene.scaleMode = .aspectFill
                
                scene.easyMode = weakSelf.easyMode
                
                scene.endGameCallback = {[weak self] in
                    if let ws = self {
                        // Push presentation
                        ws.navigationController?.popToRootViewController(animated: true)
                        
                        // Modal presentation
                        //ws.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
                skView.presentScene(scene)
            }
        }
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
