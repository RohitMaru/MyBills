//
//  Word.swift
//  imagepicker
//
//  Created by Rohit Marumamula on 5/20/17.
//  Copyright © 2017 Sara Robinson. All rights reserved.
//

import Foundation
import UIKit

class Word: UIView {
    
    class func drawLabel(word: EachWord) -> UILabel {
        let label = UILabel(frame: word.vertex)
        if let text = word.description as? String {
            label.text = text
        }
        label.font = UIFont.systemFont(ofSize: 8.0)
        label.backgroundColor = UIColor.gray
        return label
    }
    
    class func drawProduct(product: Product) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 15))
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 15))
//        label.backgroundColor = UIColor.brown
        label.text = product.name
        let price = UILabel(frame: CGRect(x: 210, y: 0, width: 300, height: 15))
        price.text = "\(product.price)"
//        price.backgroundColor = UIColor.blue
        view.addSubview(label)
        view.addSubview(price)
        return view
    }
}
