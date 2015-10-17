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

class TouristMapViewController: UIViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var pins = [Pin]()

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
        pins = getPins()
        mapView.addAnnotations(pins)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Fetch all pins
    func getPins() -> [Pin] {
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        do {
            let results = try sharedContext.executeFetchRequest(fetchRequest) as! [Pin]
            return results
            } catch _ as NSError {
                print("no pins found")
            }
        return []
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
        print("region changed")
        NSUserDefaults.standardUserDefaults().setDouble(mapView.centerCoordinate.latitude, forKey: RegionBoundary.Latitude)
        NSUserDefaults.standardUserDefaults().setDouble(mapView.centerCoordinate.longitude, forKey: RegionBoundary.Longitude)
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.span.latitudeDelta, forKey: RegionBoundary.LatitudeDelta)
        NSUserDefaults.standardUserDefaults().setDouble(mapView.region.span.longitudeDelta, forKey: RegionBoundary.LongitudeDelta)
    }
    
    func onLongPressGesture(sender: UIGestureRecognizer) {
        let touchPoint = sender.locationInView(mapView)
        
        let newCoordinate:CLLocationCoordinate2D = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        
        let newannotation = MKPointAnnotation()
        
        newannotation.coordinate = newCoordinate
        
        let dictionary: [String: AnyObject] = [
            Pin.Keys.Latitude: newCoordinate.latitude,
            Pin.Keys.Longitude: newCoordinate.longitude
        ]
        print(dictionary)
        
        // Add pin only at the gestureRecognizer .Began state. This is to prevent duplicate pins from being added if the user continues to hold press.
        if sender.state == UIGestureRecognizerState.Began {
            
            dispatch_async(dispatch_get_main_queue()){
                
                let newPin = Pin(dictionary: dictionary, context: self.sharedContext)
                
                self.mapView.addAnnotation(newPin)
                
                self.pins.append(newPin)
                
                CoreDataStackManager.sharedInstance().saveContext()
            }
        }
    }
}

extension TouristMapViewController: MKMapViewDelegate {
    
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
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        print("selected")
        let locationGallery = self.storyboard?.instantiateViewControllerWithIdentifier("LocationGallery") as! LocationGalleryViewController
        locationGallery.pin = view.annotation as! Pin
       // photoVC.lat = view.annotation.coordinate.latitude
       // photoVC.lon = view.annotation.coordinate.longitude
        self.navigationController?.pushViewController(locationGallery, animated: true)    }
    
}
