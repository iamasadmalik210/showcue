//
//  PopularMoviesCollectionViewCell.swift
//  ShowCue
//
//  Created by mac on 07/12/2024.
//

import UIKit

class PopularMoviesCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var movieName: UILabel!
    
    let imageCache = NSCache<NSString, UIImage>()

    override  func awakeFromNib() {
        super.awakeFromNib()
        addShadow()
    }
    
    
//    func configureCell(_ movie : Movie){
//        
//        movieName.text = movie.title
//        ratingLabel.text = String(format: "%.1f", movie.voteAverage)
//        movie.posterPath
//        postImageView.image = UIImage(named: "placeholderImage")
//    }
    
    func addShadow(){
        bgView.layer.cornerRadius = 10 // Adjust to your preference
        bgView.layer.shadowColor = UIColor.black.cgColor
        bgView.layer.shadowOpacity = 0.2 // Minimal shadow
        bgView.layer.shadowOffset = CGSize(width: 0, height: 2) // Subtle shadow
        bgView.layer.shadowRadius = 4 // Smooth edges
        bgView.layer.masksToBounds = false
        
//        self.layer.cornerRadius = 10 // Adjust to your preference
//        self.layer.shadowColor = UIColor.black.cgColor
//        self.layer.shadowOpacity = 0.2 // Minimal shadow
//        self.layer.shadowOffset = CGSize(width: 0, height: 2) // Subtle shadow
//        self.layer.shadowRadius = 4 // Smooth edges
//        self.layer.masksToBounds = false


    }
    
    func configureCell(_ movie: Movie) {
        movieName.text = movie.title
        ratingLabel.text = String(format: "%.1f", movie.voteAverage)
        postImageView.image = nil // Reset image to avoid showing stale data

        // Set placeholder image
        postImageView.image = UIImage(named: "placeholderImage")
        
        // Get the image URL
        guard let posterPath = movie.posterPath else { return }
        let imageUrlString = "https://image.tmdb.org/t/p/w500\(posterPath)"
        
        // Check for cached image
           if let cachedImage = imageCache.object(forKey: imageUrlString as NSString) {
               postImageView.image = cachedImage
           } else {
               // Download image and update cache
               guard let url = URL(string: imageUrlString) else { return }
               URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                   guard let self = self,
                         let data = data,
                         let image = UIImage(data: data),
                         error == nil else {
                       return
                   }
                   
                   // Cache the downloaded image
                   self.imageCache.setObject(image, forKey: imageUrlString as NSString)
                   
                   // Update the image view on the main thread
                   DispatchQueue.main.async {
                       self.postImageView.image = image
                   }
               }.resume()
           }
    }

    // Function to download and cache image
    func downloadImage(from url: URL) {
        // Create a data task to download the image
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else { return }
            
            if let image = UIImage(data: data) {
                // Cache the downloaded image
                self.imageCache.setObject(image, forKey: url.absoluteString as NSString)
                
                // Update UI on the main thread
                DispatchQueue.main.async {
                    self.postImageView.image = image
                }
            }
        }.resume()
    }
    
}
