//
//  Module9ViewController.swift
//  TRUST Heart Failure
//
//  Created by Gene Lee on 2/27/17.
//  Copyright © 2017 Nathan VelaBorja. All rights reserved.
//

import UIKit
import AVFoundation

class ModuleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AVSpeechSynthesizerDelegate, UIWebViewDelegate {

    // MARK: -  Bar items
    @IBOutlet weak var bookmarkButton: UIBarButtonItem!
    @IBOutlet weak var textSizeButton: UIBarButtonItem!
    @IBOutlet weak var tableOfContentsButton: UIBarButtonItem!
    @IBOutlet weak var TTSButton: UIBarButtonItem!
    
    // MARK: - Images
    @IBOutlet weak var imageLeft: UIImageView!
    @IBOutlet weak var imageCenter: UIImageView!
    @IBOutlet weak var imageRight: UIImageView!
    @IBOutlet weak var imageBackground: UIImageView!
    
    // MARK: - Titles
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    // MARK: - Web view
    @IBOutlet weak var webView: UIWebView!
    
    // MARK: - Progress
    @IBOutlet weak var progressBar: UIProgressView!
    
    // MARK: - Table of Contents
    @IBOutlet weak var tableOfContentsView: UITableView!
    var tocPrefix = "TOC_"   // + mid + .csv and you have your file!
    var toc = [String]()
    
    // MARK: - Page properties
    var mid = "09"
    var pid = "pla"
    var pimage = ""
    var ptitle = ""
    var psubtitle = ""
    var pcontent = ""
    var pagePrefix = "page_09_"
    var imagePrefix = "img_09_"
    var pageMax = 0
    var bookmarked = false
    
    // MARK: - Settings
    var textSize = "3"
    @IBOutlet weak var settingsTableView: UITableView!
    
    // MARK: - TTS
    let speechSynthesizer = AVSpeechSynthesizer()
    
    // MARK: - OS Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Log module entry
        print("ModuleViewController - pid:\(pid) mid:\(mid)")
        
        // Set tts delagate.
        speechSynthesizer.delegate = self
        
        // Init page textSize entry
        if (UserDefaults.standard.string(forKey: "textSize") == nil) {
            UserDefaults.standard.set(3, forKey: "textSize")
        }
        
        // Blur background image (from http://pinkstone.co.uk/how-to-apply-blur-effects-to-images-and-views-in-ios-8/)
        let blur = UIBlurEffect(style: .regular)
        let effectView = UIVisualEffectView(effect: blur)
        effectView.frame = self.view.frame
        self.imageBackground.addSubview(effectView)
        
        webView.delegate = self
        
        // Round edges of views
        titleLabel.layer.cornerRadius = 10
        titleLabel.clipsToBounds = true
        subtitleLabel.layer.cornerRadius = 10
        subtitleLabel.clipsToBounds = true
        webView.layer.cornerRadius = 10
        webView.clipsToBounds = true
        progressBar.layer.cornerRadius = 2
        progressBar.clipsToBounds = true
        
        // Initialize table of Contents
        initTableOfContents()
        
        // Initialize settings menu
        initSettingsMenu()
        
        // Load page content
        getPageMax()
        
        if (pid == "pla") {     // Only set page to page last accessed if a pid wasn't specified in segue
            getLastPage()
        }
        
