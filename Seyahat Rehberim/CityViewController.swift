//
//  CityViewController.swift
//  Seyahat Rehberim
//

import UIKit
import Firebase

class CityViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var cityName: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    
    var selectedCityName: String?
    var landmarks: [Landmark] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cityName.title = selectedCityName
        tableView.dataSource = self
        tableView.delegate = self
        fetchLandmarksForSelectedCity()
    }
    
    func fetchLandmarksForSelectedCity() {
        guard let cityName = selectedCityName else { return }
        
        let db = Firestore.firestore()
        let landmarksCollection = db.collection("cities").document(cityName).collection("landmarks")
        
        landmarksCollection.getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }
            
            guard let documents = snapshot?.documents, error == nil else {
                print("Error fetching landmarks for \(cityName): \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            self.landmarks = documents.compactMap { doc in
                let name = doc.data()["name"] as? String ?? "Unknown"
                let description = doc.data()["description"] as? String ?? "Açıklama bulunamadı."
                let latitude = doc.data()["latitude"] as? Double ?? 0.0
                let longitude = doc.data()["longitude"] as? Double ?? 0.0
                return Landmark(name: name, description: description, latitude: latitude, longitude: longitude)
            }
            
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
        cell.textLabel?.text = landmarks[indexPath.row].name
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
            destinationVC.landmarkDescription = selectedLandmark.description
            destinationVC.latitude = selectedLandmark.latitude
            destinationVC.longitude = selectedLandmark.longitude
        }
    }
}
