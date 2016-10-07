//
//  Pin.swift
//  VirtualTourist
//
//  Created by Latchezar Mladenov on 8/19/16.
//  Copyright © 2016 Latchezar Mladenov. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class Pin: NSManagedObject {
	
	var coordinate: CLLocationCoordinate2D {
		return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
	}
	
	override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
		super.init(entity: entity, insertIntoManagedObjectContext: context)
	}
	
	init(lat: Double, long: Double, context: NSManagedObjectContext) {
		let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
		super.init(entity: entity, insertIntoManagedObjectContext: context)
		
		self.latitude = lat
		self.longitude = long
		self.pageNumber = 0
		
	}
	
	var sharedContext: NSManagedObjectContext {
		return CoreDataStack.sharedInstance().managedObjectContext
	}
	
}
