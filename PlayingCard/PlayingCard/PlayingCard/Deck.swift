//
//  Deck.swift
//  PlayingCard
//
//  Created by Kamil Gucik on 28/01/2020.
//  Copyright © 2020 Kamil Gucik. All rights reserved.
//

import Foundation

struct Deck {
    
    private(set) var cards = [PlayingCard] ()
    
    init() {
        for suit in PlayingCard.Suit.all {
            for rank in PlayingCard.Rank.all {
                cards.append(PlayingCard(suit: suit, rank: rank))
            }
        }
        
    }
    
   mutating func draw() -> PlayingCard? {
        if cards.count > 0 {
            return cards.remove(at: cards.count.arc4random)
        } else {
            return nil
        }
    }
}

extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}
