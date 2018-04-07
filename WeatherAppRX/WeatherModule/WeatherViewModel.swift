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
    private var cityCoordinates: Coordinates?
    private var message: String?
    private var currentWeather: CurrentWeather?
    
    func fetchWeather(coord: Coordinates, completion: @escaping ([Weather]?, CurrentWeather?, String?) -> Void) {
    
        self.cityCoordinates = coord
        
        // Run Async Functions
        dispatch_group.enter()
        fetch7DayWeather()
        dispatch_group.enter()
        fetchCurrentWeather()
        
        //Async Completion Handler
        dispatch_group.notify(queue: .main) {
            if self.message == ErrorMessages.notFound.rawValue {
                completion(nil, nil, self.message!)
            } else {
                completion(self.weatherData, self.currentWeather, nil)
            }
        }
    }
    
    private func fetch7DayWeather() {
        
        guard let lat = cityCoordinates?.lat else { return }
        guard let lon = cityCoordinates?.lon else { return }

        
        var url = URL(string: "http://api.openweathermap.org/data/2.5/forecast/daily?lat=\(lat)&lon=\(lon)&units=imperial&appid=7ab7f589feda857e3b74f0e5e7c67fc3")!
      
//        print("URL: \(url)/")
        Alamofire.request(url).responseJSON { response in
            guard let json = response.result.value as? [String:Any] else { return }

//            print("JSON: \(json)")
            if let responseMessage = json["message"] as? String {
                if responseMessage == "city not found" {
                    self.message = ErrorMessages.notFound.rawValue
                    self.dispatch_group.leave()
                    return
                }
            }
        
            guard let jsonData = json["list"] as? [[String:Any]] else { return }
//            print("JSONData: \(jsonData)")
            
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
        guard let lat = cityCoordinates?.lat else { return }
        guard let lon = cityCoordinates?.lon else { return }
        
        var url = URL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&units=imperial&appid=7ab7f589feda857e3b74f0e5e7c67fc3")!
        
        Alamofire.request(url).responseJSON { response in
            guard let json = response.result.value as? [String:Any] else { return }
            
            if let responseMessage = json["message"] as? String {
                if responseMessage == "city not found" {
                    self.message = ErrorMessages.notFound.rawValue
                    self.dispatch_group.leave()
                    return
                }
            }
            
            do {
                let decoder = JSONDecoder()
                let data = try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
                let weather = try! decoder.decode(CurrentWeather.self, from: data)
                self.currentWeather = weather
                print("Current Weather: \(self.currentWeather)")
            } catch {
                self.message = ErrorMessages.ErrorLoading.rawValue
                self.dispatch_group.leave()
                return
            }
            self.dispatch_group.leave()
        }
    }
    
}
