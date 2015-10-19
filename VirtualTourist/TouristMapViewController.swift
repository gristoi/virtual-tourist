//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Ian Gristock on 04/10/2015.
//  Copyright © 2015 Ian Gristock. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import Foundation

class TouristMapViewController: UIViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!

    struct RegionBoundary {
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let LatitudeDelta = "latitudeDelta"
        static let LongitudeDelta = "longitudeDelta"
    }
    
    //# Mark: - Core Data Convenience. Useful for fetching, adding and saving objects
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }
    
    //# MARK: - NSFetchedResultsController
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
        }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: "onLongPressGesture:")
        longPressGesture.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPressGesture)
        setMapRegion()
        fetchedResultsController.delegate = self
        getPins()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Fetch all pins
    func getPins() -> Void {
        do {
            try fetchedResultsController.performFetch()
        } catch _ {
            print("no pins")
        }
        if let pins = fetchedResultsController.fetchedObjects as? [Pin] {
            mapView.addAnnotations(pins)
        }
    }
    
    func setMapRegion() {
        
        let latitude = NSUserDefaults.standardUserDefaults().doubleForKey(RegionBoundary.Latitude)
        if(latitude > 0){
            let longitude = NSUserDefaults.standardUserDefaults().doubleForKey(RegionBoundary.Longitude)
            let latitudeDelta = NSUserDefaults.standardUserDefaults().doubleForKey(RegionBoundary.LatitudeDelta)
            let longitudeDelta = NSUserDefaults.standardUserDefaults().doubleForKey(RegionBoundary.LongitudeDelta)
            
            mapView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2DMake(latitude, longitude), MKCoordinateSpanMake(latitudeDelta, longitudeDelta)), animated: false)
        }
    }
        
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        NSUserDefaults.standardUserDefaults().setDouble(mapView.centerCoordinate.latitude, forKey: RegionBoundary.Latitude)
        NSUserDefaults.standardUserDefaults().setDouble(mapView.centerCoordinate.longitude, forKey: RegionBoundary.Longitude)
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.span.latitudeDelta, forKey: RegionBoundary.LatitudeDelta)
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.span.longitudeDelta, forKey: RegionBoundary.LongitudeDelta)
    }
    
    func onLongPressGesture(sender: UIGestureRecognizer) {
        let touchPoint = sender.locationInView(sender.view)
        
        let newCoordinate:CLLocationCoordinate2D = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        
        let pinAnnotation = PinAnnotation()
        
        pinAnnotation.setCoordinate(newCoordinate)
        
        let dictionary: [String: AnyObject] = [
            Pin.Keys.Latitude: newCoordinate.latitude,
            Pin.Keys.Longitude: newCoordinate.longitude
        ]
        print(dictionary)
        
        // Add pin only at the gestureRecognizer .Began state. This is to prevent duplicate pins from being added if the user continues to hold press.
        if sender.state == UIGestureRecognizerState.Began {
            let newPin = Pin(dictionary: dictionary, context: self.sharedContext)
            
            self.mapView.addAnnotation(newPin)
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showGallery" {
            let galleryVC = segue.destinationViewController as! LocationGalleryViewController
            let pin : Pin = sender as! Pin
            galleryVC.pin = pin
        }
    }
}

extension TouristMapViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
       
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin") as? MKPinAnnotationView
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
                pinView!.draggable = false
                pinView!.canShowCallout = false
                pinView!.animatesDrop = true
            }
            else {
                pinView!.annotation = annotation
            }
            return pinView
            
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let pin = view.annotation as! Pin
        performSegueWithIdentifier("showGallery", sender: pin)
    }
    
}
