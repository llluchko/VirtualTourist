//
//  PhotoCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Latchezar Mladenov on 9/22/16.
//  Copyright © 2016 Latchezar Mladenov. All rights reserved.
//

import Foundation
import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
	
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var photoView: UIImageView!
	@IBOutlet weak var deleteButton: UIButton!
	
	override func prepareForReuse() {
		
		super.prepareForReuse()
		
		if photoView.image == nil {
			dispatch_async(dispatch_get_main_queue()) {
				self.activityIndicator.startAnimating()
			}
		}
	}
	
}
