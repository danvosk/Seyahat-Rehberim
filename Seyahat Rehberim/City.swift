//
//  City.swift
//  Seyahat Rehberim
//
//  Created by Görkem Karagöz on 29.10.2024.
//

import UIKit
import Firebase

struct Landmark {
    let name: String
    let description: String // Landmark açıklamasını tutmak için eklendi
}

struct City {
    let title: String
    let description: String // Şehir açıklamasını tutmak için
    let imageName: String // Görsel ismini tutmak için
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
            
            cities.removeAll() // Mevcut şehir listesini temizliyoruz
            
            let dispatchGroup = DispatchGroup() // Tüm işlemler tamamlandıktan sonra çağırmak için

            for document in documents {
                let title = document.documentID
                let imageName = document.documentID // imageName olarak şehir ismini kullanıyoruz
                let description = document.data()["description"] as? String ?? "Açıklama bulunamadı." // Şehir açıklaması
                let landmarksCollection = document.reference.collection("landmarks")
                
                dispatchGroup.enter()
                fetchLandmarks(forCityTitle: title, landmarksCollection: landmarksCollection) { landmarks in
                    let city = City(title: title, description: description, imageName: imageName, landmarks: landmarks)
                    cities.append(city)
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                completion() // Tüm veriler çekildikten sonra tamamlanıyor
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
                let description = document.data()["description"] as? String ?? "Açıklama bulunamadı." // Description çekiliyor
                let landmark = Landmark(name: name, description: description)
                landmarks.append(landmark)
            }
            completion(landmarks)
        }
    }
}
