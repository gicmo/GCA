//
//  ConferenceListTVC.swift
//  GCA
//
//  Created by Christian Kellner on 05.08.22.
//  Copyright © 2022 G-Node. All rights reserved.
//

import UIKit

class ConferenceListTVC: UITableViewController, NSFetchedResultsControllerDelegate {

    var fetchResultsCtrl: NSFetchedResultsController<Conference>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupFetchedResultsController()
        
        NSLog("ViewDidLoad")
        guard let sections = fetchResultsCtrl.sections else {
            NSLog("No sections")
            return
        }
        
        if sections[0].numberOfObjects == 0 {
            NSLog("Need refresh")
            CKDataStore.default().fetchConferences()
        }

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        let cellNib = UINib(nibName: "ConferenceCell", bundle: nil);
        self.tableView.register(cellNib, forCellReuseIdentifier: "ConferenceCell");

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
 
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        NSLog("controllerDidChangeContent");
        self.tableView.reloadData();
    }
    
    func setupFetchedResultsController() {
        let store = CKDataStore.default()
        
        let request = NSFetchRequest<Conference>(entityName: "Conference")
        let sortDesc = NSSortDescriptor(key: "start", ascending: false)
        request.sortDescriptors = [sortDesc]
        
        let ctrl = NSFetchedResultsController(fetchRequest: request, managedObjectContext: store!.container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        ctrl.delegate = self;

        do {
            try ctrl.performFetch()
        } catch {
            NSLog("Could not fetch")
        }
        
        self.fetchResultsCtrl = ctrl
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = self.fetchResultsCtrl?.sections else {
            return 0
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConferenceCell", for: indexPath)

        guard let cell = cell as? ConferenceCell else {
            NSLog("Warning: cell was not a ConferenceCell")
            return cell
        }
        
        let conference = self.fetchResultsCtrl.object(at: indexPath);
        
        cell.button?.text = conference.name;

        return cell
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
