//
//  SuccessViewController.swift
//  EPRS
//
//  Created by Matthias Bogarin on 12/12/19.
//  Copyright © 2019 Matthias Bogarin, Daniel Vilajetid , Josh Persaud, Esau Cuellar. All rights reserved.
//

import UIKit

class SuccessViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //no functionality need all UI and style is created from the StoryBoard.
    }
    

    @IBAction func DoneTapped(_ sender: Any) {
        
        let homeViewController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as?
            HomeViewController
        
        self.view.window?.rootViewController = homeViewController
        self.view.window?.makeKeyAndVisible()
    }
    
}
