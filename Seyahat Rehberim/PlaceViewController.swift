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

    @IBOutlet weak var landmarkImage: UIImageView!
    @IBOutlet weak var avarageLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var textView: UITextView!

    var cityName: String? // Şehir adı
    var landmarkName: String? // Landmark adı
    var landmarkDescription: String? // Landmark açıklaması
    var landmarkImageName: String? // Görselin adı
    
    var latitude: Double? // Landmark'ın enlemi
    var longitude: Double? // Landmark'ın boylamı
    
    let locationManager = CLLocationManager() // Kullanıcının konumunu almak için
    let db = Firestore.firestore() // Firestore referansı
    var selectedRating: Int? // Kullanıcının verdiği puan

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigation bar başlığını yerin adıyla ayarla
        self.title = landmarkName
        
        // Kullanıcı konum izni isteği
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        // Firebase'den landmark verilerini çek
        fetchLandmarkDetails()
        fetchUserRating() // Kullanıcının daha önce verdiği puanı getir
        
        if let imageName = landmarkImageName {
              landmarkImage.image = UIImage(named: imageName) // Görseli yükle
          } else {
              landmarkImage.image = nil // Görsel bulunamazsa temizle
          }
        
        // TextView düzenlemeleri
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        
        setupImageView()
        setupTextView()
        
    }
    
    private func setupImageView() {
        // Görsel kenarlarını yuvarlat ve gölge ekle
        landmarkImage.layer.cornerRadius = 12
        landmarkImage.layer.masksToBounds = true
        landmarkImage.contentMode = .scaleAspectFill

        // Gölge efekti
        landmarkImage.layer.shadowColor = UIColor.black.cgColor
        landmarkImage.layer.shadowOpacity = 0.2
        landmarkImage.layer.shadowOffset = CGSize(width: 0, height: 2)
        landmarkImage.layer.shadowRadius = 4
    }
    
    private func setupTextView() {
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.layer.cornerRadius = 8
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray4.cgColor
    }
    
    
    @IBAction func starOneButton(_ sender: UIButton) {
        ratePlace(rating: 1)
    }
    
    @IBAction func starTwoButton(_ sender: UIButton) {
        ratePlace(rating: 2)
    }
    
    @IBAction func starThreeButton(_ sender: UIButton) {
        ratePlace(rating: 3)
    }
    
    @IBAction func starFourButton(_ sender: UIButton) {
        ratePlace(rating: 4)
    }
    
    @IBAction func starFiveButton(_ sender: UIButton) {
        ratePlace(rating: 5)
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        // Geri butonunu varsayılan "Geri" yazısıyla ayarla
//        navigationItem.backButtonTitle = "Geri Dön"
//        fetchUserRating()
//    }
    
    
    @IBAction func addFavouritesButtonTapped(_ sender: Any) {
        guard let user = Auth.auth().currentUser,
              let cityName = cityName,
              let landmarkName = landmarkName else {
            print("Eksik veri, favori eklenemedi.")
            return
        }

        let userId = user.uid
        let favouritesRef = db.collection("favourites").document(userId).collection("favourites").document(landmarkName)

        favouritesRef.getDocument { [weak self] document, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Favori durumu kontrol edilirken hata oluştu: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                // Yer zaten favorilerde
                let alert = UIAlertController(title: "Zaten Favorilerde",
                                              message: "\(landmarkName) zaten favorilerinizde ekli.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                // Yer favorilerde değil, ekleme işlemi
                let alert = UIAlertController(title: "Favorilere Ekle",
                                              message: "\(landmarkName) favorilerinize eklemek ister misiniz?",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Evet", style: .default, handler: { _ in
                    let favoriteData: [String: Any] = [
                        "cityName": cityName,
                        "landmarkName": landmarkName,
                        "timestamp": FieldValue.serverTimestamp()
                    ]
                    favouritesRef.setData(favoriteData) { error in
                        if let error = error {
                            print("Favorilere ekleme sırasında hata oluştu: \(error.localizedDescription)")
                        } else {
                            print("\(landmarkName) favorilere başarıyla eklendi.")
                            // Favori eklendikten sonra uyarı göster
                            DispatchQueue.main.async {
                                let successAlert = UIAlertController(title: "Başarılı",
                                                                     message: "\(landmarkName) favorilerinize eklendi.",
                                                                     preferredStyle: .alert)
                                successAlert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
                                self.present(successAlert, animated: true, completion: nil)
                            }
                        }
                    }
                }))
                alert.addAction(UIAlertAction(title: "Hayır", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func fetchLandmarkDetails() {
        guard let cityName = cityName, let landmarkName = landmarkName else {
            print("Hata: cityName veya landmarkName eksik.") // Debug
            return
        }
        
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
        guard let latitude = latitude, let longitude = longitude else {
            print("Hata: Landmark koordinatları bulunamadı.")
            return
        }

        let alert = UIAlertController(title: "Yol Tarifi Al", message: "Bu yere yol tarifi almak ister misiniz?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Evet", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            
            if CLLocationManager().authorizationStatus == .authorizedWhenInUse || CLLocationManager().authorizationStatus == .authorizedAlways {
                guard let userLocation = self.locationManager.location?.coordinate else {
                    print("Kullanıcı konumu alınamadı.")
                    return
                }
                
                let userLatitude = userLocation.latitude
                let userLongitude = userLocation.longitude
                
                let url = URL(string: "http://maps.apple.com/?saddr=\(userLatitude),\(userLongitude)&daddr=\(latitude),\(longitude)&dirflg=d")!
                
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    print("Apple Maps açılamıyor.")
                }
            } else {
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
    
    private func ratePlace(rating: Int) {
        let alert = UIAlertController(title: "Puanlama",
                                      message: "\(rating) yıldız vermek istiyor musunuz?",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Evet", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.confirmRatePlace(rating: rating)
        }))
        
        alert.addAction(UIAlertAction(title: "Hayır", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
 
    private func confirmRatePlace(rating: Int) {
        guard let user = Auth.auth().currentUser,
              let cityName = cityName,
              let landmarkName = landmarkName else {
            print("Eksik veri.")
            return
        }

        let userId = user.uid
        let ratingRef = db.collection("Ranking").document(cityName).collection("places").document(landmarkName)

        ratingRef.getDocument { [weak self] documentSnapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("Puanlama alınırken hata: \(error.localizedDescription)")
                return
            }

            var newTotalPoints = 0
            var newTotalRatings = 0
            var previousRating: Int? = nil

            if let document = documentSnapshot, document.exists {
                let data = document.data()
                newTotalPoints = data?["totalPoints"] as? Int ?? 0
                newTotalRatings = data?["totalRatings"] as? Int ?? 0

                if let userRatings = data?["userRatings"] as? [String: Int] {
                    previousRating = userRatings[userId]
                }
            }

            if let previousRating = previousRating {
                newTotalPoints = newTotalPoints - previousRating + rating
            } else {
                newTotalPoints += rating
                newTotalRatings += 1
            }

            let averageRating = Double(newTotalPoints) / Double(newTotalRatings)

            ratingRef.setData([
                "totalPoints": newTotalPoints,
                "totalRatings": newTotalRatings,
                "averageRating": averageRating,
                "userRatings.\(userId)": rating
            ], merge: true) { error in
                if let error = error {
                    print("Puanlama kaydedilirken hata oluştu: \(error.localizedDescription)")
                } else {
                    DispatchQueue.main.async {
                        self.selectedRating = rating // Kullanıcı puanını kaydet
                        self.updateStars(rating: rating)
                        self.questionLabel.text = "Puanınız: \(rating)" // Puanını göster
                        self.avarageLabel.text = "Ort. puan: \(String(format: "%.1f", averageRating))" // Ortalamayı güncelle
                    }
                }
            }
        }
    }
    
    private func fetchUserRating() {
        guard let user = Auth.auth().currentUser,
              let cityName = cityName,
              let landmarkName = landmarkName else {
            return
        }
        
        let userId = user.uid
        let ratingRef = db.collection("Ranking").document(cityName).collection("places").document(landmarkName)
        
        ratingRef.getDocument { [weak self] documentSnapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Puanlama alınırken hata: \(error.localizedDescription)")
                return
            }
            
            if let document = documentSnapshot, document.exists {
                // Kullanıcının puanını al
                if let userRatings = document.data()?["userRatings"] as? [String: Int],
                   let rating = userRatings[userId] {
                    DispatchQueue.main.async {
                        self.selectedRating = rating
                        self.updateStars(rating: rating)
                        // Eğer kullanıcı puanladıysa, "Puanlamak ister misiniz?" yazısını değiştirme
                        self.questionLabel.text = "Puanınız: \(rating)"
                    }
                } else {
                    DispatchQueue.main.async {
                        self.selectedRating = nil // Kullanıcı puanı yok
                        self.updateStars(rating: 0)
                        self.questionLabel.text = "Puanlamak ister misiniz?"
                    }
                }
                
                // Ortalama puanı al ve göster
                if let averageRating = document.data()?["averageRating"] as? Double {
                    DispatchQueue.main.async {
                        self.avarageLabel.text = "Ort. puan: \(String(format: "%.1f", averageRating))"
                    }
                } else {
                    DispatchQueue.main.async {
                        self.avarageLabel.text = "Ort. puan: Bilinmiyor"
                    }
                }
            }
        }
    }
    
    private func updateStars(rating: Int) {
        for i in 1...5 {
            if let starButton = self.view.viewWithTag(i) as? UIButton {
                starButton.tintColor = i <= rating ? .yellow : .gray
            }
        }
        selectedRating = rating
    }
}
