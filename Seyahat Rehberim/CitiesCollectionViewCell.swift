//
//  CitiesCollectionViewCell.swift
//  Seyahat Rehberim
//
//  Created by Görkem Karagöz on 29.10.2024.
//
//
//import UIKit
//
//class CitiesCollectionViewCell: UICollectionViewCell {
//    
//    @IBOutlet weak var cityImage: UIImageView!
//    @IBOutlet weak var cityLabel: UILabel!
//    
//    func setup(with city: City) {
//         cityImage.image = city.image
//         cityLabel.text = city.title
//     }
//    override func awakeFromNib() {
//          super.awakeFromNib()
//          // Hücre kenarına çerçeve ekleme
//          self.layer.borderColor = UIColor.lightGray.cgColor
//          self.layer.borderWidth = 0.5 // Çerçeve kalınlığı
//          self.layer.cornerRadius = 8 // Hafif yuvarlatılmış köşeler için
//          self.layer.masksToBounds = true
//      }
//}
import UIKit

class CitiesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cityImage: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    
    func setup(with city: City) {
        cityImage.image = city.image
        cityLabel.text = city.title
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Hücre kenarına çerçeve ekleme
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.5
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
    }
    
    // Hücre seçildiğinde kısa süreli bir animasyon ekleme
    override var isSelected: Bool {
        didSet {
            if isSelected {
                // Seçildiğinde arka plan rengini geçici olarak değiştir
                UIView.animate(withDuration: 0.1, animations: {
                    self.backgroundColor =  UIColor.systemGray6
                }) { _ in
                    // Animasyon tamamlanınca orijinal rengine dön
                    UIView.animate(withDuration: 0.1) {
                        self.backgroundColor = .white
                    }
                }
            }
        }
    }
}
