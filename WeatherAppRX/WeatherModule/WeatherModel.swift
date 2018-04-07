//
//  WeatherModel.swift
//  WeatherAppRX
//
//  Created by Rich Ruais on 4/2/18.
//  Copyright © 2018 Rich Ruais. All rights reserved.
//

import Foundation

// ******************************
// 7 Day weather models
// ******************************

struct Weather: Codable {
    var clouds: Int?
    var deg: Int?
    var dt: Int?
    var humidity: Int?
    var pressure: Double?
    var speed: Double?
    var temp: Temp?
    var weather: [WeatherDescription]?
}

struct Temp: Codable{
    var day: Double?
    var eve: Double?
    var max: Double?
    var min: Double?
    var morn: Double?
    var night: Double?
}

struct WeatherDescription: Codable {
    var description: String?
    var icon: String?
    var id: Int?
}

// ******************************
// Current weather models
// ******************************

struct CurrentWeather: Codable {
    var main: CWmain?
    var name: String?
    var weather: [WeatherDescription]?
}

struct CWmain: Codable {
    var humidity: Int?
    var temp: Double?
    var temp_max: Double?
    var temp_min: Double?
}

// ******************************
// Public Enums
// ******************************

enum ErrorMessages: String {
    case notFound = "City not found"
    case ErrorLoading = "Error loading data"
}
