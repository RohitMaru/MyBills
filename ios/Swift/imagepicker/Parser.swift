//
//  Parser.swift
//  imagepicker
//
//  Created by Rohit Marumamula on 5/18/17.
//  Copyright © 2017 Sara Robinson. All rights reserved.
//

import Foundation
import UIKit

struct EachWord {
    let vertex: CGRect
    let description: NSString
}

class Parser: NSObject {
    //-> Dictionary<AnyHashable, Any>
    func parse(dict: NSDictionary) -> [EachWord] {
        var allData = [EachWord]()
        let allValues = dict.allValues
        if let insideArr = allValues.first as? NSArray {
            if let insideDict = insideArr[0] as? NSDictionary {
                if let textAnnotations = insideDict["textAnnotations"] as? [[NSString: AnyObject]] {
                    for (index, eachAnnotation) in textAnnotations.enumerated() {
                        if index == 0 {
                            continue
                        }
                        let description = eachAnnotation["description"] as! NSString
//                        print("vertices")
                        var frame: CGRect = CGRect.zero
                        if let boundingPoly = eachAnnotation["boundingPoly"] as? [NSString: AnyObject], let vertices = boundingPoly["vertices"] as? [[NSString: CGFloat]] {
                            let vertex1 = vertices[0]
                            let vertex2 = vertices[1]
                            let vertex3 = vertices[2]
                            frame.origin.x = vertex1["x"]!
                            frame.origin.y = vertex1["y"]!
                            frame.size.width = vertex2["x"]! - vertex1["x"]!
                            frame.size.height = vertex3["y"]! - vertex1["y"]!
//                            print(vertices)
//                            print(frame)
                            
                        }
                        let eachWord = EachWord(vertex: frame, description: description)
                        allData.append(eachWord)
                    }
                }
            }
        }
        return allData
    }
}
