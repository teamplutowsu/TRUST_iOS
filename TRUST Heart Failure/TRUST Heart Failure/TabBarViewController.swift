//
//  TabBarViewController.swift
//  TRUST Heart Failure
//
//  Created by Gene Lee on 2/27/17.
//  Copyright © 2017 Nathan VelaBorja. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Set up db only on app if first launched
        if (UserDefaults.standard.object(forKey: "firstLaunch") == nil) {
            UserDefaults.standard.set(true, forKey: "firstLaunch")
            Database.db.initModules()
            print("first launch, init db")
            Database.db.fetchModules()
        } else {
            print("not first launch")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
