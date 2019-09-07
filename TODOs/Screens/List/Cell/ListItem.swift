//
//  ListItem.swift
//  TODOs
//
//  Created by Jakub Towarek on 12/07/2019.
//  Copyright © 2019 Jakub Towarek. All rights reserved.
//

import UIKit

protocol ListItemDelegate: AnyObject {
    func didTapCircle(sender: ListItem)
}

final class ListItem: UITableViewCell {

    @IBOutlet weak var nameTextView: UITextView!
    @IBOutlet weak var circle: UIView!
    @IBOutlet weak var circleMask: UIView!
    @IBOutlet weak var circleTapArea: UIView!
    @IBOutlet weak var tickView: UIView!

    var shouldStypeAsDone = false
    weak var delegate: ListItemDelegate?

    private let tickPath: UIBezierPath = {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 7, y: 25 * 2 / 3))
        path.addLine(to: CGPoint(x: 13, y: 22))
        path.addLine(to: CGPoint(x: 30, y: 2))
        return path
    }()
    private let checkAnimation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 0.25
        animation.fromValue = 0
        animation.toValue = 1
        return animation
    }()
    private let reverseCheckAnimation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 0.25
        animation.fromValue = 1
        animation.toValue = 0
        return animation
    }()
    private let shapeLayer = CAShapeLayer()

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none

        let circleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapCircle))
        circleTapArea.addGestureRecognizer(circleTapGestureRecognizer)

    }

    @objc func didTapCircle() {
        CATransaction.begin()
        CATransaction.setCompletionBlock({ [weak self] in
            self?.delegate?.didTapCircle(sender: self!)
        })
        shouldStypeAsDone ? styleAsNotDone() : styleAsDone()
        CATransaction.commit()
    }

    func updateStyling() {

            switch shouldStypeAsDone {

            case true:
                styleAsDone(animates: false)
            case false:
                styleAsNotDone(animates: false)
            }

    }

    private func styleAsDone(animates: Bool = true) {
        var textAttributes = [NSAttributedString.Key: Any]()
        textAttributes[NSAttributedString.Key.font] = UIFont.systemFont(ofSize: 20.0, weight: .thin)
        textAttributes[NSAttributedString.Key.foregroundColor] = UIColor.lightGray
        textAttributes[NSAttributedString.Key.strikethroughStyle] = NSUnderlineStyle.single.rawValue
        textAttributes[NSAttributedString.Key.strikethroughColor] = UIColor.darkGray
        nameTextView.attributedText = NSAttributedString(string: nameTextView.text!, attributes: textAttributes)

        circle.backgroundColor = .lightGray

        shapeLayer.path = tickPath.cgPath
        shapeLayer.frame = circle.bounds
        shapeLayer.strokeColor = UIColor.darkGray.cgColor
        shapeLayer.fillColor = nil
        shapeLayer.lineWidth = 2
        shapeLayer.lineJoin = CAShapeLayerLineJoin.bevel

        tickView.layer.addSublayer(shapeLayer)
        shapeLayer.strokeEnd = 1.0
        shapeLayer.removeAllAnimations()
        if animates { shapeLayer.add(checkAnimation, forKey: nil) }
    }

    private func styleAsNotDone(animates: Bool = true) {
        var textAttributes = [NSAttributedString.Key: Any]()
        textAttributes[NSAttributedString.Key.font] = UIFont.systemFont(ofSize: 20.0, weight: .thin)
        textAttributes[NSAttributedString.Key.foregroundColor] = UIColor.black
        nameTextView.attributedText = NSAttributedString(string: nameTextView.text ?? "", attributes: textAttributes)

        circle.backgroundColor = .darkGray

        shapeLayer.path = tickPath.cgPath
        shapeLayer.frame = circle.bounds
        shapeLayer.strokeColor = UIColor.darkGray.cgColor
        shapeLayer.fillColor = nil
        shapeLayer.lineWidth = 2
        shapeLayer.lineJoin = CAShapeLayerLineJoin.bevel

        shapeLayer.strokeEnd = 0.0
        shapeLayer.removeAllAnimations()
        if animates { shapeLayer.add(reverseCheckAnimation, forKey: nil) }
    }

}
