//
//  ProfileViewController.swift
//  Seyahat Rehberim
//
//  Created by Görkem Karagöz on 24.11.2024.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController {
    
    var navigationTitle: String? // Menüden gelen başlık
    
    // Kullanıcı bilgilerini göstermek için UILabel'lar
    private let nameLabel = UILabel()
    private let surnameLabel = UILabel()
    private let usernameLabel = UILabel()
    private let emailLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = navigationTitle ?? "Profilim" // Sayfa başlığı
        
        view.backgroundColor = .white // Arka plan rengini ayarla
        setupUI() // UI elemanlarını oluştur
        fetchUserData() // Firebase'den kullanıcı bilgilerini çek
    }
    
    private func setupUI() {
        // Ad, Soyad, Kullanıcı Adı, E-posta etiketlerini düzenle
        let labels = [nameLabel, surnameLabel, usernameLabel, emailLabel]
        let titles = ["Ad:", "Soyad:", "Kullanıcı Adı:", "E-posta:"]
        
        // Her bir başlık ve veri çiftini düzenle
        for (index, label) in labels.enumerated() {
            // Başlık için bir UILabel oluştur
            let titleLabel = UILabel()
            titleLabel.text = titles[index]
            titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
            titleLabel.textColor = .black
            
            // Veri göstermek için UILabel ayarları
            label.font = UIFont.systemFont(ofSize: 16)
            label.textColor = .darkGray
            label.numberOfLines = 0 // Uzun metinler için destek
            
            // UIStackView içinde başlık ve veri göstergesi
            let stackView = UIStackView(arrangedSubviews: [titleLabel, label])
            stackView.axis = .horizontal
            stackView.spacing = 8
            stackView.alignment = .fill
            stackView.distribution = .fillEqually
            
            // Her stackView'ı ana görünüme ekle
            view.addSubview(stackView)
            
            // Auto Layout ayarları
            stackView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: CGFloat(100 + index * 50)),
                stackView.heightAnchor.constraint(equalToConstant: 40)
            ])
        }
    }
    
    private func fetchUserData() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("Kullanıcı oturumu açık değil.")
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)
        
        userRef.getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Kullanıcı verileri alınırken hata oluştu: \(error.localizedDescription)")
                return
            }
            
            if let data = snapshot?.data() {
                self.nameLabel.text = data["name"] as? String ?? "Ad bulunamadı"
                self.surnameLabel.text = data["surname"] as? String ?? "Soyad bulunamadı"
                self.usernameLabel.text = data["username"] as? String ?? "Kullanıcı adı bulunamadı"
                self.emailLabel.text = data["email"] as? String ?? "E-posta bulunamadı"
            } else {
                print("Kullanıcı verileri bulunamadı.")
            }
        }
    }
}
