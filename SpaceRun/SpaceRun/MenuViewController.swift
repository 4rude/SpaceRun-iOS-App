//
//  MenuViewController.swift
//  SpaceRun
//
//  Created by Matthew Rude on 5/3/18.
//  Copyright © 2018 CVTC_mrude. All rights reserved.
//

import UIKit
import SpriteKit

class MenuViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var difficultyChooser: UISegmentedControl!
    @IBOutlet weak var highScoreLabel: UILabel!
    
    private var demoView: SKView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        demoView = SKView(frame: self.view.bounds)
        let scene = SKScene(size: self.view.bounds.size)
        
        scene.backgroundColor = SKColor.black
        scene.scaleMode = SKSceneScaleMode.aspectFill
        
        scene.addChild(StarField())
        
        if let demoView = demoView {
            demoView.presentScene(scene)
            view.insertSubview(demoView, at: 0)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let demoView = self.demoView {
            demoView.removeFromSuperview()
            self.demoView = nil
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "PlayGame") {
            let gameController = segue.destination as! GameViewController
            gameController.easyMode = self.difficultyChooser.selectedSegmentIndex == 0
        } else {
            assert(false, "Unknown segue identifier \(segue.identifier)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let scoreFormatter = NumberFormatter()
        scoreFormatter.numberStyle = .decimal
        
        let defaults = UserDefaults.standard
        defaults.register(defaults: ["highScore":0])
        let score = defaults.integer(forKey: "highScore")
        let scoreText = "High Score: \(scoreFormatter.string(from: NSNumber(value: score))!)"
        self.highScoreLabel.text = scoreText
    }
    
}
