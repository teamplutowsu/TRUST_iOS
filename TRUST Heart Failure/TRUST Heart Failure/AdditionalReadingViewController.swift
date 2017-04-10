//
//  AdditionalReadingViewController.swift
//  TRUST Heart Failure
//
//  Created by Nathan VelaBorja on 3/23/17.
//  Copyright © 2017 Nathan VelaBorja. All rights reserved.
//

import UIKit

class AdditionalReadingViewController: UIViewController {

    
    @IBOutlet weak var module1Background: UIView!
    @IBOutlet weak var module4Background: UIView!
    @IBOutlet weak var module6Background: UIView!
    @IBOutlet weak var module1Progress: UIProgressView!
    @IBOutlet weak var module4Progress: UIProgressView!
    @IBOutlet weak var module6Progress: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set view background image
        self.view.backgroundColor = UIColor.init(patternImage: #imageLiteral(resourceName: "home"))
        
        // Blur background image (from http://pinkstone.co.uk/how-to-apply-blur-effects-to-images-and-views-in-ios-8/)
        let blur = UIBlurEffect(style: .regular)
        let effectView = UIVisualEffectView(effect: blur)
        effectView.frame = self.view.frame
        self.view.insertSubview(effectView, at: 0)
        
        // Round edges of module backgrounds
        module1Background.clipsToBounds = true
        module1Background.layer.cornerRadius = 10
        module4Background.clipsToBounds = true
        module4Background.layer.cornerRadius = 10
        module6Background.clipsToBounds = true
        module6Background.layer.cornerRadius = 10
        
        // Round edges of progress bars
        module1Progress.clipsToBounds = true
        module1Progress.layer.cornerRadius = 2
        module4Progress.clipsToBounds = true
        module4Progress.layer.cornerRadius = 2
        module6Progress.clipsToBounds = true
        module6Progress.layer.cornerRadius = 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        Database.db.logInteraction("Accessed Additional Readings")
        // Set progress bar progress
        
        // Module 1
        let module1Max = Float(Database.db.fetchNumPages("01"))
        let module1PLA = Float(Database.db.fetchLastPageAccessed("01"))
        module1Progress.setProgress(module1PLA! / module1Max!, animated: true)
        
        // Module 4
        let module4Max = Float(Database.db.fetchNumPages("04"))
        let module4PLA = Float(Database.db.fetchLastPageAccessed("04"))
        module4Progress.setProgress(module4PLA! / module4Max!, animated: true)
        
        // Module 6
        let module6Max = Float(Database.db.fetchNumPages("06"))
        let module6PLA = Float(Database.db.fetchLastPageAccessed("06"))
        module6Progress.setProgress(module6PLA! / module6Max!, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapDetected (recognizer: UITapGestureRecognizer) {
        let module1Frame = module1Background.frame
        let module4Frame = module4Background.frame
        let module6Frame = module6Background.frame
        let location = recognizer.location(in: self.view)
        
        if (module1Frame.contains(location)) {
            performSegue(withIdentifier: "additionalReadingToModule", sender: "01")
        }
        else if (module4Frame.contains(location)) {
            performSegue(withIdentifier: "additionalReadingToModule", sender: "04")
        }
        else if (module6Frame.contains(location)) {
            performSegue(withIdentifier: "additionalReadingToModule", sender: "06")
        }
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let module = segue.destination as! ModuleViewController
        let mid = (sender as! String)
        
        switch(mid) {
        case "01":
            module.mid = "01"
            module.pagePrefix = "page_01_"
            module.imagePrefix = "img_01_"
            module.navigationItem.title = "Taking Control"
        case "04":
            module.mid = "04"
            module.pagePrefix = "page_04_"
            module.imagePrefix = "img_04_"
            module.navigationItem.title = "Self-Care"
        case "06":
            module.mid = "06"
            module.pagePrefix = "page_06_"
            module.imagePrefix = "img_06_"
            module.navigationItem.title = "Managing Feelings"
        default:
            print("Error. Additional Reading Segue to Module")
        }
    }
 

}
