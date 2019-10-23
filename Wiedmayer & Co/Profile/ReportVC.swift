//
//  ReportVC.swift
//  Wiedmayer & Co
//
//  Created by Gabe Wilson on 10/23/19.
//  Copyright © 2019 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit
import SendGrid_Swift
import Parse

class ReportVC: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBAction func sendAction(_ sender: Any) {
        sendMail()
        self.performSegue(withIdentifier: "profileUnwind", sender: nil)
    }
    
    override func viewDidLoad() {
        print("In ReportVC")
        setupUI()
    }
    
    func setupUI() {
        
        // Rounded corner
        textView.layer.cornerRadius = 5
        textView.clipsToBounds = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.hideKeyboardWhenTappedAround()
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        print("showing keyboard")
        let keyboardSize = (notification.userInfo?  [UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
       let keyboardHeight = keyboardSize?.height
       if #available(iOS 11.0, *) {
            self.bottomConstraint.constant = -(keyboardHeight!)
       } else {
             self.bottomConstraint.constant = -keyboardHeight!
           }
        self.bottomConstraint.constant = keyboardHeight!

        
        UIView.animate(withDuration: 1.5) {
            self.bottomConstraint.constant = -keyboardHeight!
         }
     }
    
    func sendMail() {
        if let path = Bundle.main.path(forResource: "keys", ofType: "plist") {
            let keys = NSDictionary(contentsOfFile: path)
            let sendGrid = SendGrid(withAPIKey: keys!["sendGridKey"] as! String)
            let content = SGContent(type: .plain, value: self.textView.text)
            let from = SGAddress(email: "sender@wiedmayer-co.com")
            let personalization = SGPersonalization(to: [ SGAddress(email: "gabewils4@gmail.com") ])
            let subject = "Feedback from " + PFUser.current()!.username!
            let email = SendGridEmail(personalizations: [personalization], from: from, subject: subject, content: [content])
            sendGrid.send(email: email) { (response, error) in
                if let error = error {
                    print(error)
                    // Notify user that the email didn't send
                    return
                } else {
                    print("Success: Email Sent")
                    // Add alert that dissolves
                    return
                }
            }
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        print("hide keyboard")
        self.bottomConstraint.constant = 0 // or change according to your logic
         UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
         }
    }
    
    
    
    
}
