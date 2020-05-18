//
//  PlayingCardView.swift
//  PlayingCard
//
//  Created by Kamil Gucik on 30/01/2020.
//  Copyright © 2020 Kamil Gucik. All rights reserved.
//

import UIKit
@IBDesignable
class PlayingCardView: UIView {
    
    @IBInspectable
    var rank: Int = 13
    { didSet {setNeedsDisplay(); setNeedsLayout() } }
    @IBInspectable
    var suit: String = "❤️"
    { didSet {setNeedsDisplay(); setNeedsLayout() } }
    @IBInspectable
    var isFacedUp: Bool = true
    { didSet {setNeedsDisplay(); setNeedsLayout() } }
    
    var faceCardScale: CGFloat = SizeRatio.faceCardImageSizeToBoundsSize {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @objc func adjustFaceCardScale(recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed,.ended:
            faceCardScale *= recognizer.scale
            recognizer.scale = 1.0
        default:
            break
        }
    }

    private func centeredAttributedString (_ string: String, fontSize: CGFloat) -> NSAttributedString {
        var font = UIFont.preferredFont(forTextStyle: .body).withSize(fontSize)
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return NSAttributedString (string: string, attributes: [.paragraphStyle:paragraphStyle,.font:font])
    }

    private var cornerString: NSAttributedString {
        return centeredAttributedString(rankString+"\n" + suit, fontSize: cornerFontSize)
    }

    private lazy var upperLeftCornerLabel = createCornerLabel()
    private lazy var lowerRightCornerLabel = createCornerLabel()

    private func createCornerLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        addSubview(label)
        return label
    }

    private func configureCornerLabel (_ label: UILabel) {
        label.attributedText = cornerString
        label.frame.size = CGSize.zero
        label.sizeToFit()
        label.isHidden = !isFacedUp
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsDisplay()
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        configureCornerLabel(upperLeftCornerLabel)
        upperLeftCornerLabel.frame.origin = bounds.origin.offsetBy(dx: cornerOffset, dy: cornerOffset)

        configureCornerLabel(lowerRightCornerLabel)
        lowerRightCornerLabel.transform = CGAffineTransform.identity.translatedBy(x: lowerRightCornerLabel.frame.size.width, y: lowerRightCornerLabel.frame.size.width).rotated(by: CGFloat.pi)
        lowerRightCornerLabel.frame.origin = CGPoint(x: bounds.maxX, y: bounds.maxY)
            .offsetBy(dx: -cornerOffset, dy: -cornerOffset)
            .offsetBy(dx: -lowerRightCornerLabel.frame.size.width, dy: -lowerRightCornerLabel.frame.size.height)
    }
    
    private func drawPips() {
        let pipsPerRowForRank = [[0],[1],[1,1],[1,1,1],[2,2],[2,1,2],[2,2,2],[2,1,2,2],[2,2,2,2],[2,2,1,2,2],[2,2,2,2,2]]

        func createPipString (thatFits pipRect: CGRect) -> NSAttributedString {
            let maxVerticalPipCount = CGFloat(pipsPerRowForRank.reduce(0) {max($1.count, $0) })
            let maxHorizontalPipCount = CGFloat(pipsPerRowForRank.reduce(0) {max($1.max() ?? 0, $0) })
            let verticalPipRowSpacing = pipRect.size.height / maxVerticalPipCount
            let attemptedPipString = centeredAttributedString(suit, fontSize: verticalPipRowSpacing)
            let propablyOkayPipStringFontSize = verticalPipRowSpacing / (attemptedPipString.size().height / verticalPipRowSpacing)
            let propablyOkayPipString = centeredAttributedString(suit, fontSize: propablyOkayPipStringFontSize)
            if propablyOkayPipString.size().width > pipRect.size.width / maxHorizontalPipCount {
                return centeredAttributedString(suit, fontSize: propablyOkayPipStringFontSize / (propablyOkayPipString.size().width / (pipRect.size.width / maxHorizontalPipCount)))
            } else {
                return propablyOkayPipString
            }
        }

        if pipsPerRowForRank.indices.contains(rank) {
            let pipsPerRow = pipsPerRowForRank[rank]
            var pipRect = bounds.insetBy(dx: cornerOffset, dy: cornerOffset).insetBy(dx: cornerString.size().width, dy: cornerString.size().height / 2)
            let pipString = createPipString(thatFits: pipRect)
            let pipRowSpacing = pipRect.size.height / CGFloat(pipsPerRow.count)
            pipRect.size.height = pipString.size().height
            pipRect.origin.y += (pipRowSpacing - pipRect.size.height) / 2
            for pipCount in pipsPerRow {
                switch pipCount {
                case 1:
                    pipString.draw(in: pipRect)
                case 2:
                    pipString.draw(in: pipRect.leftHalf)
                    pipString.draw(in: pipRect.rightHalf)

                default:
                    break
                }
                pipRect.origin.y += pipRowSpacing
            }
        }
    }
    override func draw(_ rect: CGRect) {
////        if let contex = UIGraphicsGetCurrentContext() {
////            contex.addArc(center: CGPoint(x: bounds.midX, y: bounds.midY), radius: 100.0 , startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
////            contex.setLineWidth(10.0)
////            UIColor.green.setFill()
////            UIColor.red.setStroke()
////            contex.strokePath()
////            contex.fillPath()
////        }****************************
//        let path = UIBezierPath()
//        path.addArc(withCenter: CGPoint(x: bounds.midX, y: bounds.midY), radius: 100.0 , startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
//            path.lineWidth = 10.0
//            UIColor.green.setFill()
//            UIColor.red.setStroke()
//            path.stroke()
//            path.fill()
//    ********************************
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        roundedRect.addClip()
        UIColor.white.setFill()
        roundedRect.fill()
        
        if isFacedUp {
            if let faceCardImage = UIImage(named: rankString+suit, in: Bundle(for: self.classForCoder), compatibleWith: traitCollection) {
                faceCardImage.draw(in: bounds.zoom(by: faceCardScale))
                faceCardImage.draw(in: bounds)
        } else {
            drawPips()
        }
        
        } else {
            if let cardBackImage = UIImage(named: "cardback", in: Bundle(for: self.classForCoder), compatibleWith: traitCollection) {
                cardBackImage.draw(in: bounds)
            }
            
        }
    }

}

