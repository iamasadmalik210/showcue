//
//  ViewController.swift
//  ShowCue
//
//  Created by mac on 06/12/2024.
//

import UIKit
import CoreData
import Network

class ViewController: UIViewController {
    
    @IBOutlet weak var moviesCollectionView : UICollectionView!
    
    var currentPage = 1
    var totalPages = 1
    var isFetching = false // Prevent multiple simultaneous API calls
    

    
    var popularMovies  = [Movie](){
        didSet{
            moviesCollectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initialLoads()
        
    }
    
    func initialLoads() {
        setCollectionView()

        if isNetworkAvailable() {
            fetchMovies(page: currentPage)
        } else {
            fetchMoviesFromCoreData()
        }
    }

    func fetchMovies(page: Int) {
        guard !isFetching && page <= totalPages else { return }
        isFetching = true

        DispatchQueue.global().async {
            NetworkManager.shared.getPopularMovies(page) { result in
                switch result {
                case .success(let moviesResponse):
                    DispatchQueue.main.async {
                        self.popularMovies.append(contentsOf: moviesResponse.results)
                        self.totalPages = moviesResponse.total_pages
                        self.saveMoviesToCoreData(moviesResponse.results) // Save to Core Data
                        self.isFetching = false
                        self.currentPage += 1
                    }
                case .failure(let error):
                    print("Error fetching movies:", error)
                    self.isFetching = false
                }
            }
        }
    }

    func setCollectionView(){
        moviesCollectionView.delegate = self
        moviesCollectionView.dataSource = self
        fetchMovies(page: currentPage) // Fetch the first page
    }
    
//    func fetchMovies(page: Int) {
//            guard !isFetching && page <= totalPages else { return }
//            isFetching = true
//            
//            DispatchQueue.global().async {
//                NetworkManager.shared.getPopularMovies(page) { result in
//                    switch result {
//                    case .success(let moviesResponse):
//                        DispatchQueue.main.async {
//                            self.popularMovies.append(contentsOf: moviesResponse.results)
//                            self.totalPages = moviesResponse.total_pages
//                            self.isFetching = false
//                            self.currentPage += 1
//                        }
//                    case .failure(let error):
//                        print("Error fetching movies:", error)
//                        self.isFetching = false
//                    }
//                }
//            }
//        }
    
//    func getPopularMovies(){
//        DispatchQueue.global().async {
//            NetworkManager.shared.getPopularMovies { result in
//                switch result {
//                case .success(let moviesResponse):
//                    print("Popular Movies:", moviesResponse.results)
//                    DispatchQueue.main.async {
//                        self.popularMovies = moviesResponse.results
//
//                    }
//                case .failure(let error):
//                    print("Error fetching popular movies:", error)
//                }
//            }
//        }
//        
//
//    }

}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return popularMovies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularMoviesCollectionViewCell", for: indexPath) as? PopularMoviesCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configureCell(self.popularMovies[indexPath.item])
        return cell
    }

    // Adjust size of each cell for 3 per row and vertical spacing of 10
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 10
        let availableWidth = collectionView.frame.size.width - padding * 4 // For 3 cells + 2 spacings between cells
        let width = availableWidth / 3
        let height: CGFloat = 200 // Adjust the height as per your requirement
        
        return CGSize(width: width, height: height)
    }

    // Minimum line spacing (vertical spacing)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10 // Vertical spacing between rows
    }

    // Minimum inter-item spacing (horizontal spacing)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10 // Horizontal spacing between cells
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let movieDetailVC = storyboard?.instantiateViewController(withIdentifier: "MovieDetailViewController") as? MovieDetailViewController {
            movieDetailVC.movieID = self.popularMovies[indexPath.row].id
            movieDetailVC.movieTitle = self.popularMovies[indexPath.row].title

            self.navigationController?.pushViewController(movieDetailVC, animated: true)
        }
        
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let frameHeight = scrollView.frame.size.height
            
            // Trigger pagination when the user scrolls close to the bottom
            if offsetY > contentHeight - frameHeight * 2 {
                fetchMovies(page: currentPage)
            }
        }
    
    func saveMoviesToCoreData(_ movies: [Movie]) {
        let context = CoreDataHelper.shared.context

        for movie in movies {
            let fetchRequest: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %d", movie.id)

            if let existingMovie = try? context.fetch(fetchRequest).first {
                // Update existing record
                existingMovie.title = movie.title
                existingMovie.posterImage = movie.posterPath
            } else {
                // Create a new record
                let newMovie = MovieEntity(context: context)
                newMovie.id = Int64(Int32(movie.id))
                newMovie.title = movie.title
                newMovie.posterImage = movie.posterPath
            }
        }

        CoreDataHelper.shared.saveContext()
    }

    func fetchMoviesFromCoreData() {
        let context = CoreDataHelper.shared.context
        let fetchRequest: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()

        do {
            let storedMovies = try context.fetch(fetchRequest)
            print("Store Movies \(storedMovies)")

            // Map Core Data entities to Movie struct
            popularMovies = storedMovies.map { storedMovie in
                print("Store movie \(storedMovie.title ?? "")")
                
                return Movie(
                    adult: false,
                    backdropPath: nil, // Default for optional fields
                    genreIDs: [], // Default for genre IDs
                    id: Int(storedMovie.id), // Core Data's `id`
                    originalLanguage: "", // Default for missing field
                    originalTitle: "", // Default for missing field
                    overview: "", // Default for missing field
                    popularity: 0.0, // Default for missing field
                    posterPath: storedMovie.posterImage, // Map from Core Data
                    releaseDate: "", // Default for missing field
                    title: storedMovie.title ?? "", // Map from Core Data
                    video: false, // Default for missing field
                    voteAverage: 0.0, // Default for missing field
                    voteCount: 0 // Default for missing field
                )
            }
            
        } catch {
            print("Failed to fetch movies from Core Data: \(error)")
        }
    }

    
    func isNetworkAvailable() -> Bool {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue.global(qos: .background)
        monitor.start(queue: queue)

        return monitor.currentPath.status == .satisfied
    }

}

