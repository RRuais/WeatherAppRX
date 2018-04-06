//
//  EmptyTableView.swift
//  WeatherAppRX
//
//  Created by Rich Ruais on 4/5/18.
//  Copyright © 2018 Rich Ruais. All rights reserved.
//

import UIKit

class EmptyTableView: UIView {

    @IBOutlet var contentView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("EmptyTableView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.frame
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

}
