//
//  WeatherTableViewCell.swift
//  WeatherAppRX
//
//  Created by Rich Ruais on 4/2/18.
//  Copyright © 2018 Rich Ruais. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class WeatherTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    
    var weather: Weather? {
        didSet {
            guard let humidity = weather?.humidity! else { return }
            let max = Double((weather?.temp?.max)!)
            let min = Double((weather?.temp?.min)!)
            let desc = weather?.weather![0].description
            let date = convertDate(dt: (weather?.dt!)!)
            lowLabel.text = "\(String(describing: weather?.temp?.min))"
            humidityLabel.text = "\(String(describing: humidity)) %"
            highLabel.text = "\(Int(max.rounded())) F"
            lowLabel.text = "\(Int(min.rounded())) F"
            descriptionLabel.text = desc
            dateLabel.text = date
            assignImage(id: (weather?.weather![0].id!)!, icon: (weather?.weather![0].icon!)!, cell: self)
        }
    }
    
    func convertDate(dt: Int) -> String {
        let monthsStr = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        let monthsNum = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
        let dt = Double(dt)
        let fullDate = NSDate(timeIntervalSince1970: dt)
        let fullDateString = String(describing: fullDate)
        let fullDateArray = fullDateString.components(separatedBy: " ")
        let date = fullDateArray[0]
        let dateArr = date.components(separatedBy: "-")
        let index = monthsNum.index(of: dateArr[1])
        let month = monthsStr[index!]
        let convertedDate = "\(month) \(dateArr[2])"
        
        return convertedDate
    }
    
    func assignImage(id: Int, icon: String, cell: WeatherTableViewCell) {
        let url = URL(string: "http://openweathermap.org/img/w/\(icon).png")
        Alamofire.request(url!).responseImage { response in
            if let image = response.result.value {
                cell.weatherImageView.image = image
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
