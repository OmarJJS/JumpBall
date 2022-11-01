
import SpriteKit

class SuperScoreNode : SKNode{
    
    //MARK: - Properties
    private var node : SKSpriteNode!
    private let radius : CGFloat = 35.0
    private let scale : CGFloat = 0.5
    
    //MARK: - Initializers
    override init(){
        super.init()
        self.name = "SuperScene"
        self.zPosition = 10.0
        self.setupPhysics()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//MARK: - Setups

extension SuperScoreNode{
    
    private func setupPhysics(){
        node = SKSpriteNode(imageNamed: "icon-star")
        node.name = "SuperScore"
        node.physicsBody = SKPhysicsBody(circleOfRadius: radius * 0.0)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = PhysicsCategories.SuperScore
        addChild(node)
    }
    
    func bounce(){
        let isRepeat = SKAction.repeat(.sequence([
            .scale(to: scale * 0.85, duration: 0.1),
            .scale(to: scale * 1.0, duration: 0.1)
        ]), count : 2)
        
        run(.wait(forDuration: 0.5)){
            self.node.run(.repeatForever(.sequence([isRepeat, .wait(forDuration: 1.5)])))
        }
    }
    
    
}
