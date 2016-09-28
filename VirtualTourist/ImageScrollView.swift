//
//  ImageScrollView.swift
//  VirtualTourist
//
//  Created by Latchezar Mladenov on 9/22/16.
//  Copyright © 2016 Latchezar Mladenov. All rights reserved.
//

import Foundation
import UIKit

class ImageScrollView: UIViewController {
	
	
	@IBOutlet weak var myImageView: UIImageView!
	
	var selectedImage: String = ""
	
	override func viewDidLoad() {
		super.viewDidLoad()
		print(selectedImage)
		
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		let imageUrl = NSURL(string:self.selectedImage)
		let imageData = NSData(contentsOfURL: imageUrl!)
		if (imageData != nil)
		{
			self.myImageView.image  = UIImage(data: imageData!)
		}
		
	}
	
}
