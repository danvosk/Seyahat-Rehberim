//
//  CityViewController.swift
//  Seyahat Rehberim
//
//  Created by Görkem Karagöz on 29.10.2024.
//
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
        
        // Şehir adını navigation bar’da göster
        cityName.title = selectedCityName
        
        // TableView veri kaynağı ve delegesi
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
        landmarksCollection.getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return } // Retain cycle önlemek için
            
            guard let documents = snapshot?.documents, error == nil else {
                print("Error fetching landmarks for \(cityName): \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Landmark verilerini landmarks array’ine ekle
            self.landmarks = documents.compactMap { doc in
                let name = doc.data()["name"] as? String ?? "Unknown"
                let description = doc.data()["description"] as? String ?? "Açıklama bulunamadı."
                return Landmark(name: name, description: description)
            }
            
            // TableView’ı güncelle
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return landmarks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LandmarkCell", for: indexPath)
        let landmark = landmarks[indexPath.row]
        cell.textLabel?.text = landmark.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toPlaceVc", sender: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPlaceVc",
           let destinationVC = segue.destination as? PlaceViewController,
           let indexPath = sender as? IndexPath {
            let selectedLandmark = landmarks[indexPath.row]
            destinationVC.cityName = selectedCityName
            destinationVC.landmarkName = selectedLandmark.name
            destinationVC.landmarkDescription = selectedLandmark.description // Description gönderiliyor
        }
    }
}
