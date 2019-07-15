//
//  DetailsViewController.swift
//  ToDo
//
//  Created by Jan Malewski on 14/07/2019.
//  Copyright © 2019 Jan Malewski. All rights reserved.
//

import UIKit
import RealmSwift

class DetailsViewController: UIViewController, UITextViewDelegate {
    
    let realm = try! Realm()
    
    @IBOutlet weak var details: UITextView!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIButton!
    
    var selectedTask : Task?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.details.delegate = self
        
        if let task = selectedTask {
            self.navBar.title = task.title
            self.details.text = task.details
            if task.done {
                self.doneButton.setTitle("Undo", for: .normal)
            } else {
                self.doneButton.setTitle("Done", for: .normal)
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        save()
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
        
        self.details.isEditable = !self.details.isEditable
        
        if self.details.isEditable == true {
            self.details.becomeFirstResponder()
            self.editButton.title = "End"
        } else {
            self.details.resignFirstResponder()
            self.editButton.title = "Edit"
        }
    
    }
    
    func save(){
        if let task = selectedTask {
            do {
                try realm.write {
                    task.details = details.text
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
    }
}
