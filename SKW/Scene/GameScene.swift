import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //Actors
    let oldLady = Player()
    
//    var doctor = Doctor()
    var hud = HUD()
    
    var velocity = CGPoint.zero
    
    
    // Update Timer
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    var doctorCreationTime: TimeInterval = 0
    
    // Special
    var isMoving = false
    
    //tombNumber
    var tombCount = 0

    override func sceneDidLoad() {
        self.physicsWorld.contactDelegate = self
        //    self.physicsWorld.gravity = CGVector(dx:0, dy: -9.8)
        //    self.physicsBody?.restitution = 0
        //    self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
    }
    
    override func didMove(to view: SKView) {
        
//        if isMoving == false {
//            oldLady.animate(type: "idle")
//        }
    
        //Background

        
                let background = SKSpriteNode(imageNamed: "scene1Background")
                background.position = CGPoint(x: size.width/2, y: size.height/2)
                background.size = CGSize(width: self.frame.width, height: self.frame.height)
                background.zPosition = -1
                addChild(background)
        
        //Game Plane
        GameManager.shared.setup(view: self.view!)
        
        // Player
        debugPrint( GameManager.shared.setup)
        oldLady.setup(view: self.view!)
//        oldLady.zPosition = 100
        //        debugPrint("pos old lady: \(oldLady.squarePlayerPosition)")
        //        oldLady.zPosition = 1
        addChild(oldLady)
    
        hud.setup(size: size)
        addChild(hud)
        
        
        
//        spawnTombs()
        
        //start Game
        GameManager.shared.startTimer(label: hud.timerLabel)
        
        
        
        //Audio
        let alarm = SKAudioNode(fileNamed: "scene1Audio")
        addChild(alarm)
        
        
        // Gestures
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeMoveUp))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        self.view?.addGestureRecognizer(swipeUp)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeMoveRight))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view?.addGestureRecognizer(swipeRight)
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeMoveDown))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.view?.addGestureRecognizer(swipeDown)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeMoveLeft))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view?.addGestureRecognizer(swipeLeft)
        
    }
    @objc func swipeMoveUp() {
        isMoving = true
        debugPrint("swipeup")
        oldLady.moveUp()
//        isMoving = false
    }
    @objc func swipeMoveRight() {
        isMoving = true
        debugPrint("swiperight")
        oldLady.moveRight()
//        isMoving = false
    }
    @objc func swipeMoveDown() {
        isMoving = true
        debugPrint("swipedown")
        oldLady.moveDown()
//        isMoving = false
    }
    @objc func swipeMoveLeft() {
        isMoving = true
        oldLady.moveLeft()
        debugPrint("swipelefy")
//        isMoving = false
    }
    
    func touchDown(atPoint pos: CGPoint) {
        
    }
    func touchMoved(toPoint pos: CGPoint) {
        
    }
    func touchUp(atPoint pos: CGPoint) {
        //    stickTouchUp(pos: pos)
        //    dPadTouchUp(pos: pos)
        // Gesture Trigger
        if !isMoving{
            oldLady.attack()
        }
        isMoving = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        self.touchDown(atPoint: touch.location(in: self))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        self.touchMoved(toPoint: touch.location(in: self))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        self.touchUp(atPoint: touch.location(in: self))
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    // MARK: Render Loop
    override func update(_ currentTime: TimeInterval) {
        
        // If we don't have a last frame time value, this is the first frame, so delta time will be zero.
        if lastUpdateTime <= 0 { lastUpdateTime = currentTime }
        
        // Update delta time
        dt = currentTime - lastUpdateTime
        // debugPrint("\(deltaTime * 1000) milliseconds")
        
        // Set last frame time to current time
        lastUpdateTime = currentTime
//        if currentTime > doctorCreationTime{
        if !GameManager.shared.doctorIsIn{
            GameManager.shared.doctorIsIn = true
            spawnDoctor()
//            doctorCreationTime = currentTime + 11.5
        }

        
        oldLady.update(deltaTime: dt)
        checkPlayerDoctorCollision()
        checkTombDoctorCollision()
        spawnTombs()
        
        
        //        checkSimpleCollision()
        
    }
    
    func spawnDoctor(){
        let doctor = Doctor()
        doctor.setup(view: self.view!)
        addChild(doctor)
    }
    
    
    func checkPlayerDoctorCollision() {
        enumerateChildNodes(withName: "doctor") { doc, stop in
            self.enumerateChildNodes(withName: "player") { player, stop in
                if player.frame.intersects(doc.frame) {
                    if player.zPosition == doc.zPosition{
                        debugPrint("player and doctor Intersected!")
                        //                    let doc = doctor as? Doctor
                        //                    doc?.doctorHitPlayer()
                                            doc.removeFromParent()
                                            GameManager.shared.doctorIsIn = false
                        GameManager.shared.loseTime(label: self.hud.timerLabel)
                        self.oldLady.playerBeHit()
                    }
                    
                }
            }
        }
    }
    
    func checkTombDoctorCollision() {
        enumerateChildNodes(withName: "doctor") { doc, stop in
            self.enumerateChildNodes(withName: "tomb") { tomb, stop in
                if tomb.frame.intersects(doc.frame) {
                    if tomb.zPosition == doc.zPosition{
                        debugPrint("tomb and doctor Intersected!")
                        //                    let doc = doctor as? Doctor
                        //                    doc?.doctorHitPlayer()
                        doc.removeFromParent()
                        GameManager.shared.doctorIsIn = false
                        tomb.removeFromParent()
                        self.tombCount -= 1
                        self.hud.score = Scores.malus
                        GameManager.shared.loseTime(label: self.hud.timerLabel)
                    }
                    
                }
            }
        }
    }
    
//    func spawnTombs(){
//
//        for count in 0...3{
////            debugPrint("count: \(count)")
//            let newTomb = Tomb()
//            let posAdpt = CGPoint(x:  0, y:  newTomb.size.height / 2)
//            let i = GameManager.shared.tombsPosIndex[count].0
////            debugPrint("i: \(i)")
//            var j = GameManager.shared.tombsPosIndex[count].1
////            debugPrint("j: \(j)")
//            newTomb.position = plus(left: GameManager.shared.gameMatrix[i][j], right: posAdpt)
//            newTomb.zPosition = CGFloat(GameManager.shared.maxRows - count)
//
//            addChild(newTomb)
//
//        }
//    }
    
    func spawnTombs(){
        
        if tombCount <= 3
        {
            
        
        let newTomb = Tomb()
        let posAdpt = CGPoint(x:  0, y:  newTomb.size.height / 2)
        let i = arc4random_uniform(UInt32(GameManager.shared.maxRows))
        //            debugPrint("i: \(i)")
        var partJ = UInt32(GameManager.shared.maxRows) - i + 1
            var secondPartJ = UInt32(GameManager.shared.maxColums) - (UInt32(GameManager.shared.maxRows) + i)
        var j = arc4random_uniform(secondPartJ) + partJ
        //            debugPrint("j: \(j)")
            debugPrint("i: \(i), j: \(j)")
        newTomb.position = plus(left: GameManager.shared.gameMatrix[Int(i)][Int(j)], right: posAdpt)
        newTomb.zPosition = CGFloat(GameManager.shared.maxRows - Int(i))
        tombCount += 1
        
//            GameManager.shared.tombsPosIndex
        addChild(newTomb)
        }
        
    }
    
    //    override func update(_ currentTime: TimeInterval) {
    //
    //        player.position = CGPoint(x: player.position.x , y: player.position.y)
    //        if lastUpdateTime > 0 {
    //            dt = currentTime - lastUpdateTime
    //        } else {
    //            dt = 0 }
    //        lastUpdateTime = currentTime
    //        debugPrint("\(dt*1000) milliseconds since last update")
    //
    //    }
    
    
    
}


