//  BackEndMethods.swift
//  GroupMeTest
//
//  Created by Austin Hua on 1/15/16.
//  Copyright © 2016 Brian Lin. All rights reserved.
//

import UIKit
import Alamofire
import Parse
import Bolts




//TO STORE DATA LOCALLY
//      NSUserDefaults.standardUserDefaults().setObject(classObjectMap, forKey: "classObjectMap")
//
//TO ACCESS DATA STORED LOCALLY
//      if let userName = NSUserDefaults.standardUserDefaults().objectForKey("name") as? String {
//          print(userName)
//      }

// -------------------------------------------
//  BACKEND METHODS TO BE INTEGRATED WITH APP
// -------------------------------------------

class Backend {
    let baseURL = "https://api.groupme.com/v3"
    let ADMIN_TOKEN: String! = "Uy6V4BXpuvHDp6XUWZ0IkgSQojFRw1h3SRhAWoK6"
    var sectionNumber = "99"
//    var ACCESS_TOKEN: String! = "789c70c095910133042e1d21ec12b914" // user's access token, comes from OAuth login
    var tempString = "Test1"
    // Prints a String
    func testFunc(myString: String, completion: (result: String) -> Void) {
        print(myString)
        completion(result: "we finished")
    }
    
    // ---------------------
    //  Creating a new group
    // ---------------------
    
    // Called by: CreateGroupViewController.swift
    
