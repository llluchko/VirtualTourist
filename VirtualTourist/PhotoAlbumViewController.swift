//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Latchezar Mladenov on 8/18/16.
//  Copyright © 2016 Latchezar Mladenov. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
	
	var pin: Pin? = nil
	
	// Flag for deleting pictures
	var isDeleting = false
	
	var editingFlag = false
	
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var bottomButton: UIButton!
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var noImagesLabel: UILabel!
	
	// Array of IndexPath - keeping track of index of selected cells
	var selectedIndexofCollectionViewCells = [NSIndexPath]()
	
	
	// MARK: - Core Data Convenience
	
	var sharedContext: NSManagedObjectContext {
		return CoreDataStack.sharedInstance().managedObjectContext
	}
	
	// Mark: - Fetched Results Controller
	
	// Lazily computed property pointing to the Photos entity objects, sorted by title, predicated on the pin.
	lazy var fetchedResultsController: NSFetchedResultsController = {
		
		// Create fetch request for photos which match the sent Pin.
		let fetchRequest = NSFetchRequest(entityName: "Photos")
		
		// Limit the fetch request to just those photos related to the Pin.
		fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin!)
		
		// Sort the fetch request by title, ascending.
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
		
		// Create fetched results controller with the new fetch request.
		let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
		
		return fetchedResultsController
	}()
	
	
	// MARK: - Life Cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: #selector(PhotoAlbumViewController.edit))
		bottomButton.addTarget(self, action: #selector(bottomButtonClicked), forControlEvents: .TouchUpInside)
		
		self.view.addSubview(bottomButton)
		
		bottomButton.hidden = false
		noImagesLabel.hidden = true
		
		mapView.delegate = self
		
		// Load the map
		loadMapView()
		
		collectionView.delegate = self
		collectionView.dataSource = self
		
		// Perform the fetch
		do {
			try fetchedResultsController.performFetch()
		} catch let error as NSError {
			print("\(error)")
		}
		
		// Set the delegate to this view controller
		fetchedResultsController.delegate = self
		
		// Subscirbe to notification so photos can be reloaded - catches the notification from FlickrConvenient
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PhotoAlbumViewController.photoReload(_:)), name: "downloadPhotoImage.done", object: nil)
	}
	
	// Inserting dispatch_async to ensure the closure always run in the main thread
	func photoReload(notification: NSNotification) {
		dispatch_async(dispatch_get_main_queue(), {
			self.collectionView.reloadData()
			
			// If no photos remaining, show the 'New Collection' button
			let numberRemaining = FlickrClient.sharedInstance().numOfPhotoDownloaded
			print("numberRemaining is from photoReload \(numberRemaining)")
			if numberRemaining <= 0 {
				self.bottomButton.hidden = false
			}
		})
	}
	
	private func reFetch() {
		do {
			try fetchedResultsController.performFetch()
		} catch let error as NSError {
			print("reFetch - \(error)")
		}
	}
	
	
	// Note: "new' images might overlap with previous collections of images
	func bottomButtonClicked(sender: UIButton!) {
		
		// Hiding the button once it's tapped, because I want to finish either deleting or reloading first
		bottomButton.hidden = true
		
		// If deleting flag is true, delete the photo
		if isDeleting == true
		{
			// Removing the photo that user selected one by one
			for indexPath in selectedIndexofCollectionViewCells {
				
				// Get photo associated with the indexPath.
				let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photos
				
				print("Deleting this -- \(photo)")
				
				// Remove the photo
				sharedContext.deleteObject(photo)
				
			}
			
			// Empty the array of indexPath after deletion
			selectedIndexofCollectionViewCells.removeAll()
			
			// Save the chanages to core data
			CoreDataStack.sharedInstance().saveContext()
			
			// Update cells
			reFetch()
			collectionView.reloadData()
			
			// Change the button to say 'New Collection' after deletion
			bottomButton.setTitle("New Collection", forState: UIControlState.Normal)
			bottomButton.hidden = false
			self.navigationItem.rightBarButtonItem?.enabled = true
			
			isDeleting = false
			
			// Else "New Collection" button is tapped
		} else {
			
			// 1. Empty the photo album from the previous set
			for photo in fetchedResultsController.fetchedObjects as! [Photos]{
				sharedContext.deleteObject(photo)
			}
			
			// 2. Save the chanages to core data
			CoreDataStack.sharedInstance().saveContext()
			
			// 3. Download a new set of photos with the current pin
			FlickrClient.sharedInstance().downloadPhotosForPin(pin!, completionHandler: {
				success, error in
				
				if success {
					dispatch_async(dispatch_get_main_queue(), {
						CoreDataStack.sharedInstance().saveContext()
					})
				} else {
					dispatch_async(dispatch_get_main_queue(), {
						print("error downloading a new set of photos")
						self.bottomButton.hidden = false
					})
				}
				// Update cells
				dispatch_async(dispatch_get_main_queue(), {
					self.reFetch()
					self.collectionView.reloadData()
				})
				
			})
		}
	}
	
	// Load map view for the current pin
	func loadMapView() {
		
		let point = MKPointAnnotation()
		
		point.coordinate = CLLocationCoordinate2DMake((pin?.latitude)!, (pin?.longitude)!)
		point.title = pin?.pinTitle
		mapView.addAnnotation(point)
		mapView.centerCoordinate = point.coordinate
		
		// Select the annotation so the title can be shown
		mapView.selectAnnotation(point, animated: true)
		
	}
	
	// Return the number of photos from fetchedResultsController
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
		
		let sectionInfo = self.fetchedResultsController.sections![section]
		print("Number of photos returned from fetchedResultsController #\(sectionInfo.numberOfObjects)")
		
		// If numberOfObjects is not zero, hide the noImagesLabel
		noImagesLabel.hidden = sectionInfo.numberOfObjects != 0
		
		return sectionInfo.numberOfObjects
	}
	
	func edit() {
		
		if editingFlag == false {
			editingFlag = true
			self.navigationItem.rightBarButtonItem?.enabled = false
			//bottomButton.setTitle("Tap photos to delete", forState: UIControlState.Normal)
		}
			
		else if editingFlag {
			//self.navigationItem.rightBarButtonItem?.enabled = true
			editingFlag = false
			bottomButton.hidden = false
		}
		
	}
	
	// Remove photos from an album when user select a cell or multiple cells
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
		
		if editingFlag == false{
			
			let myImageViewPage: ImageScrollView = self.storyboard?.instantiateViewControllerWithIdentifier("ImageScrollView") as! ImageScrollView
			let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photos
			
			// Pass the selected image
			myImageViewPage.selectedImage = photo.url!
			
			self.navigationController?.pushViewController(myImageViewPage, animated: true)
		}
			
		else if (editingFlag) {
			
			// Configure the UI of the collection item
			let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCollectionViewCell
			
			// When user deselect the cell, remove it from the selectedIndexofCollectionViewCells array
			if let index = selectedIndexofCollectionViewCells.indexOf(indexPath){
				selectedIndexofCollectionViewCells.removeAtIndex(index)
				cell.deleteButton.hidden = true
			} else {
				// Else, add it to the selectedIndexofCollectionViewCells array
				selectedIndexofCollectionViewCells.append(indexPath)
				cell.deleteButton.hidden = false
				bottomButton.setTitle("New Collection", forState: UIControlState.Normal)
			}
			
			// If the selectedIndexofCollectionViewCells array is not empty, show the 'Delete # photo(s)' button
			if selectedIndexofCollectionViewCells.count > 0 {
				
				print("Delete array has \(selectedIndexofCollectionViewCells.count) photo(s).")
				if selectedIndexofCollectionViewCells.count == 1{
					bottomButton.setTitle("Delete \(selectedIndexofCollectionViewCells.count) photo", forState: UIControlState.Normal)
				} else {
					bottomButton.setTitle("Delete \(selectedIndexofCollectionViewCells.count) photos", forState: UIControlState.Normal)
				}
				isDeleting = true
			} else{
				bottomButton.setTitle("New Collection", forState: UIControlState.Normal)
				isDeleting = false
			}
		}
		
	}
	
	// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
		
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCollectionViewCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
		let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photos
		//print("Photo URL from the collection view is \(photo.url)")
		
		cell.photoView.image = photo.image
		
		cell.deleteButton.hidden = true
		cell.deleteButton.layer.setValue(indexPath, forKey: "indexPath")
		
		// Trigger the action 'deletePhoto' when the button is tapped
		cell.deleteButton.addTarget(self, action: #selector(PhotoAlbumViewController.deletePhoto(_:)), forControlEvents: UIControlEvents.TouchUpInside)
		
		return cell
	}
	
	func deletePhoto(sender: UIButton){
		
		// I want to know if the cell is selected giving the indexPath
		let indexOfTheItem = sender.layer.valueForKey("indexPath") as! NSIndexPath
		
		// Get the photo associated with the indexPath
		let photo = fetchedResultsController.objectAtIndexPath(indexOfTheItem) as! Photos
		print("Delete cell selected from 'deletePhoto' is \(photo)")
		
		// When user deselected it, remove it from the selectedIndexofCollectionViewCells array
		if let index = selectedIndexofCollectionViewCells.indexOf(indexOfTheItem){
			selectedIndexofCollectionViewCells.removeAtIndex(index)
		}
		
		// Remove the photo
		sharedContext.deleteObject(photo)
		
		// Save to core data
		CoreDataStack.sharedInstance().saveContext()
		
		// Update selected cell
		reFetch()
		collectionView.reloadData()
	}
	
	
}
