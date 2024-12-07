//
//  GenresCollectionViewCell.swift
//  ShowCue
//
//  Created by mac on 07/12/2024.
//

import UIKit

class GenresCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var genre : UILabel!
    
    
    override  func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
   func configureGenreCell(_ genreText : String){
        genre.text = genreText
    }
    
}
