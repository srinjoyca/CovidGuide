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
         let destinationLocation = CLLocationCoordinate2D(latitude: 37.3360, longitude: -121.9988)
         let sourcePin = customPin(pinTitle: "Me", pinSubTitle: "", location: sourceLocation)
         let destPin = customPin(pinTitle: "Kaiser Permanente", pinSubTitle: "", location: destinationLocation)
         self.mapView.addAnnotation(sourcePin)
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