    // Helper function to make a new group when section doesn't exist, makes nested call to joinGroup()
    // Inputs: 
    //    1) Course String - from inherited global variable
    //    2) Section Number String - from text field
    //    3) Professor Name String - from text field
    func makeGroup(parseClassString: String, mySection: String, myProf: String, completion: (result: String) -> Void){
        var objectID = String()
        var groupID = String()
        var shareToken = String()
        
        // Retrieve stored tokens
        let adminToken = NSUserDefaults.standardUserDefaults().objectForKey("adminToken") as? String
        
        // Make a new group
        let parameters: [String: AnyObject] = ["name":parseClassString, "share":true]
        Alamofire.request(.POST, self.baseURL + "/groups?token=" + adminToken!, parameters: parameters, encoding: .JSON) // CREATES a new group using above 'parameters' variable
            .responseJSON { response in
                if let test = response.result.value {
                    // Code for parsing Group ID
                    groupID = "\(test["response"]!!["group_id"]!!)"
                    // Code for parsing Share Token
                    var shareURL = test["response"]!!["share_url"]!!
                    var shareArray = shareURL.componentsSeparatedByString("/")
                    shareToken = shareArray[shareArray.count-1]
                    
                    // Add new object to Parse
                    // CITE: Taken from Parse's quick start tutorial: https://parse.com/apps/quickstart#parse_data/mobile/ios/swift/existing
                    var testObject = PFObject(className: parseClassString)
                    testObject["groupID"] = groupID
                    testObject["sectionProf"] = myProf
                    testObject["shareToken"] = shareToken
                    testObject["memberCount"] = 1
                    testObject["sectionNumber"] = mySection
                    testObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            print("New group " + groupID + " has been created and stored.")
                            objectID = testObject.objectId!
                            // Note: group info will be locally stored using the joinGroup() method
                            // Now add the USER to this new group!
                            self.joinGroup(groupID, shareToken: shareToken, objID: objectID, courseString: parseClassString){
                                (result: String) in
                                completion(result: "create and join finished")
                            }

                        }
                        else {
                            print("Error has occurred in storing new group " + groupID)
                            print(error)
                        }
                    }
                }
        }
    }
    
    
    // --------------------------
    //  Joining an existing group
    // --------------------------
    
    // Called by: SectionTableViewController.swift
    
    // Joins a group that already exists
    // Inputs:
    //    1) joinURL - comes from makeString()
    //    2) objID - comes from Parse
    //    3) token - comes from OAuth login
    //    4) courseString - comes from parseClassString
    
    func joinGroup(groupID: String, shareToken: String, objID: String, courseString: String, completion: (result: String) -> Void) -> Void {
        
        // Retrieve userToken from local storage
        let userToken = NSUserDefaults.standardUserDefaults().objectForKey("userToken") as? String
        
        let myRequest = "/groups/" + groupID + "/join/" + shareToken
        
        // Add user to group with Alamofire
        Alamofire.request(.POST, self.baseURL + myRequest + "?token=" + userToken!)
//        print("Group Joined")
//        print("courseString: " + courseString + " " + "objID: " + objID)
        
        // Update Parse's member count for that group
        var query = PFQuery(className:courseString)
        query.getObjectInBackgroundWithId(objID) {
            (object: PFObject?, error: NSError?) -> Void in
            if error != nil {
                print(error)
            } else if let object = object {
                var temp: Int = object["memberCount"] as! Int
                object["memberCount"] = temp + 1
                object.saveInBackground()
            }
        }
        
        // Update local storage with joined group's information
        if var classObjectMap = NSUserDefaults.standardUserDefaults().objectForKey("classObjectMap") as? Dictionary<String,String> {
            classObjectMap[courseString] = objID
            NSUserDefaults.standardUserDefaults().setObject(classObjectMap, forKey: "classObjectMap")
            completion(result: "join finished")
        }
        else { // classObjectMap doesn't exist yet
            var classObjectMap = [courseString : objID]
            NSUserDefaults.standardUserDefaults().setObject(classObjectMap, forKey: "classObjectMap")
            completion(result: "join finished")
        }
        
    }

    
    // Recheck member count in GroupMe through Alamofire call
    func getGroupMeMemberCount(groupID: String, objID: String) -> Void {
        var memberCount = Int()
        Alamofire.request(.GET, self.baseURL + "/groups/" + groupID + "?token=" + self.ADMIN_TOKEN) // SHOW group information
            .responseJSON { response in
                if let test = response.result.value {
                    // Find number of members
                    memberCount = test["response"]!!["members"]!!.count
                    // !!!!!!! PUT THE NEXT CODE/FUNCTION TO BE RUN HERE TO WAIT FOR ALAMOFIRE RESPONSE
                }
        }
        
    }
    
    // Get member count from Parse with some courseString(ClassName) and sectionNumber, gotten from the global variables,
    func getParseMemberCount(groupID: String, objID: String) -> Void { // Can extend to get other information from Parse
        var query = PFQuery(className:tempString)
        query.getObjectInBackgroundWithId(objID)
            {
            (object: PFObject?, error: NSError?) -> Void in
            if error != nil {
                print(error)
                print("Error from Parse")
            } else if let object = object {
                var memberCount: Int = object["memberCount"] as! Int
                // !!!!!!! PUT THE NEXT CODE/FUNCTION TO BE RUN HERE TO WAIT FOR PARSE RESPONSE
            }
        }
//        query.findObjectsInBackgroundWithBlock {
//            (objects: [PFObject]?, error: NSError?) -> Void in
//            if error == nil {
//                // The find succeeded.
//                print("Successfully retrieved \(objects!.count) groups.")
//                // Do something with the found objects
//                if let objects = objects {
//                    for object in objects {
//                        print("Object ID: " + object.objectId!)
//                        print("Group ID: " + String(object["groupID"]))
//                        print("Share Token: " + String(object["shareToken"]))
//                        print("Member Count: " + String(object["memberCount"]))
//                        
//                        if object["memberCount"] as! Int > maxMembers {
//                            objectID = object.objectId!
//                            groupID = object["groupID"] as! String
//                            shareToken = object["shareToken"] as! String
//                            maxMembers = object["memberCount"] as! Int
//                        }
//                    }
//                }
//            }
//        }
    }
    
    // Get group information for the group of interest
    // If empty, delete it and recall checkForOpen (empty = size 1 = only admin)
    // If not empty, calls makeString()
    func checkEmpty(groupID: String, shareToken: String, objID: String) -> Void {
        var memberCount = Int()
        Alamofire.request(.GET, self.baseURL + "/groups/" + groupID + "?token=" + self.ADMIN_TOKEN) // SHOW group information
            .responseJSON { response in
                if let test = response.result.value {
                    // Find number of members
                    memberCount = test["response"]!!["members"]!!.count
                    print("Member count of " + groupID + " in GroupMe: " + String(memberCount))
                }
                if memberCount == 1 {
                    self.deleteGroup(groupID, objID: objID) //Delete group and recall checkForOpen()
                }
        }
    }
    
    // Delete group from both GroupMe and Parse
    func deleteGroup(groupID:String, objID:String) -> Void {
        var query = PFQuery(className:tempString)
        query.getObjectInBackgroundWithId(objID) {
            (object: PFObject?, error: NSError?) -> Void in
            if error != nil {
                print(error)
                print("Error deleting group from Parse")
            } else if let object = object {
                object.deleteInBackground()
                print("Deleting " + groupID)
                Alamofire.request(.POST, self.baseURL + "/groups/" + groupID + "/destroy?token=" + self.ADMIN_TOKEN) // Delete from Alamofire
            }
        }
    }

}