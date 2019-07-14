//
//  DetailsViewController.swift
//  ToDo
//
//  Created by Jan Malewski on 14/07/2019.
//  Copyright © 2019 Jan Malewski. All rights reserved.
//

import UIKit
import RealmSwift

class DetailsViewController: UIViewController {
    
    let realm = try! Realm()
    
    @IBOutlet weak var details: UITextView!
    @IBOutlet weak var navBar: UINavigationItem!
    
    var selectedTask : Task? {
        didSet{
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if let task = selectedTask {
            self.navBar.title = task.title
        }
    }
    
    @IBAction func DoneButtonPressed(_ sender: Any) {
        if let task = selectedTask {
            do {
                try realm.write {
                    task.done = !task.done
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func EditButtonPressed(_ sender: Any) {
        
    }
}
