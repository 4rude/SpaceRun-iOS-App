//
//  GameScene.swift
//  SpaceRun
//
//  Created by Matthew Rude on 4/26/18.
//  Copyright © 2018 CVTC_mrude. All rights reserved.
//

import SpriteKit
import GameplayKit

var shipHealth: CGFloat = 2.0

class GameScene: SKScene {
    
    // MARK: - Constants
    private let SpaceshipNodeName = "ship"
    private let PhotonTorpedoNodeName = "photon"
    private let ObstacleNodeName = "obstacle"
    private let PowerupNodeName = "powerup"
    private let HealthPowerupNodeName = "healthpowerup"
    private let HUDNodeName = "hud"
    
    // MARK: - Variables
    private weak var shipTouch: UITouch?
    private var lastUpdateTime: TimeInterval = 0
    private var lastShotFireTime: TimeInterval = 0
    private var tapGesture: UITapGestureRecognizer?
    
    private var shipHealthRate: CGFloat = 2.0 
    
    typealias endGameCallbackType = () -> Void
    var endGameCallback: endGameCallbackType?
    
    var easyMode: Bool = true
    
    private let defaultFireRate: Double = 0.5
    private var shipFireRate: Double = 0.5
    private let powerUpDuration: TimeInterval = 5.0
    
