//
//  MainViewController.swift
//  Seyahat Rehberim
//
//  Created by Görkem Karagöz on 29.10.2024.
//

import UIKit
import Firebase
import FirebaseDatabase

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!

    private var activityIndicator: UIActivityIndicatorView! // Indicator için bir değişken

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        
        setupActivityIndicator() // Indicator'ı ayarla ve göster
        
        // Firebase'den şehir verilerini yükle ve güncelle
        CityData.fetchCities {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.stopActivityIndicator() // Yükleme tamamlandı, indicator'ı durdur
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hücrelerin seçim durumunu sıfırla
        if let selectedItems = collectionView.indexPathsForSelectedItems {
            for indexPath in selectedItems {
                collectionView.deselectItem(at: indexPath, animated: false)
                if let cell = collectionView.cellForItem(at: indexPath) {
                    cell.contentView.backgroundColor = UIColor.white // Varsayılan renge döndür
                }
            }
        }
    }
  
    private func setupActivityIndicator() {
        // Indicator'ı oluştur
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .gray
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        // Görünüme ekle
        view.addSubview(activityIndicator)
        
        // Ortala
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Başlat
        activityIndicator.startAnimating()
    }
    
    private func stopActivityIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview() // Yükleme tamamlandıktan sonra kaldır
    }

    @IBAction func menuBarItem(_ sender: Any) {
        print("Hamburger menüye tıklandı")
        performSegue(withIdentifier: "toMenuVc", sender: nil)
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
        let padding: CGFloat = 8
        let collectionViewSize = collectionView.frame.size.width - padding * 3

        let itemWidth = collectionViewSize / 2
        return CGSize(width: itemWidth, height: itemWidth * 1)
    }
    
    // MARK: - UICollectionViewDelegate Methods
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toCityVc", sender: indexPath)
    }
    
    // MARK: - Segue Preparation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCityVc",
           let destinationVC = segue.destination as? CityViewController,
           let indexPath = sender as? IndexPath {
            let selectedCity = CityData.cities[indexPath.row]
            destinationVC.selectedCityName = selectedCity.title
            destinationVC.landmarks = selectedCity.landmarks
        }
    }
}
