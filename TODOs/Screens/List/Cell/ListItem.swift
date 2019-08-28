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
        animation.duration = 1
        animation.fromValue = 0
        animation.toValue = 1
        return animation
    }()
    private let reverseCheckAnimation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 1
        animation.fromValue = 1
        animation.toValue = 0
        return animation
    }()
    private let shapeLayer = CAShapeLayer()

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none

        let circleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapCircle))
        circleMask.isUserInteractionEnabled = false
        circle.isUserInteractionEnabled = true
        circle.addGestureRecognizer(circleTapGestureRecognizer)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @objc func didTapCircle() {
        print("recived circle tap event")
        delegate?.didTapCircle(sender: self)
    }

    @objc func didTapBody() {

    }

    func updateStyling() {

        switch shouldStypeAsDone {

        case true:
            styleAsDone()
        case false:
            styleAsNotDone()
        }

    }

    private func styleAsDone() {
        print("style as done")
        nameTextView.textColor = .lightGray
        var textAttributes = [NSAttributedString.Key: Any]()
        textAttributes[NSAttributedString.Key.strikethroughStyle] = NSUnderlineStyle.single.rawValue
        textAttributes[NSAttributedString.Key.strikethroughColor] = UIColor.darkGray
        nameTextView.attributedText = NSAttributedString(string: nameTextView.text!, attributes: textAttributes)

        shapeLayer.path = tickPath.cgPath
        shapeLayer.frame = circle.bounds
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.fillColor = nil
        shapeLayer.lineWidth = 2
        shapeLayer.lineJoin = CAShapeLayerLineJoin.bevel

        tickView.layer.addSublayer(shapeLayer)
        shapeLayer.strokeEnd = 1.0
        shapeLayer.removeAllAnimations()
        shapeLayer.add(checkAnimation, forKey: "strokeEnd")
    }

    private func styleAsNotDone() {
        print("style as not done")
        nameTextView.textColor = .black
        let textAttributes = [NSAttributedString.Key: Any]()
        nameTextView.attributedText = NSAttributedString(string: nameTextView.text ?? "", attributes: textAttributes)

        shapeLayer.path = tickPath.cgPath
        shapeLayer.frame = circle.bounds
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.fillColor = nil
        shapeLayer.lineWidth = 2
        shapeLayer.lineJoin = CAShapeLayerLineJoin.bevel

        shapeLayer.strokeEnd = 0.0
        shapeLayer.removeAllAnimations()
        shapeLayer.add(reverseCheckAnimation, forKey: "strokeEnd")
    }

}
