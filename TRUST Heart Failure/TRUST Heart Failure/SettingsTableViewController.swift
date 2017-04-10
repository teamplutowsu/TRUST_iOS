//
//  SettingsTableViewController.swift
//  TRUST Heart Failure
//
//  Created by Gene Lee on 2/27/17.
//  Copyright © 2017 Nathan VelaBorja. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    
    var adminPassword: String!
    var adminLoginSuccess: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        print("SettingsTableViewController")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkUserDefaults()
        Database.db.logInteraction("Accessed Settings")
        print(Database.db.logsToJson())
    }

    func checkUserDefaults () {
        if (UserDefaults.standard.object(forKey: "userID") != nil) {
            let id = UserDefaults.standard.string(forKey: "userID")
            userIdLabel.text = "User ID: \(id!)"
            //volumeSlider.value = Float(volume)
        } else {
            userIdLabel.text = "User ID:"
            //volumeSlider.value = 10.0
        }
        
        if (UserDefaults.standard.object(forKey: "version") != nil) {
            let version = UserDefaults.standard.string(forKey: "version")
            versionLabel.text = "\(version!)"
        } else {
            versionLabel.text = "0.0"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0 || section == 1) { // UserID or Version section
            return 1
        }
        else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if (indexPath.row == 0) {
            print ("User Id accessory tapped")
            if (UserDefaults.standard.object(forKey: "userID") == nil) {
                adminPasswordAlert()
            } else {
                let alert = UIAlertController(title: "Oops", message: "App already associated with User ID", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default))
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    // Pops up alert to ask Admin for password
    // Call checkValidAdminPassword to do a url request for password validation
    func adminPasswordAlert () {
        let alert = UIAlertController(title: "Adminstrator", message: "Provide password", preferredStyle: .alert)
        alert.addTextField(configurationHandler: passwordTextFieldHandler)
        alert.addAction(UIAlertAction(title: "Login", style: .default, handler: { (action) in
            // execute some code when this option is selected
            let password = alert.textFields?[0].text
            self.checkValidAdminPassword(password!) // url request to check password
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        
        present(alert, animated: true, completion: nil)
    }
    
    func passwordTextFieldHandler (_ textField: UITextField) {
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
    }
    
    func userIDTextFieldHandler (_ textField: UITextField) {
        textField.placeholder = "User ID"
    }
    
    // Url request to check if password is valid
    func checkValidAdminPassword (_ password: String) {
        var request = URLRequest(url: URL(string: "" /* This string would point to a php script on our server */)!)
        request.httpMethod = "POST"
        let postString = "password=\(password)"
        request.httpBody = postString.data(using: .utf8)
        let session = URLSession.shared

        let task = session.dataTask(with: request, completionHandler: {(data, response, err) in
            if let data = data, let html = String(data: data, encoding: String.Encoding.utf8) {
                let jsonData = html.data(using: .utf8)!
                if let json = try? JSONSerialization.jsonObject(with: jsonData) as! [String:String] {
                    //print (json)
                    self.adminValidPasswordAlert(json)
                }
            }
        })
        task.resume()
    }
    
    // Shows alert depending on password validation
    func adminValidPasswordAlert (_ json: [String:String]) {
        let alert = UIAlertController(title: "Oops", message: json["error"], preferredStyle: .alert)

        if (json["success"] == "Welcome") {
            print(json["success"]!)
            alert.title = json["success"]
            alert.message = "Enter User ID"
            alert.addTextField(configurationHandler: userIDTextFieldHandler)
            alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { (action) in
                // execute some code when this option is selected
                let userID = alert.textFields?[0].text
                self.assignUserID(userID!)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))

        } else {
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    // Url request to adding User ID
    func assignUserID (_ userID: String) {
        var request = URLRequest(url: URL(string: "" /* This string would point to a php script on our server */)!)
        request.httpMethod = "POST"
        let postString = "ID=\(userID)"
        request.httpBody = postString.data(using: .utf8)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request, completionHandler: {(data, response, err) in
            if let data = data, let html = String(data: data, encoding: String.Encoding.utf8) {
                let jsonData = html.data(using: .utf8)!
                if let json = try? JSONSerialization.jsonObject(with: jsonData) as! [String:String] {
                    //print (json)
                    self.validUserIDAlert(json, userID)
                }
            }
        })
        task.resume()
    }
    
    // Shows alert depending on user ID validation
    func validUserIDAlert (_ json: [String:String], _ userID: String) {
        let alert = UIAlertController(title: "Oops", message: json["error"], preferredStyle: .alert)
        
        if (json.first!.key == "success") {
            print(json["success"]!)
            alert.title = "Success"
            alert.message = json["success"]
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                // execute some code when this option is selected
                UserDefaults.standard.set(userID, forKey: "userID")
                self.checkUserDefaults()
            }))
 
        } else {
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
        }
        
        present(alert, animated: true, completion: nil)
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
