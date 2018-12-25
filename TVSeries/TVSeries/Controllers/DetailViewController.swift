//
//  DetailViewController.swift
//  TVSeries
//
//  Created by OliverPérez on 12/24/18.
//  Copyright © 2018 OliverPérez. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    
    @IBOutlet weak var poster: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var network: UILabel!
    @IBOutlet weak var webSiteURL: UITextView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var days: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var posterImage = UIImage()
    var serieTitle = ""
    var serieDescription = ""
    var networkName = ""
    var website = ""
    var serieId = 0
    var timeLabel = ""
    var daysLabel = ""
    
    var seasonPosters = [UIImage]()
    var seasonsInfo = [SeasonElement]()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        webSiteURL.textContainer.maximumNumberOfLines = 1
        webSiteURL.textContainer.lineBreakMode = .byTruncatingTail
        updateInfo()
        fetchSeasonsFor(id: serieId)
    }
    
    //MARK: -Update information methods
    func updateInfo(){
        poster.image = posterImage
        titleLabel.text = serieTitle
        descriptionText.text = serieDescription
        network.text = networkName
        time.text = timeLabel
        days.text = daysLabel
        
        let attributedString = NSMutableAttributedString(string: website)
        attributedString.addAttribute(.link, value: website, range: NSRange(location: 0, length: website.count))
        webSiteURL.attributedText = attributedString
    }
    func updateTableViewWith(image: UIImage){
        seasonPosters.append(image)
        tableView.reloadData()
    }
    
    func saveFetchedSeriesInfo(newSeason: SeasonElement){
        seasonsInfo.append(newSeason)
    }
    func updateSeasonsInfo(seasonsResults: Seasons = Seasons()){
        
        if seasonsResults.count == 0 {tableView.reloadData(); return }
        
        for season in seasonsResults {
            if let imgURL = season.image?.original {
                fetchPhoto(url: imgURL) { (image) in
                    self.saveFetchedSeriesInfo(newSeason: season)
                    self.updateTableViewWith(image: image)
                }
            }else{
                saveFetchedSeriesInfo(newSeason: season)
                updateTableViewWith(image: UIImage(named: "noImage")!)
                
            }
        }
    }
  
    //MARK: -Fetching data methods from API
    func fetchSeasonsFor(id: Int){
        print("http://api.tvmaze.com/shows/\(id)/episodes")
        let url = URL(string: "http://api.tvmaze.com/shows/\(id)/episodes")!
        let task = URLSession.shared.dataTask(with: url) { (data,
            response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data,
                let seasonsInfo = try? jsonDecoder.decode(Seasons.self, from: data) {
                DispatchQueue.main.async {
                   self.seasonPosters.removeAll()
                   self.updateSeasonsInfo(seasonsResults: seasonsInfo)
                }
            }
        }
        task.resume()
    }
    
    
    func fetchPhoto(url: String, completion: @escaping (UIImage) -> Void) {
        
        let url = URL(string: url)!
        
        let task = URLSession.shared.dataTask(with: url) { (data,
            response, error) in
            if let data = data {
                DispatchQueue.main.async {
                    completion(UIImage(data: data)!)
                }
            }
        }
        task.resume()
    }
    
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL, options: [:])
        return false
    }
    
    
    //MARK: -Table View Data Source Methods
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return seasonsInfo.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "seasonCell") as! SeasonTableViewCell
        cell.titleName.text = seasonsInfo[indexPath.row].name
        cell.posterImage.image = seasonPosters[indexPath.row]
        cell.descritionSeason.text = seasonsInfo[indexPath.row].summary.html2String
        return cell
    }
    
}
