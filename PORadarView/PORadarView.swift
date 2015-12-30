//
//  RadarView.swift
//  ios-radar-view
//
//  Created by Julien Coudsi on 16/12/2015.
//  Copyright (c) 2015 Julien Coudsi. All rights reserved.
//

import UIKit

let π:CGFloat = CGFloat(M_PI)

@IBDesignable public class PORadarView: UIView {
    
    private var lineCircleStartAngleInDegrees : CGFloat = 0
    private var lineCircleWidthInDegrees : CGFloat = 30
    private var radius:CGFloat = 0
    private var rectCenter:CGPoint = CGPoint(x: 0,y: 0)
    private var imageView:UIImageView?
    private var detectionItemShapeLayer:CAShapeLayer?
    
    public var isImageDisplayed = false
    public var isDetecting = false

    public var detectionItemColor:UIColor = UIColor.blueColor()
    public var contentCircleColor:UIColor = UIColor.greenColor()
    
    public required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    override public required init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
    }
    
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
    
    private func createDetectionItemPathAtStartDegreesAngle(startDegreesAngle:CGFloat, endDegreesAngle:CGFloat) -> UIBezierPath {

        let detectionItemPath = UIBezierPath(arcCenter: self.rectCenter,
            radius: self.radius,
            startAngle: convertToRadians(startDegreesAngle),
            endAngle: convertToRadians(startDegreesAngle) + convertToRadians(endDegreesAngle),
            clockwise: true)
        
        detectionItemPath.addLineToPoint(self.rectCenter)
        detectionItemPath.closePath()
        
        return detectionItemPath
    }
    
    
    public func setImage(image:UIImage) {
        
        guard let imageView:UIImageView = UIImageView(image: image) else {
            return
        }
        
        let frameWidth = self.frame.size.width
        let frameHeight = self.frame.size.height
        let imageWidth =  frameWidth/2
        let imageHeight = frameHeight/2
        
        imageView.frame = CGRectMake(frameWidth / 2 - imageWidth/2, frameHeight / 2 - imageHeight/2, imageWidth, imageHeight)
        self.imageView = imageView

    }
    
    public func startAnimateDetection() {
        
        if (detectionItemShapeLayer == nil) {
            
            detectionItemShapeLayer = CAShapeLayer()
            detectionItemShapeLayer?.fillColor = detectionItemColor.CGColor
            self.layer.addSublayer(detectionItemShapeLayer!)
        }
        
        animate()
    }
    
    public func animate() {
        
        let anim:CABasicAnimation = CABasicAnimation(keyPath: "path")
        anim.duration = 0.1
        anim.fromValue = self.createDetectionItemPathAtStartDegreesAngle(self.lineCircleStartAngleInDegrees, endDegreesAngle: self.lineCircleWidthInDegrees).CGPath
        
        if (self.lineCircleStartAngleInDegrees+10 >= 360) {
            self.lineCircleStartAngleInDegrees = 0
        } else {
            self.lineCircleStartAngleInDegrees+=10
        }
        
        anim.toValue = self.createDetectionItemPathAtStartDegreesAngle(self.lineCircleStartAngleInDegrees, endDegreesAngle: self.lineCircleWidthInDegrees).CGPath
        anim.delegate = self;
        anim.removedOnCompletion = false;
        anim.fillMode = kCAFillModeForwards;
        
        detectionItemShapeLayer!.addAnimation(anim, forKey: "animateRadar")
    }
    
    override public func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        
        if (self.isDetecting) {
            animate()
        }
    }

    public func startDetection() {
        
        if (!self.isDetecting) {
            startAnimateDetection()
            self.isDetecting = true
        }
        
        self.setNeedsDisplay()
    }
    
    public func stopDetection() {
        
        if (self.isDetecting) {
            self.isDetecting = false
            self.detectionItemColor = self.contentCircleColor
            self.detectionItemShapeLayer?.removeAllAnimations()
        }
        self.setNeedsDisplay()
    }
    
    
    public func objectDetected() {
        
        if (!self.isImageDisplayed) {
        
            self.addSubview(self.imageView!)
            self.showImageWithAnimation()
            self.isImageDisplayed = true
        }
    }
    
    public func objectDetectedWithAutoStopDetection() {
        self.objectDetected()
        self.stopDetection()
    }
    
    public func objectUndetectedWithAutoStopDetection() {
        self.objectUndetected()
        self.stopDetection()
    }
    
    public func objectUndetectedWithAutoRestartDetection() {
        self.objectUndetected()
        self.startDetection()
    }
    
    public func objectUndetected() {
        self.hideImageWithAnimation()
    }
    
    private func showImageWithAnimation() {
        
        weak var weakSelf = self
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            weakSelf!.imageView!.transform = CGAffineTransformMakeScale(1.2, 1.2)
            
            }, completion: { (Bool) -> Void in
                
                UIView.animateWithDuration(0.4, animations: { () -> Void in
                    weakSelf!.imageView!.transform = CGAffineTransformMakeScale(0.8, 0.8)
                })
        })
    }
    
    private func hideImageWithAnimation() {
        
        weak var weakSelf = self
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            weakSelf!.imageView?.transform = CGAffineTransformMakeScale(0.1, 0.1)
            
            }, completion: { (Bool) -> Void in
                weakSelf!.imageView?.removeFromSuperview()
                weakSelf!.isImageDisplayed = false
        })
    }
    
    private func convertToRadians(degrees:CGFloat) -> CGFloat  {
        return (degrees*π)/180
    }
    
    
    
    
    
}
