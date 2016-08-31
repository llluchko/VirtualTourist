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

class TravelLocationsViewController: UIViewController, MKMapViewDelegate {
	@IBOutlet weak var mapView: MKMapView!

	@IBOutlet weak var deletePinsLabel: UILabel!
	
	@IBOutlet weak var editButton: UINavigationItem!
	
	var pins = [Pin]()
	var selectedPin: Pin? = nil
	
	// Flag for editing mode
	var editingPins = false
	
	// Core Data
	var sharedContext: NSManagedObjectContext {
		return CoreDataStack.sharedInstance().managedObjectContext
	}
	
	func fetchAllPins() -> [Pin] {
		
		// Create the fetch request
		let fetchRequest = NSFetchRequest(entityName: "Pin")
		
		// Execute the fetch request
		do {
			return try sharedContext.executeFetchRequest(fetchRequest) as! [Pin]
		} catch {
			print("error in fetch")
			return [Pin]()
		}
	}

	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// TO-DO: - Add long press handle
		
		// Set the map view delegate
		mapView.delegate = self
		
		// TO-DO: - Add Delete label
		
		// addSavedPinsToMap()
		
	}

	// Find saved pins and show it on the map
	func addSavedPinsToMap() {
		
		pins = fetchAllPins()
		print("Pins in core data are \(pins.count)")
		
		for pin in pins {
			let annotation = MKPointAnnotation()
			annotation.coordinate = pin.coordinate
			annotation.title = pin.pinTitle
			mapView.addAnnotation(annotation)
		}
	}
	
	// TO-DO : - When a pin is tapped, it will transition to the Phone Album View Controller
	
	// TO-DO: Start by updating the view for the annotation. This is necessary because it allows you to intercept taps on the annotation's view (the pin).

}