extension PlayingCardView {
    private struct SizeRatio {
        static let cornerFontSizeToBoundsHeight: CGFloat = 0.085
        static let cornerRadiusToBoundsHeight: CGFloat = 0.06
        static let cornerOffsetToCornerRadius: CGFloat = 0.33
        static let faceCardImageSizeToBoundsSize: CGFloat = 0.75
    }
    private var cornerRadius: CGFloat {
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }
    private var cornerOffset: CGFloat {
        return cornerRadius * SizeRatio.cornerOffsetToCornerRadius
    }
    private var cornerFontSize: CGFloat {
        return bounds.size.height * SizeRatio.cornerFontSizeToBoundsHeight
}
    private var rankString: String {
        switch rank {
        case 1: return "A"
        case 2...10: return String(rank)
        case 11: return "J"
        case 12: return "Q"
        case 13: return "K"
        default: return "?"
        }
    }
}

extension CGRect {
    var leftHalf: CGRect {
        return CGRect(x: minX, y: minY, width: width/2, height: height)
    }
    var rightHalf: CGRect {
        return CGRect(x: midX, y: minY, width: width/2, height: height)
    }
    func inset(by size: CGSize) -> CGRect {
        return insetBy(dx: size.width, dy: size.height)
    }
    func sized(to size: CGSize) -> CGRect {
        return CGRect(origin: origin, size: size)
    }
    func zoom (by scale: CGFloat) -> CGRect {
        let newWidth = width * scale
        let newHeight = height * scale
        return insetBy(dx: (width - newWidth) / 2, dy: (height - newHeight) / 2)
    }
    
}

extension CGPoint {
    func offsetBy (dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x+dx, y: y+dy)
    }
}
