// Copyright 2016 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit
import SwiftyJSON
import Foundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let imagePicker = UIImagePickerController()
    let session = URLSession.shared
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var labelResults: UITextView!
    @IBOutlet weak var faceResults: UITextView!
    @IBOutlet weak var billView: UIScrollView!
    
    var fullData = [EachWord]()
    var numOfLines = 0
    var lines = [[EachWord]]()
    var bills = [[EachWord]]()

    var googleAPIKey = "AIzaSyB2biVwaSzxzC_BGOqAnGfE-RCE2GRHVM4"
    var googleURL: URL {
        return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(googleAPIKey)")!
    }
    
    @IBAction func loadImageButtonTapped(_ sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imagePicker.delegate = self
        labelResults.isHidden = true
        faceResults.isHidden = true
        spinner.hidesWhenStopped = true
        
        var jsonObj: Any;
        if let filePath = Bundle.main.path(forResource: "sample", ofType: "json") {
            do {
                let dataString = try String(contentsOfFile: filePath)
                if let data = dataString.data(using: .utf8) {
                    do {
                        jsonObj = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        if let dict = jsonObj as? NSDictionary {
                            fullData = Parser().parse(dict: dict)
                            DispatchQueue.main.async {
//                                var eachLine: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 1000, height: 15))
                                var eachLine = [EachWord]()
                                var lineX: CGFloat = 0.0
                                for eachWord in self.fullData {
                                    if (eachWord.vertex.origin.y - lineX) > 5.0 {
                                        lineX = eachWord.vertex.origin.y
                                        self.numOfLines += 1
                                        self.lines.append(eachLine)
                                        let lastWord = eachLine.last
                                        if lastWord?.description == "X" {
                                            self.bills.append(eachLine)
                                        }
                                        eachLine = [EachWord]()
//                                        eachLine = UIView(frame: CGRect(x: 0, y: 0, width: 1000, height: 15))
                                    }
                                    eachLine.append(eachWord)
//                                    eachLine.addSubview(Word(frame: CGRect.zero).drawLabel(word: eachWord))
//                                    self.billView.addSubview(Word(frame: CGRect.zero).drawLabel(word: eachWord))
                                }
//                                for line in lines {
//                                    self.billView.addSubview(line)
//                                }
                                self.billView.contentSize = CGSize(width: 1000, height: 1000)
                                print("final \(self.numOfLines)")
                                print(self.bills)
                                var products = [Product]()
                                for eachProduct in self.bills {
                                    let numOfWords = eachProduct.count - 1
                                    let xWord = eachProduct[numOfWords]
                                    let cents = eachProduct[numOfWords - 1]
                                    let dot = eachProduct[numOfWords - 2]
                                    let dollars = eachProduct[numOfWords - 3]
                                    var productName = ""
                                    for (index, word) in eachProduct.enumerated() {
                                        if index <= (numOfWords - 5) {
                                            productName.append("\(word.description) ")
                                        }
                                    }
                                    if let doubleValue = Double("\(dollars.description).\(cents.description)") {
                                        let amount = CGFloat(doubleValue)
                                        products.append(Product(name: productName, price: amount))
                                    }
                                }
                                print(products)
                                
                                for (index, product) in products.enumerated() {
                                    let eachLine = Word.drawProduct(product: product)
                                    var frame = eachLine.frame
                                    frame.origin.y = CGFloat(Double(index*15) + 70.0)
                                    if index == 0 {
                                        frame.origin.y = 70
                                    }
                                    eachLine.frame = frame
                                    self.billView.addSubview(eachLine)
                                    
                                }
                            }
                        }
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


/// Image processing

extension ViewController {
    
    func analyzeResults(_ dataToParse: Data) {
        
        // Update UI on the main thread
        DispatchQueue.main.async(execute: {
            
            
            // Use SwiftyJSON to parse results
            let json = JSON(data: dataToParse)
//            let json = JSON(parseJSON)
            let errorObj: JSON = json["error"]
            
            self.spinner.stopAnimating()
            self.imageView.isHidden = true
            self.labelResults.isHidden = false
            self.faceResults.isHidden = false
            self.faceResults.text = ""
            
            // Check for errors
            if (errorObj.dictionaryValue != [:]) {
                self.labelResults.text = "Error code \(errorObj["code"]): \(errorObj["message"])"
            } else {
                // Parse the response
                print(json)
//                if let parsedJSON = json.rawValue as? NSDictionary {
//                    Parser().parse(dict: parsedJSON)
//                    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//                    if let documentsDirectory = paths.first {
//                        if let jsonTest = try? JSONSerialization.jsonObject(with: dataToParse, options: []) as? NSDictionary {
//                            jsonTest?.write(toFile: documentsDirectory.appendingPathComponent("sample.json").path, atomically: true)
//                        }
//                    }
//
//                }
                
                let responses: JSON = json["responses"][0]
                
                // Get face annotations
                let faceAnnotations: JSON = responses["faceAnnotations"]
                if faceAnnotations != nil {
                    let emotions: Array<String> = ["joy", "sorrow", "surprise", "anger"]
                    
                    let numPeopleDetected:Int = faceAnnotations.count
                    
                    self.faceResults.text = "People detected: \(numPeopleDetected)\n\nEmotions detected:\n"
                    
                    var emotionTotals: [String: Double] = ["sorrow": 0, "joy": 0, "surprise": 0, "anger": 0]
                    var emotionLikelihoods: [String: Double] = ["VERY_LIKELY": 0.9, "LIKELY": 0.75, "POSSIBLE": 0.5, "UNLIKELY":0.25, "VERY_UNLIKELY": 0.0]
                    
                    for index in 0..<numPeopleDetected {
                        let personData:JSON = faceAnnotations[index]
                        
                        // Sum all the detected emotions
                        for emotion in emotions {
                            let lookup = emotion + "Likelihood"
                            let result:String = personData[lookup].stringValue
                            emotionTotals[emotion]! += emotionLikelihoods[result]!
                        }
                    }
                    // Get emotion likelihood as a % and display in UI
                    for (emotion, total) in emotionTotals {
                        let likelihood:Double = total / Double(numPeopleDetected)
                        let percent: Int = Int(round(likelihood * 100))
                        self.faceResults.text! += "\(emotion): \(percent)%\n"
                    }
                } else {
                    self.faceResults.text = "No faces found"
                }
                
                // Get label annotations
                let labelAnnotations: JSON = responses["labelAnnotations"]
                let numLabels: Int = labelAnnotations.count
                var labels: Array<String> = []
                if numLabels > 0 {
                    var labelResultsText:String = "Labels found: "
                    for index in 0..<numLabels {
                        let label = labelAnnotations[index]["description"].stringValue
                        labels.append(label)
                    }
                    for label in labels {
                        // if it's not the last item add a comma
                        if labels[labels.count - 1] != label {
                            labelResultsText += "\(label), "
                        } else {
                            labelResultsText += "\(label)"
                        }
                    }
                    self.labelResults.text = labelResultsText
                } else {
                    self.labelResults.text = "No labels found"
                }
            }
        })
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFit
            imageView.isHidden = true // You could optionally display the image here by setting imageView.image = pickedImage
            spinner.startAnimating()
            faceResults.isHidden = true
            labelResults.isHidden = true
            
            // Base64 encode the image and create the request
            let binaryImageData = base64EncodeImage(pickedImage)
            createRequest(with: binaryImageData)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = UIImagePNGRepresentation(newImage!)
        UIGraphicsEndImageContext()
        return resizedImage!
    }
}


/// Networking

extension ViewController {
    func base64EncodeImage(_ image: UIImage) -> String {
        var imagedata = UIImagePNGRepresentation(image)
        
        // Resize the image if it exceeds the 2MB API limit
        if (imagedata?.count > 2097152) {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
            imagedata = resizeImage(newSize, image: image)
        }
        
        return imagedata!.base64EncodedString(options: .endLineWithCarriageReturn)
    }
    
    func createRequest(with imageBase64: String) {
        // Create our request URL
        
        var request = URLRequest(url: googleURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        // Build our API request
        let jsonRequest = [
            "requests": [
                "image": [
                    "content": imageBase64
                ],
                "features": [
                    [
                        "type": "DOCUMENT_TEXT_DETECTION",
                    ]
                ]
            ]
        ]
        let jsonObject = JSON(jsonDictionary: jsonRequest)
        
        // Serialize the JSON
        guard let data = try? jsonObject.rawData() else {
            return
        }
        
        request.httpBody = data
        
        // Run the request on a background thread
        DispatchQueue.global().async { self.runRequestOnBackgroundThread(request) }
    }
    
    func runRequestOnBackgroundThread(_ request: URLRequest) {
        // run the request
        
        let task: URLSessionDataTask = session.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "")
                return
            }
            
            self.analyzeResults(data)
        }
        
        task.resume()
    }
}


// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}
