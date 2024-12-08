//
//  MoviewDetailViewController.swift
//  ShowCue
//
//  Created by mac on 07/12/2024.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    
    @IBOutlet weak var banerImageView: UIImageView!
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
    var shimmerViews: [UIView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initialLoads()
        getMovieDetail()
        genresCollectionView.accessibilityIdentifier = "genreCollectionView"
        movieTitleLabel.accessibilityIdentifier = "movieDetailTitleLabel"
        ratingLabel.accessibilityIdentifier = "movieRatingLabel"
        movieDescription.accessibilityIdentifier = "movieDescriptionTextView"
        banerImageView.accessibilityIdentifier = "movieBannerImageView"
        moviePosterImageView.accessibilityIdentifier = "moviePosterImageView"
        criticsLabel.accessibilityIdentifier = "movieCriticsLabel"
        rateThisLabel.accessibilityIdentifier = "movieRateThisLabel"


        
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
                        self.stopShimmerEffect()
                        
                    }
                case .failure(let error):
                    print("Error fetching popular movies:", error)
                }
                
            }
        }
        
        
    }
    
    func initialLoads(){

        setCollectionView()
        setupShimmerEffect()
        setNavigation()
    }
    
    func setCollectionView(){
        genresCollectionView.delegate = self
        genresCollectionView.dataSource = self
    }
    
    func setNavigation() {
        self.navigationItem.title = ""
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysOriginal).withTintColor(.label), // Use system image
            style: .plain,
            target: self,
            action: #selector(didTapBackBtn)
        )
    }

    
    @objc func didTapBackBtn(){
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupUI() {
        guard let movie = movieDetail else { return }
        
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
        
        if let bannerImage = movie.backdropPath {
            let imageUrlString = "https://image.tmdb.org/t/p/original\(bannerImage)"
            loadImage(from: imageUrlString, into: banerImageView)
            banerImageView.isHidden = false
        } else {
            banerImageView.image = UIImage(named: "placeholderImage")
            banerImageView.isHidden = true
        }
        
        movieDescription.text = movie.overview
        ratingLabel.text = String(format: "%.1f", movie.voteAverage)
        noOfRatings.text = "\(movie.voteCount)"
        totalRating.text = "10"
        criticsLabel.text = movie.tagline.isEmpty ? "No tagline available" : movie.tagline
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
    
    func setupShimmerEffect() {
        // Add shimmer effect to the views while loading data
        shimmerViews = [movieTitleLabel, releaseYear, pg, runtime, moviePosterImageView, movieDescription, ratingLabel, totalRating, noOfRatings, rateThisLabel, criticsLabel,moviePosterImageView]
        
        for view in shimmerViews {
            addShimmer(to: view)
        }
    }
    
    // Function to add shimmer effect using gradient layer
    func addShimmer(to view: UIView) {
        let shimmerLayer = CAGradientLayer()
        shimmerLayer.frame = view.bounds
        shimmerLayer.colors = [UIColor.lightGray.withAlphaComponent(0.2).cgColor, UIColor.lightGray.withAlphaComponent(0.4).cgColor, UIColor.lightGray.withAlphaComponent(0.2).cgColor]
        shimmerLayer.locations = [0, 0.5, 1]
        shimmerLayer.startPoint = CGPoint(x: 0, y: 0.5)
        shimmerLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        // Add animation for shimmer effect
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        shimmerLayer.add(animation, forKey: "shimmerAnimation")
        
        view.layer.addSublayer(shimmerLayer)
    }
    
    // Function to remove shimmer effect once data is loaded
    func stopShimmerEffect() {
        for view in shimmerViews {
            if let sublayers = view.layer.sublayers {
                for layer in sublayers {
                    if layer is CAGradientLayer {
                        layer.removeAllAnimations()
                        layer.removeFromSuperlayer()
                    }
                }
            }
        }
    }
}
