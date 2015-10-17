//
//  LocationGalleryViewController.swift
//  VirtualTourist
//
//  Created by Ian Gristock on 13/10/2015.
//  Copyright © 2015 Ian Gristock. All rights reserved.
//

import UIKit
import MapKit
import CoreData
class LocationGalleryViewController: UIViewController {

    var pin: Pin!
    
    // Keep track of insertions, deletions and updates
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin!);
        
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
        }()
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let mapRegion = MKCoordinateRegionMakeWithDistance(pin.coordinate, 3200, 3200)
        mapView.region = mapRegion
        mapView.addAnnotation(pin)
        // Set delegate
        fetchedResultsController.delegate = self
        
        // Perform fetch results
        let repo = GalleryRepository.sharedInstance();
        repo.getPhotos(pin, context:sharedContext,   completionHandler: {
            a,b in
            }, errorHandler: {
                error in
        })
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension LocationGalleryViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
    }
    
    // May be called multiple times, once for each Test instance being added to Core Data
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            insertedIndexPaths.append(newIndexPath!)
            break
        case .Delete:
            deletedIndexPaths.append(indexPath!)
            break
        case .Update:
            updatedIndexPaths.append(indexPath!)
            break
        case .Move:
            print("move an item")
            break
        default:
            break
        }
    }
    func controller(controller: NSFetchedResultsController,
        didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
        atIndex sectionIndex: Int,
        forChangeType type: NSFetchedResultsChangeType) {
            
            switch type {
            case .Insert:
                collectionView.insertSections(NSIndexSet(index: sectionIndex))
                
            case .Delete:
                collectionView.deleteSections(NSIndexSet(index: sectionIndex))
                
            default:
                return
            }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        collectionView.performBatchUpdates({ () -> Void in
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItemsAtIndexPaths([indexPath])
            }
            }, completion:nil)
    }
}

extension LocationGalleryViewController: UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // Get reference to Photo object at cell in question
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        // Get reference to PhotoCell object at cell in question
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("GalleryCell", forIndexPath: indexPath) as! GalleryViewCell
        
        FlickrClient.sharedInstance().getImage(photo.srcUrl!, completionHandler: {
            responseCode, data in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let image = UIImage(data: data)

                // Assign image to image view of cell
                cell.image.image = image
                cell.indicator.stopAnimating()
                // Enable "New Collection" button again after all images have been downloaded...
            })
            }, errorHandler: {
            error in
                print(error)
        });
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate Methods
    
    // Handle tap on a photo
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // Remove from Core Data (Managed Object Context) and implicitly from device and collection view
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        self.sharedContext.deleteObject(photo)
    }}

extension LocationGalleryViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        //reuseID and pinView
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID) as? MKPinAnnotationView
        _ = mapView.gestureRecognizers![0] as! UILongPressGestureRecognizer
        //if no pinView, then create one
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView!.animatesDrop = true
            pinView!.draggable = false
            
        } else {
            //otherwise, add annotation
            pinView!.annotation = annotation
        }
        
        return pinView
    }

}