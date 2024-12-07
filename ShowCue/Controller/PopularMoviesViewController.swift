//
//  ViewController.swift
//  ShowCue
//
//  Created by mac on 06/12/2024.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var moviesCollectionView : UICollectionView!
    
    var popularMovies  = [Movie](){
        didSet{
            moviesCollectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initialLoads()
        
    }
    
    func initialLoads(){
        setCollectionView()
        
    }
    func setCollectionView(){
        moviesCollectionView.delegate = self
        moviesCollectionView.dataSource = self
        getPopularMovies()
    }
    
    func getPopularMovies(){
        DispatchQueue.global().async {
            NetworkManager.shared.getPopularMovies { result in
                switch result {
                case .success(let moviesResponse):
                    print("Popular Movies:", moviesResponse.results)
                    DispatchQueue.main.async {
                        self.popularMovies = moviesResponse.results

                    }
                case .failure(let error):
                    print("Error fetching popular movies:", error)
                }
            }
        }
        

    }

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
}

