//
//  ViewController.swift
//  connected-cup
//
//  Created by COUDSI Julien on 29/10/2015.
//  Copyright (c) 2015 Julien Coudsi. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    var isAnimating:Bool = false
    var displayFromPairing:Bool = false
    
    @IBOutlet weak var radarView: PORadarView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.radarView.setImage(UIImage(named:"new-item-example")!)
        
        self.configureForExample1(self)

    }
    
    
    @IBAction func configureForExample1(sender: AnyObject) {
        
        self.radarView.contentCircleColor = ColorHelper.getLightRedColor()
        self.radarView.detectionItemColor = ColorHelper.getMediumRedColor()
        
        self.radarView.objectUndetectedWithAutoRestartDetection()
    }
    
    @IBAction func configureForExample2(sender: AnyObject) {
        
        self.radarView.contentCircleColor = ColorHelper.getMediumOrangeColor()
        self.radarView.detectionItemColor = ColorHelper.getMediumRedColor()
        
        self.radarView.objectDetected()
        self.radarView.startDetection()
    }
    
    @IBAction func configureForExample3(sender: AnyObject) {
        
        self.radarView.contentCircleColor = ColorHelper.getMediumGreenColor()
        
        self.radarView.objectDetectedWithAutoStopDetection()
    }
    
}

