//
//  ViewController.swift
//  TinderClone
//
//  Created by NL33 on 2/12/15.
//  Copyright (c) 2015 NL33. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
  
    @IBOutlet weak var loginCancelledLabel: UILabel! //corresponds to message saying login did not work--initially alpha set to 0 (so hidden)
    
    var fbloginView:FBLoginView = FBLoginView(readPermissions: ["email", "public_profile"])

    @IBAction func signIn(sender: AnyObject) {
        
        self.loginCancelledLabel.alpha = 0  //this makes the label saying login failed invisible every time button is pressed.
        
        var permissions = ["email", "public_profile"]  //if wanted full permissions we can get from Facebook, would enter: var permissions = ["public_profile", "email", "likes"]
        
        //LOGS IN WITH FACEBOOK WHEN CLICK SIGNUP:
        PFFacebookUtils.logInWithPermissions(permissions, {
            (user: PFUser!, error: NSError!) -> Void in
            if user == nil {
                NSLog("Uh oh. The user cancelled the Facebook login.")
                
                self.loginCancelledLabel.alpha = 1  //this is to show the label saying login failed.
                
            } else if user.isNew {
                NSLog("User signed up and logged in through Facebook!")
                
                self.performSegueWithIdentifier("signUp", sender: self) //if user new and sign up successful do the segue with identifier "signUp"--which takes to signup view controller.
                
            } else {
                NSLog("User logged in through Facebook!")
                
                
            }

        })
        
        
    }
        override func viewDidLoad() {
        super.viewDidLoad()
        //CHECKING IF CURRENT USER IS LOGGED IN:
            if PFUser.currentUser() != nil {
                
                println("User logged in")
                
                
            }
        //THIS IS TO SEND PUSH NOTIFICATIONS:
        var push = PFPush()
        push.setMessage("This is a test") //this will be what the message is
        push.sendPushInBackgroundWithBlock({
            (isSuccessful: Bool!, error: NSError!) -> Void in  //isSuccessful is a boolean to tell us if sucessful
            
            println(isSuccessful)
        })
        
        
      
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

