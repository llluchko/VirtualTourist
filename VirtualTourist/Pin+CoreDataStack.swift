//
//  Pin+CoreDataStack.swift
//  VirtualTourist
//
//  Created by Latchezar Mladenov on 8/19/16.
//  Copyright © 2016 Latchezar Mladenov. All rights reserved.
//

import Foundation
import CoreData

extension Pin {
	
	@NSManaged var latitude: Double
	@NSManaged var longitude: Double
	@NSManaged var pageNumber: NSNumber?
	@NSManaged var photos: NSSet?
	@NSManaged var pinTitle: String?

}
