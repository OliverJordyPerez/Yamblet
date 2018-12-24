//
//  ViewController.swift
//  MyLyrics
//
//  Created by OliverPérez on 12/19/18.
//  Copyright © 2018 OliverPérez. All rights reserved.
//

import UIKit
import CoreData
import SVProgressHUD //Pod for progress hud

class SearchViewController: UIViewController {

    @IBOutlet weak var songTitle: UITextField!
    @IBOutlet weak var artistName: UITextField!
    
    let baseURL = URL(string: "https://api.lyrics.ovh/v1/")!
    var lyrics = ""
    var isSongAlreadySaved = false
 
    //Core data context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
    }
    
    
    @IBAction func searchLyrics(_ sender: Any) { //
        guard songTitle.text != "" && artistName.text != "" else { //If text fields are empty, return
            return
        }
        SVProgressHUD.show()

        if let song = fetchLyricsFromDB(), song.count > 0 { //If song was already saved, load it
            lyrics = song[0].lyrics!
            isSongAlreadySaved = true
            performSegue(withIdentifier: "sendLyrics", sender: self)
        }else{ //If song is not already saved, get it from API
            fetchLyricsFromAPI()
        }
    }
    
    //MARK: - Fetching data methods
    func fetchLyricsFromDB() -> [Song]?{ //Searchs if requested song is already in the data model
        
        let request: NSFetchRequest<Song> = Song.fetchRequest()
        request.predicate = NSPredicate(format: "artistName MATCHES[cd] %@ AND songName MATCHES[cd] %@", artistName.text!, songTitle.text!)
        var song: [Song]? = nil
        do {
            song = try context.fetch(request)
        } catch  {
            print("Error fetching data from context \(error)")
        }
        return song
    }
    
    func fetchLyricsFromAPI(){ // Gets the lyrics from the API
        let url = baseURL.appendingPathComponent("\(artistName.text!)/\(songTitle.text!)")
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            let jsonDecoder = JSONDecoder()
            if let data = data, let lyricsData = try? jsonDecoder.decode([String:String].self, from: data), let lyrics = lyricsData["lyrics"] {
                DispatchQueue.main.async {
                    self.lyrics = lyrics
                    self.isSongAlreadySaved = false
                    SVProgressHUD.dismiss()
                    self.performSegue(withIdentifier: "sendLyrics", sender: self)
                }
            }
            else {
                SVProgressHUD.dismiss()
                self.showAlert()
            }
        }
        task.resume()
        
    }
    
    //MARK: - Other
    //Show alert message when lyrics was not found
    func showAlert(){
        let alert = UIAlertController(title: "Error", message: "Canción no encontrada", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //Send song info to Lyrics View Controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sendLyrics" {
            let destinationVC = segue.destination as! LyricsViewController
            destinationVC.lyrics = lyrics
            destinationVC.artistName = artistName.text!.uppercased()
            destinationVC.songTitle = songTitle.text!.uppercased()
            destinationVC.songIsSaved = isSongAlreadySaved
            artistName.text = ""
            songTitle.text = ""
        }
    }
    
}

//MARK: - Extension
extension UIViewController //To hide keyboard when user taps the screen
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}
