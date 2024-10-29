//
//  CityViewController.swift
//  Seyahat Rehberim
//
//  Created by Görkem Karagöz on 29.10.2024.
//

import UIKit
import Firebase

class CityViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var cityName: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    
    var selectedCityName: String? // MainViewController’dan gelen şehir ismi
    var landmarks: [Landmark] = [] // Firebase’den çekilen landmark verileri
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cityName.title = selectedCityName // Şehir adını göster
        tableView.dataSource = self
        tableView.delegate = self
        
        // Firebase’den landmark verilerini çek
        fetchLandmarksForSelectedCity()
    }
    
    func fetchLandmarksForSelectedCity() {
        guard let cityName = selectedCityName else { return }
        
        // Firestore bağlantısı
        let db = Firestore.firestore()
        let landmarksCollection = db.collection("cities").document(cityName).collection("landmarks")
        
        // Landmark verilerini çek
        landmarksCollection.getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents, error == nil else {
                print("Error fetching landmarks for \(cityName): \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Landmark verilerini landmarks array’ine ekle
            self.landmarks = documents.compactMap { doc in
                let name = doc.data()["name"] as? String ?? "Unknown"
                return Landmark(name: name)
            }
            
            // TableView’ı güncelle
            self.tableView.reloadData()
        }
    }
    
    // MARK: - TableView DataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return landmarks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LandmarkCell", for: indexPath)
        let landmark = landmarks[indexPath.row]
        cell.textLabel?.text = landmark.name
        return cell
    }
    
    // MARK: - TableView Delegate Methods
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            // Hücre seçildiğinde yapmak istediğiniz işlemler varsa buraya ekleyin
            print("Seçilen hücre: \(landmarks[indexPath.row].name)")
            
            // Seçim durumunu hemen kaldır
            tableView.deselectRow(at: indexPath, animated: true)
        }
}
