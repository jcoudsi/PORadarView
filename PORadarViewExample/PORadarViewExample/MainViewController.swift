//
//  ViewController.swift
//  connected-cup
//
//  Created by COUDSI Julien on 29/10/2015.
//  Copyright (c) 2015 Julien Coudsi. All rights reserved.
//

import UIKit
import PORadarView

class MainViewController: UIViewController {

    var isAnimating: Bool = false
    var displayFromPairing: Bool = false
    var radarView: PORadarView!

    @IBOutlet weak var radarContainerView: UIView!

    override func viewDidLoad() {

        super.viewDidLoad()

        self.radarView = PORadarView(frame: self.radarContainerView.bounds)
        self.radarView.setImage(UIImage(named:"new-item-example")!)

        self.radarContainerView.addSubview(self.radarView)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.configureForExample1(self)
    }


    @IBAction func configureForExample1(_ sender: AnyObject) {

        self.radarView.contentCircleColor = ColorHelper.getLightRedColor()
        self.radarView.detectionItemColor = ColorHelper.getMediumRedColor()

        self.radarView.objectUndetectedWithAutoRestartDetection()
    }

    @IBAction func configureForExample2(_ sender: AnyObject) {

        self.radarView.contentCircleColor = ColorHelper.getMediumOrangeColor()
        self.radarView.detectionItemColor = ColorHelper.getMediumRedColor()

        self.radarView.objectDetected()
        self.radarView.startDetectionIfNeeded()
    }

    @IBAction func configureForExample3(_ sender: AnyObject) {

        self.radarView.contentCircleColor = ColorHelper.getMediumGreenColor()

        self.radarView.objectDetectedWithAutoStopDetection()
    }

}
