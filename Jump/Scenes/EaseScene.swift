//
//  GameScene.swift
//  Jump
//
//  Created by Digis01 Soluciones Digitales on 29/10/22.
//

import SpriteKit
import GameplayKit

class EaseScene: SKScene {
    
    //MARK: - Properties
    
    private let worldNode = SKNode()
    private var bgNode : SKSpriteNode!
    private var hudNode = HUDNode()
    
    private let playerNode = PlayerNode(diff : 0)
    private let wallNode = WallNode()
    private let rightNode = SideNode()
    private let leftNode = SideNode()
    private let obstaclesNode = SKNode()
    
    var firstTap = true
    private var posY : CGFloat = 0.0
    private var pairNum = 0
    private var score = 0
    
    lazy var colors: [ColorModel] = {
        return ColorModel.shared()
    }()
    
    private let superScoreSound = SKAction.playSoundFileNamed(SoundName.superScore, waitForCompletion: false)
    private let jumpSound = SKAction.playSoundFileNamed(SoundName.jump, waitForCompletion: false)
    private let scoreSound = SKAction.playSoundFileNamed(SoundName.score, waitForCompletion: false)
    private let collisionSound = SKAction.playSoundFileNamed(SoundName.collision, waitForCompletion: false)

    
    
    private let easeScoreKey = "EaseScoreKey"
    private let easeNotifKey = "EaseNotifKey"
    
    private let requestScore = 50
    
    private let btnName = "icon-letsGo"
    private let titleText = "Wellcome to level Ease"
    private let subTxt = """
You have to score
at least 50 score in before
you can play next next level.
Good luck!!!
"""
    
    //MARK: - Lifecycle
    override func didMove(to view: SKView) {
        setupNodes()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch  = touches.first else {return}
        if firstTap{
        playerNode.activate(true)
            firstTap = false
        }
        
        let location = touch.location(in: self)
        let right = !(location.x > frame.width/2)
        
        playerNode.jump(right)
        run(jumpSound)
        //if (location.x > frame.width/2){
        //   right = false
        //}
    }
    override func update(_ currentTime: TimeInterval) {
        if -playerNode.height() + frame.midY < worldNode.position.y {
            worldNode.position.y = -playerNode.height() + frame.midY
        }
        if posY - playerNode.height() < frame.midY{
            addObstacles()
        }
        obstaclesNode.children.forEach({
            let i = score - 2
            if $0.name == "Pair \(i)" {
                $0.removeFromParent()
                print("removeFromParent")
            }
        })
    }
}
        
    //MARK: - Setups
extension EaseScene{
    private func setupNodes(){
        backgroundColor = .white
        setupPhysics()
        
        //TODO: - BackgroundNode
        addBG()
        
        //TODO: - HUDdNode
        addChild(hudNode)
        hudNode.SKView = view
        hudNode.easeScene = self
        
        if !UserDefaults.standard.bool(forKey: easeNotifKey){
            UserDefaults.standard.set(true, forKey: easeNotifKey)
            hudNode.setupPanel(subTxt: subTxt, titleTxt: titleText, btnName: btnName)
            
        }
        
        
        
        //TODO: - WorldNode
        addChild(worldNode)
        
        //TODO: - PlayerNode
        playerNode.position = CGPoint(x: frame.midX, y: frame.midY * 0.6)
        worldNode.addChild(playerNode)
        
        //TODO: - WallNode
        addWall()
        
        //TODO: - ObstacleNode
        worldNode.addChild(obstaclesNode)
        posY = frame.midY
        addObstacles()
        
        
    }
    
