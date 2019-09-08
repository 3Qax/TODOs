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
    /// UIView over circle, bigger than circle.
    /// Tap events in this view are being intepreted as the circle taps
    @IBOutlet weak var circleTapArea: UIView!
    /// UIView in which tick can be draw
    @IBOutlet weak var tickView: UIView!

    var shouldStyleAsDone = false {
        // updates styling of ListItem regarding to shouldStyleAsDone
        didSet { shouldStyleAsDone ? styleAsDone(animates: false) : styleAsNotDone(animates: false) }
    }
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

        let circleAreaTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapCircleArea))
        circleTapArea.addGestureRecognizer(circleAreaTapGestureRecognizer)

    }

    /// Called on tap of circleArea
    /// First perform animation, then calles delegate
    @objc private func didTapCircleArea() {
        CATransaction.begin()
        CATransaction.setCompletionBlock({ [weak self] in
            self?.delegate?.didTapCircle(sender: self!)
        })
        shouldStyleAsDone ? styleAsNotDone() : styleAsDone()
        CATransaction.commit()
    }

    /// Styles ListItem as done
    /// - Parameter animates: should changes in style be done as animation
    private func styleAsDone(animates: Bool = true) {

        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20.0, weight: .thin),
            .foregroundColor: UIColor.lightGray,
            .strikethroughStyle: NSUnderlineStyle.single.rawValue,
            .strikethroughColor: UIColor.darkGray ]

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

    /// Styles ListItem as not done
    /// - Parameter animates: should changes in style be done as animation
    private func styleAsNotDone(animates: Bool = true) {

        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20.0, weight: .thin),
            .foregroundColor: UIColor.black ]

        nameTextView.attributedText = NSAttributedString(string: nameTextView.text!, attributes: textAttributes)

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
