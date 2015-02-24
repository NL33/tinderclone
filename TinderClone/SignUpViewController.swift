//
//  SignUpViewController.swift
//  Tinder
//
//  Created by Rob Percival on 17/10/2014.
//  Copyright (c) 2014 Appfish. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    
    @IBOutlet weak var genderSwitch: UISwitch!
    
    
    @IBAction func signUp(sender: AnyObject) {
        
        var user = PFUser.currentUser()
        
        if genderSwitch.on { //this will say true if the switch is to the right; false if switch is to the left
            
            user["interestedIn"]="female"  //we chose female just because in the storyboard we had set it up so that women are on the right. We have used female/male instead of just men and women
            
        } else {
            
            user["interestedIn"]="male"
            
        }
        
        user.save() //save info to Parse
        
        self.performSegueWithIdentifier("signedUp", sender: self)  //identifier for the Segue is signUp and the sender is this viewcontroller (ie, Self)
        
    }

 
     weak var profilePic: UIImageView!
    
     override func viewDidLoad() {
        super.viewDidLoad()
        //GET USERS PROFILE PIC FROM FACEBOOK TO SHOW UP ON LOADING:
        var user = PFUser.currentUser()
        
        var FBSession = PFFacebookUtils.session() //this is a session that will allow us to get the Facebook API
        
        var accessToken = FBSession.accessTokenData.accessToken //required to get the Facebook API
        
        let url = NSURL(string: "https://graph.facebook.com/me/picture?type=large&return_ssl_resources=1&access_token="+accessToken) //this is the location of the user's profile picture. the string is from Facebook's api (Facebook graph is Facebook's API).
        
        let urlRequest = NSURLRequest(URL: url!)  //this line and next are to send the request to retrieve the picture
        
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue(), completionHandler: { //
            response, data, error in
            
            let image = UIImage(data: data) //the data is what is returned from the NSURL connection request
            
            self.profilePic.image = image //
            
            //SAVING THE IMAGE WE GET FROM FACEBOOK TO OUR SYSTEM (ie, PARSE), SO WE DO NOT HAVE TO QUERY FACEBOOK EVERY TIME TO GET THE IMAGE:
            
            user["image"] = data
            
            user.save()
            
            //GET USER'S GENDER AND NAME AND EMAIL FROM FACEBOOK AND SAVING TO PARSE:
            FBRequestConnection.startForMeWithCompletionHandler({  //this will go online and get all the details of the user that we request:
                connection, result, error in //this returns the information from the Facebook account
                
                user["gender"] = result["gender"] //this saves the gender portion of the information we retrieved (result["gender"])
                user["name"] = result["name"] //this gets the user's name from the facebook information result
                 user["email"] = result["email"]  //gets email from facebook information and saves
                
                user.save() //saves this user
                
                println(result)
                
                
            })
            
        })
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
