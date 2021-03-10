//
//  HUDNode.swift
//  SpaceRun
//
//  Created by Matthew Rude on 5/10/18.
//  Copyright © 2018 CVTC_mrude. All rights reserved.
//

import SpriteKit

class HUDNode: SKNode {
    
    // MARK: - Constants
    private let ScoreGroupName = "scoreGroup"
    private let ScoreValueName = "scoreValue"
    private let ElapsedGroupName = "elapsedGroup"
    private let ElapsedValueName = "elapsedValue"
    private let TimerActionName = "elapsedGameTimer"
    
    private let PowerupGroupName = "powerupGroup"
    private let PowerupValueName = "powerupValue"
    private let PowerupTimerActionName = "showPowerupTimer"
    
    private let HealthGroupName = "healthGroup"
    private let HealthValueName = "healthValue"
    
    // MARK: - Variables
    var elapsedTime: TimeInterval = 0.0
    var score: Int = 0
    var health: CGFloat = 2.0
//    private var currentHealth: Int = 0
    
    lazy private var scoreFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    lazy private var timeFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }()
    
    lazy private var healthFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }()
    
    override init() {
        super.init()
        
        createScoreGroup()
        createElapsedGroup()
        createPowerupGroup()
        createHealthGroup()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Individual HUD Nodes
    
    func createScoreGroup() {
        
        let scoreGroup = SKNode()
        scoreGroup.name = ScoreGroupName
        
        // Score Title setup
        // Create an SKLabel node for our score title label
        let scoreTitle = SKLabelNode(fontNamed: "AvenirNext-Medium")
        scoreTitle.fontSize = 12.0
        scoreTitle.fontColor = SKColor.white
        
        // Set the verticle and horizontal alighment modes in a way to help us lay out the labels inside this group node
        scoreTitle.horizontalAlignmentMode = .left
        scoreTitle.verticalAlignmentMode = .bottom
        scoreTitle.text = "SCORE"
        scoreTitle.position = CGPoint(x: 0.0, y: 4.0)
        
        scoreGroup.addChild(scoreTitle)
        
        // New node setup
        let scoreValue = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreValue.fontSize = 20.0
        scoreValue.fontColor = SKColor.white
        
        scoreValue.horizontalAlignmentMode = .left
        scoreValue.verticalAlignmentMode = .top
        scoreValue.name = ScoreValueName
        scoreValue.text = "0"
        scoreValue.position = CGPoint(x: 0.0, y: -4.0)
        
        scoreGroup.addChild(scoreValue)
        
        addChild(scoreGroup)
        // End of score group
    }
    
    func createElapsedGroup() { 
        
        // Elapsed Group
        let elapsedGroup = SKNode()
        elapsedGroup.name = ElapsedGroupName
        
        // Score Title setup
        // Create an SKLabel node for our score title label
        let elapsedTitle = SKLabelNode(fontNamed: "AvenirNext-Medium")
        elapsedTitle.fontSize = 12.0
        elapsedTitle.fontColor = SKColor.white
        
        // Set the verticle and horizontal alighment modes in a way to help us lay out the labels inside this group node
        elapsedTitle.horizontalAlignmentMode = .right
        elapsedTitle.verticalAlignmentMode = .bottom
        elapsedTitle.text = ""
        elapsedTitle.position = CGPoint(x: 0.0, y: 4.0)
        
        elapsedGroup.addChild(elapsedTitle)
        
        // New node setup
        let elapsedValue = SKLabelNode(fontNamed: "AvenirNext-Bold")
        elapsedValue.fontSize = 20.0
        elapsedValue.fontColor = SKColor.white
        
        elapsedValue.horizontalAlignmentMode = .right
        elapsedValue.verticalAlignmentMode = .top
        elapsedValue.name = ElapsedValueName
        elapsedValue.text = ""
        elapsedValue.position = CGPoint(x: 0.0, y: -4.0)
        
        elapsedGroup.addChild(elapsedValue)
        
        addChild(elapsedGroup)
        
        // End of Elapsed group
    }
    
    func createPowerupGroup() {
        
        let powerupGroup = SKNode()
        powerupGroup.name = PowerupGroupName
        
        let powerupTitle = SKLabelNode(fontNamed: "AvenirNext-Bold")
        powerupTitle.fontSize = 14.0
        powerupTitle.fontColor = SKColor.red
        
        powerupTitle.verticalAlignmentMode = .bottom
        powerupTitle.text = "Power-up!"
        powerupTitle.position = CGPoint(x: 0.0, y: 4.0)
        
        // Actions to make our Powerup Timer pulse
        let scaleUp = SKAction.scale(to: 1.3, duration: 0.3)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.3)
        
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        
        let pulseForever = SKAction.repeatForever(pulse)
        
        powerupTitle.run(pulseForever)
        
        powerupGroup.addChild(powerupTitle)
        
        let powerupValue = SKLabelNode(fontNamed: "AvenirNext-Bold")
        powerupValue.fontSize = 20.0
        powerupValue.fontColor = SKColor.red
        
        powerupValue.verticalAlignmentMode = .top
        powerupValue.name = PowerupValueName
        powerupValue.text = "0s left"
        powerupValue.position = CGPoint(x: 0.0, y: -4.0)
        
        powerupGroup.addChild(powerupValue)
        
        addChild(powerupGroup)
        
        powerupGroup.alpha = 0.0
        
        
    }
    
    // Health powerup func
    func createHealthGroup() {
        
        let healthGroup = SKNode()
        healthGroup.name = HealthGroupName
        
        // Score Title setup
        // Create an SKLabel node for our health title label
        let healthTitle = SKLabelNode(fontNamed: "AvenirNext-Medium")
        healthTitle.fontSize = 12.0
        healthTitle.fontColor = SKColor.white
        
        // Set the verticle and horizontal alighment modes in a way to help us lay out the labels inside this group node
        healthTitle.horizontalAlignmentMode = .right
        healthTitle.verticalAlignmentMode = .bottom
        healthTitle.text = "LIVES"
        healthTitle.position = CGPoint(x: 0.0, y: 4.0)
        
        healthGroup.addChild(healthTitle)
        
        
        // New node setup
        let healthValue = SKLabelNode(fontNamed: "AvenirNext-Bold")
        healthValue.fontSize = 20.0
        healthValue.fontColor = SKColor.white
        
        healthValue.horizontalAlignmentMode = .right
        healthValue.verticalAlignmentMode = .top
        healthValue.name = HealthValueName
        healthValue.text = "2.0" //
        healthValue.position = CGPoint(x: 0.0, y: -4.0)
        
        healthGroup.addChild(healthValue)
        
        addChild(healthGroup)
        
        // End of health group
        
    }
    
    func layoutForScene() {
        
        if let scene = scene {
            
            let sceneSize = scene.size
            // Used to calculate position of each group
            var groupSize = CGSize.zero
            
            if let scoreGroup = childNode(withName: ScoreGroupName) {
                
                groupSize = scoreGroup.calculateAccumulatedFrame().size
                scoreGroup.position = CGPoint(x: 0.0 - sceneSize.width/2.0 + 20.0,
                                              y: sceneSize.height/2.0 - groupSize.height)
                
                
            } else {
                assert(false, "No score group node was found")
            }
            
            // Powerup timer
            if let powerupGroup = childNode(withName: PowerupGroupName) {
                groupSize = powerupGroup.calculateAccumulatedFrame().size
                powerupGroup.position = CGPoint(x: 0.0, y: sceneSize.height/2.0 - groupSize.height)
                
            } else {
                assert(false, "No power-up group node was found.")
            }
            
            
            if let healthGroup = childNode(withName: HealthGroupName) {
                groupSize = healthGroup.calculateAccumulatedFrame().size
                healthGroup.position = CGPoint(x: sceneSize.width/2.0 - 20.0, y: sceneSize.height/2.0 - groupSize.height)
            } else {
                assert(false, "No health group node was found.")
            }
            
        } else {
            assert(false, "Cannot be called unless added to a scene")
            
        }
        
        
    }
    
    // MARK: - HUD Functions
    func addPoints(_ points: Int) {
        
        score += points
        
        if let scoreValue = childNode(withName: "\(ScoreGroupName)/\(ScoreValueName)") as! SKLabelNode? {
            scoreValue.text = scoreFormatter.string(from: NSNumber(value: score))
            
            let scale = SKAction.scale(to: 1.1, duration: 0.02)
            let shrink = SKAction.scale(to: 1.0, duration: 0.07)
            
            scoreValue.run(SKAction.sequence([scale, shrink]))
            
        }
        
    }
    
    func addHealth() {
        let health: Double = 4.0
        if let healthValue = childNode(withName: "\(HealthGroupName)/\(HealthValueName)") as! SKLabelNode? {
            
            healthValue.text = healthFormatter.string(from: NSNumber(value: health))
            
        }
    }
    
    // The amount parameter is vague because its an amount that is added or subtracted to the ships "life force"
    func subtractHealth(_ shipHealthRate: Double) {
        
        var health: Double = shipHealthRate
        health -= 1.0
        
        if let healthValue = childNode(withName: "\(HealthGroupName)/\(HealthValueName)") as! SKLabelNode? {
            
            healthValue.text = healthFormatter.string(from: NSNumber(value: health))
        }
    }
    
    func startGame() {
        
        // Calculate the timestamp when starting the game
        let startTime = NSDate.timeIntervalSinceReferenceDate
        
        // Changed this to a not equals nil if statement because XCode recommended it
        if (childNode(withName: "\(ElapsedGroupName)/\(ElapsedValueName)") as! SKLabelNode?) != nil {
            
            let update = SKAction.run({
                [weak self] in
                
                if let weakSelf = self {
                    
                    let now = NSDate.timeIntervalSinceReferenceDate
                    let elapsed = now - startTime
                    weakSelf.elapsedTime = elapsed
                    
                    // Sanity Check
                    print("HUD ELAPSED TIME-NEW: \(weakSelf.elapsedTime)")
                    
                    
                }
            })
            
            let delay = SKAction.wait(forDuration: 0.05)
            
            let updateAndDelay = SKAction.sequence([update, delay])
            
            let timer = SKAction.repeatForever(updateAndDelay)
            
            run(timer, withKey: TimerActionName)
        }
        
    }
    
    func endGame() {
        removeAction(forKey: TimerActionName)
        
        if let powerupGroup = childNode(withName: PowerupGroupName) {
            powerupGroup.removeAction(forKey: PowerupTimerActionName)
            
            let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 0.3)
            powerupGroup.run(fadeOut)
        }
        
    }
    
    func showPowerupTimer(_ time: TimeInterval) {
        if let powerupGroup = childNode(withName: PowerupGroupName) {
            powerupGroup.removeAction(forKey: PowerupTimerActionName)
            
            if let powerupValue = powerupGroup.childNode(withName: PowerupValueName) as! SKLabelNode? {
                
                let start = NSDate.timeIntervalSinceReferenceDate
                
                let block = SKAction.run({
                    [weak self] in
                    
                    if let weakSelf = self {
                        
                        let elapsed = NSDate.timeIntervalSinceReferenceDate - start
                        let timeLeft = max(time - elapsed, 0)
                        let timeLeftFormat = weakSelf.timeFormatter.string(from: NSNumber(value: timeLeft))!
                        
                        powerupValue.text = "\(timeLeftFormat)s left"
                    }
                })
                
                let blockPause = SKAction.wait(forDuration: 0.05)
                let countDownSequence = SKAction.sequence([block, blockPause])
                let countDown = SKAction.repeatForever(countDownSequence)
                
                let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
                let wait = SKAction.wait(forDuration: time)
                let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 1.0)
                
                let stopAction = SKAction.run({ () -> Void in
                    powerupGroup.removeAction(forKey: self.PowerupTimerActionName)
                })
                
                let visuals = SKAction.sequence([fadeIn, wait, fadeOut, stopAction])
                
                powerupGroup.run(SKAction.group([countDown, visuals]), withKey: self.PowerupTimerActionName)
            }
        }
    }
}









