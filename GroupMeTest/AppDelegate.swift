//
//  AppDelegate.swift
//  GroupMeTest
//
//  Created by Brian Lin on 12/15/15.
//  Copyright © 2015 Brian Lin. All rights reserved.
//

import UIKit
import Alamofire
import Parse
import Bolts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var ACCESS_TOKEN: String! // This access token belongs to the user and will be used to join or leave groups that have been created already (user will never create a group)
    var ADMIN_TOKEN: String! = "Uy6V4BXpuvHDp6XUWZ0IkgSQojFRw1h3SRhAWoK6" // This access token corresponds to an admin account that we will use to create and track every single group
    
    
    // Add handleOpenURL function- will call this function everytime the app is opened from a URL
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        
        // This code chunk is for setting up PARSE
        Parse.setApplicationId("jy4MUG3yk2hLkU7NVTRRwQx1p5siV9BPwjr3410A",
            clientKey: "crnLPudofSLV9LmmydyAl2Eb8sJmlHi4Pd6HNtxW")
        
        let urlString = url.query // take in String https://YOUR_CALLBACK_URL/?access_token=ACCESS_TOKEN
        let queryArray = urlString!.componentsSeparatedByString("=") // split url like Java's String.split()
        ACCESS_TOKEN = queryArray[1]; // should contain ACCESS TOKEN only
//        print(ACCESS_TOKEN);
        
        var courseString = "Bio201" // Placeholder Course String
        var groupID = String() // Store GroupID of newly created group
        var memberCount = Int() //
        
        //         This code chunk SHOWS a group with the user's ACCESS_TOKEN
        Alamofire.request(.GET, "https://api.groupme.com/v3/groups/18779921?token=" + ACCESS_TOKEN)
            .responseJSON { response in
                if let test = response.result.value {
                    //                        print("My response: " + "\(test)")
                    //                            groupID = Int("\(test["response"]!!["group_id"])")
                    groupID = "\(test["response"]!!["group_id"]!!)"
                    //                        print( "\(groupID)") // Need to get rid of Optional() wrapper
                    print("Course String: " + courseString)
                    print("Group ID: " + groupID)
                    
                    
                    //                        print("Number of members: \(test["response"]!!["members"]!!.count)") // This needs to be checked
                    memberCount = test["response"]!!["members"]!!.count
                    print("Member Count: " + String(memberCount))
                    print(memberCount)
                    
                }
        }
        
        // This code chunk MAKES a group using the ADMIN_TOKEN
        //        let parameters: [String: AnyObject] = ["name":"Test 1", "share":true]
        //        Alamofire.request(.POST, "https://api.groupme.com/v3/groups?token=" + ADMIN_TOKEN, parameters: parameters, encoding: .JSON).responseJSON { response in
        //            if let test = response.result.value {
        //                groupID = Int("\(test["response"]!!["group_id"])")
        //                print( "\(groupID)") // Print for debugging
        //
        //                print("Number of members: \(test["response"]!!["members"])") // Use this format to parse JSON!!
        //            }
        //            }
        
        // For some reason, the below code is executing before the Alamofire stuff, which causes us to send blank fields to Parse
        
        // This code chunk is for testing PARSE
        var testObject = PFObject(className: courseString)
        testObject["GroupID"] = String(groupID)
        testObject["MemberCount"] = Int(memberCount)
//        testObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
//            print("New group has been created and stored.")
        testObject.saveInBackground()
        print("end")
//        }
        
        
        
        return true;
        //TODO: Add bad request check?
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