        loadPage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Helps maintain settings across tabs, but is redundant on original view load
        loadPage()
        Database.db.logInteraction("Accessed Module:\(mid) Page:\(pid)")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if(speechSynthesizer.isSpeaking)
        {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Button Actions
    @IBAction func TTSButtonPressed(_ sender: UIBarButtonItem) {
        
        Database.db.logInteraction("TTS button pressed.")
        
        if(speechSynthesizer.isSpeaking)
        {
            //Stop the tts. Delegate handles the icon.
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        else{
            // Update icon change on main queue
            DispatchQueue.main.async {
                self.TTSButton.image = #imageLiteral(resourceName: "Icon_TTS-Filled")
            }
            
            // Parse the tags out of the string and speak.
            let str = parseStr(str: pcontent)
            let speechUtterance = AVSpeechUtterance(string: str)
            speechSynthesizer.speak(speechUtterance)
        }
        
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.TTSButton.image = #imageLiteral(resourceName: "Icon_TTS-Hollow")
        }
        Database.db.logInteraction("TTS finished.")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        self.TTSButton.image = #imageLiteral(resourceName: "Icon_TTS-Hollow")
        Database.db.logInteraction("TTS cancelled.")
    }
    
    @IBAction func tableOfContentsButtonPressed(_ sender: UIBarButtonItem) {
        let fadeTime = 0.25
        
        // If settings view is also open, close that first
        if (!settingsTableView.isHidden) {
            textSizeButtonPressed(textSizeButton)
        }
        
        // Fade view in/out then hide/reveal
        if (tableOfContentsView.isHidden) {
            // Reveal view then fade in
            tableOfContentsView.isHidden = false
            UIView.animate(withDuration: fadeTime) {
                self.tableOfContentsView.alpha = 0.97
            }
            
            // Set button icon
            tableOfContentsButton.image = #imageLiteral(resourceName: "Icon_TableOfContents-Filled")
            
            Database.db.logInteraction("Accessed TOC for Module:\(mid)")
        }
        else {
            // Fade out and delay hide
            UIView.animate(withDuration: fadeTime) {
                self.tableOfContentsView.alpha = 0
            }
            let when = DispatchTime.now() + fadeTime
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.tableOfContentsView.isHidden = !self.tableOfContentsView.isHidden
            }
            
            // Set button icon
            tableOfContentsButton.image = #imageLiteral(resourceName: "Icon_TableOfContents-Hollow")
        }
    }
    
