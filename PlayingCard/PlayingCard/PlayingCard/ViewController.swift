//
//  ViewController.swift
//  PlayingCard
//
//  Created by Kamil Gucik on 28/01/2020.
//  Copyright © 2020 Kamil Gucik. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    var deck = Deck()
    
    lazy var animator = UIDynamicAnimator(referenceView: self.view)
    
    lazy var cardBehavior = CardBehavior(in: animator)
    
    var lastChosenCardView: PlayingCardView?
            
    @IBOutlet var playingCardView: [PlayingCardView]!
//        {
//        didSet {
//            let swipe = UISwipeGestureRecognizer(target: self, action: #selector(nextCard))
//            swipe.direction = [.left,.right]
//            playingCardView.addGestureRecognizer(swipe)
//            let pinch = UIPinchGestureRecognizer(target: playingCardView, action: #selector(PlayingCardView.adjustFaceCardScale(recognizer:)))
//            playingCardView.addGestureRecognizer(pinch)
//        }
//    }
//
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if CMMotionManager.shared.isAccelerometerAvailable {
            cardBehavior.gravityBehavior.magnitude = 1.0
            CMMotionManager.shared.accelerometerUpdateInterval = 1/10
            CMMotionManager.shared.startAccelerometerUpdates(to: .main) { (data, error) in
                if var x = data?.acceleration.x, var y = data?.acceleration.y {
                    switch UIDevice.current.orientation {
                    case .portrait: y *= -1
                    case .portraitUpsideDown: break
                    case .landscapeRight: swap(&x, &y)
                    case .landscapeLeft: swap(&x, &y); y *= -1
                    default:
                        x = 0; y = 0;
                    }
                    self.cardBehavior.gravityBehavior.gravityDirection = CGVector(dx: x, dy: y)
                }
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cardBehavior.gravityBehavior.magnitude = 0
        CMMotionManager.shared.stopAccelerometerUpdates()
    }
    
    
    
    
    @objc func flipCard(_ recoginzer: UITapGestureRecognizer) {
        switch recoginzer.state  {
        case .ended:
            if let choosenCard = recoginzer.view as? PlayingCardView, facedUpCards.count < 2 {
                lastChosenCardView = choosenCard
                cardBehavior.removeItem(choosenCard)
                UIView.transition(with: choosenCard,
                                  duration: 0.6,
                                  options: [.transitionFlipFromLeft],
                                  animations: {
                                    choosenCard.isFacedUp = !choosenCard.isFacedUp
                },
                                  completion: { finished in
                                    let cardsToAnimate = self.facedUpCards
                                    if self.facedUpCardsMatched {
                                        UIViewPropertyAnimator.runningPropertyAnimator(
                                            withDuration: 0.6,
                                            delay: 0,
                                            options: [],
                                            animations: {
                                                cardsToAnimate.forEach {
                                                    $0.transform = CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0)
                                                }
                                        },
                                            completion: { position in
                                                UIViewPropertyAnimator.runningPropertyAnimator(
                                                    withDuration: 0.75,
                                                    delay: 0,
                                                    options: [],
                                                    animations: {
                                                        cardsToAnimate.forEach {
                                                            $0.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
                                                            $0.alpha = 0
                                                        }
                                                },
                                                    completion: { position in
                                                        cardsToAnimate.forEach {
                                                            $0.isHidden = true
                                                            $0.alpha = 1
                                                            $0.transform = .identity
                                                        }
                                                        
                                                        
                                                }
                                                )
                                        }
                                        )
                                    }
                                    else if cardsToAnimate.count == 2 {
                                        if choosenCard == self.lastChosenCardView {
                                        cardsToAnimate.forEach { playingCardView in
                                            UIView.transition(with: playingCardView,
                                                              duration: 0.6,
                                                              options: [.transitionFlipFromLeft],
                                                              animations: {
                                                                playingCardView.isFacedUp = false
                                            },
                                                              completion: {finished in
                                                                self.cardBehavior.addItem(playingCardView)
                                            }
                                        )
                                    }
                                    }
                                } else {
                                    if !choosenCard.isFacedUp {
                                        self.cardBehavior.addItem(choosenCard)
                                    }
                                }
                            }
                        )
                    }
                default:
                break
            }
        }
//
//    @objc func nextCard() {
//        if let card = deck.draw() {
//            playingCardView.rank = card.rank.order
//            playingCardView.suit = card.suit.rawValue
//        }
//
//    }
    
    private var facedUpCardsMatched: Bool {
        return facedUpCards.count == 2 &&
        facedUpCards[0].rank == facedUpCards[1].rank &&
            facedUpCards[0].suit == facedUpCards[1].suit
    }
    
    private var facedUpCards: [PlayingCardView] {
        return playingCardView.filter { $0.isFacedUp && !$0.isHidden && $0.transform != CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0) && $0 .alpha == 1}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var cards = [PlayingCard]()
        for _ in 1...((playingCardView.count + 1)/2) {
            let card = deck.draw()!
            cards += [card, card]
        }
        for cardView in playingCardView {
            cardView.isFacedUp = false
            let card = cards.remove(at: cards.count.arc4random)
            cardView.rank = card.rank.order
            cardView.suit = card.suit.rawValue
            cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCard(_: ))))
            cardBehavior.addItem(cardView)
        }
    }
}



extension CGFloat {
        var arc4random: CGFloat {
            if self > 0 {
                return CGFloat(arc4random_uniform(UInt32(self)))
            } else if self < 0 {
                return -CGFloat(arc4random_uniform(UInt32(abs(self))))
            } else {
                return 0
            }
        }
    }