    private func setupPhysics(){
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -15.0)
        physicsWorld.contactDelegate = self
    }
    
    //MARK: - BackgroundNode
}
    extension EaseScene{
        private func addBG(){
            bgNode = SKSpriteNode(imageNamed: "background")
            bgNode.zPosition = -1.0
            bgNode.position = CGPoint(x : frame.midX, y: frame.midY)
            addChild(bgNode)
            
            //print(AnchorPoint)
            //bgNode.anchorPoint
        }
    }
    
    //MARK: - WallNode
    extension EaseScene {
        private func addWall(){
            wallNode.position = CGPoint(x: frame.midX, y: 0.0)
            leftNode.position = CGPoint(x: playableRect.minX, y: frame.midY)
            rightNode.position = CGPoint(x: playableRect.maxX, y: frame.midY)
            
            addChild(wallNode)
            addChild(leftNode)
            addChild(rightNode)
        }
    }
    
    
    //MARK: - ObstacleNode

    extension EaseScene{

        private func addObstacles(){
            
            let model = colors[Int(arc4random_uniform(UInt32(colors.count-1)))]
            let randomX = CGFloat(arc4random() % UInt32(playableRect.width/2))
            
            let pipePair = SKNode()
            pipePair.position = CGPoint(x: 0.0, y: posY)
            pipePair.zPosition=1.0
            
            pairNum += 1
            
            pipePair.name = "Pair\(pairNum)"
            let size = CGSize(width: screenWidth, height: 50.0)
            
            let pipe_1 = SKSpriteNode(color: model.color, size: size)
            pipe_1.position = CGPoint(x: -250, y: 0.0)
            pipe_1.physicsBody = SKPhysicsBody(rectangleOf: size)
            pipe_1.physicsBody?.isDynamic = false
            pipe_1.physicsBody?.categoryBitMask = PhysicsCategories.Obstacles
            
            let pipe_2 = SKSpriteNode(color: .black, size: size)
            pipe_2.position = CGPoint(x: pipe_1.position.x + size.width + 250, y: 0.0)
            pipe_2.physicsBody = SKPhysicsBody(rectangleOf: size)
            pipe_2.physicsBody?.isDynamic = false
            pipe_2.physicsBody?.categoryBitMask = PhysicsCategories.Obstacles
            
            let score = SKNode()
            score.position = CGPoint(x: 0.0, y: size.height)
            score.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width*2, height: size.height))
            score.physicsBody?.isDynamic = false
            score.physicsBody?.categoryBitMask = PhysicsCategories.Score
            
            pipePair.addChild(pipe_1)
            pipePair.addChild(pipe_2)
            pipePair.addChild(score)
            
            obstaclesNode.addChild(pipePair)
            
            switch arc4random_uniform(200) {
            case 0...80 : break
            default: addSuperScore()
            }
            
            
            addSuperScore() //2:18:44
            
            posY += frame.midY * 0.7
        }
        
        private func addSuperScore(){
            let node = SuperScoreNode()
            
            let randomX = playableRect.midX + CGFloat(arc4random_uniform(UInt32(playableRect.width/2))) + node.frame.width
            
            let randomY = posY + CGFloat(arc4random_uniform(UInt32(posY * 0.5))) + node.frame.height
            
            node.position = CGPoint(x: randomX , y: randomY)
            
            worldNode.addChild(node)
            
            node.bounce()
        }
    }
    
    //MARK: - GameState

extension EaseScene{
    private func gameOver(){
        playerNode.over()
        
        var highscore = UserDefaults.standard.integer(forKey: easeScoreKey)
        if score > highscore{
            highscore = score
        }
        hudNode.setupGameOver(score, highscore)
        run(collisionSound)
        }
    
    private func Success(){
        if score >= requestScore{
            playerNode.activate(false)
            print("Success")
            hudNode.setupSuccess()
            
            //Unlock MediumScene
        }
    }
}

//MARK: - SKPhysicsContactDelegate

extension EaseScene : SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let body = contact.bodyA.categoryBitMask == PhysicsCategories.Player ? contact.bodyB : contact.bodyA
        
        switch body.categoryBitMask{
        case PhysicsCategories.Wall : print("Wall")
            gameOver()
        case PhysicsCategories.Side : print("Side")
            playerNode.side()
        case PhysicsCategories.Obstacles: print("Obstacles")
            gameOver()
            
        case PhysicsCategories.Score: print("Score")
            if let node = body.node{
            score += 1
                hudNode.updateScore(score)
                
                let highscore = UserDefaults.standard.integer(forKey: easeScoreKey)
                if score > highscore{
                    UserDefaults.standard.set(score, forKey: easeScoreKey)
                }
                
            //print("Score: \(score)")
                run(superScoreSound)
                node.removeFromParent()
                Success()
            }
            
        case PhysicsCategories.SuperScore: print("SuperScore")
            if let node = body.node{
            score += 5
                hudNode.updateScore(score)
                
                let highscore = UserDefaults.standard.integer(forKey: easeScoreKey)
                if score > highscore{
                    UserDefaults.standard.set(score, forKey: easeScoreKey)
                }
                
            //print("Score: \(score)")
                node.removeFromParent()
                Success()
            }
            
        default : break
        }
    }
}
