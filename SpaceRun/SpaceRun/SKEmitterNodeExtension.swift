//
//  SKEmitterNodeExtension.swift
//  SpaceRun
//
//  Created by Matthew Rude on 5/3/18.
//  Copyright © 2018 CVTC_mrude. All rights reserved.
//

import SpriteKit

extension String {
    var length: Int {
        return self.count
    }
}

extension SKEmitterNode {
    
    class func nodeWithFile(_ filename: String) -> SKEmitterNode? {
        
        let basename = (filename as NSString).deletingPathExtension
        var fileExt = (filename as NSString).pathExtension
        
        if fileExt.length == 0 {
            fileExt = "sks"
        }
        
        if let path = Bundle.main.path(forResource: basename, ofType: fileExt) {
            let node = NSKeyedUnarchiver.unarchiveObject(withFile: path) as! SKEmitterNode
            return node
        }
        
        return nil
    }
    
    func dieOutInDuration(duration: TimeInterval) {
        // Get the first wait time
        let firstWait = SKAction.wait(forDuration: duration)
        
        // Set the birthtate to zero in order to make the particle disappear using the SKAction code block
        let stop = SKAction.run ({
            // Prevent memory leaks
            [weak self] in
            
            if let weakSelf = self {
                weakSelf.particleBirthRate = 0
            }
            
        })
        
        // Get the second wait time
        let secondWait = SKAction.wait(forDuration: TimeInterval(self.particleLifetime))
        
        // Set up the removal from the parent
        let remove = SKAction.removeFromParent()
        
        let dieOut = SKAction.sequence([firstWait, stop, secondWait, remove])
        
        run(dieOut)
    }
}
