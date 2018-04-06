//
//  WeatherViewModel.swift
//  WeatherAppRX
//
//  Created by Rich Ruais on 4/2/18.
//  Copyright © 2018 Rich Ruais. All rights reserved.
//

import Foundation
import Alamofire


class WeatherViewModel {
    
    private let dispatch_group: DispatchGroup = DispatchGroup()
    private var weatherData = [Weather]()
    private var searchData: (searchBy,String)?
    private var cityCoordinates: Coordinates?
    private var cityName: String?
    private var message: String?
    private var currentWeather: CurrentWeather?
    
    func fetchWeatherData(search: (searchBy,String), completion: @escaping ([Weather]?, String, Coordinates?, CurrentWeather?, String) -> Void) {

        // Format Search Text
        let searchText = search.1
        let trimmedText = searchText.trimmingCharacters(in: .whitespaces)
        let finalText = trimmedText.replacingOccurrences(of: " ", with: "+")
        
        // Load Search Data
        searchData = (search.0, finalText)
        
        // Run Async Functions
        dispatch_group.enter()
        fetch7DayWeather()
        dispatch_group.enter()
        fetchCurrentWeather()
        
        // Async Completion Handler
        dispatch_group.notify(queue: .main) {
            if self.message == ErrorMessages.notFound.rawValue {
                print("Has Error Message")
                completion(nil, "", nil, nil, self.message!)
            } else {
                print("No Error Message")
                completion(self.weatherData, self.cityName!, self.cityCoordinates, self.currentWeather, "")
            }
        }
    }
    
    private func fetch7DayWeather() {
        print("searcData: \(searchData)")
        guard let text = searchData?.1 else { return }
        print("Text: \(text)")
        var url: URL?
        if (searchData?.0)!.rawValue == searchBy.zipCode.rawValue {
            url = URL(string: "http://api.openweathermap.org/data/2.5/forecast/daily?zip=\(text)&units=imperial&appid=7ab7f589feda857e3b74f0e5e7c67fc3")!
        } else {
            print("Text: \(text)")
            url = URL(string: "http://api.openweathermap.org/data/2.5/forecast/daily?q=\(text)&units=imperial&appid=7ab7f589feda857e3b74f0e5e7c67fc3")!
        }
            
        Alamofire.request(url!).responseJSON { response in
            guard let json = response.result.value as? [String:Any] else { return }

            if let responseMessage = json["message"] as? String {
                if responseMessage == "city not found" {
                    self.message = ErrorMessages.notFound.rawValue
                    self.dispatch_group.leave()
                    return
                }
            }
        
            guard let jsonData = json["list"] as? [[String:Any]] else { return }
        
            if let city = json["city"] as? [String:Any] {
                if let name = city["name"] as? String {
                    self.cityName = name
                }
                if let coord = city["coord"] as? [String:Any] {
                    let lat = coord["lat"] as! Float
                    let lon = coord["lon"] as! Float
                    self.cityCoordinates = Coordinates(lat: lat, lon: lon)
                }
            }
            
            do {
                let decoder = JSONDecoder()
                let data = try JSONSerialization.data(withJSONObject: jsonData, options: JSONSerialization.WritingOptions.prettyPrinted)
                let weather = try! decoder.decode([Weather].self, from: data)
                self.weatherData.removeAll()
                self.weatherData.append(contentsOf: weather)
            } catch {
                self.message = ErrorMessages.ErrorLoading.rawValue
                self.dispatch_group.leave()
                return
            }
            self.message = ""
            self.dispatch_group.leave()
        }
    }
    
    private func fetchCurrentWeather() {
        currentWeather = CurrentWeather()
        guard let text = searchData?.1 else { return }
        var url: URL?
        if (searchData?.0)!.rawValue == searchBy.zipCode.rawValue {
            url = URL(string: "http://api.openweathermap.org/data/2.5/weather?zip=\(text)&units=imperial&appid=7ab7f589feda857e3b74f0e5e7c67fc3")!
        } else {
            url = URL(string: "http://api.openweathermap.org/data/2.5/weather?q=\(text)&units=imperial&appid=7ab7f589feda857e3b74f0e5e7c67fc3")!
        }
        
        Alamofire.request(url!).responseJSON { response in
            guard let json = response.result.value as? [String:Any] else { return }
            
            if let responseMessage = json["message"] as? String {
                if responseMessage == "city not found" {
                    self.message = ErrorMessages.notFound.rawValue
                    self.dispatch_group.leave()
                    return
                }
            }
            
            print("JSON: \(json)")
            do {
                let decoder = JSONDecoder()
                let data = try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
                let weather = try! decoder.decode(CurrentWeather.self, from: data)
                self.currentWeather = weather
            } catch {
                self.message = ErrorMessages.ErrorLoading.rawValue
                self.dispatch_group.leave()
                return
            }
            self.dispatch_group.leave()
        }
    }
    
}
