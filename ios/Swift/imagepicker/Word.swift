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
    
    func drawLabel(word: EachWord) -> UILabel {
        let label = UILabel(frame: word.vertex)
        if let text = word.description as? String {
            label.text = text
        }
        label.font = UIFont.systemFont(ofSize: 8.0)
        label.backgroundColor = UIColor.gray
        return label
    }
}
