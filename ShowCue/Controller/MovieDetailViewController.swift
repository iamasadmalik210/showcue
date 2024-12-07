//
//  MoviewDetailViewController.swift
//  ShowCue
//
//  Created by mac on 07/12/2024.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    
    @IBOutlet weak var movieTitleLabel: UILabel!

    @IBOutlet weak var releaseYear: UILabel!
    @IBOutlet weak var pg: UILabel!
    @IBOutlet weak var runtime: UILabel!

    
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var moviePosterImageView: UIImageView!
    @IBOutlet weak var movieDescription: UITextView!

    @IBOutlet weak var genresCollectionView: UICollectionView!

    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var totalRating: UILabel!
    @IBOutlet weak var noOfRatings: UILabel!
    
    @IBOutlet weak var rateThisLabel: UILabel!
    @IBOutlet weak var criticsLabel: UILabel!
    
    var movieDetail : MovieDetail?{
        didSet{
            genresCollectionView.reloadData()
        }
    }
    var movieID : Int = 0
    var movieTitle : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initialLoads()
        getMovieDetail()
    }
    func getMovieDetail(){
        DispatchQueue.global().async {
            NetworkManager.shared.getMovieDetails(id: self.movieID) { result in
                switch result {
                case .success(let movieDetail):
                    print("Popular Movies:", movieDetail)
                    DispatchQueue.main.async {
                        self.movieDetail = movieDetail
                        self.setupUI()

                    }
                case .failure(let error):
                    print("Error fetching popular movies:", error)
                }
                
            }
        }
        

    }
    
    func initialLoads(){
        setNavigation()
        setCollectionView()
    }
    
    func setCollectionView(){
        genresCollectionView.delegate = self
        genresCollectionView.dataSource = self
    }
    
    func setNavigation(){
        self.navigationController?.navigationItem.title = movieTitle
        self.navigationController?.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(didTapBackBtn))
    }
    @objc func didTapBackBtn(){
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupUI() {
            guard let movie = movieDetail else { return }
            
            // Title
            movieTitleLabel.text = movie.title
            
            // Release Year
            if let releaseDate = movie.releaseDate.split(separator: "-").first {
                releaseYear.text = String(releaseDate)
            }
            
            // Parental Guidance (PG)
            pg.text = movie.adult ? "18+" : "PG-13"
            
            // Runtime
        if movie.runtime > 0 {
            let runtimeInMinutes = movie.runtime
            let hours = runtimeInMinutes / 60
            let minutes = runtimeInMinutes % 60
            runtime.text = "\(hours)h \(minutes)m"
        } else {
            runtime.text = "N/A"
        }
            // Movie Poster
            if let posterPath = movie.posterPath {
                let imageUrlString = "https://image.tmdb.org/t/p/w500\(posterPath)"
                loadImage(from: imageUrlString, into: moviePosterImageView)
            } else {
                moviePosterImageView.image = UIImage(named: "placeholderImage")
            }
            
            // Description
            movieDescription.text = movie.overview
            
            // Rating
            ratingLabel.text = String(format: "%.1f", movie.voteAverage)
            noOfRatings.text = "\(movie.voteCount)"
            
            // Total Rating
            totalRating.text = "10"
            
            // Critics Label
            criticsLabel.text = movie.tagline.isEmpty ? "No tagline available" : movie.tagline
            
            // Update genres in the collection view
            genresCollectionView.reloadData()
        }
    
    
    private func loadImage(from urlString: String, into imageView: UIImageView) {
          guard let url = URL(string: urlString) else { return }
          URLSession.shared.dataTask(with: url) { data, _, error in
              guard let data = data, error == nil, let image = UIImage(data: data) else { return }
              DispatchQueue.main.async {
                  imageView.image = image
              }
          }.resume()
      }

}
extension MovieDetailViewController : UICollectionViewDataSource,UICollectionViewDelegate{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieDetail?.genres.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GenresCollectionViewCell", for: indexPath) as? GenresCollectionViewCell else{
            return UICollectionViewCell()
        }
        cell.configureGenreCell(movieDetail?.genres[indexPath.item].name ?? "")
        
        return cell
        
    }
}
