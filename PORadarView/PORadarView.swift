//
//  PORadarView.swift
//  PORadarView
//
//  Created by Julien Coudsi on 16/12/2015.
//  Copyright (c) 2015 Julien Coudsi. All rights reserved.
//

import UIKit

let π: CGFloat = CGFloat(M_PI)

@IBDesignable open class PORadarView: UIView, CAAnimationDelegate {
    
    fileprivate var radius: CGFloat = 0
    fileprivate var rectCenter: CGPoint = CGPoint.zero
    fileprivate var imageView: UIImageView?
    fileprivate var detectionItemShapeLayer: CAShapeLayer!
    
    fileprivate var isImageDisplayed = false
    fileprivate var isDetecting = false
    
    open var detectionItemColor: UIColor = UIColor.blue {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    open var contentCircleColor: UIColor = UIColor.green {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    override public required init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
    }
    
    //#MARK: - Drawing
    
    override open func draw(_ rect: CGRect) {
        self.drawContentCicle(rect: rect)
    }
    
    
    fileprivate func drawContentCicle(rect: CGRect) {
        
        self.rectCenter = CGPoint(x: rect.midX, y: rect.midY)
        self.radius = rect.size.width/2
        
        let contentCirclePath = UIBezierPath(arcCenter: self.rectCenter,
                                             radius: self.radius,
                                             startAngle: 0.0,
                                             endAngle: 2*π,
                                             clockwise: true)
        
        self.contentCircleColor.setFill()
        contentCirclePath.fill()
    }
    
    fileprivate func createDetectionItemPath(startDegreesAngle: CGFloat, endDegreesAngle: CGFloat) -> UIBezierPath {
        
        let detectionItemPath = UIBezierPath(arcCenter: CGPoint(x: self.rectCenter.x, y:self.rectCenter.y),
                                             radius: self.radius,
                                             startAngle: convertToRadians(degrees: startDegreesAngle),
                                             endAngle: convertToRadians(degrees: startDegreesAngle) + convertToRadians(degrees: endDegreesAngle),
                                             clockwise: true)
        
        detectionItemPath.addLine(to: self.rectCenter)
        detectionItemPath.close()
        
        return detectionItemPath
    }
    
    
    fileprivate func createDetectionItemShapeLayer() -> CAShapeLayer {
        
        let detectionItemLayer = CAShapeLayer()
        
        detectionItemLayer.path = self.createDetectionItemPath(startDegreesAngle: 0, endDegreesAngle: 30).cgPath
        
        if let detectionItemLayerPath = detectionItemLayer.path {
            
            detectionItemLayer.frame = detectionItemLayerPath.boundingBox
            detectionItemLayer.bounds = detectionItemLayerPath.boundingBox
            detectionItemLayer.fillColor = detectionItemColor.cgColor
            detectionItemLayer.anchorPoint = CGPoint(x: 0, y: 0)
            detectionItemLayer.position = self.rectCenter
        }
        
        return detectionItemLayer
        
    }
    
    open func setImage(_ image: UIImage) {
        
        guard let imageView: UIImageView = UIImageView(image: image) else {
            return
        }
        
        let frameWidth = self.frame.size.width
        let frameHeight = self.frame.size.height
        let imageWidth =  frameWidth/2
        let imageHeight = frameHeight/2
        
        imageView.frame = CGRect(x: frameWidth / 2 - imageWidth/2, y: frameHeight / 2 - imageHeight/2, width: imageWidth, height: imageHeight)
        self.imageView = imageView
        
    }
    
    //#MARK: - Animation
    
    open func startAnimateDetection() {
        
        if (self.detectionItemShapeLayer == nil) {
            self.detectionItemShapeLayer = self.createDetectionItemShapeLayer()
        }
        
        self.layer.addSublayer(self.detectionItemShapeLayer)
        self.animate()
    }
    
    open func animate() {
        
        let animateRotation = CABasicAnimation(keyPath: "transform.rotation")
        animateRotation.toValue = M_PI*2
        animateRotation.isAdditive = true
        animateRotation.repeatCount = Float.infinity
        animateRotation.duration = 5
        animateRotation.delegate = self
        
        self.detectionItemShapeLayer.add(animateRotation, forKey: "animateRadar")
    }
    
    open func animationDidStart(_ anim: CAAnimation) {
        self.isDetecting = true
    }
    
    open func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        self.isDetecting = false
    }
    
    //#MARK: - Detection management
    
    open func startDetectionIfNeeded() {
        
        guard !self.isDetecting else {
            return
        }
        
        self.startAnimateDetection()
        
    }
    
    open func stopDetectionIfNeeded() {
        
        guard self.isDetecting else {
            return
        }
        
        self.detectionItemColor = self.contentCircleColor
        self.detectionItemShapeLayer?.removeAllAnimations()
        self.detectionItemShapeLayer.removeFromSuperlayer()
    }
    
    open func objectDetectedWithAutoStopDetection() {
        self.objectDetected()
        self.stopDetectionIfNeeded()
    }
    
    open func objectUndetectedWithAutoStopDetection() {
        self.objectUndetected()
        self.stopDetectionIfNeeded()
    }
    
    open func objectUndetectedWithAutoRestartDetection() {
        self.objectUndetected()
        self.startDetectionIfNeeded()
    }
    
    open func objectDetected() {
        
        guard !self.isImageDisplayed, let imageView = self.imageView else {
            return
        }
        
        self.addSubview(imageView)
        self.showImageWithAnimation(imageView)
        self.isImageDisplayed = true
        
    }
    
    open func objectUndetected() {
        self.hideImageWithAnimation()
        self.isImageDisplayed = false
    }
    
    
    //#MARK: - Image
    
    fileprivate func showImageWithAnimation(_ imageView: UIImageView) {
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            imageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            
            }, completion: { (Bool) -> Void in
                
                UIView.animate(withDuration: 0.4, animations: { () -> Void in
                    imageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                })
        })
    }
    
    fileprivate func hideImageWithAnimation() {
        
        guard let imageView = self.imageView else {
            return
        }
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            imageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            
            }, completion: { (Bool) -> Void in
                imageView.removeFromSuperview()
        })
    }
    
    //#MARK: - Helpers
    
    fileprivate func convertToRadians(degrees: CGFloat) -> CGFloat {
        return (degrees*π)/180
    }
    
}