    @IBAction func textSizeButtonPressed(_ sender: UIBarButtonItem) {
        let fadeTime = 0.25
        
        // If toc view is also open, close that first
        if (!tableOfContentsView.isHidden) {
            tableOfContentsButtonPressed(tableOfContentsButton)
        }
        
        // Fade view in/out then hide/reveal
        if (settingsTableView.isHidden) {
            // Reveal view then fade in
            settingsTableView.isHidden = false
            UIView.animate(withDuration: fadeTime) {
                self.settingsTableView.alpha = 0.97
            }
            
            // Set button icon
            textSizeButton.image = #imageLiteral(resourceName: "Icon_TextSize-Filled")
            self.textSize = UserDefaults.standard.string(forKey: "textSize")!
        }
        else {
            // Fade out and delay hide
            UIView.animate(withDuration: fadeTime) {
                self.settingsTableView.alpha = 0
            }
            let when = DispatchTime.now() + fadeTime
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.settingsTableView.isHidden = !self.settingsTableView.isHidden
            }
            
            // Set button icon
            textSizeButton.image = #imageLiteral(resourceName: "Icon_TextSize-Hollow")
            
            // If text size was changed, reload page
            if (self.textSize != UserDefaults.standard.string(forKey: "textSize")) {
                self.textSize = UserDefaults.standard.string(forKey: "textSize")!
                Database.db.logInteraction("Changed text size to \(self.textSize) for Module:\(mid)")
                displayPage()
            }
        }
    }
    
    @IBAction func bookmarkButtonPressed(_ sender: UIBarButtonItem) {
        
        if (self.bookmarked) {       // If this page is already bookmarked
            // Toggle button
            bookmarkButton.image = #imageLiteral(resourceName: "Icon_Ribbon-Hollow")
            
            // Remove from bookmarks
            removeBookmark()
            
            // Toggle local bookmark record
            self.bookmarked = false
        }
        else {                  // If this page is not yet bookmarked
            // Toggle button
            bookmarkButton.image = #imageLiteral(resourceName: "Icon_Ribbon-Filled")
            
            // Add to bookmarks
            addBookmark()
            
            // Toggle local bookmark record
            self.bookmarked = true
        }
    }
    
    // MARK: - Page Functions
    func loadPage() {
        
        if(speechSynthesizer.isSpeaking)
        {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        // First clear everything
        clearPage()
        
        let pagePath = Bundle.main.path(forResource: pagePrefix+pid, ofType: "txt")
        do {
            // Get entire page file
            let pageFile = try String(contentsOfFile: pagePath!)
            
            // Parse page file
            let keys = ["Module", "Page", "Image", "Title", "Subtitle", "Content"]
            
            for key in keys {
                let start = pageFile.index(pageFile.startIndex, offsetBy: indexOf("<\(key)>", pageFile, true))
                let end = pageFile.index(pageFile.startIndex, offsetBy: indexOf("</\(key)>", pageFile, false))
                let data = pageFile[Range(start ..< end)]
                
                switch (key) {
                    case "Module":
                        // TODO: verify module matches expected value
                        break
                    case "Page":
                        self.pid = data
                        break
                    case "Image":
                        self.pimage = data
                        break
                    case "Title":
                        self.ptitle = data
                        break
                    case "Subtitle":
                        self.psubtitle = data
                        break
                    case "Content":
                        self.pcontent = data
                        break
                    default:
                        print("Error. Module \(mid): unrecognized key in file parsing.")
                }
            }
            
            // If parsing went well display page data
            checkBookmarkStatus()
            displayPage()
        } catch {
            print("Error loading page \(pid) in module \(mid)")
            titleLabel.text = "Error Loading Page"
        }
    }
    
    func displayPage() {
        // Sets all page data to relevant page elements
        setImages()
        titleLabel.text = ptitle
        subtitleLabel.text = psubtitle
        
        let finalHTML = "<!DOCTYPE html><html><head><style>html {font-size: \(10 + Int(UserDefaults.standard.string(forKey: "textSize")!)! * 3)px; }</style></head><body>\(pcontent)</body></html>"
        webView.loadHTMLString(finalHTML, baseURL: nil)
        progressBar.setProgress(Float(pid)! / Float(pageMax), animated: false)
    }
    
    func updateTextSize(_ size :Int) {
        // Sets the text size of the webview based on the text size value in user defaults
    }
    
    func setImages() {
        // Sets images based on page
        let id = Int(pimage)!
        let imageID = id * 3
        
        var tag1 = String(imageID)
        if (imageID < 10) {
            tag1 = "0\(tag1)"
        }
        
        var tag2 = String(imageID - 1)
        if (imageID - 1 < 10) {
            tag2 = "0\(tag2)"
        }
        
        var tag3 = String(imageID - 2)
        if (imageID - 2 < 10) {
            tag3 = "0\(tag3)"
        }
        
        imageLeft.image = UIImage(named: "\(imagePrefix)\(tag1)")
        imageCenter.image = UIImage(named: "\(imagePrefix)\(tag2)")
        imageRight.image = UIImage(named: "\(imagePrefix)\(tag3)")
    }
    
    func clearPage() {
        imageLeft.image = nil
        imageCenter.image = nil
        imageRight.image = nil
        titleLabel.text = ""
        subtitleLabel.text = ""
        webView.loadHTMLString("", baseURL: nil)
        progressBar.setProgress(0.0, animated: false)
    }
    
    func changePage(_ pid : String) {
        // Changes page to given page id, then loads new page content
        speechSynthesizer.stopSpeaking(at: .immediate)
        let pidInt = Int(pid)!
        if (pidInt < 1 || pidInt > pageMax || pid == self.pid) {
            return
        }
        
        self.pid = pid
        Database.db.updateLastPageAccessed(mid, pid)
        Database.db.logInteraction("Changed page to Module:\(mid) Page:\(pid)")
        loadPage()
    }
    
    func getLastPage() {
        // Query core data to get last page accessed
        pid = Database.db.fetchLastPageAccessed(mid)
    }
    
    func getPageMax() {
        // Query core data to get number of pages in module
        self.pageMax = Int(Database.db.fetchNumPages(mid))!
    }
    
    func checkBookmarkStatus() {
        // Query to see if this page is bookmarked
        self.bookmarked = Database.db.doesBookmarkExist(mid, pid)
        
        // Set bookmark image
        bookmarkButton.image = self.bookmarked ? #imageLiteral(resourceName: "Icon_Ribbon-Filled") : #imageLiteral(resourceName: "Icon_Ribbon-Hollow")
    }
    
    func addBookmark() {
        // add current page to bookmarks
        Database.db.createBookmark(mid, pid)
        Database.db.logInteraction("Added bookmark Module:\(mid) Page:\(pid)")
    }
    
    func removeBookmark() {
        // remove current page from bookmarks
        Database.db.removeBookmark(mid, pid)
        Database.db.logInteraction("Removed bookmark Module:\(mid) Page:\(pid) from Page")
    }
    
    func initTableOfContents() {
        // TODO: programmatically set all the toc info
        tableOfContentsView.clipsToBounds = true
        tableOfContentsView.layer.cornerRadius = 10
        tableOfContentsView.isHidden = true
        tableOfContentsView.alpha = 0
        
        // Open the table of contents file for current module and load array
        let pagePath = Bundle.main.path(forResource: tocPrefix + mid, ofType: "csv")
        do {
            // Get entire page file
            let pageFile = try String(contentsOfFile: pagePath!)
            self.toc = pageFile.components(separatedBy: ",")
        } catch {
            print("ModuleViewController: Error loading toc. mid=\(mid)")
        }
    }
    
    func initSettingsMenu() {
        settingsTableView.clipsToBounds = true
        settingsTableView.layer.cornerRadius = 10
        settingsTableView.isHidden = true
        settingsTableView.alpha = 0
    }
    
    // MARK: - Gesture Functions
    
    @IBAction func swipeDetected (recognizer: UISwipeGestureRecognizer) {
        var pidInt = Int(pid)!
        
        switch (recognizer.direction) {
        case UISwipeGestureRecognizerDirection.left:
            print("Log. Module \(mid): Swipe right detected")
            pidInt += 1
        case UISwipeGestureRecognizerDirection.right:
            print("Log. Module \(mid): Swipe left detected")
            pidInt -= 1
        default:
            print("Error. Module \(mid): Unrecognized gesture")
        }
        
        if (pidInt < 10) {
            changePage("0\(pidInt)")
            return
        }
        
        changePage("\(pidInt)")
    }
    
    // MARK: - Table Functions  // Used tutorial on https://peterwitham.com/swift-archives/intermediate/creating-and-using-ios-prototype-cells-with-swift/
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (tableView === tableOfContentsView) {
            return toc.count
        }
        else if (tableView === settingsTableView) {
            return 2
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (tableView === tableOfContentsView) {
            let cellData = toc[indexPath.row].components(separatedBy: ":")
            let cell = tableView.dequeueReusableCell(withIdentifier: "tocProtoCell") as! TableOfContentsTableViewCell
            cell.numberLabel.text = cellData[0]
            cell.titleLabel.text = cellData[1]
            return cell
        }
        else if (tableView === settingsTableView) {
            
            switch(indexPath.row) {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "brightnessProtoCell") as! BrightnessTableViewCell
                cell.brightnessSlider.value = Float(UIScreen.main.brightness)
                cell.selectionStyle = .none
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "textSizeProtoCell") as! TextSizeTableViewCell
                cell.selectionStyle = .none
                cell.textSizeSegmentedControl.selectedSegmentIndex = Int(UserDefaults.standard.string(forKey: "textSize")!)! - 1
                return cell
            default:
                print("Error. Page View - table view setup")
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView === tableOfContentsView) {
            let cell = tableView.cellForRow(at: indexPath) as! TableOfContentsTableViewCell
            
            Database.db.logInteraction("Tapped from TOC Module:\(mid) Page:\(cell.numberLabel.text!)")
            changePage(cell.numberLabel.text!)
            
            // Then programmatically press the toc button
            tableOfContentsButtonPressed(tableOfContentsButton)
        }
    }
    
    // Delegate method to handle link taps in webView
    func webView(_: UIWebView, shouldStartLoadWith: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.linkClicked {
            let urlStringBeforeParse = "\(shouldStartLoadWith.url!)"
            var urlStringArray = urlStringBeforeParse.components(separatedBy: "/")
            let urlString = "\(urlStringArray[urlStringArray.count - 1])"
            Database.db.logInteraction("Clicked link to \(urlString)")
            let url = URL(string: "http://\(urlString)")
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            return false
        }
        return true
    }

    //MARK: - Helper Functions
    func parseStr(str: String) -> String
    {
        var s = ""
        var marker = false
        for i in str.characters.indices
        {
            if str[i] == "<"
            {
                marker = false
            }
            else if str[i] == ">"
            {
                marker = true
            }
            if(marker == true && str[i] != ">")
            {
                s.append(str[i])
            }
        }
        print(s)
        return s
    }
}
