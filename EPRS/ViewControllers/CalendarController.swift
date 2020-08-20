//
//  CalendarController.swift
//  EPRS
//
//  Created by Matthias Bogarin on 11/30/19.
//  Copyright © 2019 Matthias Bogarin, Daniel Vilajetid , Josh Persaud, Esau Cuellar. All rights reserved.
//
import UIKit
import EventKit
import EventKitUI
import Foundation


class CalenderController: UIViewController {

    var Home = HomeViewController()
    let eventStore = EKEventStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Requests access to the calendar.
        eventStore.requestAccess(to: .event, completion: {granted, error in})
        
        setUpInitialTexts()
        
        setUpElements()
    
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func setUpInitialTexts(){
        
        EditEventLabel.alpha = 1
        TitleLabel.alpha = 1
        EventTitle.text = gTitle!
        print("Title of text",EventTitle.text!)
        EventTitle.alpha = 1
        DateLabel.alpha = 1
        EventDate.date = gDate!
        EventDate.alpha = 1
        LocationLabel.alpha = 1
        EventLocation.text = gLoc!
        print("Title of Loc",EventLocation.text!)
        EventLocation.alpha = 1
        PushToCalendar.alpha = 1
        
    }
    
    func setUpElements(){
        
        
        Utilities.styleTextField(EventTitle)
        Utilities.styleTextField(EventLocation)
        Utilities.styleFilledButton(PushToCalendar)
        
    }
    
    //Object that will be usedto create an event in the user's calendar
    //let eventStore = EKEventStore()
    
    //Function to request access to use the calendar
    func requestAccess(to entityType: EKEntityType, completion: @escaping EKEventStoreRequestAccessCompletionHandler){}

    //variables connected to the various textfields, textview, and label
    @IBOutlet var EditEventLabel: UILabel!

    @IBOutlet weak var EventTitle: UITextField!
    
    @IBOutlet var TitleLabel: UILabel!
    @IBOutlet weak var EventLocation: UITextField!
    
    @IBOutlet var LocationLabel: UILabel!
    @IBOutlet weak var EventDate: UIDatePicker!
    @IBOutlet var DateLabel: UILabel!
    
    @IBOutlet weak var ErrorLabel: UILabel!
    
    @IBOutlet var PushToCalendar: UIButton!
    
    //A validation function which ensures all of the datafields are filled
    func validation() -> String?{
        if EventTitle.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
         EventLocation.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            return "Please fill out data fields"}
        else{
            return nil
        }
    }
    
    //Universal function used throughout the app to show an error message
    func showError(_ message:String){
        
        ErrorLabel.text = message
        ErrorLabel.alpha = 1
    }
    
    //Main regex funtion. Uses NSDataDetector to find the date object in the string. Data Detector allows for multiple different formats of date without having to use expanded if else statements, or multiple declarations of DateFormatter. Will look for the date within the string. result.date is the object to be returned, and is the date object extracted from the string
    func findDate(_ dateString:String) -> Date?{
        let types: NSTextCheckingResult.CheckingType = .date
        let dataDetector = try! NSDataDetector(types: types.rawValue)
        let result = NSTextCheckingResult()
        dataDetector.enumerateMatches(in: dateString, options: [], range: NSMakeRange(0, dateString.count)) { (result, _, _) in }
        return result.date
    }
    
    func calToSuccess(){
               let successViewController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.successViewController) as?
               SuccessViewController
        
        self.view.window?.rootViewController = successViewController
        self.view.window?.makeKeyAndVisible()
           }
    
    //The function for the button. Will check if the fields are filled, and the format for date and time are correct.
    @IBAction func Push(_ sender: Any) {
        let error = validation()
        
        //Will display error if fields are not filled
        if(error != nil){
            showError(error!)
        }
        else{
            //Created the event object
            let event = EKEvent(eventStore: self.eventStore)
                        //Requests access to the calendar.
            let end_date = EventDate.date
            //Will set the event object to the textfields
            event.title = EventTitle.text
            event.location = EventLocation.text
            //Uses the above regex function in order to set the start and end dates
            event.startDate = EventDate.date
            event.endDate = end_date.advanced(by: 3600.0)
            event.calendar = eventStore.defaultCalendarForNewEvents
            
            
            
            //A try catch to create an event in the IOS calendar. Will show an error message if the event fails to save. This will likely be due to the wrong date/time format being used
            do
            {
                try eventStore.save(event, span: .thisEvent)
                calToSuccess()
            }
            catch
            {
                print("Error info: \(error)")
            }
        }
       
    }
}

