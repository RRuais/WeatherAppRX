//
//  Utilities.swift
//  WeatherAppRX
//
//  Created by Rich Ruais on 4/4/18.
//  Copyright © 2018 Rich Ruais. All rights reserved.
//

import Foundation
import UIKit

func presentAlert(title: String, message: String, vc: UIViewController) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let ok = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in
    }
    alertController.addAction(ok)
    vc.present(alertController, animated: true, completion: nil)
}
