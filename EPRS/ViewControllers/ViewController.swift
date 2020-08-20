//
//  ViewController.swift
//  EPRS
//
//  Created by Matthias Bogarin on 11/4/19.
//  Copyright © 2019 Matthias Bogarin, Daniel Vilajetid , Josh Persaud, Esau Cuellar. All rights reserved.
//



//Here we import all the appropriate Libraries and CocoaPods we utilize in this view.
import UIKit
import Firebase

class ViewController: UIViewController{

    
    @IBOutlet var LoginWithEmailButton: UIButton!
    
    @IBOutlet var SignUpWithEmailButton: UIButton!
    
    @IBOutlet var GuestSignInButton: UIButton!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 0, green: 0.4471, blue: 0.3412, alpha: 1.0)
   
        //Set the styles of buttons and textfields
        setUpElements()
        
    }

    
    func setUpElements(){
        
        //Style the Elements
        Utilities.styleFilledButton(LoginWithEmailButton)
        Utilities.styleFilledButton(SignUpWithEmailButton)
        
        Utilities.styleHollowButton(GuestSignInButton)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Disposes of any resources that can be created.
    }
    
    

    @IBAction func LoginView(_ sender: Any) {
        //Performs Seque to loginViewController Page when Login Button is tapped.
        self.performSegue(withIdentifier:"LoginView", sender: self);
    }
    
    @IBAction func SignupView(_ sender: Any) {
         //Performs Seque to SignUpViewController Page when Sign up button is tapped.
        
        self.performSegue(withIdentifier: "SignupView", sender: self);
    }
    
    
    @IBAction func HomeViewController(_ sender: Any) {
       //moves to home
        let homeViewController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as?
            HomeViewController
        
        self.view.window?.rootViewController = homeViewController
        self.view.window?.makeKeyAndVisible()
    }
    
    
}

