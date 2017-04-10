//
//  TutorialsNavigationViewController.swift
//  TRUST Heart Failure
//
//  Created by Nathan VelaBorja on 3/22/17.
//  Copyright © 2017 Nathan VelaBorja. All rights reserved.
//

import UIKit

class TutorialsNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "home"))
        
        // Blur background image (from http://pinkstone.co.uk/how-to-apply-blur-effects-to-images-and-views-in-ios-8/)
        let blur = UIBlurEffect(style: .regular)
        let effectView = UIVisualEffectView(effect: blur)
        effectView.frame = self.view.frame
        self.view.insertSubview(effectView, at: 0)
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
