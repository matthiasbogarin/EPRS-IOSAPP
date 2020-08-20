//
//  BoudningBoxImageView.swift
//  EPRS
//
//  Copyright © 2019 Matthias Bogarin, Daniel Vilajetid , Josh Persaud, Esau Cuellar. All rights reserved.
//




//Here we import all the appropriate Libraries and CocoaPods we utilize in this view.
import Photos
import Vision
import UIKit


class BoundingBoxImageView: UIImageView {
        var croppedGlobalImage: UIImage?
    
    // The bounding boxes currently shown
    private var boundingBoxViews = [UIView]()
    
    func load(boundingBoxes: [CGRect]) {
        // Remove all the old bounding boxes before adding the new ones
        removeExistingBoundingBoxes()
        
        // Add each bounding box
        for box in boundingBoxes {
            load(boundingBox: box)
        }
    }
    
    // Removes all existing bounding boxes
    func removeExistingBoundingBoxes() {
        for view in boundingBoxViews {
            view.removeFromSuperview()
        }
        boundingBoxViews.removeAll()
    }
    
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            ac.present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            ac.present(ac, animated: true)
        }
    }
    
    private func load(boundingBox: CGRect) {
        // Cache the image rectangle to avoid unneccessary work
        let imageRect = self.imageRect
        
        // Create a mutable copy of the bounding box
        var boundingBox = boundingBox
        
        // Flip the Y axis of the bounding box because Vision uses a different coordinate system to that of UIKit
        boundingBox.origin.y = 1 - boundingBox.origin.y
        print("Bounding box before conversion: " ,boundingBox)
        
        // Convert the bounding box rect based on the image rectangle
        var convertedBoundingBox = VNImageRectForNormalizedRect(boundingBox, Int(imageRect.width), Int(imageRect.height))
        print("Bounding box after conversion: ", convertedBoundingBox)
        
        // Adjust the bounding box based on the position of the image inside the UIImageView
        // Note that we only adjust the axis that is not the same in both--because we're using `scaleAspectFit`, one of the axis will always be equal
        if frame.width - imageRect.width != 0 {
            convertedBoundingBox.origin.x += imageRect.origin.x
            convertedBoundingBox.origin.y -= convertedBoundingBox.height
        } else if frame.height - imageRect.height != 0 {
            convertedBoundingBox.origin.y += imageRect.origin.y
            convertedBoundingBox.origin.y -= convertedBoundingBox.height
        }
        
        // Enlarge the bounding box to make it contain the text neatly
        let enlargementAmount = CGFloat(2.2)
        convertedBoundingBox.origin.x    -= enlargementAmount
        convertedBoundingBox.origin.y    -= enlargementAmount
        convertedBoundingBox.size.width  += enlargementAmount * 2
        convertedBoundingBox.size.height += enlargementAmount * 2
        
        let cgImage1 = self.image?.cgImage
        let uiImage1 = UIImage(cgImage:cgImage1!)
      
        let view = UIView(frame: convertedBoundingBox)
        view.layer.opacity = 1
        view.layer.borderColor = UIColor.green.cgColor
        view.layer.borderWidth = 2
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        view.backgroundColor = .clear
        
        
      
        //croppedGlobalImage = UIImage(cgImage: croppedCGImage!)
        
        addSubview(view)
        boundingBoxViews.append(view)
        
       
    }
}


