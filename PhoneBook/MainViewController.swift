//
//  MainViewController.swift
//  PhoneBook
//
//  Created by Игорь Капустин on 21.09.2021.
//

import UIKit
import RealmSwift

class MainViewController: UITableViewController {
       
    private let searchController = UISearchController(searchResultsController: nil)
    private var contacts: Results<Contact>!
    private var filteredContacts: Results<Contact>!
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }

    override func viewDidLoad() {
        super.viewDidLoad()
     
        contacts = realm.objects(Contact.self)
        
        // Setup the search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredContacts.count
        }
        return contacts.isEmpty ? 0 : contacts.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        var contact = Contact()
        if isFiltering {
            contact = filteredContacts[indexPath.row]
        } else {
            contact = contacts[indexPath.row]
        }
        cell.nameLabel.text = contact.name
        cell.secondNameLabel.text = contact.secondName
        return cell
    }
    
    // MARK: Table view delegate
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let contact = contacts[indexPath.row]
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (_, _) in
            StorageManager.deleteObject(contact)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        return [deleteAction]
    }


    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let contact: Contact
            if isFiltering {
                contact = filteredContacts[indexPath.row]
            } else {
                contact = contacts[indexPath.row]
            }
            let newContactVC = segue.destination as! NewContactViewController
            newContactVC.currentContact = contact
        }
    }

    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        
        guard let newContactVC = segue.source as? NewContactViewController else { return }
        newContactVC.saveContact()
        tableView.reloadData()
    }

}

extension MainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filteredContacts = contacts.filter("name CONTAINS[c] %@ OR secondName CONTAINS[c] %@ OR email CONTAINS[c] %@", searchText, searchText, searchText, searchText)
        tableView.reloadData()
    }
}
