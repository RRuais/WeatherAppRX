//
//  MapViewController.swift
//  WeatherAppRX
//
//  Created by Rich Ruais on 4/5/18.
//  Copyright © 2018 Rich Ruais. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var backBtn: UIButton!
    
    var coordinates: Coordinates!
    var currentCity: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setupView() {
        backBtn.layer.cornerRadius = 10
    }
    
    func setupMapView() {
        let camera = GMSCameraPosition.camera(withLatitude: CLLocationDegrees((coordinates?.lat)!), longitude: CLLocationDegrees((coordinates?.lon)!), zoom: 10.0)
        mapView.camera = camera
        showMarker(position: camera.target)
    }
    
    func showMarker(position: CLLocationCoordinate2D){
                let marker = GMSMarker()
                marker.position = position
                marker.title = currentCity
                marker.map = mapView
    }

    @IBAction func back(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
