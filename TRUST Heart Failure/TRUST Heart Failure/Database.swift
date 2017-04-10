//
//  Database.swift
//  TRUST Heart Failure
//
//  Created by Gene Lee on 2/28/17.
//  Copyright © 2017 Nathan VelaBorja. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Database {
    
    static let db = Database() // singleton -- shared instance used throughout app
    
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    func clearLogs () {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Log")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        do {
            try getContext().execute(request)
        } catch let error as NSError  {
            print("Could not clear: \(error), \(error.userInfo)")
        }
    }
    
    func logsToJson () -> ([Any], Int) {
        let logs = self.fetchLogs()
        var lenJson = 0;
        
        var logsJson: [Any] = []
        for log in logs! as [NSManagedObject] {
            let json = ["event_num": "\(log.value(forKey: "event_num")!)", "event": "\(log.value(forKey: "event")!)", "id": "\(log.value(forKey: "id")!)", "date": "\(log.value(forKey: "date")!)", "time": "\(log.value(forKey: "time")!)", "platform": "\(log.value(forKey: "platform")!)"]
            logsJson.append(json)
            lenJson += 1
        }
        return (logsJson, lenJson)
    }
    
    func sendLogsToServer () {
        if (UserDefaults.standard.object(forKey: "userID") != nil) { // only send if a user ID is registered
            let logs = self.logsToJson()
            let len: Int = logs.1
            
            let jsonLogs: [Any] = logs.0
            let jsonData = try? JSONSerialization.data(withJSONObject: jsonLogs)
            
            let url = URL(string: "" /* This string would point to a php script on our server */)
            var request = URLRequest(url: url!)
            request.httpMethod = "POST"
            request.httpBody = jsonData!
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json",forHTTPHeaderField: "Accept")
            let dataTask = URLSession.shared.dataTask(with: request, completionHandler: {(data, response, err) in
                let dataStr = String(data: data!, encoding: .utf8)
                if (dataStr != "" && Int(dataStr!)! == len) { // all logs were received by server
                    print ("\(len) == \(Int(dataStr!)) logs sent successfully")
                    self.clearLogs()
                }
            })
            dataTask.resume()
        }
    }
    
    // MARK: - Log
    
    func logInteraction (_ event: String) {
        if (UserDefaults.standard.object(forKey: "userID") != nil) {
            let context = getContext()
            
            // retrieve the entity
            let entity = NSEntityDescription.entity(forEntityName: "Log", in: context)
            
            let logdb = NSManagedObject(entity: entity!, insertInto: context)
            
            // set the entity values
            if (UserDefaults.standard.object(forKey: "eventNumAutoInc") != nil) {
                var event_num = UserDefaults.standard.integer(forKey: "eventNumAutoInc")
                logdb.setValue(event_num, forKey: "event_num")
                event_num += 1
                UserDefaults.standard.set(event_num, forKey: "eventNumAutoInc")
            } else {
                logdb.setValue(1, forKey: "event_num")
                UserDefaults.standard.set(2, forKey: "eventNumAutoInc")
            }
            
            logdb.setValue(event, forKey: "event")
            
            let userID = UserDefaults.standard.string(forKey: "userID")
            logdb.setValue(userID, forKey: "id")
            
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
            formatter.timeZone = TimeZone(abbreviation: "PST")
            let result = formatter.string(from: date)
            let resultArr = result.components(separatedBy: " ")
            logdb.setValue(resultArr[0], forKey: "date")
            logdb.setValue(resultArr[1], forKey: "time")
            
            logdb.setValue("iOS", forKey: "platform")
            
            //save the object
            do {
                try context.save()
                print("event log: \(event) saved!")
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            } catch {
                
            }
        }
    }
    
    func fetchLogs () -> [NSManagedObject]? {
        let fetchRequest: NSFetchRequest<Log> = Log.fetchRequest()
        
        do {
            // get the results
            let searchResults = try getContext().fetch(fetchRequest)
            
            print ("num of log results = \(searchResults.count)")
            
            // convert to NSManagedObejct to use 'for' loops
            for log in searchResults as [NSManagedObject] {
                print ("\(log.value(forKey: "event_num")!) \(log.value(forKey: "event")!) \(log.value(forKey: "id")!) \(log.value(forKey: "date")!) \(log.value(forKey: "time")!) \(log.value(forKey: "platform")!)")
            }
            return searchResults as [NSManagedObject]
        } catch {
            print("Error with request \(error)")
        }
        return nil
    }
    
    // MARK: - Module
    
    func initModules () {
        if (UserDefaults.standard.object(forKey: "firstLaunch") != nil) {
            let fetchRequest: NSFetchRequest<Module> = Module.fetchRequest()
            
            do {
                // get the results
                let searchResults = try getContext().fetch(fetchRequest)
                
                if (searchResults.count <= 0) {
                    initModule("09", "Advanced Care Planning", 52, "img_09_")
                    initModule("01", "Taking Control of Heart Failure", 16, "img_01_")
                    initModule("04", "Self-Care", 42, "img_04_")
                    initModule("06", "Managing Feelings About Heart Failure", 17, "img_06_")
                }
            } catch {
                print("Error with request \(error)")
            }
        }
    }
    
    private func initModule (_ module: String, _ title: String, _ npages: Int, _ img_file: String) {
        let context = getContext()
        
        // retrieve the entity
        let entity = NSEntityDescription.entity(forEntityName: "Module", in: context)
        
        let moduleDb = NSManagedObject(entity: entity!, insertInto: context)
        
        // set the entity values
        moduleDb.setValue(module, forKey: "module_num")
        moduleDb.setValue(title, forKey: "title")
        moduleDb.setValue(npages, forKey: "npages")
        moduleDb.setValue(img_file, forKey: "img_file")
        moduleDb.setValue("01", forKey: "pla")
        
        do {
            try context.save()
            print("module \(module) initialized")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            
        }
    }
    
    func fetchModules () -> [NSManagedObject]? {
        let fetchRequest: NSFetchRequest<Module> = Module.fetchRequest()
        
        do {
            // get the results
            let searchResults = try getContext().fetch(fetchRequest)
            
            print ("num of module results = \(searchResults.count)")
            
            // convert to NSManagedObejct to use 'for' loops
            for mod in searchResults as [NSManagedObject] {
                print ("\(mod.value(forKey: "module_num")!) \(mod.value(forKey: "title")!) \(mod.value(forKey: "npages")!) \(mod.value(forKey: "img_file")!) \(mod.value(forKey: "pla")!)")
            }
            return searchResults as [NSManagedObject]
        } catch {
            print("Error with request \(error)")
        }
        return nil
    }
    
    func fetchNumPages (_ module: String) -> String {
        let fetchRequest: NSFetchRequest<Module> = Module.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "module_num == %@", argumentArray: [module])
        
        do {
            let searchResult = try getContext().fetch(fetchRequest) as [NSManagedObject]
            let module = searchResult.first!
            return "\(module.value(forKey: "npages")!)" // cast as string
        } catch {
            print("Error with request \(error)")
        }
        return "-1"
    }
    
    func fetchLastPageAccessed (_ module_num: String) -> String {
        let fetchRequest: NSFetchRequest<Module> = Module.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "module_num == %@", module_num)
        
        do {
            let searchResult = try getContext().fetch(fetchRequest) as [NSManagedObject]
            let module = searchResult.first!
            print ("\(module.value(forKey: "pla")!)")
            return module.value(forKey: "pla")! as! String
        } catch {
            print("Error with request \(error)")
        }
        return "1"
    }
    
    func updateLastPageAccessed (_ module: String, _ page: String) {
        let context = getContext()
        
        let fetchRequest: NSFetchRequest<Module> = Module.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "module_num == %@", argumentArray: [module])
        
        do {
            let searchResult = try context.fetch(fetchRequest) as [NSManagedObject]
            let module = searchResult.first!
            module.setValue(page, forKey: "pla")
            do {
                try context.save()
                print("updated pla!")
            } catch let error as NSError  {
                print("Could not update \(error), \(error.userInfo)")
            } catch {
                
            }
        } catch {
            print("Error with request \(error)")
        }
    }
    
    // MARK: - Bookmark
    
    func createBookmark (_ module: String, _ page: String) {
        let context = getContext()
        
        let fetchRequest: NSFetchRequest<Bookmark> = Bookmark.fetchRequest()
        let modPred = NSPredicate(format: "module_num == %@", argumentArray: [module])
        let pagePred = NSPredicate(format: "page_num == %@", argumentArray: [page])
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [modPred, pagePred])
        fetchRequest.predicate = predicate
        
        do {
            let searchResult = try context.fetch(fetchRequest) as [NSManagedObject]
            if (searchResult.count <= 0) { // only insert if it doesnt exist already
                // retrieve the entity
                let entity = NSEntityDescription.entity(forEntityName: "Bookmark", in: context)
                
                let bookmarkDb = NSManagedObject(entity: entity!, insertInto: context)
                
                // set the entity values
                bookmarkDb.setValue(module, forKey: "module_num")
                bookmarkDb.setValue(page, forKey: "page_num")
                
                do {
                    try context.save()
                    print("bookmark saved!")
                } catch let error as NSError  {
                    print("Could not save \(error), \(error.userInfo)")
                } catch {
                    
                }
            }
        } catch {
            print("Error with request \(error)")
        }
    }
    
    func doesBookmarkExist (_ module: String, _ page: String) -> Bool {
        let context = getContext()
        
        let fetchRequest: NSFetchRequest<Bookmark> = Bookmark.fetchRequest()
        let modPred = NSPredicate(format: "module_num == %@", argumentArray: [module])
        let pagePred = NSPredicate(format: "page_num == %@", argumentArray: [page])
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [modPred, pagePred])
        fetchRequest.predicate = predicate
        
        do {
            let searchResult = try context.fetch(fetchRequest) as [NSManagedObject]
            if (searchResult.count > 0) {
                return true
            }
        } catch {
            print("Error with request \(error)")
        }
        return false
    }
    
    func fetchBookmarks () -> [NSManagedObject]? {
        let fetchRequest: NSFetchRequest<Bookmark> = Bookmark.fetchRequest()
        let sd = NSSortDescriptor(key: "page_num", ascending: true)
        NSSortDescriptor(fetchRequest.sortDescriptors = [sd])
        
        do {
            // get the results
            let searchResults = try getContext().fetch(fetchRequest)
            
            print ("num of bm results = \(searchResults.count)")
            
            // convert to NSManagedObejct to use 'for' loops
            for bm in searchResults as [NSManagedObject] {
                print ("\(bm.value(forKey: "module_num")!) \(bm.value(forKey: "page_num")!)")
            }
            return searchResults as [NSManagedObject]
        } catch {
            print("Error with request \(error)")
        }
        return nil
    }
    
    func removeBookmark (_ module: String, _ page: String) {
        let context = getContext()
        
        let fetchRequest: NSFetchRequest<Bookmark> = Bookmark.fetchRequest()
        let modPred = NSPredicate(format: "module_num == %@", argumentArray: [module])
        let pagePred = NSPredicate(format: "page_num == %@", argumentArray: [page])
    
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [modPred, pagePred])
        fetchRequest.predicate = predicate
        
        do {
            let searchResult = try context.fetch(fetchRequest) as [NSManagedObject]
            let bm = searchResult.first!
            
            context.delete(bm)
            try context.save()
            print("Removed bookmark: mod: \(module) pg: \(page) from database")
        } catch {
            print("Error with request \(error)")
        }
    }
}
