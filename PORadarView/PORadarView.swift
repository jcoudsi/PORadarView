//
//  PORadarView.swift
//  PORadarView
//
//  Created by Julien Coudsi on 16/12/2015.
//  Copyright (c) 2015 Julien Coudsi. All rights reserved.
//

import UIKit

let π: CGFloat = CGFloat(M_PI)

@IBDesignable public class PORadarView: UIView {

    private var radius: CGFloat = 0
    private var rectCenter: CGPoint = CGPoint.zero
    private var imageView: UIImageView?
    private var detectionItemShapeLayer: CAShapeLayer!

    private var isImageDisplayed = false
    private var isDetecting = false

    public var detectionItemColor: UIColor = UIColor.blueColor() {
        didSet {
            self.setNeedsDisplay()
        }
    }

    public var contentCircleColor: UIColor = UIColor.greenColor() {
        didSet {
            self.setNeedsDisplay()
        }
    }

    public required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
    }

    override public required init(frame: CGRect) {

        super.init(frame: frame)

        self.backgroundColor = UIColor.clearColor()
    }

    //#MARK: - Drawing

    override public func drawRect(rect: CGRect) {
        self.drawContentCicle(rect)
    }


    private func drawContentCicle(rect: CGRect) {

        self.rectCenter = CGPoint(x: CGRectGetMidX(rect), y: CGRectGetMidY(rect))
        self.radius = rect.size.width/2

        let contentCirclePath = UIBezierPath(arcCenter: self.rectCenter,
            radius: self.radius,
            startAngle: 0.0,
            endAngle: 2*π,
            clockwise: true)

        self.contentCircleColor.setFill()
        contentCirclePath.fill()
    }

    private func createDetectionItemPathAtStartDegreesAngle(startDegreesAngle: CGFloat, endDegreesAngle: CGFloat) -> UIBezierPath {

        let detectionItemPath = UIBezierPath(arcCenter: CGPoint(x: self.rectCenter.x, y:self.rectCenter.y),
            radius: self.radius,
            startAngle: convertToRadians(startDegreesAngle),
            endAngle: convertToRadians(startDegreesAngle) + convertToRadians(endDegreesAngle),
            clockwise: true)

        detectionItemPath.addLineToPoint(self.rectCenter)
        detectionItemPath.closePath()

        return detectionItemPath
    }


    private func createDetectionItemShapeLayer() -> CAShapeLayer {

        let detectionItemLayer = CAShapeLayer()
        detectionItemLayer.path = self.createDetectionItemPathAtStartDegreesAngle(0, endDegreesAngle: 30).CGPath
        detectionItemLayer.frame = CGPathGetBoundingBox(detectionItemLayer.path)
        detectionItemLayer.bounds = CGPathGetBoundingBox(detectionItemLayer.path)
        detectionItemLayer.fillColor = detectionItemColor.CGColor
        detectionItemLayer.anchorPoint = CGPoint(x: 0, y: 0)
        detectionItemLayer.position = self.rectCenter

        return detectionItemLayer

    }

    public func setImage(image: UIImage) {

        guard let imageView: UIImageView = UIImageView(image: image) else {
            return
        }

        let frameWidth = self.frame.size.width
        let frameHeight = self.frame.size.height
        let imageWidth =  frameWidth/2
        let imageHeight = frameHeight/2

        imageView.frame = CGRectMake(frameWidth / 2 - imageWidth/2, frameHeight / 2 - imageHeight/2, imageWidth, imageHeight)
        self.imageView = imageView

    }

    //#MARK: - Animation

    public func startAnimateDetection() {

        if (self.detectionItemShapeLayer == nil) {
            self.detectionItemShapeLayer = self.createDetectionItemShapeLayer()
        }

        self.layer.addSublayer(self.detectionItemShapeLayer)
        self.animate()
    }

    public func animate() {

        let animateRotation = CABasicAnimation(keyPath: "transform.rotation")
        animateRotation.toValue = M_PI*2
        animateRotation.additive = true
        animateRotation.repeatCount = Float.infinity
        animateRotation.duration = 5
        animateRotation.delegate = self

        self.detectionItemShapeLayer.addAnimation(animateRotation, forKey: "animateRadar")
    }

    public override func animationDidStart(anim: CAAnimation) {
        self.isDetecting = true
    }

    public override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        self.isDetecting = false
    }

    //#MARK: - Detection management

    public func startDetectionIfNeeded() {

        guard !self.isDetecting else {
            return
        }

        self.startAnimateDetection()

    }

    public func stopDetectionIfNeeded() {

        guard self.isDetecting else {
            return
        }

        self.detectionItemColor = self.contentCircleColor
        self.detectionItemShapeLayer?.removeAllAnimations()
        self.detectionItemShapeLayer.removeFromSuperlayer()
    }

    public func objectDetectedWithAutoStopDetection() {
        self.objectDetected()
        self.stopDetectionIfNeeded()
    }

    public func objectUndetectedWithAutoStopDetection() {
        self.objectUndetected()
        self.stopDetectionIfNeeded()
    }

    public func objectUndetectedWithAutoRestartDetection() {
        self.objectUndetected()
        self.startDetectionIfNeeded()
    }

    public func objectDetected() {

        guard !self.isImageDisplayed, let imageView = self.imageView else {
            return
        }

        self.addSubview(imageView)
        self.showImageWithAnimation(imageView)
        self.isImageDisplayed = true

    }

    public func objectUndetected() {
        self.hideImageWithAnimation()
        self.isImageDisplayed = false
    }


    //#MARK: - Image

    private func showImageWithAnimation(imageView: UIImageView) {

        UIView.animateWithDuration(0.3, animations: { () -> Void in
            imageView.transform = CGAffineTransformMakeScale(1.2, 1.2)

            }, completion: { (Bool) -> Void in

                UIView.animateWithDuration(0.4, animations: { () -> Void in
                    imageView.transform = CGAffineTransformMakeScale(0.8, 0.8)
                })
        })
    }

    private func hideImageWithAnimation() {

        guard let imageView = self.imageView else {
            return
        }

        UIView.animateWithDuration(0.3, animations: { () -> Void in
            imageView.transform = CGAffineTransformMakeScale(0.1, 0.1)

            }, completion: { (Bool) -> Void in
                imageView.removeFromSuperview()
        })
    }

    //#MARK: - Helpers

    private func convertToRadians(degrees: CGFloat) -> CGFloat {
        return (degrees*π)/180
    }

}
