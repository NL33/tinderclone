//
//  ContactsViewController.swift
//  Tinder
//
//  Created by NL33 2014.
//  Copyright (c) 2014 Appfish. All rights reserved.
//

import UIKit
import MessageUI

class ContactsViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    var emails = [String]()  //this is for the looping through user information for two matching users below    
    var images = [NSData]()  //this is for the looping through user information for two matching users below
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MATCHING USERS WHO HAVE ACCEPTED EACH OTHER
        //Return only those users who have accepted our user and who have been accepted by our user:
        var query = PFUser.query()
        query.whereKey("accepted", equalTo: PFUser.currentUser().username)  //we look in the accepted column on Parse, and want to search for our current user's user name. Note that if you set the equal to whereKey on an array, it will look for the presence of that anywhere on the array
        
        query.whereKey("username", containedIn: PFUser.currentUser()["accepted"] as [AnyObject]) //also want to find where their user name is contained in the array of the current user
        //
        //Run the query:
        query.findObjectsInBackgroundWithBlock { (results, error) -> Void in //this runs the query
        
            if results != nil {
                
                println(results)
                
                for result in results { //we loop through the results, and display the email and the image by appending them to the arrays we used above:
                    
                    self.emails.append(result["email"] as String)
                    
                    self.images.append(result["image"] as NSData)
                    
                    
                }
                self.tableView.reloadData()  //update the table
                
            }
            
            
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    //DEFINE THE TABLE CELLS:
     override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return emails.count  //return the number of emails in the list
        
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell { //configure the cell:
        
        // Update - replaced as with as!
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel?.text = emails[indexPath.row] //set the cell text label text to be the email address
        
        cell.imageView?.image = UIImage(data: images[indexPath.row]) //set the image to be a UIImage and get that from data, and the data we will use is images and indexPath
        
        // Configure the cell...
        
        return cell
    }
    
    
    //ENABLING SENDING OF EMAIL:
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var url = NSURL(string: "mailto:dts@apple.com")  //this is a "mail to" string. This is embedding sending an email in our app.
        //NOTE THAT Rob in the video includes a different code (perhaps for older Xcode versions):
        //var url = NSURL(string: "mailto:" + emails(indexPath.row) + "?subject=Hi!").  NOTE: To send the email within the app itself, can Use MFMailComposeView
        
        UIApplication.sharedApplication().openURL(url!)  //this calls the URL (opening it up)
        
    }
    
}
