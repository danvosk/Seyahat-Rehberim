//
//  PlaceViewController.swift
//  Seyahat Rehberim
//
//

import UIKit
import Firebase
import FirebaseAuth
import CoreLocation // Kullanıcının konumunu almak için gerekli
import MapKit // Apple Maps'e yönlendirme yapmak için gerekli

class PlaceViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var textView: UITextView!

    var cityName: String? // Şehir adı
    var landmarkName: String? // Landmark adı
    var landmarkDescription: String? // Landmark açıklaması
    
    var latitude: Double? // Landmark'ın enlemi
    var longitude: Double? // Landmark'ın boylamı
    
    let locationManager = CLLocationManager() // Kullanıcının konumunu almak için
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigation bar başlığını yerin adıyla ayarla
        self.title = landmarkName
        
        // Kullanıcı konum izni isteği
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        // Firebase'den landmark verilerini çek
        fetchLandmarkDetails()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Geri butonunu varsayılan "Back" yazısıyla ayarla
        navigationItem.backButtonTitle = "Back"
    }
    
    func fetchLandmarkDetails() {
        guard let cityName = cityName, let landmarkName = landmarkName else {
            print("Hata: cityName veya landmarkName eksik.") // Debug
            return
        }
        
        let db = Firestore.firestore()
        let landmarkRef = db.collection("cities").document(cityName).collection("landmarks").whereField("name", isEqualTo: landmarkName)
        
        landmarkRef.getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Firestore hatası: \(error.localizedDescription)")
                return
            }
            
            if let document = snapshot?.documents.first {
                self.landmarkDescription = document.data()["description"] as? String
                self.latitude = document.data()["latitude"] as? Double
                self.longitude = document.data()["longitude"] as? Double
                
                DispatchQueue.main.async {
                    self.displayDescription()
                }
            } else {
                print("Hata: Landmark açıklaması veya koordinatları bulunamadı.")
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
    
    @IBAction func getDirectionsButtonTapped(_ sender: Any) {
        // Landmark koordinatlarını kontrol et
        guard let latitude = latitude, let longitude = longitude else {
            print("Hata: Landmark koordinatları bulunamadı.")
            return
        }

        // Kullanıcıya uyarı mesajı göster
        let alert = UIAlertController(title: "Yol Tarifi Al", message: "Bu yere yol tarifi almak ister misiniz?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Evet", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            
            // Kullanıcının anlık konumunu al
            if CLLocationManager().authorizationStatus == .authorizedWhenInUse || CLLocationManager().authorizationStatus == .authorizedAlways {
                guard let userLocation = self.locationManager.location?.coordinate else {
                    print("Kullanıcı konumu alınamadı.")
                    return
                }
                
                let userLatitude = userLocation.latitude
                let userLongitude = userLocation.longitude
                
                // Apple Maps URL oluştur
                let url = URL(string: "http://maps.apple.com/?saddr=\(userLatitude),\(userLongitude)&daddr=\(latitude),\(longitude)&dirflg=d")!
                
                // Apple Maps uygulamasını aç
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    print("Apple Maps açılamıyor.")
                }
            } else {
                // Kullanıcıdan konum izni iste
                self.locationManager.requestWhenInUseAuthorization()
                print("Konum izni gerekli.")
            }
        }))
        alert.addAction(UIAlertAction(title: "Hayır", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func commentButton(_ sender: Any) {
        let commentsVC = CommentsViewController()
        commentsVC.cityName = self.cityName
        commentsVC.landmarkId = self.landmarkName // Landmark ID veya name
        self.navigationController?.pushViewController(commentsVC, animated: true)
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
        
        // Önce aynı landmark'ın zaten favorilere eklenip eklenmediğini kontrol et
        favouritesRef.whereField("landmarkName", isEqualTo: landmarkName).getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Firestore hatası: \(error.localizedDescription)")
                return
            }
            
            if let documents = snapshot?.documents, !documents.isEmpty {
                // Zaten eklenmiş
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Zaten Favorilerde", message: "\(landmarkName) zaten favorilere eklenmiş.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            } else {
                // Favorilere ekle
                let favouriteData: [String: Any] = [
                    "landmarkName": landmarkName,
                    "cityName": cityName
                ]
                
                favouritesRef.addDocument(data: favouriteData) { error in
                    if let error = error {
                        print("Favorilere eklenirken hata oluştu: \(error.localizedDescription)")
                    } else {
                        print("Favorilere başarıyla eklendi!")
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "Başarılı", message: "\(landmarkName) favorilere eklendi.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
}

