//  City.swift
//  Seyahat Rehberim
//

import UIKit
import Firebase

// Landmark modeli, koordinatları içeriyor
struct Landmark {
    let name: String
    let description: String
    let latitude: Double
    let longitude: Double
    let imageName: String // Görsel adı (Assets'teki görselin adıyla eşleşiyor)

}

struct City {
    let title: String
    let description: String
    let imageName: String
    var landmarks: [Landmark]
    var image: UIImage? {
        return UIImage(named: imageName)
    }
}

class CityData {
    static var cities: [City] = []
    
    static func fetchCities(completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        
        db.collection("cities").getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents, error == nil else {
                print("Error fetching cities: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            cities.removeAll()
            let dispatchGroup = DispatchGroup()
            
            for document in documents {
                let title = document.documentID
                let imageName = document.documentID
                let description = document.data()["description"] as? String ?? "Açıklama bulunamadı."
                let landmarksCollection = document.reference.collection("landmarks")
                
                dispatchGroup.enter()
                fetchLandmarks(forCityTitle: title, landmarksCollection: landmarksCollection) { landmarks in
                    let city = City(title: title, description: description, imageName: imageName, landmarks: landmarks)
                    cities.append(city)
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion()
            }
        }
    }
    
    static func fetchLandmarks(forCityTitle title: String, landmarksCollection: CollectionReference, completion: @escaping ([Landmark]) -> Void) {
        var landmarks: [Landmark] = []
        
        landmarksCollection.getDocuments { (snapshot, error) in
            guard let documents = snapshot?.documents, error == nil else {
                print("Error fetching landmarks for \(title): \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }
            
            for document in documents {
                let name = document.data()["name"] as? String ?? "Unknown"
                let description = document.data()["description"] as? String ?? "Açıklama bulunamadı."
                let latitude = document.data()["latitude"] as? Double ?? 0.0
                let longitude = document.data()["longitude"] as? Double ?? 0.0
                let imageName = document.data()["imageName"] as? String ?? "" // Görsel adı
                let landmark = Landmark(name: name, description: description, latitude: latitude, longitude: longitude, imageName: imageName)
                landmarks.append(landmark)
            }
            completion(landmarks)
        }
    }
}
