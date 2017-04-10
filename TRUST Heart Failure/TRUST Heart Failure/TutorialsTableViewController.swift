//
//  TutorialsTableViewController.swift
//  TRUST Heart Failure
//
//  Created by Gene Lee on 2/27/17.
//  Copyright © 2017 Nathan VelaBorja. All rights reserved.
//

import UIKit

class TutorialsTableViewController: UITableViewController {

    var tutorials = [[String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        // Set background to clear so we can see navigation controller image background
        self.view.backgroundColor = UIColor.clear
        
        print("TutorialsTableViewController")
        
        initTutorials()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Database.db.logInteraction("Accessed Tutorials")
    }
    
    func initTutorials() {
        tutorials.append(["Application Overview", "Icon_Sun-Filled", "https://www.youtube.com/embed/Cgivkf6EEuM"])
        tutorials.append(["Page View Overview", "Tab_Home-Filled", "https://www.youtube.com/embed/oN_81PdZX0k"])
        tutorials.append(["How to Turn Pages", "Tab_Home-Hollow", "https://www.youtube.com/embed/IZ-gMZTxen4"])
        tutorials.append(["How to Use Table of Contents", "Icon_TableOfContents-Filled", "https://www.youtube.com/embed/qQejtKHHdoM"])
        tutorials.append(["How to Change Page Settings", "Icon_TextSize-Filled", "https://www.youtube.com/embed/H9CM5KkTqfI"])
        tutorials.append(["How to Add a Bookmark", "Icon_Ribbon-Filled", "https://www.youtube.com/embed/hxC4jAq2J8w"])
        tutorials.append(["How to Delete a Bookmark", "Icon_Ribbon-Hollow", "https://www.youtube.com/embed/ReKY5MnLWbM"])
        tutorials.append(["How to Access Additional Reading", "Tab_Home-Filled", "https://www.youtube.com/embed/X3Ae0RHpX4g"])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tutorials.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tutorialCell", for: indexPath) as! TutorialTableViewCell

        // Configure the cell...
        let cellInfo = tutorials[indexPath.row]
        
        cell.tutorialLabel.text = cellInfo[0]
        cell.tutorialImage.image = UIImage(imageLiteralResourceName: cellInfo[1])
        cell.youtubeURL = cellInfo[2]
        
        // Style the cell
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 0.5
        cell.layer.borderColor = UIColor.white.cgColor
        cell.backgroundColor = UIColor(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.6)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        performSegue(withIdentifier: "segueToTutorialView", sender: cell)
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        print("Segue: segueToTutorialView ")
        
        let tutorialView = segue.destination as! TutorialViewController
        let cell = sender as! TutorialTableViewCell
        tutorialView.navigationItem.title = cell.tutorialLabel.text
        tutorialView.url = cell.youtubeURL
        
        Database.db.logInteraction("Viewing tutorial for \"\(cell.tutorialLabel.text!)\"")
    }
}
