//
//  BookmarksTableViewController.swift
//  TRUST Heart Failure
//
//  Created by Gene Lee on 2/27/17.
//  Copyright © 2017 Nathan VelaBorja. All rights reserved.
//

import UIKit
import CoreData

class BookmarksTableViewController: UITableViewController {
    
    var bms: [NSManagedObject] = []
    let section = ["Advance Care Planning", "Taking Control of Heart Failure", "Self-Care", "Managing Feelings About Heart Failure"]
    var sectionedBms = [[NSManagedObject](), [NSManagedObject](), [NSManagedObject](), [NSManagedObject]()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        print("BookmarksTableViewController")
        
        self.tableView.backgroundColor = .clear
    }
    
    // refresh the table, everytime we come in
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            //Clear the 2d array of bookmarks so the list in the view is accurate.
            
            self.getBookMarks()
            self.tableView.reloadData()
        }
        Database.db.logInteraction("Accessed Bookmarks")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    //customize the table section headers
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        if(self.sectionedBms[section].count > 0)
        {
            let title = UILabel()
            title.font = UIFont(name: "System", size: 25)
        
            //let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
            header.contentView.backgroundColor = UIColor(white: 1, alpha: 0.75)
            header.textLabel!.font = title.font
            header.textLabel?.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)//black text
            //header.layer.cornerRadius = 10
            header.layer.borderWidth = 0.5
            header.layer.borderColor = UIColor.white.cgColor
            header.textLabel?.text = header.textLabel!.text!.capitalized
            header.isHidden = false
            
        }
        else{
            header.isHidden = true
        }
    }
    //Set section header height
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //This hides empty sections
        if(self.sectionedBms[section].count == 0)
        {
            return 0.1
        }
        else{
            return 40.0
        }
        
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        //This hides empty sections
        if(self.sectionedBms[section].count == 0)
        {
            return ""
        }
        else{
            return self.section[section]
        }
        
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        //Eliminates gaps when sections have no bookmarks in them
        if(self.sectionedBms[section].count == 0)
        {
            return 0.1
        }
        else{
            return 5.0
        }
    }
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        //Helps eliminate "jumpy" view when cells get deleted and the view is updated.
        return 75.0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.section.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sectionedBms[section].count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> BookmarkTableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookmarkCell", for: indexPath) as! BookmarkTableViewCell
        let bookmark = self.sectionedBms[indexPath.section][indexPath.row]//bms[indexPath.row]
        let mid = bookmark.value(forKey: "module_num") as! String
        let pid = bookmark.value(forKey: "page_num") as! String
        
        cell.mid = mid
        cell.pid = pid
        
        var moduleName = ""
        switch (mid) {
        case "01":
            moduleName = "Taking Control"
        case "04":
            moduleName = "Self-Care"
        case "06":
            moduleName = "Managing Feelings"
        case "09":
            moduleName = "Advance Care"
        default:
            break
        }
        
        // Get page name from TOC file (currently fastest way to do this)
        var toc = [String]()
        let tocPrefix = "TOC_"
        let pagePath = Bundle.main.path(forResource: tocPrefix + mid, ofType: "csv")
        
        do {
            // Get entire page file
            let pageFile = try String(contentsOfFile: pagePath!)
            toc = pageFile.components(separatedBy: ",")
        } catch {
            print("BookmarksTableViewController: Error loading toc. mid=\(mid)")
        }
        
        let tocData = toc[Int(pid)! - 1].components(separatedBy: ":")
        let pageName = tocData[1]
        
        // Configure the cell...
        cell.pageNumberLabel.text = pid
        cell.subtitleLabel.text = pageName
        
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = UIColor.white.cgColor
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "bookmarkToModule", sender: indexPath)
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            let cell = tableView.cellForRow(at: indexPath) as! BookmarkTableViewCell
            let mn = cell.mid
            let pn = cell.pageNumberLabel.text!
            
            Database.db.removeBookmark(mn, pn)
            Database.db.logInteraction("Removed bookmark Module:\(mn) Page:\(pn) from Bookmark View")
            
            getBookMarks()
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            //Eliminates "jumpy" section headers while cells are deleted
            let sectionIndex = IndexSet(integer: indexPath.section)
            DispatchQueue.main.async {
                self.tableView.reloadSections(sectionIndex, with: .fade)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        //grokswift.com/transparent-table-view
        cell.backgroundColor = UIColor(white:1, alpha: 0.6)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let module = segue.destination as! ModuleViewController
        let indexPath = sender as! IndexPath
        let cell = self.tableView.cellForRow(at: indexPath) as! BookmarkTableViewCell
        
        module.mid = cell.mid
        module.pid = cell.pid
        module.pagePrefix = "page_\(cell.mid)_"
        module.imagePrefix = "img_\(cell.mid)_"
        module.navigationItem.title = "Bookmark \(indexPath.row + 1)"
        
        Database.db.logInteraction("Tapped bookmark for Module:\(cell.mid) Page:\(cell.pid)")
        print("Segue: bookmarkToModule mid=\(cell.mid) pid=\(cell.pid)")
    }
    
    func getBookMarks(){
        //Get a list of all bookmarks
        bms = Database.db.fetchBookmarks()!
        
        //Clear the 2D array that holds the bookmarks per each section
        self.sectionedBms = [[NSManagedObject](), [NSManagedObject](), [NSManagedObject](), [NSManagedObject]()]
        
        //Sort each bookmark by module number into a 2d array.
        for var marks in bms{
            if((marks.value(forKey: "module_num") as! String) == "09")
            {
                sectionedBms[0].append(marks)
            }
            else if((marks.value(forKey: "module_num") as! String) == "01")
            {
                sectionedBms[1].append(marks)
            }
            else if((marks.value(forKey: "module_num") as! String) == "04")
            {
                sectionedBms[2].append(marks)
            }
            else if((marks.value(forKey: "module_num") as! String) == "06")
            {
                sectionedBms[3].append(marks)
            }
        }
    }
}
