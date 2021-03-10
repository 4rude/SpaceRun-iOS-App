//
//  StarField.swift
//  SpaceRun
//
//  Created by Matthew Rude on 5/3/18.
//  Copyright © 2018 CVTC_mrude. All rights reserved.
//

import SpriteKit

class StarField: SKNode {

    override init() {
        super.init()
        initSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        initSetup()
    }
    
    func initSetup() {
        let update = SKAction.run ({
            [weak self] in
            
            if arc4random_uniform(10) < 3 {
                if let weakSelf = self {
                    weakSelf.launchStar()
                }
            }
        })
        
        let delay = SKAction.wait(forDuration: 0.01)
        let updateLoop = SKAction.sequence([delay, update])
        run(SKAction.repeatForever(updateLoop))
    }
    
    func launchStar() {
        
        // Set a reference to our scene
        if let scene = self.scene {
            
            // Calculate a random starting point for our stars at the top of the screen
            let randX = Double(arc4random_uniform(UInt32(scene.size.width)))
            let maxY = Double(scene.size.height)
            let randomStart = CGPoint(x: randX, y: maxY)
            
            let star = SKSpriteNode(imageNamed: "shootingstar")
            star.position = randomStart
            
            // Randomly adjust the size of the star and its transparency
            star.size = CGSize(width: 2.0, height: 10.0)
            star.alpha = 0.1 + (CGFloat(arc4random_uniform(10)) / 10)
            addChild(star)
            
            // Move the star to the bottom of the screen and remove it from memory when it passes the bottom
            let destY = 0.0 - scene.size.height - star.size.height
            let duration = 0.1 + (Double(arc4random_uniform(10)) / 10.0)
            let move = SKAction.moveBy(x: 0.0, y: destY, duration: duration)
            let remove = SKAction.removeFromParent()
            star.run(SKAction.sequence([move, remove]))
        }
    }
}






















