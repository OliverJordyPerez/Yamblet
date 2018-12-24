//
//  TableViewController.swift
//  MyLyrics
//
//  Created by OliverPérez on 12/21/18.
//  Copyright © 2018 OliverPérez. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController {

    var songsArray = [Song]()
    var artistName = ""
    var songName = ""
    var lyrics = ""

    //Core Data context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    

    override func viewWillAppear(_ animated: Bool) {
        loadSongs()
    }
    
    // MARK: - Table view data source methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath)
        
        cell.textLabel?.text =  "\(songsArray[indexPath.row].artistName!) - \(songsArray[indexPath.row].songName!)"
        cell.textLabel?.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return songsArray.count
    }

    //MARK: Table view delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        artistName = songsArray[indexPath.row].artistName!
        songName = songsArray[indexPath.row].songName!
        lyrics = songsArray[indexPath.row].lyrics!
        
        performSegue(withIdentifier: "seeLyrics", sender: self)
    }

    //Delete row on right swipe action
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = deleteAction (at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
        
    }


    //MARK: - Songs local memory managment methods
    
    //Removes song from local storage
    func deleteSongFromDB(at indexPath: IndexPath){
        self.context.delete(songsArray[indexPath.row])
        self.songsArray.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
        do {
            try context.save()
        } catch  {
            print("Error saving context \(error)")
        }
    }
    
    //Read song from local storage
    func loadSongs(with request: NSFetchRequest<Song> = Song.fetchRequest()){
        do {
            songsArray = try context.fetch(request)
        } catch  {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
    
    //MARK: - Other
    //Send song info to Lyrics View Controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! LyricsViewController
        destinationVC.artistName = artistName
        destinationVC.songTitle = songName
        destinationVC.lyrics = lyrics
        destinationVC.songIsSaved = true
    }
    
    //Deletes song at indexPath
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            
            self.deleteSongFromDB(at: indexPath)
            completion(true)
        }
        
        action.image = UIImage(named: "TrashIcon")
        action.backgroundColor =  #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        return action
    }
    
}

//MARK: - Search bar methods
extension TableViewController: UISearchBarDelegate{
    

    //Search song when users writes on the search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 { //Reload songs from DB when the user clears the search bar
            loadSongs()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
        else {
            let request: NSFetchRequest<Song> = Song.fetchRequest()
            request.predicate = NSPredicate(format: "artistName CONTAINS[cd] %@", searchBar.text!)
            request.sortDescriptors = [NSSortDescriptor(key: "artistName", ascending: true)]
            
            loadSongs(with: request)
        }
    }
    
}