    // MARK: - Sounds
    private let shootSound: SKAction = SKAction.playSoundFileNamed("laserShot.wav", waitForCompletion: true)
    private let obstacleExplodeSound: SKAction = SKAction.playSoundFileNamed("darkExplosion.wav", waitForCompletion: true)
    private let shipExplodeSound: SKAction = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: true)
    
    // MARK: - Explosions
    private let shipExplodeTemplate: SKEmitterNode = SKEmitterNode.nodeWithFile("shipExplode.sks")!
    private let obstacleExplodeTemplate: SKEmitterNode = SKEmitterNode.nodeWithFile("obstacleExplode.sks")!
    
    // MARK: - Initializers
    override init(size: CGSize) {
        super.init(size: size)
        setupGame(size)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Game Setup
    func setupGame(_ size: CGSize) {
        
        let ship = SKSpriteNode(imageNamed: "Spaceship.png")
        ship.position = CGPoint(x: size.width/2.0, y: size.height/2.0)
        ship.size = CGSize(width: 40.0, height: 40.0)
        ship.name = SpaceshipNodeName
        addChild(ship)
        
        // Add the thruster particle to our ship
        if let thrust = SKEmitterNode.nodeWithFile("thrust.sks") {
            thrust.position = CGPoint(x: 0.0, y: -20.0)
            
            // Add the thrust object as a child of our ship so the position is relative to the ship's position
            ship.addChild(thrust)
        }
        
        addChild(StarField())
        
        
        
        // Set up the HUD
        let hudNode = HUDNode()
        
        hudNode.name = HUDNodeName
        hudNode.zPosition = 100.0
        hudNode.position = CGPoint(x: size.width/2.0, y: size.height/2.0)
        
        addChild(hudNode)
        
        // Lay out our score and time labels
        hudNode.layoutForScene()
        
        // Start the game
        hudNode.startGame()
        
    }
    
    
    // MARK: - Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Called when a touch begins
        if let touch = touches.first {
            self.shipTouch = touch
            
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        // Calculate the time change since the last frame
        let timeDelta = currentTime - lastUpdateTime
        
        if let shipTouch = shipTouch {
            moveShipTowardPoint(shipTouch.location(in: self), timeDelta: timeDelta)
            
            if currentTime - lastShotFireTime > shipFireRate {
                shoot()
                
                // Reset the lastShoTFireTime to the currentTime
                lastShotFireTime = currentTime
            }
        }
        
        var thingProbability: UInt32 = 0
        
        if self.easyMode {
            thingProbability = 15
        } else {
            thingProbability = 30
        }
        
        if arc4random_uniform(1000) <= thingProbability {
            dropThing()
        }
        
        checkCollisions()
        
        
        lastUpdateTime = currentTime
    }
    
    func moveShipTowardPoint(_ point: CGPoint, timeDelta: TimeInterval) {
        
        // Points per second the ship should travel
        let shipSpeed = CGFloat(130)
        
        if let ship = self.childNode(withName: SpaceshipNodeName) {
            
            // Using the pythagorean theorem
            let distanceLeftToTravel = sqrt(pow(ship.position.x - point.x, 2) + pow(ship.position.y - point.y, 2))
            
            if distanceLeftToTravel > 4 {
                let distanceRemaining = CGFloat(timeDelta) * shipSpeed
                
                let angle = atan2(point.y - ship.position.y, point.x - ship.position.x)
                let xOffset = distanceRemaining * cos(angle)
                let yOffset = distanceRemaining * sin(angle)
                
                ship.position = CGPoint(x: ship.position.x + xOffset, y: ship.position.y + yOffset)
            }
        }
    }
    
    
    func shoot(){
        if let ship = self.childNode(withName: SpaceshipNodeName) {
            
            // Create our photon sprite node
            let photon = SKSpriteNode(imageNamed: PhotonTorpedoNodeName)
            photon.name = PhotonTorpedoNodeName
            
            // Position the photon torpedo at the same position as our ship
            photon.position = ship.position
            
            // Add photon to scene
            self.addChild(photon)
            
            let fly = SKAction.moveBy(x: 0, y: self.size.height + photon.size.height, duration: 0.5)
            let remove = SKAction.removeFromParent()
            
            let fireAndRemove = SKAction.sequence([fly, remove])
            
            photon.run(fireAndRemove)
            
            self.run(self.shootSound)
        }
    }
    
    // MARK: - Drop Functions
    func dropThing() {
        
        // Dice roll between 0 and 99
        let dice = arc4random_uniform(100)
        
        // Drop a health powerup 3% of the time, powerup 5% of the time, enemy ship 15% of the time and an asteroid 85% of the time
        if dice < 3 {
            dropHealth()
        } else if dice < 8 {
            dropPowerUp()
        } else if dice < 23 {
            dropEnemyShip()
        } else {
            dropAsteroid()
        }
    }
    
    func dropEnemyShip() {
        let sideSize = 30.0
        
        let startX = Double(arc4random_uniform(UInt32(self.size.width - 40)) + 20)
        let startY = Double(self.size.height) + sideSize
        
        let enemy = SKSpriteNode(imageNamed: "enemy")
        
        enemy.size = CGSize(width: sideSize, height: sideSize)
        enemy.position = CGPoint(x: startX, y: startY)
        enemy.name = ObstacleNodeName
        
        self.addChild(enemy)
        
        let shipPath = buildEnemyShipMovementPath()
        
        let followPath = SKAction.follow(shipPath, asOffset: true, orientToPath: true, duration: 7.0)
        
        let remove = SKAction.removeFromParent()
        
        let followPathAndRemove = SKAction.sequence([followPath, remove])
        
        enemy.run(followPathAndRemove)
    }
    
    func dropAsteroid() {
        
        // Asteroid movement variables
        let sideSize = Double(15 + arc4random_uniform(30))
        
        let maxX = Double(self.size.width)
        
        let quarterX = maxX / 4.0
        
        let startX = Double(arc4random_uniform(UInt32(maxX + (quarterX * 2)))) - quarterX
        
        let startY = Double(self.size.height) + sideSize
        
        let endX = Double(arc4random_uniform(UInt32(maxX)))
        
        let endY = 0.0 - sideSize
        
        // Create the asteroid sprite
        let asteroid = SKSpriteNode(imageNamed: "asteroid")
        asteroid.size = CGSize(width: sideSize, height: sideSize)
        asteroid.position = CGPoint(x: startX, y: startY)
        asteroid.name = ObstacleNodeName
        self.addChild(asteroid)
        
        // Run some actions to move our asteroid
        let move = SKAction.move(to: CGPoint(x: endX, y: endY), duration: Double(3 + arc4random_uniform(4)))
        let remove = SKAction.removeFromParent()
        let travelAndRemove = SKAction.sequence([move, remove])
        
        let spin = SKAction.rotate(byAngle: 3.0, duration: Double(arc4random_uniform(2) + 1))
        let spinForever = SKAction.repeatForever(spin)
        
        let all = SKAction.group([spinForever, travelAndRemove])
        
        asteroid.run(all)
    }
    
    // Create a power up sprite spinning and moving from top to bottom across the screen. We are using the enemy path curve drop.
    func dropPowerUp() {
        // Define the size of the sides of the enemy ship
        let sideSize = 30.0
        
        // Determine starting x and y position values
        let startX = Double(arc4random_uniform(UInt32(self.size.width - 60)) + 30)
        let startY = Double(self.size.height) + sideSize
        let endY = 0 - sideSize
        
        // Create and consider the enemy ship, it is another obstacle node
        let powerUp = SKSpriteNode(imageNamed: PowerupNodeName)
        
        powerUp.size = CGSize(width: sideSize, height: sideSize)
        powerUp.position = CGPoint(x: startX, y: startY)
        powerUp.name = PowerupNodeName
        
        self.addChild(powerUp)
        
        let move = SKAction.move(to: CGPoint(x: startX, y: endY), duration: 6)
        
        // Clean up node
        let remove = SKAction.removeFromParent()
        let travelAndRemove = SKAction.sequence([move, remove])
        
        // Rotate asteroid by 3 radians (less than 180 degrees) over 1-3 second duration
        let spin = SKAction.rotate(byAngle: 1, duration: 1)
        
        let spinForever = SKAction.repeatForever(spin)
        
        let all = SKAction.group([spinForever, travelAndRemove])
        
        powerUp.run(all)
        
    }
    
    func dropHealth() {
        // Define the size of the sides of the enemy ship
        let sideSize = 20.0
        
        // Determine starting x and y position values
        let startX = Double(arc4random_uniform(UInt32(self.size.width - 60)) + 30)
        let startY = Double(self.size.height) + sideSize
        let endY = 0 - sideSize
        
        // Create the asteroid sprite
        let shipHealth = SKSpriteNode(imageNamed: "healthpowerup")
        shipHealth.size = CGSize(width: sideSize, height: sideSize)
        shipHealth.position = CGPoint(x: startX, y: startY)
        shipHealth.name = HealthPowerupNodeName
        self.addChild(shipHealth)
        
        let move = SKAction.move(to: CGPoint(x: startX, y: endY), duration: 5)
        
        // Clean up node
        let remove = SKAction.removeFromParent()
        let travelAndRemove = SKAction.sequence([move, remove])
        
        // Replace [health] with scale down 50% & fade out its as moving towards the bottom of the screen
        let fade = SKAction.fadeOut(withDuration: 5)
        
        let scale = SKAction.resize(toWidth: CGFloat(sideSize / 2), height: CGFloat(sideSize / 2), duration: 5)
        
        let fadeAndScale = SKAction.sequence([fade, scale])
        let all = SKAction.group([fadeAndScale, travelAndRemove])
        
        shipHealth.run(all)
        
    }
    
    
    // MARK: - Collisions
    func checkCollisions() {
        
        if let ship = self.childNode(withName: SpaceshipNodeName) {
            if self.shipHealthRate == 0 {
                ship.removeFromParent()
                self.run(self.shipExplodeSound)
                
                let explosion = self.shipExplodeTemplate.copy() as! SKEmitterNode
                
                explosion.position = ship.position
                explosion.dieOutInDuration(duration: 0.3)
                self.addChild(explosion)
                
                self.endGame()
            }
            // If the ship bumps into a power-up, remove the power-up from the scene and
            // reset the shipFireRate to 0.1 to increase the ships firing rate.
            enumerateChildNodes(withName: PowerupNodeName) {
                powerUp, _ in
                
                if ship.intersects(powerUp) {
                    if let hud = self.childNode(withName: self.HUDNodeName) as! HUDNode? {
                        hud.showPowerupTimer(self.powerUpDuration)
                    }
                    
                    
                    
                    powerUp.removeFromParent()
                    
                    // Increase the ships firing rate
                    self.shipFireRate = 0.1
                    
                    let powerDown = SKAction.run({
                        self.shipFireRate = self.defaultFireRate
                    })
                    
                    let wait = SKAction.wait(forDuration: self.powerUpDuration)
                    let waitAndPowerDown = SKAction.sequence([wait, powerDown])
                    
                    //ship.run(waitAndPowerDown)
                    
                    let powerDownActionKey = "waitAndPowerDown"
                    ship.removeAction(forKey: powerDownActionKey)
                    ship.run(waitAndPowerDown, withKey: powerDownActionKey)
                }
            }
            
            enumerateChildNodes(withName: HealthPowerupNodeName) {
                healthPowerUp, _ in
                
                if ship.intersects(healthPowerUp) {
                    
                    // Increase the ships health
                    print("\(self.shipHealthRate)\n")
                    self.shipHealthRate = 4.0
                    
                    // Set health in HUDNode
                    if let hud = self.childNode(withName: self.HUDNodeName) as! HUDNode? {
                        hud.addHealth()
                    }
                    
                    print("\(self.shipHealthRate)\n")
                    
                    // Remove node from scene
                    healthPowerUp.removeFromParent()
                    
                    
                    
                }
            }
            
            
            enumerateChildNodes(withName: ObstacleNodeName) {
                obstacle, _ in
                
                if ship.intersects(obstacle) {
                    self.shipTouch = nil
                    obstacle.removeFromParent()
                    
                    if self.shipHealthRate == 0.0 {
                        
                        ship.removeFromParent()
                        self.run(self.shipExplodeSound)
                        
                        let explosion = self.shipExplodeTemplate.copy() as! SKEmitterNode
                        
                        explosion.position = ship.position
                        explosion.dieOutInDuration(duration: 0.3)
                        self.addChild(explosion)
                        
                        self.endGame()
                        
                    } else if self.shipHealthRate > 0.0 {
                        
                        if let hud = self.childNode(withName: self.HUDNodeName) as! HUDNode? {
                            hud.subtractHealth(Double(self.shipHealthRate))
                        }
                        self.shipHealthRate = self.shipHealthRate - 1.0
                        
                        obstacle.removeFromParent()
                        
                        self.run(self.obstacleExplodeSound)
                        
                        let explosion = self.obstacleExplodeTemplate.copy() as! SKEmitterNode
                        
                        explosion.position = obstacle.position
                        
                        explosion.dieOutInDuration(duration: 0.1)
                        self.addChild(explosion)
                    }
                }
                
                self.enumerateChildNodes(withName: self.PhotonTorpedoNodeName) {
                    
                    myPhoton, stop in
                    
                    if myPhoton.intersects(obstacle) {
                        
                        myPhoton.removeFromParent()
                        
                        
                        obstacle.removeFromParent()
                        
                        self.run(self.obstacleExplodeSound)
                        
                        let explosion = self.obstacleExplodeTemplate.copy() as! SKEmitterNode
                        
                        explosion.position = obstacle.position
                        
                        explosion.dieOutInDuration(duration: 0.1)
                        self.addChild(explosion)
                        
                        // Update the score
                        if let hud = self.childNode(withName: self.HUDNodeName) as! HUDNode? {
                            let score = 10 * Int(hud.elapsedTime) * (self.easyMode ? 1 : 2)
                            hud.addPoints(score)
                            
                            
                        }
                        
                        
                        // This is like a "break" in other languages
                        stop.pointee = true
                        
                    }
                }
            }
        }
    }
    
    
    // MARK: - End Game
    func endGame() {
        
        if let view = self.view {
            tapGesture = UITapGestureRecognizer(target: self, action: #selector(GameScene.tapped))
            view.addGestureRecognizer(tapGesture!)
            let node = GameOverNode()
            node.position = CGPoint(x: self.size.width / 2.0, y: self.size.height / 2.0)
            addChild(node)
        }
        
        let hud = childNode(withName: HUDNodeName) as! HUDNode
        hud.endGame()
        
        let defaults = UserDefaults.standard
        let highScore = defaults.value(forKey: "highScore")
        
        if ((highScore as AnyObject).integerValue < hud.score) {
            defaults.setValue(hud.score, forKey: "highScore")
        }
        
    }
    
    
    @objc func tapped() {
        if let endGameCallback = endGameCallback {
            endGameCallback()
        }
    }
    
    override func willMove(from view: SKView) {
        if let view = self.view {
            if tapGesture != nil {
                view.removeGestureRecognizer(tapGesture!)
                tapGesture = nil
            }
        }
    }
    
    
    func buildEnemyShipMovementPath() -> CGPath {
        
        let yMax = -1.0 * self.size.height
        
        let bezierPath = UIBezierPath()
        
        bezierPath.move(to: CGPoint(x: 0.5, y: -0.5))
        
        bezierPath.addCurve(to: CGPoint(x: -2.5, y: -59.5), controlPoint1: CGPoint(x: 0.5, y: -0.5), controlPoint2: CGPoint(x: 4.55, y: -29.48))
        
        bezierPath.addCurve(to: CGPoint(x: -27.5, y: -154.5), controlPoint1: CGPoint(x: -9.55, y: -89.52), controlPoint2: CGPoint(x: -43.32, y: -115.43))
        
        bezierPath.addCurve(to: CGPoint(x: 30.5, y: -243.5), controlPoint1: CGPoint(x: -11.68, y: -193.57), controlPoint2: CGPoint(x: 17.28, y: -186.95))
        
        bezierPath.addCurve(to: CGPoint(x: -52.5, y: -379.5), controlPoint1: CGPoint(x: 43.72, y: -300.05), controlPoint2: CGPoint(x: -47.71, y: -335.76))
        
        bezierPath.addCurve(to: CGPoint(x: 54.5, y: -449.5), controlPoint1: CGPoint(x: -57.29, y: -423.24), controlPoint2: CGPoint(x: -8.14, y: -482.45))
        
        bezierPath.addCurve(to: CGPoint(x: -5.5, y: -348.5), controlPoint1: CGPoint(x: 117.14, y: -416.55), controlPoint2: CGPoint(x: 52.25, y: -308.62))
        
        bezierPath.addCurve(to: CGPoint(x: 10.5, y: -494.5), controlPoint1: CGPoint(x: -63.25, y: -388.38), controlPoint2: CGPoint(x: -14.48, y: -457.43))
        
        bezierPath.addCurve(to: CGPoint(x: 0.5, y: -559.5), controlPoint1: CGPoint(x: 23.74, y: -514.16), controlPoint2: CGPoint(x: 6.93, y: -537.57))
        
        bezierPath.addCurve(to: CGPoint(x: -2.5, y: yMax), controlPoint1: CGPoint(x: -5.2, y: yMax), controlPoint2: CGPoint(x: -2.5, y: yMax))
        
        return bezierPath.cgPath
        
    }
    
}
