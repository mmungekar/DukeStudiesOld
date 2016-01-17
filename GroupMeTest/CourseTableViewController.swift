//
//  CourseTableViewController.swift
//  GroupMeTest
//
//  Created by Brian Lin on 1/15/16.
//  Copyright © 2016 Brian Lin. All rights reserved.
//
//
//  CourseTableViewController.swift
//  SwiftParseChat
//
//  Created by Jesse Hu on 3/9/15.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

/* Brian's Key Changes:
- Comment out all references to 'GroupSelectTableViewControllerDelegate'
- Replace courseToGroupSegue with courseToSectionSegue (since we still need to segue to section selection)
*/

import UIKit

class CourseTableViewController: UITableViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    
    var subject: NSDictionary!
    var courses: NSArray!
    //    var delegate: GroupSelectTableViewControllerDelegate!
    var selectedSubjectString: String! // to be displayed in SectionVC
    var selectedCourseString: String! // to be displayed in SectionVC
    var selectedCourse: [String: String]!
    
    var filteredCourses: NSArray!
    var searchController: UISearchController!
    var parseClassString: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        if let subjectCode = subject["code"] as? String {
            self.navigationItem.title? = subjectCode
        }
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.sizeToFit()
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.definesPresentationContext = true;
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchController.active {
            return self.filteredCourses.count
        }
        return self.courses.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        if self.searchController.active {
            if let course = self.filteredCourses[indexPath.row] as? [String: String] {
                cell.textLabel?.text = course["course_number"]
                cell.detailTextLabel?.text = course["course_title"]
            }
        }
        else {
            if let course = self.courses[indexPath.row] as? [String: String] {
                cell.textLabel?.text = course["course_number"]
                cell.detailTextLabel?.text = course["course_title"]
            }
        }
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if self.searchController.active {
            /* Retrieve course and append subject code and name */
            if let course = self.filteredCourses[indexPath.row] as? [String: String] {
                self.selectedCourse = course
                parseClassString = parseClassString + " " + course["course_number"]! as String
                if let code = self.subject["code"] as? String {
                    self.selectedCourse["subject_code"] = code
                }
                if let desc = self.subject["desc"] as? String {
                    self.selectedCourse["subject_desc"] = desc
                }
                
                self.performSegueWithIdentifier("courseToSectionSegue", sender: self)
            }
        }
        else {
            /* Retrieve course and append subject code and name */
            if let course = self.courses[indexPath.row] as? [String: String] {
                self.selectedCourse = course
                self.selectedCourseString = course["course_number"]! as String
                parseClassString = parseClassString + course["course_number"]! as String
                print(parseClassString)
                if let code = self.subject["code"] as? String {
                    self.selectedCourse["subject_code"] = code
                }
                if let desc = self.subject["desc"] as? String {
                    self.selectedCourse["subject_desc"] = desc
                }
                
                self.performSegueWithIdentifier("courseToSectionSegue", sender: self)
            }
        }
    }
    
    // MARK: - Navigation
    
    //    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    //        if segue.identifier == "courseToGroupsSegue" {
    //            let groupSelectVC = segue.destinationViewController as! GroupSelectTableViewController
    //            groupSelectVC.delegate = self.delegate
    //            groupSelectVC.course = self.selectedCourse
    //        }
    //    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "courseToSectionSegue" {
            let sectionVC = segue.destinationViewController as! SectionTableViewController
            sectionVC.selectedCourseString = self.selectedCourseString
            sectionVC.selectedSubjectString = self.selectedSubjectString
            sectionVC.parseClassString = self.parseClassString
            //            courseVC.delegate = self.delegate
            //            sectionVC.subject = self.selectedCourse
            //            sectionVC.courses = self.courses
        }
    }
    
    
    // MARK: - UISearchControllerDelegate
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        
        let predicate = NSPredicate(format: "course_number contains[c] %@ OR course_title contains[c] %@", argumentArray: [searchString!, searchString!])
        self.filteredCourses = self.courses.filteredArrayUsingPredicate(predicate)
        
        self.tableView.reloadData()
    }
    
}
