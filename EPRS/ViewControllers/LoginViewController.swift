//
//  LoginViewController.swift
//  EPRS
//
//  Created by Matthias Bogarin on 11/6/19.
//  Copyright © 2019 Matthias Bogarin, Daniel Vilajetid , Josh Persaud, Esau Cuellar. All rights reserved.
//




//Here we import all the appropriate Libraries and CocoaPods we utilize in this view.
import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var EmailTextField: UITextField!
    
    @IBOutlet var PasswordTextField: UITextField!
    
    @IBOutlet var LoginButton: UIButton!
    
    @IBOutlet var ErrorLabel: UILabel!
    
    
    
    

    override func viewDidLoad() {
        self.view.backgroundColor = UIColor(red: 0, green: 0.4471, blue: 0.3412, alpha: 1.0)
        super.viewDidLoad()

        self.EmailTextField.delegate = self
        self.PasswordTextField.delegate = self
        
        //Sets up the UI for the app to make the buttons and textfield have a more modern view.
        setUpElements()
        
    }
    
    //open up keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //Method for hiding keyboard when the return button is clicked.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    
    
    //This will return to the previous page if the back button is clicked.
    //It does this by performing a seque to that specific view.
    @IBAction func BackButtonTapped(_ sender: Any) {
        
        self.performSegue(withIdentifier:"ViewController", sender: self);
    }
    
    func setUpElements(){
        
        
        //Hide the error label
        ErrorLabel.alpha = 0;
        
        //Style the elements
        Utilities.styleTextField(EmailTextField)
        Utilities.styleTextField(PasswordTextField)
        Utilities.styleFilledButton(LoginButton)
        
        
    }

    
    
    func validateFields() -> String?{
        
        //Check that all fields are filled in.
        if EmailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            PasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
        
            return "Please fill in all fields."
            
        }
        
        return nil
    }
    
     
    @IBAction func LoginTapped(_ sender: Any) {
        
        //Validate Text Fields
        let error = validateFields()
        
         //Create clean versions of the data.
         
         let email = EmailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
         
         let password = PasswordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        //Signing in the user
        
        if error != nil{
            showError(error!)
        }
        else
        {
            //checks for authorization
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                
                if error != nil
                {
                    //Couldnt sign in
                    self.ErrorLabel.text = error!.localizedDescription
                    self.ErrorLabel.alpha = 1
                }
                else
                {
                    //calls next view
                    let homeViewController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as?
                               HomeViewController
                           
                           self.view.window?.rootViewController = homeViewController
                           self.view.window?.makeKeyAndVisible()
                    
                    
                }
            }
        }
    }
    
    func showError(_ message:String){
        //dispays any error passed to the function from anywhere in the app.
        ErrorLabel.text = message
        ErrorLabel.alpha = 1
    }
}
