//
//  TinderViewController.swift
//  Tinder
//
//  Created by Rob Percival on 17/10/2014.
//  Copyright (c) 2014 Appfish. All rights reserved.
//

import UIKit

class TinderViewController: UIViewController {
       var xFromCenter: CGFloat = 0  //this is to enable the element to drag to the right when the user drags to the right, and left when user drags to the left. See below...
   
    //these three variables are for loading up the users, per the code below:
    var usernames = [String]() //array of strings to put in the usernames from the users around our user
    var userImages = [NSData]() //array of nsdata to put in the images from those users
    var currentUser = 0 //this is to identify what user we are on in the system as the user goes through

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //GETTING USER LOCATION: We want to do this whenever this page loads (we have previously entered the prompts to get user location at info.plist):
        PFGeoPoint.geoPointForCurrentLocationInBackground { (geopoint: PFGeoPoint!, error: NSError!) -> Void in //to save the location to Parse
            
            if error == nil {
                
                println(geopoint)
                
                var user = PFUser.currentUser()
                
                user["location"] = geopoint
                
                //GET USERS (and user info) that are closest to user to produce on the app (this is mostly from Parse code):
                var query = PFUser.query()
                query.whereKey("location", nearGeoPoint:geopoint) //near the geopoint that is nearest
                
                query.limit = 10 //this limits to 10 users we would see
                query.findObjectsInBackgroundWithBlock({ (users, error) -> Void in
                    //loop through the users and display them:
                   
                    //SYSTEM TO AVOID SHOWING USERS WHO HAVE BEEN ACCEPTED OR REJECTED
                    
                    var accepted = [String]() //set variable as empty array of strings
                    
                    if PFUser.currentUser()["accepted"] != nil {  //IF THERE ARE ANY USERS THAT HAVE BEEN ACCEPTED OR (BELOW) REJECTED, THEN DO THE FOLLOWING (don't want to do this unless someone already accepted/rejected, else there will be an error--NOTE THIS conditional is added in in the later video, lecture 133, at 6:50:
                      accepted = PFUser.currentUser()["accepted"] as [String] //this is an array of strings. Idea is that we will make sure that the username that has been entered into an accepted or rejected column in Parse (per below code) does not get entered into this array.  THe parse column is the PFUser "accepted" column from below. We set an array equal to anyone in this column.  Same action with respect to rejected below                    }
                    }
                    
                    var rejected = [String]()
                    
                    
      
                    if PFUser.currentUser()["rejected"] != nil {
                    rejected = PFUser.currentUser()["rejected"] as [String]
                    }
                    
                    //
                    
                    for user in users { //the below is to save the images.  For speedy download, it might be a good idea to download just a few at a time, not 10 at a time.//This code is to only display the gender that the user is interested in, and also to be sure the user is not getting him or herself to come up. Note that originally Rob did this by using code like whereKey...NotEqual to username, but a bug meant this would not work. Rob was not sure why, so we did the below method, which is a bit less efficient because it is producing more data than we need:
                        
                        var gender1 = user["gender"] as? NSString  //we convert to string so we can compare (otherwise would have issue with comparing any object)
                        var gender2 = PFUser.currentUser()["interestedIn"] as? NSString  //We convert here again to be able to compare. (note that interestedIn is the column in Parse we have created
                        
                        if gender1 == gender2 && PFUser.currentUser().username != user.username && !contains(accepted, user.username) && !contains(rejected, user.username){  //if both of these are true  && THE CONTAINS STATEMENTS the variable (here, the username of the user) is not contained inside the array (here, the accepted array) and ALSO the variable username is not contained inside the "rejected" array--the Contains statements here are used so that the user who has already been accepted or rejected, does not come here. If so, then append to the array:
                            
                            self.usernames.append(user.username)
                            self.userImages.append(user["image"] as NSData)
                            
                        }
                        
                        
                    }
                //CREATE IMAGE THAT WILL BE DRAGGED:
                    var userImage: UIImageView = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)) //the info in parantheses sets the size of the image to be the size of the screen
                    userImage.image = UIImage(data: self.userImages[0]) //this sets up the image
                    userImage.contentMode = UIViewContentMode.ScaleAspectFit //this sets the proper aspect ratio for the image
                    self.view.addSubview(userImage)
                    
                    var gesture = UIPanGestureRecognizer(target: self, action: Selector("wasDragged:"))
                    userImage.addGestureRecognizer(gesture)  //this adds the gesture to the image
                    
                    userImage.userInteractionEnabled = true  //this adds user interaction to the image
                    
                    
                    
                })
                
