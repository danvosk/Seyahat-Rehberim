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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        
        // Firebase'den şehir verilerini yükle ve güncelle
        CityData.fetchCities {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
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
