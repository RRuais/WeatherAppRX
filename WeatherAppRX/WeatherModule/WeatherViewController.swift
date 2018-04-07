//
//  HomeViewController.swift
//  WeatherAppRX
//
//  Created by Rich Ruais on 4/2/18.
//  Copyright © 2018 Rich Ruais. All rights reserved.
//

import UIKit
import GooglePlaces

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var weatherTableView: UITableView!
    @IBOutlet weak var clearBtn: UIButton!
    @IBOutlet weak var searchMethodSegment: UISegmentedControl!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var detailsBtn: UIImageView!
    @IBOutlet weak var forcastLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    
    let emptyView = EmptyTableView()
    let weatherViewModel = WeatherViewModel()
    var weatherData = [Weather]()
    var currentWeather = CurrentWeather()
    var currentCity: String?
    var coordinates: Coordinates?
    
    var indicatorView: UIActivityIndicatorView?
    var placesClient: GMSPlacesClient!
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var autocompleteController: GMSAutocompleteViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupApp()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setupApp() {
        hideWeatherDetailView()
        setupTableView()
        setupTextField()
        setupGestures()
        setupLoadingIndicator()
        
        // Setup Google Places
        placesClient = GMSPlacesClient.shared()
        setupGooglePlacesControls()
    }
    
    func setupView() {
        clearBtn.layer.cornerRadius = 10
        topView.layer.cornerRadius = 10
    }
    
    func fetchWeatherData() {
        clear()
        addIndicator()
        weatherViewModel.fetchWeather(coord: coordinates!) { (weatherData, currentWeather, error) in
            
            if error == ErrorMessages.notFound.rawValue {
                presentAlert(title: "Opps!", message: "City not found. Please try again.", vc: self)
                    self.clear()
                    self.removeIndicator()
            } else {
                self.weatherData = weatherData!
                self.currentWeather = currentWeather!
                self.hideEmptyTableView()
                self.setupWeatherDetailsView()
                self.showWeatherDetailView()
                self.weatherTableView.reloadData()
                self.removeIndicator()
            }

            
        }
    }
    
    func resetText() {
        searchTextField.text = ""
        cityLabel.text = ""
    }
    
    func setupWeatherDetailsView() {
        if let currentTemp = currentWeather.main?.temp {
             currentTempLabel.text = "\(currentTemp) F"
        }
        if let city = currentCity {
            cityLabel.text = "\(city)"
        }
    }
    
    func hideWeatherDetailView() {
        cityLabel.isHidden = true
        detailsBtn.isHidden = true
        forcastLabel.isHidden = true
        currentTempLabel.isHidden = true
    }
    
    func showWeatherDetailView() {
        cityLabel.isHidden = false
        detailsBtn.isHidden = false
        forcastLabel.isHidden = false
        currentTempLabel.isHidden = false
    }
    
    @IBAction func clearSearch(_ sender: UIButton) {
        clear()
        resetText()
    }
    
    func clear() {
        weatherData.removeAll()
        weatherTableView.reloadData()
        showEmptyTableView()
        hideWeatherDetailView()
    }
    
    func setupGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.loadMapsView(sender:)))
        detailsBtn.addGestureRecognizer(tap)
        
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard(sender:)))
        self.view.addGestureRecognizer(tap2)
        
    }
    
    @objc func loadMapsView(sender:UITapGestureRecognizer) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = mainStoryboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        vc.coordinates = coordinates
        vc.currentCity = currentCity
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func hideKeyboard(sender:UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
}

// ******************************
// TableView Methods
// ******************************

extension WeatherViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        weatherTableView.delegate = self
        weatherTableView.dataSource = self
        weatherTableView.backgroundColor = UIColor.clear
        weatherTableView.separatorStyle = .none
        weatherTableView.allowsSelection = false
        showEmptyTableView()
    }
    
    func hideEmptyTableView() {
        emptyView.removeFromSuperview()
        weatherTableView.isScrollEnabled = true
        clearBtn.isEnabled = true
        detailsBtn.isUserInteractionEnabled = true
    }
    
    func showEmptyTableView() {
        weatherTableView.isScrollEnabled = false
        emptyView.frame = weatherTableView.bounds
        emptyView.center = CGPoint(x: weatherTableView.frame.size.width  / 2, y:
            weatherTableView.frame.size.height / 2);
        weatherTableView.addSubview(emptyView)
        clearBtn.isEnabled = false
        detailsBtn.isUserInteractionEnabled = false
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (weatherData.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath) as! WeatherTableViewCell
        let weather = weatherData[indexPath.row]
        cell.weather = weather
        return cell
    }
}

// ******************************
// TestField Delegate Methods
// ******************************

extension WeatherViewController: UITextFieldDelegate {
    func setupTextField() {
        searchTextField.delegate = self
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        present(autocompleteController!, animated: true, completion: nil)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.resignFirstResponder()
        return true
    }
}

// ******************************
// Google Places Methods
// ******************************

extension WeatherViewController: GMSAutocompleteViewControllerDelegate {
    
    func setupGooglePlacesControls() {
        autocompleteController = GMSAutocompleteViewController()
        autocompleteController?.delegate = self
        let filter = GMSAutocompleteFilter()
        filter.type = .city
        autocompleteController?.autocompleteFilter = filter
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("PLACE: \(place)")
        self.coordinates = Coordinates(lat: Float(place.coordinate.latitude), lon: Float(place.coordinate.longitude))
        self.currentCity = place.name
        self.fetchWeatherData()
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        dismiss(animated: true, completion: nil)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
}

// ******************************
// Activity Indicator Methods
// ******************************

extension WeatherViewController {
    func setupLoadingIndicator() {
        indicatorView = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        let iSize = indicatorView!.sizeThatFits(emptyView.bounds.size)
        let iRect = CGRect( x:emptyView.bounds.width/2 - iSize.width/2, y:emptyView.bounds.height/2 - iSize.height/2, width:iSize.width,height:iSize.height )
        indicatorView?.frame = iRect
        indicatorView?.hidesWhenStopped = true
        indicatorView?.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        emptyView.addSubview(self.indicatorView!)
        indicatorView?.isHidden = true
    }
    
    func addIndicator() {
        indicatorView?.isHidden = false
        indicatorView?.startAnimating()
    }
    
    func removeIndicator() {
        indicatorView?.isHidden = true
        indicatorView?.stopAnimating()
    }
}