                user.save()
                
            }
            
        }
        
    }
    
    //MOVING THE OBJECT WHEN USER DRAGS:
    func wasDragged(gesture: UIPanGestureRecognizer) {
        //we need to know how much was dragged in any particular drag. a "Translation" is a vector that takes you from one point on the screen to another point (like 1 to the right, and 3 up...)
        let translation = gesture.translationInView(self.view) //this gives us the movement (the translation) in this part of the drag. So we want to move the label by this translation:
        var label = gesture.view! //this is the thing that has been dragged.
        
        xFromCenter += translation.x  //this means that any move to the right is going to increase x from center, and any move to the left is going to decrease x from center
        
        var scale = min(100 / abs(xFromCenter), 1) //this is to make the object smaller as we drag right or left. Scale is relative to x from center. We want it to get smaller as x from center gets bigger. Scale is the number we stretch by. Stretch below is the transformation itself. We use "abs" to make it positive. Otherwise the result could be negative, meaning it would flip upside down (22:00 of video).  We also put in the min...1 to say that it will have a maximum scale of 1 (do not want it bigger than that). Means that take the smaller of the number in the paranthesis or 1.
        
        label.center = CGPoint(x: label.center.x + translation.x, y: label.center.y + translation.y)//this changes the position of the label by the translation. The x coordinate is the center of the lable + the distance moved along the x; same with the y. Translation.x is the amount it moves to the right. Translation.y is the amount it moves to the left.
        
        gesture.setTranslation(CGPointZero, inView: self.view)  //this sets the translation back to 0 after the drag is registered.
        
        var rotation:CGAffineTransform = CGAffineTransformMakeRotation(xFromCenter / 200) //this is part of rotating the object. AffineTransform is a certain type of transformation. The transformation is measured by radiants (breaking up a circle into a bout 4 parts--so 1 would be 1/4 of a circle. the xfrom Center is to make the element go right as swipe right and legt as swipe left.
        
        var stretch:CGAffineTransform = CGAffineTransformScale(rotation, scale, scale) //this is the transformation itself.
        
        label.transform = stretch //this applies the transformation to the label
        

        
        //to reset the label to be in the original location and original orientation when user lifts finger off of screen, and to register if swiped left or right
        if gesture.state == UIGestureRecognizerState.Ended { //meaning if the gesture is done/user has let go:
            
            //TO DETECT IF USER DRAGS PAST A CERTAIN POINT ON SCREEN, and add User to reject or accept:
            if label.center.x < 100 { //label.center.x gives us the x coordinate of the label. So, if this is less than 100--meaning it has been swiped to the left, then it is a reject:
                
                println("Not Chosen")
                
                PFUser.currentUser().addUniqueObject(self.usernames[self.currentUser], forKey:"rejected")  //adding user to the rejected column we have set up in Parse.
                PFUser.currentUser().save() //saving user added to reject
                
                self.currentUser++  //this is the code to increment the user (the "currentUser") that our user is reviewing
            
            } else if label.center.x > self.view.bounds.width - 100 { //self.view.bounds.width is to get the width of the screen (so, by itself it would be the full length of the screen--ie, over all the way to the left). -100 to say do not need to go all the way to the end of the screen. So, if swiped to the right:
                
                println("Chosen")
                
                PFUser.currentUser().addUniqueObject(self.usernames[self.currentUser], forKey:"accepted") //to add user to accepted column we have set up in Parse
                PFUser.currentUser().save()
                
                self.currentUser++ //this is the code to increment the user (the "currentUser") that our user is reviewing            
            
            }
            
            label.removeFromSuperview()
            
             //replacing the image with the Next User that should be displayed:
            if self.currentUser < self.userImages.count { //this is to set what happens if run out of users to view
              
                var userImage: UIImageView = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
                userImage.image = UIImage(data: self.userImages[self.currentUser])
                userImage.contentMode = UIViewContentMode.ScaleAspectFit
                self.view.addSubview(userImage)
                
                //RECOGNIZING WHEN USER DRAGS:
                var gesture = UIPanGestureRecognizer(target: self, action: Selector("wasDragged:")) //UIPan is "panning"--same thing as dragging. So this gesture recognizer recognizes dragging. wasDragged isthe function below. The colon is necessary to send what we need bout the gesture to the wasDragged function below.
                label.addGestureRecognizer(gesture) //we then add the recognizer to the label itself
                
                label.userInteractionEnabled = true//we add this to enable the label to be moved around. Normally a label is not moving. THis would not be necessary for a button. We expressly have to tell xcode to make the label interactive.
                xFromCenter = 0
                
            } else {
                
                println("No more users") //if run out of users, could have label come up saying "We have run out of users", or load more users when a certain amount are left--could load more when 3 or 4 in array (look at difference between current user and count of array, and then run the code again at that point)
                
            }
            
        }
    
     
    
        //ADDING OTHER PEOPLE:
        var i = 10
        
        func addPerson(urlString:String) {  //function will download the image noted below and add it to profile for new user.
            
            var newUser = PFUser()
            
            let url = NSURL(string: urlString)  //this and below is code from earlier for getting picture of user
            
            let urlRequest = NSURLRequest(URL: url!)
            
            NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue(), completionHandler: {
                response, data, error in
                
                newUser["image"] = data
                
                newUser["gender"] = "female"
                
                //CREATE LOCATION FOR NEW USERS:
                
                var lat = Double(37 + i)  //Double is the type of variable you put into PFGeoPoint. the "37" for lat and "-122" for lon are from Rob's code, as they are Rob's lat and Lon. This code gives the new users a location that is near Rob, and then also adds in the i variable, which changes each time function runs, to ensure the new users we are adding have different locations
                
                var lon = Double(-122 + i)
                
                i = i + 10 //we increase i by 10 each time we recreate the function.
                
                var location = PFGeoPoint(latitude: lat, longitude: lon)
                
                newUser["location"] = location
                
                
                //SET USER NAME AND PASSWORD FOR EACH USER
                newUser.username = "\(i)"  //this uses the is variable so they all have different user name and convert it to string
                
                newUser.password = "password"
                
                newUser.signUp()
                
            })
           
        }
        //ADDING OTHER USERS WITH THE FUNCTION ABOVE:
     
         addPerson("http://www.polyvore.com/cgi/img-thing?.out=jpg&size=l&tid=44643840")
         addPerson("http://static.comicvine.com/uploads/square_small/0/2617/103863-63963-torongo-leela.JPG")
         addPerson("http://i263.photobucket.com/albums/ii139/whatgloom/janejetson.jpg")
         addPerson("http://www.scrapwallpaper.com/wp-content/uploads/2014/08/female-cartoon-characters-pictures-6.jpg")
        addPerson("http://diaryofalagosmumblog.files.wordpress.com/2011/11/smurfette-scaled500.gif")
        
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
