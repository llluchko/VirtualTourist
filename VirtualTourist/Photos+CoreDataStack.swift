//
//  Photos+CoreDataStack.swift
//  VirtualTourist
//
//  Created by Latchezar Mladenov on 8/20/16.
//  Copyright © 2016 Latchezar Mladenov. All rights reserved.
//

import Foundation
import CoreData

extension Photos {
	
	@NSManaged var url: String?
	@NSManaged var id: String?
	@NSManaged var title: String?
	@NSManaged var filePath: String?
	@NSManaged var pin: Pin?
}