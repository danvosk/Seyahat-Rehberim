//
//  CitiesCollectionViewCell.swift
//  Seyahat Rehberim
//
//  Created by Görkem Karagöz on 29.10.2024.
//
//

import UIKit

class CitiesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cityImage: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    
    func setup(with city: City) {
        cityImage.image = city.image // City modelinden UIImage'ı alıyoruz
        cityLabel.text = city.title
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.5
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        
        setupSelectedBackgroundView() // Seçim arka planını ayarla
    }
    
    private func setupSelectedBackgroundView() {
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5) // Seçim arka plan rengi
        selectedBackgroundView = selectedView
    }
}
