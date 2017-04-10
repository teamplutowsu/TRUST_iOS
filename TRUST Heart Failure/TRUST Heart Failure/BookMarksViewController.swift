//
//  BookMarksViewController.swift
//  TRUST Heart Failure
//
//  Created by Kameron Haramoto on 3/8/17.
//  Copyright © 2017 Nathan VelaBorja. All rights reserved.
//

import UIKit

class BookMarksViewController: UIViewController {

    @IBOutlet weak var BackGroundImage: UIImageView!
    @IBOutlet weak var bookmarkTableViewControllerContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let blur = UIBlurEffect(style: .regular)
        let effectView = UIVisualEffectView(effect: blur)
        effectView.frame = self.view.frame
        self.BackGroundImage.addSubview(effectView)
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
