//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Latchezar Mladenov on 8/3/16.
//  Copyright © 2016 Latchezar Mladenov. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import CoreLocation

class TravelLocationsViewController: UIViewController {
	@IBOutlet weak var mapView: MKMapView!

	@IBOutlet weak var deletePinsLabel: UILabel!
	
	@IBOutlet weak var editButton: UINavigationItem!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

