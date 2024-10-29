//
//  MainViewController.swift
//  Seyahat Rehberim
//
//  Created by Görkem Karagöz on 29.10.2024.
//

import UIKit

class MainViewController:  UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
    }
    
    // MARK: - UICollectionViewDataSource Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CityData.cities.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CitiesCollectionViewCell", for: indexPath) as! CitiesCollectionViewCell
        cell.setup(with: CityData.cities[indexPath.row])
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout Methods
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 8 // Hücreler arası boşluk
        let collectionViewSize = collectionView.frame.size.width - padding * 3

        let itemWidth = collectionViewSize / 2 // 2 sütun için
        return CGSize(width: itemWidth, height: itemWidth * 1) // Hücrenin yüksekliği genişliğinin 1.5 katı
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12 // Hücreler arası yatay boşluk

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12 // Hücreler arası dikey boşluk

    }
    
    // MARK: - UICollectionViewDelegate Methods
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(CityData.cities[indexPath.row].title)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        // Uyarı oluşturma
        let alert = UIAlertController(title: "Çıkış Yap", message: "Çıkış yapmak istediğinize emin misiniz?", preferredStyle: .alert)
        
        // "Tamam" butonunu ekleme
        let confirmAction = UIAlertAction(title: "Tamam", style: .default) { [weak self] _ in
            self?.performSegue(withIdentifier: "toLoginVC", sender: nil)
        }
        
        // "İptal" butonunu ekleme
        let cancelAction = UIAlertAction(title: "İptal", style: .cancel, handler: nil)
        
        // Uyarıya butonları ekleme
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        // Uyarıyı gösterme
        present(alert, animated: true, completion: nil)
    }
}
