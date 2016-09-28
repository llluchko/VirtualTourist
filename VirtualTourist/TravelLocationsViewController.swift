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
		
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: #selector(TravelLocationsViewController.edit))
		
		let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(TravelLocationsViewController.handleLongPress(_:)))
		
		longPressRecogniser.minimumPressDuration = 1.0
		mapView.addGestureRecognizer(longPressRecogniser)
		
		// Set the map view delegate
		mapView.delegate = self
		deletePinsLabel.hidden = true
		
		addSavedPinsToMap()
		
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
	
	// When the edit button is clicked, show the 'Done' button and flag the editingPins to true
	func edit() {
		if editingPins == false {
			editingPins = true
			deletePinsLabel.hidden = false
			self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: #selector(TravelLocationsViewController.edit))
		}
			
		else if editingPins {
			self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: #selector(TravelLocationsViewController.edit))
			editingPins = false
			deletePinsLabel.hidden = true
		}
	}
	
	// Pressing and holding a point on the map creates a new Pin object and adds it to the map
	func handleLongPress(getstureRecognizer : UIGestureRecognizer){
		
		// If it's in editing mode, do nothing
		if (editingPins) {
			return
		} else {
			
			if getstureRecognizer.state != .Began { return }
			
			let touchPoint = getstureRecognizer.locationInView(self.mapView)
			let touchMapCoordinate = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
			
			let annotation = MKPointAnnotation()
			annotation.coordinate = touchMapCoordinate
			
			let newPin = Pin(lat: annotation.coordinate.latitude, long: annotation.coordinate.longitude, context: sharedContext)
			
			// Saving to core data
			CoreDataStack.sharedInstance().saveContext()
			
			// Adding the newPin to the pins array
			pins.append(newPin)
			
			// Adding the newPin to the map
			mapView.addAnnotation(annotation)
			
			// Downloading photos for new pin (only download it if it's a new pin)
			FlickrClient.sharedInstance().downloadPhotosForPin(newPin) { (success, error) in print("downloadPhotosForPin is success:\(success) - error:\(error)") }
			
			// Find out the location name based on the coordinates
			let coordinates = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
			
			let geoCoder = CLGeocoder()
			
			geoCoder.reverseGeocodeLocation(coordinates, completionHandler: { (placemark, error) -> Void in
				if error != nil {
					print("Error: \(error!.localizedDescription)")
					return
				}
				if placemark!.count > 0 {
					let pm = placemark![0] as CLPlacemark
					if (pm.locality != nil) && (pm.country != nil) {
						// Assigning the city and country to the annotation's title
						annotation.title = "\(pm.locality!), \(pm.country!)"
					}
				} else {
					print("Error with placemark")
				}
			})
			
		}
	}
	
	// Mark: - When a pin is tapped, it will transition to the Phone Album View Controller
	
	// Start by updating the view for the annotation. This is necessary because it allows you to intercept taps on the annotation's view (the pin).
	func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
		let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
		annotationView.canShowCallout = false
		
		return annotationView
	}
	
	
	func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
		
		mapView.deselectAnnotation(view.annotation, animated: true)
		guard let annotation = view.annotation else { /* no annotation */ return }
		
		let title = annotation.title!
		print(annotation.title)
		
		selectedPin = nil
		
		for pin in pins {
			
			if annotation.coordinate.latitude == pin.latitude && annotation.coordinate.longitude == pin.longitude {
				
				selectedPin = pin
				
				if editingPins {
					print("Deleting pin - verify core data is deleting as well")
					sharedContext.deleteObject(selectedPin!)
					
					// Deleting selected pin on map
					self.mapView.removeAnnotation(annotation)
					
					// Save the chanages to core data
					CoreDataStack.sharedInstance().saveContext()
					
				} else {
					
					if title != nil {
						pin.pinTitle = title!
						
					} else {
						pin.pinTitle = "This pin has no name"
					}
					// Move to the Phone Album View Controller
					self.performSegueWithIdentifier("PhotoAlbum", sender: nil)
				}
			}
		}
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if (segue.identifier == "PhotoAlbum") {
			let viewController = segue.destinationViewController as! PhotoAlbumViewController
			viewController.pin = selectedPin
		}
	}


}

