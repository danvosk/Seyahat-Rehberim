//
//  PlaceViewController.swift
//  Seyahat Rehberim
//

import UIKit
import Firebase
import FirebaseAuth

class PlaceViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!

    var cityName: String? // Şehir adı
    var landmarkName: String? // Landmark adı
    var landmarkDescription: String? // Landmark açıklaması

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sayfa başlığı
        self.title = landmarkName
        
        // Eğer açıklama yoksa Firebase'den çek
        if landmarkDescription == nil {
            fetchLandmarkDescription()
        } else {
            displayDescription()
        }
    }
    
    func fetchLandmarkDescription() {
        guard let cityName = cityName, let landmarkName = landmarkName else {
            print("Hata: cityName veya landmarkName eksik.") // Debug
            return
        }
        
        let db = Firestore.firestore()
        let landmarkRef = db.collection("cities").document(cityName).collection("landmarks").whereField("name", isEqualTo: landmarkName)
        
        landmarkRef.getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Firestore hatası: \(error.localizedDescription)") // Debug
                return
            }
            
            if let document = snapshot?.documents.first, let description = document.data()["description"] as? String {
                self.landmarkDescription = description
                DispatchQueue.main.async {
                    self.displayDescription()
                }
            } else {
                print("Hata: Landmark açıklaması bulunamadı.") // Debug
            }
        }
    }
    
    func displayDescription() {
        if let description = landmarkDescription {
            textView.text = description
        } else {
            textView.text = "Açıklama bulunamadı."
        }
    }
    
    @IBAction func addFavouritesButton(_ sender: Any) {
        // Favorilere ekle butonu
        let alert = UIAlertController(title: "Favorilere Ekle", message: "Bu yeri favorilerinize eklemek ister misiniz?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Evet", style: .default, handler: { [weak self] _ in
            self?.addToFavourites()
        }))
        alert.addAction(UIAlertAction(title: "Hayır", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func addToFavourites() {
        guard let user = Auth.auth().currentUser else {
            print("Kullanıcı oturumu açık değil.") // Debug
            return
        }
        
        let userID = user.uid
        guard let landmarkName = landmarkName, let cityName = cityName else {
            print("Landmark veya şehir bilgisi eksik.") // Debug
            return
        }
        
        let db = Firestore.firestore()
        let favouritesRef = db.collection("favourites").document(userID).collection("favourites")
        
        let favouriteData: [String: Any] = [
            "landmarkName": landmarkName,
            "cityName": cityName
        ]
        
        favouritesRef.addDocument(data: favouriteData) { error in
            if let error = error {
                print("Favorilere eklenirken hata oluştu: \(error.localizedDescription)")
            } else {
                print("Favorilere başarıyla eklendi!")
            }
        }
    }
}
