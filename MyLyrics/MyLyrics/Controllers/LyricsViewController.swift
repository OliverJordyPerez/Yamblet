//
//  LyricsViewController.swift
//  MyLyrics
//
//  Created by OliverPérez on 12/20/18.
//  Copyright © 2018 OliverPérez. All rights reserved.
//

import UIKit
import CoreData

class LyricsViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!

    var lyrics = ""
    var artistName = ""
    var songTitle = ""
    var songIsSaved = false
    
    //CoreData context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLyrics()
        updateButtonImage()
    }
    
    func updateLyrics(){ //Set text labels and text view values
        artistNameLabel.text = artistName
        songNameLabel.text = songTitle
        textView.text = lyrics
    }
    
    func updateButtonImage(){ //Toggle button's icon from Trash to Save or vice versa
        let buttonImage = songIsSaved ? "TrashIcon" : "SaveIcon"
        saveButton.setImage(UIImage(named: buttonImage), for: .normal)
    }
    
    //MARK: - Lyrics local memory managment methods
    
    @IBAction func toggleSongFromMemory(_ sender: Any) { //Deletes the song if it's already in local memory or save it if it's not
        if songIsSaved {
            deleteSong()
        } else {
            saveSong()
        }
    }
  
    func saveSong(){ //Saves the song locally
        let song = Song(context: context)
        song.artistName = artistName
        song.songName = songTitle
        song.lyrics = lyrics
        
        do {
            try context.save()
            songIsSaved = true
            updateButtonImage()
        }
        catch{}
    }
    
    func deleteSong(){ //Removes the song from local memory
        let request: NSFetchRequest<Song> = Song.fetchRequest()
        request.predicate = NSPredicate(format: "artistName MATCHES[cd] %@ AND songName MATCHES[cd] %@", artistName, songTitle)
        
        do {
           let song = (try context.fetch(request))[0]
           context.delete(song)
        } catch  {
            print("Error fetching data from context \(error)")
        }
        do {
            try context.save()
        } catch  {
            print("Error saving context \(error)")
        }
        songIsSaved = false
        updateButtonImage()
    }

}
