//
//  HomeViewController.swift
//  EPRS
//
//  Created by Matthias Bogarin on 11/6/19.
//  Copyright © 2019 Matthias Bogarin, Daniel Vilajetid , Josh Persaud, Esau Cuellar. All rights reserved.
//





//Here we import all the appropriate Libraries and CocoaPods we utilize in this view.
import Photos
import UIKit
import Vision
import VisionKit

//Global Variables for all controllers
var gTitle: String?
var gLoc: String?
var gDate: Date?

class HomeViewController: UIViewController, VNDocumentCameraViewControllerDelegate{
    @IBOutlet var textView: UITextView!
        
        //Image View
        @IBOutlet weak var imageView: UIImageView!
        
        //Global Varibales:
        var wordBox: CGRect?
        var textDict: [Int: String] = [:]
        var prompt: String?
        
        //Buttons
        @IBOutlet var scanButton: UIButton!
        @IBOutlet var nextButton: UIButton!
        @IBOutlet var LogoutButton: UIButton!
    
    // Layer into which to draw bounding box paths
        var pathLayer: CALayer?
        
        // Image parameters for reuse throughout app
        var imageWidth: CGFloat = 0
        var imageHeight: CGFloat = 0
        
        var textRecognitionRequest = VNRecognizeTextRequest(completionHandler: nil)
        private let textRecognitionWorkQueue = DispatchQueue(label: "TextRecognitionQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
        
        // Background is black, so display status bar in white.
        override var preferredStatusBarStyle: UIStatusBarStyle {
            return .lightContent
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            gTitle = "Event1"
            gLoc = "Location1"
            gDate = Date()
            
            nextButton.alpha = 0
            textView.alpha = 1
           
            imageView.layer.cornerRadius = 10.0
            textView.layer.cornerRadius = 10.0
            scanButton.layer.cornerRadius = 10.0
            nextButton.layer.cornerRadius
                = 10.0
           
            scanButton.addTarget(self, action: #selector(scanDocument), for: .touchUpInside)

           setupVision()
            
            
        }
    //Finds and provides the Date for the user.
    func findDate(_ dateString:String) -> Date?{
                let types: NSTextCheckingResult.CheckingType = .date
                let dataDetector = try! NSDataDetector(types: types.rawValue)
    
                let result = dataDetector.firstMatch(in: dateString, options: [], range: NSMakeRange(0, dateString.count))
  
            return result?.date
            }
        
        func findLocation(_ textData: String) -> String?{
            let types: NSTextCheckingResult.CheckingType = .address
            let dataDetector = try! NSDataDetector(types: types.rawValue)
            let result = dataDetector.firstMatch(in: textData, options: [], range: NSMakeRange(0, textData.count))
            print("Location test: ", result?.addressComponents?.first?.value)
            print("Location counter: ", result?.addressComponents?.count)
            let testOutput = result?.addressComponents?.values.description
            print("test:", testOutput)

            return testOutput
        }
        
        
        
        /// - Tag: PreprocessImage
        func scaleAndOrient(image: UIImage) -> UIImage {
            print("Scale&orient function started: ")
            // Set a default value for limiting image size.
            let maxResolution: CGFloat = 640
            
            guard let cgImage = image.cgImage else {
                print("UIImage has no CGImage backing it!")
                return image
            }
            
            // Compute parameters for transform.
            let width = CGFloat(cgImage.width)
            let height = CGFloat(cgImage.height)
            var transform = CGAffineTransform.identity
            
            var bounds = CGRect(x: 0, y: 0, width: width, height: height)
            
            if width > maxResolution ||
                height > maxResolution {
                let ratio = width / height
                if width > height {
                    bounds.size.width = maxResolution
                    bounds.size.height = round(maxResolution / ratio)
                } else {
                    bounds.size.width = round(maxResolution * ratio)
                    bounds.size.height = maxResolution
                }
            }
            
            let scaleRatio = bounds.size.width / width
            let orientation = image.imageOrientation
            
            switch orientation {
            case .up:
                transform = .identity
            case .down:
                transform = CGAffineTransform(translationX: width, y: height).rotated(by: .pi)
            case .left:
                let boundsHeight = bounds.size.height
                bounds.size.height = bounds.size.width
                bounds.size.width = boundsHeight
                transform = CGAffineTransform(translationX: 0, y: width).rotated(by: 3.0 * .pi / 2.0)
            case .right:
                let boundsHeight = bounds.size.height
                bounds.size.height = bounds.size.width
                bounds.size.width = boundsHeight
                transform = CGAffineTransform(translationX: height, y: 0).rotated(by: .pi / 2.0)
            case .upMirrored:
                transform = CGAffineTransform(translationX: width, y: 0).scaledBy(x: -1, y: 1)
            case .downMirrored:
                transform = CGAffineTransform(translationX: 0, y: height).scaledBy(x: 1, y: -1)
            case .leftMirrored:
                let boundsHeight = bounds.size.height
                bounds.size.height = bounds.size.width
                bounds.size.width = boundsHeight
                transform = CGAffineTransform(translationX: height, y: width).scaledBy(x: -1, y: 1).rotated(by: 3.0 * .pi / 2.0)
            case .rightMirrored:
                let boundsHeight = bounds.size.height
                bounds.size.height = bounds.size.width
                bounds.size.width = boundsHeight
                transform = CGAffineTransform(scaleX: -1, y: 1).rotated(by: .pi / 2.0)
            }

            print("Got to scale&orients return line:")
            return UIGraphicsImageRenderer(size: bounds.size).image { rendererContext in
                let context = rendererContext.cgContext
                
                if orientation == .right || orientation == .left {
                    context.scaleBy(x: -scaleRatio, y: scaleRatio)
                    context.translateBy(x: -height, y: 0)
                } else {
                    context.scaleBy(x: scaleRatio, y: -scaleRatio)
                    context.translateBy(x: 0, y: -height)
                }
                context.concatenate(transform)
                context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
            }
        }
        
        
    
        func show(_ image: UIImage) {
            print("Show function started: ")
            
            // Remove previous paths & image
            pathLayer?.removeFromSuperlayer()
            pathLayer = nil
            imageView.image = nil
            
            // Account for image orientation by transforming view.
            let correctedImage = scaleAndOrient(image: image)
            
            
            // Place photo inside imageView.
            imageView.image = correctedImage
            
            // Transform image to fit screen.
            guard let cgImage = correctedImage.cgImage else {
                print("Trying to show an image not backed by CGImage!")
                return
            }

            
            
            let fullImageWidth = CGFloat(cgImage.width)
            let fullImageHeight = CGFloat(cgImage.height)
            
            let imageFrame = imageView.frame
            let widthRatio = fullImageWidth / imageFrame.width
            let heightRatio = fullImageHeight / imageFrame.height
            
            // ScaleAspectFit: The image will be scaled down according to the stricter dimension.
            let scaleDownRatio = max(widthRatio, heightRatio)
            
            // Cache image dimensions to reference when drawing CALayer paths.
            imageWidth = fullImageWidth / scaleDownRatio
            imageHeight = fullImageHeight / scaleDownRatio
            
            // Prepare pathLayer to hold Vision results.
            let xLayer = (imageFrame.width - imageWidth) / 2
            let yLayer = imageView.frame.minY + (imageFrame.height - imageHeight) / 2
            let drawingLayer = CALayer()
            drawingLayer.bounds = CGRect(x: xLayer, y: yLayer, width: imageWidth, height: imageHeight)
            drawingLayer.anchorPoint = CGPoint.zero
            drawingLayer.position = CGPoint(x: xLayer, y: yLayer)
            drawingLayer.opacity = 0.5
            pathLayer = drawingLayer
            self.view.layer.addSublayer(pathLayer!)
        }
        
        
        
        
        // MARK: - Path-Drawing
     
        fileprivate func boundingBox(forRegionOfInterest: CGRect, withinImageBounds bounds: CGRect) -> CGRect {
            
            let imageWidth = bounds.width
            let imageHeight = bounds.height
            
            // Begin with input rect.
            var rect = forRegionOfInterest
            
            // Reposition origin.
            rect.origin.x *= imageWidth
            rect.origin.x += bounds.origin.x
            rect.origin.y = (1 - rect.origin.y) * imageHeight + bounds.origin.y
            
            // Rescale normalized coordinates.
            rect.size.width *= imageWidth
            rect.size.height *= imageHeight
            
            return rect
        }

        fileprivate func shapeLayer(color: UIColor, frame: CGRect) -> CAShapeLayer {
            // Create a new layer.
            let layer = CAShapeLayer()
            
            // Configure layer's appearance.
            layer.fillColor = nil // No fill to show boxed object
            layer.shadowOpacity = 0
            layer.shadowRadius = 0
            layer.borderWidth = 2
            
            // Vary the line color according to input.
            layer.borderColor = color.cgColor
            
            // Locate the layer.
            layer.anchorPoint = .zero
            layer.frame = frame
            layer.masksToBounds = true
            
            
            // Transform the layer to have same coordinate system as the imageView underneath it.
            layer.transform = CATransform3DMakeScale(1, -1, 1)
            
            return layer
        }
        @IBAction func draw(_ sender: Any) {
        }
     
    
        // Lines of text are RED.  Individual characters are PURPLE.
     
        fileprivate func draw(text: [VNTextObservation], onImageWithBounds bounds: CGRect) {
            print("Draw function started: ")
            CATransaction.begin()
            var countButton = 0
            for wordObservation in text {
                 wordBox = boundingBox(forRegionOfInterest: wordObservation.boundingBox, withinImageBounds: bounds)
                let wordLayer = shapeLayer(color: .red, frame: wordBox!)
            
                
                
                let button = UIButton(frame: CGRect(x: wordBox!.minX, y: wordBox!.minY, width: wordBox!.size.width, height: -wordBox!.size.height))
                
                button.setTitle(String(countButton), for: .disabled)
        
                button.backgroundColor = .blue
                button.alpha = 0.30
                countButton += 1
                
                button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
                self.view.addSubview(button)
                pathLayer?.addSublayer(wordLayer)
            
                
                // Iterate through each character within the word and draw its box.
                guard let charBoxes = wordObservation.characterBoxes else {
                    continue
                }
                for charObservation in charBoxes {
                    let charBox = boundingBox(forRegionOfInterest: charObservation.boundingBox, withinImageBounds: bounds)
                    let charLayer = shapeLayer(color: .purple, frame: charBox)
                    charLayer.borderWidth = 1
                    
                    // Add to pathLayer on top of image.
                    pathLayer?.addSublayer(charLayer)
                }
                
            }
            CATransaction.commit()
        }
    
    //functionality for buttons tapped around recognized boxes.
        @objc func buttonTapped(sender: UIButton!)
        {
            getStringFromDict(key: sender.title(for: .disabled)!)
            print("key: ",sender.title(for: .disabled)!)
        }
        
    
       @objc func setupVision() {

                textRecognitionRequest = VNRecognizeTextRequest { (request, error) in

                    guard let observations = request.results as? [VNRecognizedTextObservation] else { return }

                    

                    var detectedText = ""

                    var boundingBoxes = [CGRect]()
                 
                    var countBox = 0
                    var count = 0
                    var cgfloatArray = [CGFloat]()
                 
                    var allText = ""
                    
                    var observationAreaArray: [Int: CGFloat] = [:]
                    var observationArray2:[CGFloat] = []
                    
                    for observation in observations {
                        
                        guard let topCandidate = observation.topCandidates(1).first else { return }
                        countBox = observations.count
                     cgfloatArray = [observation.boundingBox.minX, observation.boundingBox.minY]
                     
                     detectedText += topCandidate.string
                        print("inloop detected order: ", detectedText)
                        allText+=(" "+detectedText)
                        detectedText += "\n"
                        self.textDict.updateValue(topCandidate.string, forKey: count)
                        
                  
                        observationAreaArray.updateValue(observation.boundingBox.height * observation.boundingBox.width, forKey: count)
                     observationArray2.append(observation.boundingBox.height * observation.boundingBox.width)
                        count = count + 1
                        do {
                        

                         guard let rectangle = try topCandidate.boundingBox(for:     topCandidate.string.startIndex..<topCandidate.string.endIndex)
                         else
                         {
                                 return
                         }
                     

                         boundingBoxes.append(rectangle.boundingBox)
                         
                         
                    
                         

                        } catch {

                            

                            print("Error: ", error)

                        }
                     

                    }
                 
                    let maxNum = observationArray2.max()
                                    
                                       var largestBox:Int?
                                       
                                       for area in 0...observationAreaArray.count{
                                           if (observationAreaArray[area] == maxNum){
                                               largestBox = area
                                           }
                                       }
                                       
                                       
                                       
                                       
                                       var dateObj:Date?
                                       var locationObj:String?
                    
                    
                 for text in self.textDict {
                     print("Text in dict", text)
                    
                    
                    
                    var locationTest = self.findLocation("4513 Manhattan College Pkwy, The Bronx, NY 10471")
                    print(locationTest)
                

                    
                    if self.findLocation(text.value) != nil{
                        locationObj = self.findLocation(text.value)
                    }
                    
                    
                    
                    
                 }
                    if self.findDate(allText) != nil
                    {
                    dateObj = self.findDate(allText)
                    print("print all text:===================", allText)
                    }
                    
                    if self.textDict[largestBox!] != nil{
                                           gTitle = self.textDict[largestBox!]
                                           print("Title is: ", gTitle!)
                                       }
                                       
                                       if dateObj != nil{
                                           gDate = dateObj!
                                           print("Event Date: ", gDate!)
                                       }
                                       
                                       if locationObj != nil {
                                           gLoc = locationObj!
                                           print("Location of Event: ", gLoc!)
                                       }
                    
                     
                    DispatchQueue.main.async {
                    self.scanButton.isEnabled = false
                    self.scanButton.alpha = 0
                    self.nextButton.alpha = 1
                    self.nextButton.isEnabled = true
                    self.prompt = "Title"

                    }

                }


        textRecognitionRequest.progressHandler = { [weak self] (_, progress, _) in

                    DispatchQueue.main.async {

                     self?.scanButton.isEnabled = progress == 1
                        
                    }

        }
                textRecognitionRequest.recognitionLevel = .accurate

    }
        
       //functionality for nextButton, Switches to do different transitions
        @IBAction func NextButtonTapped(_ sender: Any) {
            //Call Initial recognition funciton first
            
            if(gTitle == "" && gLoc == ""){
            promptViews()
            }
            else
            {
            prompt = ""
            promptViews()
            }
            
        }
        
        /// Shows a `VNDocumentCameraViewController` to let the user scan documents
    
    //creates the camera/scan view
         @objc func scanDocument() {
            
            textView.alpha = 0
            LogoutButton.isEnabled = false
            LogoutButton.alpha = 0

             let scannerViewController = VNDocumentCameraViewController()

            scannerViewController.delegate = self

             present(scannerViewController, animated: true)

         }

         

         // MARK: - Scan Handling
       
         private func processImage(_ image: UIImage) {
        

            show(image)
            let cgOrientation = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue))
            
            // Fire off request based on URL of chosen photo.
            guard let cgImage = image.cgImage else {
                return
            }
            performVisionRequest(image: cgImage,
                                 orientation: cgOrientation!)
            
            
            TextInImage(image)

         }
        
