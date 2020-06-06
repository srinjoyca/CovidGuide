//
//  ViewController.swift
//  CovidGuide
//
//  Created by Srinjoy Dutta on 6/5/20.
//  Copyright © 2020 Srinjoy Dutta. All rights reserved.
//
import CoreLocation
import MapKit
import UIKit

extension CLLocationCoordinate2D {
    //distance in meters, as explained in CLLoactionDistance definition
    func distance(from: CLLocationCoordinate2D) -> CLLocationDistance {
        let destination=CLLocation(latitude:from.latitude,longitude:from.longitude)
        return CLLocation(latitude: latitude, longitude: longitude).distance(from: destination)
    }
}

class customPin: NSObject, MKAnnotation{
    var coordinate : CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    init(pinTitle:String,pinSubTitle:String, location:CLLocationCoordinate2D){
        self.title = pinTitle
        self.subtitle = pinSubTitle
        self.coordinate = location
        
    }
}
class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer =  MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 4.0
        return renderer
    }
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
            manager.stopUpdatingLocation()
            render(location)
        }
    }
    func render(_ location: CLLocation){
        
        let sourceLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                                longitude: location.coordinate.longitude)
        let sourcePin = customPin(pinTitle: "Me", pinSubTitle: "", location: sourceLocation)
        self.mapView.addAnnotation(sourcePin)
        
        let destinationLocation1 = CLLocationCoordinate2D(latitude: 37.3360, longitude: -121.9988)
        let destPin1 = customPin(pinTitle: "Kaiser Permanente", pinSubTitle: "", location: destinationLocation1)
        
        let destinationLocation2 = CLLocationCoordinate2D(latitude: 37.35143, longitude: -121.9919)
        let destPin2 = customPin(pinTitle: "Instant Urgent Care", pinSubTitle: "", location: destinationLocation2)
        
        let destinationLocation3 = CLLocationCoordinate2D(latitude: 37.3240, longitude: -121.9470)
        let destPin3 = customPin(pinTitle: "Forward Clinic", pinSubTitle: "", location: destinationLocation3)
        
        let destinations = [destinationLocation1, destinationLocation2, destinationLocation3]
        let destinationPins = [destPin1, destPin2, destPin3]
        
        var minDistance = 10000000.000
        var destinationLocation = destinationLocation1
        var destPin = destPin1
        var i = 0
        for destination in destinations {
            let distance = sourceLocation.distance(from: destination)
            print(distance)
            if(distance < minDistance){
                minDistance = distance
                destinationLocation = destination
                destPin = destinationPins[i]
            }
            i+=1
        }
                        
        self.mapView.addAnnotation(destPin)
        let sourcePlaceMark = MKPlacemark(coordinate: sourceLocation)
        let destinationPlaceMark = MKPlacemark(coordinate: destinationLocation)
                
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        directionRequest.transportType = .automobile
         
        let directions = MKDirections(request: directionRequest)
        directions.calculate{(response, error) in
            guard let directionResonse = response else{
                if let error = error{
                    print("we have an error in getting directions==\(error.localizedDescription)")
                }
                return
            }
            let route = directionResonse.routes[0]
            self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    
    
}


