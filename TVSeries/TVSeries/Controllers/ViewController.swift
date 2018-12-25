//
//  ViewController.swift
//  TVSeries
//
//  Created by OliverPérez on 12/24/18.
//  Copyright © 2018 OliverPérez. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate{

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var posters = [UIImage]()
    var serieTitle = ""
    var serieDescription = ""
    var networkName = ""
    var website = ""
    var serieID = 0
    var time = ""
    var days = ""

    var selectedPoster = UIImage()
    var seriesInfo = [SeriesElement]()

    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 20, left: 16, bottom: 10, right: 16)
        collectionView.collectionViewLayout = layout

    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        posters.removeAll()
        updateSerieInfo()
        fetchSeries(query: searchText)
    }
    
    //MARK: -Update Collection View Methods
    func updateSerieInfo(seriesResults: Series = Series()){
        if seriesResults.count == 0 { collectionView.reloadData(); return }
        for serie in seriesResults {
            if let imgURL = serie.show.image?.original {
                fetchPhoto(url: imgURL) { (image) in
                    self.saveFetchedSeriesInfo(newSerie: serie)
                    self.updateCollectionViewWith(image: image)
                }
            }
        }
    }
    
    func updateCollectionViewWith(image: UIImage){
        posters.append(image)
        collectionView.reloadData()
    }
    
    func saveFetchedSeriesInfo(newSerie: SeriesElement){
        seriesInfo.append(newSerie)
        
    }
    
    //MARK: - Fetching info from API
    func fetchSeries(query: String){
        let url = URL(string: "http://api.tvmaze.com/search/shows?q=\(query.replacingOccurrences(of: " ", with: ""))")!
        let task = URLSession.shared.dataTask(with: url) { (data,
            response, error) in
            let jsonDecoder = JSONDecoder()
            if let data = data,
                let seriesInfo = try? jsonDecoder.decode(Series.self, from: data) {
                DispatchQueue.main.async {
                    self.posters.removeAll()
                    self.updateSerieInfo(seriesResults: seriesInfo)
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
   
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinarionVC = segue.destination as! DetailViewController
        destinarionVC.posterImage = selectedPoster
        destinarionVC.serieTitle = serieTitle
        destinarionVC.serieDescription = serieDescription.html2String
        destinarionVC.networkName = networkName
        destinarionVC.website = website
        destinarionVC.serieId = serieID
        destinarionVC.timeLabel = time
        destinarionVC.daysLabel = days
    }
    
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {
    
    //MARK: -Collection View Data source methods
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SerieCell", for: indexPath) as! SerieCollectionViewCell
        cell.imageView.image = posters[indexPath.row]
        transform(cell: cell )
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.width / 3) - 15
        let height = width + 60
        
        return CGSize(width: width, height: height)
    }
    
    //MARK: - Collection View Delegate methods
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        collectionView.visibleCells.forEach{
            transform(cell: $0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedPoster = posters[indexPath.item]
        serieTitle = seriesInfo[indexPath.item].show.name!
        serieDescription = seriesInfo[indexPath.item].show.summary ?? "Sin descripción"
        networkName = seriesInfo[indexPath.item].show.network?.name ?? "Desconocido"
        website = seriesInfo[indexPath.item].show.officialSite ?? ""
        serieID = seriesInfo[indexPath.item].show.id
        time = seriesInfo[indexPath.item].show.schedule?.time ?? ""
        if let daysArray = seriesInfo[indexPath.item].show.schedule?.days{
            for day in daysArray{
                days += " \(day)"
            }
        }
        performSegue(withIdentifier: "showSerieDetails", sender: self)
    }
    
    // MARK: - Collection View customization methods
    func transform(cell: UICollectionViewCell){
        
        let coverFrame = cell.convert(cell.bounds, to: self.view)
        let transformOffsetY = collectionView.bounds.height * 3/4
        let percent =  getPercent(value: (coverFrame.minY - transformOffsetY)/(collectionView.bounds.height - transformOffsetY))
        let maxScaleDifference: CGFloat =  0.2
        let scale = percent * maxScaleDifference
        
        cell.transform =  CGAffineTransform(scaleX: 1-scale, y: 1-scale)
    }
    
    func getPercent(value: CGFloat) -> CGFloat{
        let lowerBound:CGFloat = 0
        let upperBound:CGFloat = 1
        
        if value < lowerBound {
            return lowerBound
        } else if value > upperBound{
            
            return upperBound
        } else{
            
            return value
        }
    }
}

