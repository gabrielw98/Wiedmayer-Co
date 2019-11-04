//
//  ProfileVC.swift
//  Wiedmayer & Co
//
//  Created by Gabe Wilson on 10/12/19.
//  Copyright © 2019 Gabe Wilson. All rights reserved.
//

import Foundation
import UIKit
import Parse
import SendGrid_Swift
import SCLAlertView

class ProfileVC: UIViewController {
    
    @IBOutlet weak var settingsImageView: UIImageView!
    @IBOutlet weak var inviteImageView: UIImageView!
    @IBOutlet weak var adminImageView: UIImageView!
    @IBOutlet weak var actionsView: UIView!
    @IBOutlet weak var adminLabel: UIButton!
    
    var code = ""
    var verifiedEmails = ["ryan@wiedmayer.com", "gabewils4@gmail.com"]
    let textView = UITextView(frame: CGRect.zero)
    
    @IBAction func profileUnwind(segue: UIStoryboardSegue) {
    }
    
    @IBAction func settingsAction(_ sender: Any) {
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: true
        )
        
        let alert = SCLAlertView(appearance: appearance)
        alert.addButton("Report") {
            self.performSegue(withIdentifier: "showReport", sender: nil)
        }
        alert.showInfo("Notice", // Title of view
        subTitle: "Report a bug or any features that might be useful to you.", // String of view
        colorStyle: 0x434343,
        colorTextButton: 0xF9E4B7)
    }
    
    @IBAction func inviteAction(_ sender: Any) {
        let items: [Any] = ["Manage properties with our new app!", URL(string: "http://www.wiedmayer.com")!]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
    
    @IBAction func adminAction(_ sender: Any) {
        if DataModel.adminStatus == "Verified" {
            let appearance = SCLAlertView.SCLAppearance(
                kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
                kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
                kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
                showCloseButton: true
            )
            
            let alert = SCLAlertView(appearance: appearance)
            alert.showInfo("Congrats on Admin Status!", // Title of view
            subTitle: "You are now able to add, update, and delete properties.", // String of view
            colorStyle: 0x434343,
            colorTextButton: 0xF9E4B7,
            circleIconImage: UIImage(named: "adminUnlocked"))
        } else if DataModel.adminStatus == "Requested" {
            let appearance = SCLAlertView.SCLAppearance(
                kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
                kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
                kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
                showCloseButton: true
            )
            let alert = SCLAlertView(appearance: appearance)
            alert.showEdit("Notice", // Title of view
            subTitle: "Your admin status request will be reviewed within 5 business days.", // String of view
            colorStyle: 0x434343,
            colorTextButton: 0xF9E4B7)
        } else {
            let appearance = SCLAlertView.SCLAppearance(
                kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
                kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
                kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
                showCloseButton: true
            )
            let alert = SCLAlertView(appearance: appearance)
            
            // Alert Textfield
            let txt = alert.addTextField("Enter your work email")
            txt.keyboardAppearance = .dark
            txt.autocorrectionType = .no
            txt.returnKeyType = .done
            txt.keyboardType = .emailAddress
            txt.autocapitalizationType = .none
            
            alert.addButton("Send Code") {
                print("Text value: \(String(describing: txt.text))")
                let email = txt.text
                if email != nil && self.isValidEmail(emailStr: email!) && self.verifiedEmails.contains(email!) {
                    self.code = self.createVerificationCode()
                    self.sendMail(enteredEmail: email!, code: self.code)
                } else {
                    print("Not a verified email...")
                    let failAlertAppearance = SCLAlertView.SCLAppearance(
                        kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
                        kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
                        kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
                        showCloseButton: true
                    )
                    
                    let failAlert = SCLAlertView(appearance: failAlertAppearance)
                    failAlert.addButton("Request Admin Status") {
                        self.requestAdminAccess()
                    }
                    failAlert.showInfo("Notice", // Title of view
                    subTitle: "This is not a verified email address. Email gabewils4@gmail.com to request admin status.", // String of view
                    colorStyle: 0x434343,
                    colorTextButton: 0xF9E4B7)
                    return
                }
            }
            alert.showEdit("Email", // Title of view
            subTitle: "Enter your email to recieve a 6 digit verification code.", // String of view
            colorStyle: 0x434343,
            colorTextButton: 0xF9E4B7)
        }
        
    }
    
    func createVerificationCode() -> String {
        let min: UInt32 = 100_000
        let max: UInt32 = 999_999
        let i = min + arc4random_uniform(max - min + 1)
        return String(i)
    }
    
    func isValidEmail(emailStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: emailStr)
    }
    
    
    @IBAction func logoutAction(_ sender: Any) {
        let refreshAlert = UIAlertController(title: "Notice", message: "Are you sure you want to log out?", preferredStyle: UIAlertController.Style.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (action: UIAlertAction!) in
            DataModel.isAdmin = false
            DataModel.adminStatus = ""
            PFUser.logOut()
            //self.performSegue(withIdentifier: "unwindProfileToRegistration", sender: nil)
            self.performSegue(withIdentifier: "logoutSegue", sender: nil)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        present(refreshAlert, animated: true, completion: nil)
    }
    
    func requestAdminAccess() {
        if let path = Bundle.main.path(forResource: "keys", ofType: "plist") {
            let keys = NSDictionary(contentsOfFile: path)
            let sendGrid = SendGrid(withAPIKey: keys!["sendGridKey"] as! String)
            let contentText = "Username: '" + PFUser.current()!.username! + "', ID: '" + PFUser.current()!.objectId! + "'"
            let content = SGContent(type: .plain, value: contentText)
            let personalization = SGPersonalization(to: [ SGAddress(email: "gabewils4@gmail.com")])
            let subject = "Admin Status Request"
            let from = SGAddress(email: "sender@wiedmayer-co.com")
            let email = SendGridEmail(personalizations: [personalization], from: from, subject: subject, content: [content])
            sendGrid.send(email: email) { (response, error) in
                if let error = error {
                    print(error)
                } else {
                    DataModel.adminStatus = "Requested"
                    DispatchQueue.main.async {
                        self.adminLabel.setTitle("Requested", for: .normal)
                    }
                    let CurrentUser = PFUser(withoutDataWithObjectId: PFUser.current()?.objectId)
                    CurrentUser["adminStatus"] = "Requested"
                    CurrentUser.saveInBackground { (success, error) in
                        if success {
                            print("Success: Request Admin Status Email Sent")
                        } else {
                            print("Error:", error!)
                        }
                    }
                }
            }
        }
    }
    
    func sendMail(enteredEmail: String, code: String) {
        if let path = Bundle.main.path(forResource: "keys", ofType: "plist") {
            let keys = NSDictionary(contentsOfFile: path)
            let sendGrid = SendGrid(withAPIKey: keys!["sendGridKey"] as! String)
            let content = SGContent(type: .plain, value: "The verification code is \(code).")
            let from = SGAddress(email: "sender@wiedmayer-co.com")
            let personalization = SGPersonalization(to: [ SGAddress(email: enteredEmail) ])
            let subject = "Verification Code"
            let email = SendGridEmail(personalizations: [personalization], from: from, subject: subject, content: [content])
            sendGrid.send(email: email) { (response, error) in
                if let error = error {
                    print(error)
                } else {
                    print("Email Sent with this code:", code)
                    //Update
                    let appearance = SCLAlertView.SCLAppearance(
                        kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
                        kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
                        kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
                        showCloseButton: true
                    )
                    DispatchQueue.main.async {
                        let alert = SCLAlertView(appearance: appearance)
                        
                        // Alert Textfield
                        let txt = alert.addTextField("Enter the code")
                        txt.keyboardAppearance = .dark
                        txt.keyboardType = .numberPad
                        
                        alert.addButton("Verify") {
                            print("Text value: \(String(describing: txt.text))")
                            if txt.text == self.code {
                                DataModel.isAdmin = true
                                DataModel.adminStatus = "Verified"
                                DataModel.adminStatusChanged = true
                                let CurrentUser = PFUser(withoutDataWithObjectId: PFUser.current()?.objectId)
                                CurrentUser["isAdmin"] = true
                                CurrentUser["adminStatus"] = "Verified"
                                CurrentUser.saveInBackground { (success, error) in
                                    if success {
                                        print("Success: Saved the current admin")
                                    } else {
                                        print("Error:", error!)
                                    }
                                }
                            }
                        }
                        alert.showEdit("Verify Code", // Title of view
                        subTitle: "Enter the your email to recieve a 6 digit verification code.", // String of view
                        colorStyle: 0x434343,
                        colorTextButton: 0xF9E4B7)
                    }
                    
                }
            }
        }
    }
    
    override func viewDidLoad() {
        print("In ProfileVC")
        self.setupUI()
    }
    
    func setupUI() {
        
        if DataModel.adminStatus == "Requested" {
            self.adminLabel.setTitle("Requested", for: .normal)
        }
        
        // Actions
        self.actionsView.clipsToBounds = true
        self.actionsView.layer.cornerRadius = 5
        let inviteTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(inviteTapped(tapGestureRecognizer:)))
        let adminTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(adminTapped(tapGestureRecognizer:)))
        let settingsTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(settingsTapped(tapGestureRecognizer:)))
        
        // Image Views
        self.inviteImageView.isUserInteractionEnabled = true
        self.adminImageView.isUserInteractionEnabled = true
        self.settingsImageView.isUserInteractionEnabled = true
        self.inviteImageView.addGestureRecognizer(inviteTapGestureRecognizer)
        self.adminImageView.addGestureRecognizer(adminTapGestureRecognizer)
        self.settingsImageView.addGestureRecognizer(settingsTapGestureRecognizer)
    }
    
    @objc func inviteTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.inviteAction(self)
    }
    
    @objc func adminTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.adminAction(self)
    }
    
    @objc func settingsTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.settingsAction(self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "logoutSegue" {
            let targetVC = segue.destination as! RegistrationVC
            targetVC.fromLogout = true
        }
    }
    
    
}
