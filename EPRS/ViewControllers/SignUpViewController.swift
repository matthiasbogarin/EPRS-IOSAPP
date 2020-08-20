//
//  SignUpViewController.swift
//  EPRS
//
//  Created by Matthias Bogarin on 11/6/19.
//  Copyright © 2019 Matthias Bogarin, Daniel Vilajetid , Josh Persaud, Esau Cuellar. All rights reserved.
//




//Here we import all the appropriate Libraries and CocoaPods we utilize in this view.
import UIKit
import FirebaseAuth
import Firebase

class SignUpViewController: UIViewController, UITextFieldDelegate{
    
    //All the elements declared here and connected to the main.storyboard
    
    @IBOutlet var FirstNameTextField: UITextField!
    
    @IBOutlet var LastNameTextField: UITextField!
    
    
    @IBOutlet var EmailTextField: UITextField!

    @IBOutlet var PasswordTextField: UITextField!
    
    @IBOutlet var RepeatPasswordTextField: UITextField!
    
    @IBOutlet var SignUpButton: UIButton!
    
    @IBOutlet var ErrorLabel: UILabel!
    
    
    
 
    
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor(red: 0, green: 0.4471, blue: 0.3412, alpha: 1.0)
        super.viewDidLoad()
        
        self.FirstNameTextField.delegate = self
        self.LastNameTextField.delegate = self
        self.EmailTextField.delegate = self
        self.PasswordTextField.delegate = self
        self.RepeatPasswordTextField.delegate = self
        
    
        
        
                
        //Sets up the UI for the app to make the buttons and textfield have a more modern view.
        setUpElements()
    }
  
    //opens up keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //Method for hiding keyboard when the return button is clicked.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    //This will return to the previous page if the back button is clicked.
    //It does this by performing a seque to that specific view..
    @IBAction func BackButtonTapped(_ sender: Any) {
        
        self.performSegue(withIdentifier:"ViewController", sender: self);
    }
    
    
    //This function calls the Utilities file that holds functions that change the layout of our views to look more modern.
    func setUpElements(){
        
        
        //hide the error label
        ErrorLabel.alpha = 0
        
        
        //Style the elements
        Utilities.styleTextField(FirstNameTextField)
        Utilities.styleTextField(LastNameTextField)
        Utilities.styleTextField(EmailTextField)
        Utilities.styleTextField(PasswordTextField)
        Utilities.styleTextField(RepeatPasswordTextField)
        Utilities.styleFilledButton(SignUpButton)
        
        
    }

    
    //Here in this function we evaulate the fields that are put into the textfields.
    //It also checks if the user left any textfield empty and prompts the appropiate errors.
    func validateFields() -> String?{
        
        
        //Check that all fields are filled in.
        if EmailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            PasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            RepeatPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            FirstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            LastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            
            return "Please fill in all fields."
        }
        
        
        //Check if the password is secure.
        let cleanedPassword = PasswordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if Utilities.isPasswordValid(cleanedPassword) == false{
            //password isnt secure enough.
            return "Please make sure your passwrd is at least 8 characters, contains a special character and a number."
        }
        //Check if the passwords are the same.
        if PasswordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines) != RepeatPasswordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        {
            //Will return an error message if the passwords do not match.
            return "Please make sure the passwords are the same."
        }
        
        return nil
    }

    //Add the code for adding the first name, last name and calendar preference to the firebase app.
    
    //figure out how to get google to give us access to their calendar.
    
    
    @IBAction func SignUpTapped(_ sender: Any) {
        
        //Validate fields.
        let error = validateFields()
        
        if error != nil{
            showError(error!)
        }
        else
        {
            
            //Create clean versions of the data.
            
            let firstname = FirstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let lastname = LastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            
            let email = EmailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let password = PasswordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Create the user.
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
               if err != nil {
                    //There was an error creating the user.
                    self.showError("Error creating user")
               }
               else
               {
                    //User was created successfully
                    //This also will insert the users info into our firebase database.
                   
                let db = Firestore.firestore()
                
                db.collection("users").addDocument(data: ["FirstName": firstname,"LastName": lastname, "email": email,"password": password,"uid": result!.user.uid]){(error) in
                    
                    if error != nil{
                        self.showError("Error saving user data")
                    }
                    
                    self.transitionToHome()
                    //This then will move the user to the homeview of our app to scan/take a photo of their preferred event.
                    
                }
                
        
                    
                }
            }
        }
        
    }
    
   
    
    //Transition to home screen
    func transitionToHome(){
        
        let homeViewController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as?
            HomeViewController
        
        self.view.window?.rootViewController = homeViewController
        self.view.window?.makeKeyAndVisible()
        
    }
    
    //This is a universal function to help us display the error on our views.
    //We call this function in many different places and it handles it by recieving the correct string with the proper errro and displays it to the user.
    func showError(_ message:String){
        
        ErrorLabel.text = message
        ErrorLabel.alpha = 1
    }
    
}