        /// - Tag: PerformRequests
       fileprivate func performVisionRequest(image: CGImage, orientation: CGImagePropertyOrientation) {
            
            // Fetch desired requests based on switch status.
            let requests = createVisionRequests()
            // Created a request handler.
            let imageRequestHandler = VNImageRequestHandler(cgImage: image,
                                                            orientation: orientation,
                                                            options: [:])
            
            // Send the requests to the request handler.
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try imageRequestHandler.perform(requests)
                } catch let error as NSError {
                    print("Failed to perform image request: \(error)")
                    return
                }
            }
        }
        
        /// - Tag: CreateRequests
        fileprivate func createVisionRequests() -> [VNRequest] {
            
            
            var requests: [VNRequest] = []
            
            requests.append(self.textDetectionRequest)
            
           
            return requests
        }
        
        fileprivate func handleDetectedText(request: VNRequest?, error: Error?) {
            if (error as NSError?) != nil {
               print("NSError at handledDetectText function: ", error!)
                return
            }
            // Perform drawing on the main thread.
            DispatchQueue.main.async {
                guard let drawLayer = self.pathLayer,
                    let results = request?.results as? [VNTextObservation] else {
                        return
                }
                self.draw(text: results, onImageWithBounds: drawLayer.bounds)
                drawLayer.setNeedsDisplay()
            }
        }
        
        lazy var textDetectionRequest: VNDetectTextRectanglesRequest = {
            let textDetectRequest = VNDetectTextRectanglesRequest(completionHandler: self.handleDetectedText)
           
            textDetectRequest.reportCharacterBoxes = true
            return textDetectRequest
        }()
        

        private func TextInImage(_ image: UIImage) {

             guard let cgImage = image.cgImage else { return }

             scanButton.isEnabled = false

             textRecognitionWorkQueue.async {

                 let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])

                 do {

                     try requestHandler.perform([self.textRecognitionRequest])

                 } catch {

                     print(error)

                 }

             }

         }

         

         // MARK: - VNDocumentCameraViewControllerDelegate

         func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {

             

             guard scan.pageCount >= 1 else {

                

                 controller.dismiss(animated: true)

                 return

             }

             

            
             let originalImage = scan.imageOfPage(at: 0)

             let fixedImage = reloadedImage(originalImage)

             

             
            
             controller.dismiss(animated: true)

             

             // Process the image

             processImage(fixedImage)

         }

         

         func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {

             

             print("Error: ", error)

             

            

             controller.dismiss(animated: true)

         }

         

         func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {

             controller.dismiss(animated: true)

         }

         



         func reloadedImage(_ originalImage: UIImage) -> UIImage {

             guard let imageData = originalImage.jpegData(compressionQuality: 1),

                 let reloadedImage = UIImage(data: imageData) else {

                     return originalImage

             }

             return reloadedImage

         }
    
    
        //Prompts view only if we can not find the data for the inputs on the server side.
        func promptViews(){
            nextButton.isEnabled = false
            textView.alpha = 1
            if(prompt == "Title")
            {
            textView.text = "Pick your Events Title by clicking on the correct text Box."
                nextButton.isEnabled = true
                return
            }
            else if (prompt == "Loc")
            {
                textView.text = "Pick your Events Location by clicking on the correct text Box."
                nextButton.isEnabled = true
                return
            }
            else
            {
                textView.alpha = 0
                nextButton.isEnabled = true
                print("Title; ", gTitle ?? "Event1")
                print("Location: ", gLoc ?? "Location1")
                let calendarController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.calendarController) as? CalenderController
                
                self.view.window?.rootViewController = calendarController
                self.view.window?.makeKeyAndVisible()
                return
            }
            
            
            
        }
        
        //Gets the value using the buttons around the boxes and our Dictionary with the text recognized.
        func getStringFromDict(key: String!)
        {
            if(prompt == "Title")
            {
                print("title prompt")
                let value = Int(key!)
                let string: String! = textDict[value!]
                print("string: ",string!)
                gTitle = string
                prompt = "Loc"
                return
            }
            else if(prompt == "Loc")
            {
                print("Loc prompt")
                let value2 = Int(key!)
                let string2: String! = textDict[value2!]
                print("string2: ", string2!)
                gLoc = string2
                prompt = ""
                return
            }
        
            
        }
    
     
    @IBAction func LogoutTapped(_ sender: Any) {
        
        
        //Log Off the Firebase account if there is one connected
        
        //Goes back to First view
        let viewController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.viewController) as?
            ViewController
        
        self.view.window?.rootViewController = viewController
        self.view.window?.makeKeyAndVisible()
    }
    

}
