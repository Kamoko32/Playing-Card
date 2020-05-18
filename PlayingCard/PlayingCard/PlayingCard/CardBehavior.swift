//
//  CardBehavior.swift
//  PlayingCard
//
//  Created by Kamil Gucik on 09/03/2020.
//  Copyright © 2020 Kamil Gucik. All rights reserved.
//

import UIKit

class CardBehavior: UIDynamicBehavior {
    
    lazy var collisionBehavior: UICollisionBehavior = {
       let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        return behavior
    }()
    
    lazy var itemBehaviour: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.allowsRotation = false
        behavior.elasticity = 1.0
        behavior.resistance = 0
        return behavior
    }()
    
    private func push ( _ item: UIDynamicItem) {
    let push = UIPushBehavior(items: [item], mode: .instantaneous)
        if let referenceBound = dynamicAnimator?.referenceView?.bounds {
            let center = CGPoint(x: referenceBound.midX, y: referenceBound.midY)
            switch (item.center.x, item.center.y) {
            case let (x,y) where x < center.x && y < center.y:
                push.angle = (CGFloat.pi/2).arc4random
            case let (x,y) where x > center.x && y < center.y:
                push.angle = CGFloat.pi-(CGFloat.pi/2).arc4random
            case let (x,y) where x < center.x && y > center.y:
                push.angle = (-CGFloat.pi/2).arc4random
            case let (x,y) where x > center.x && y > center.y:
                push.angle = CGFloat.pi+(CGFloat.pi/2).arc4random
            default:
                push.angle = (CGFloat.pi*2).arc4random
            }
        }
//    push.angle = (CGFloat.pi*2).arc4random
    push.magnitude = CGFloat(1.0) + CGFloat(2.0).arc4random
    push.action = { [unowned push, weak self] in
        self?.removeChildBehavior(push)
        }
        addChildBehavior(push)
    }
    
    var gravityBehavior: UIGravityBehavior = {
        let behavior = UIGravityBehavior()
        behavior.magnitude = 0
       return behavior
    }()
    
    func addItem(_ item: UIDynamicItem) {
        collisionBehavior.addItem(item)
        itemBehaviour.addItem(item)
        gravityBehavior.addItem(item)
        push(item)
    }
    
    func removeItem(_ item: UIDynamicItem) {
        collisionBehavior.removeItem(item)
        itemBehaviour.removeItem(item)
        gravityBehavior.removeItem(item)
    }
    
    override init() {
        super.init()
        addChildBehavior(collisionBehavior)
        addChildBehavior(itemBehaviour)
        addChildBehavior(gravityBehavior)
    }
    
    convenience init(in animator: UIDynamicAnimator) {
        self.init()
        animator.addBehavior(self)
    }

}