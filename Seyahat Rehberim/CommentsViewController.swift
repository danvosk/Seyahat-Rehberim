//
//
//  CommentsViewController.swift
//  Seyahat Rehberim
//
//  Created by Görkem Karagöz on 25.11.2024.
//

import UIKit
import Firebase
import FirebaseAuth

class CommentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var tableView = UITableView()
    private var commentTextField = UITextField()
    private var sendButton = UIButton(type: .system)
    private var comments: [(username: String, comment: String, userId: String)] = []
    
    var cityName: String? // Şehir adı
    var landmarkId: String? // Landmark ID (Aynı zamanda seçilen yerin adı)

    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        view.backgroundColor = .white
        
        // Navigation bar başlığı için seçilen yerin adını ayarla
        self.title = landmarkId

        // Klavyeyi kapatmak için ekran dokunmasını algılayan gesture tanımlama
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        loadComments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Geri butonunu varsayılan "Back" yazısıyla ayarla
        navigationItem.backButtonTitle = "Back"
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true) // Klavyeyi kapat
    }
    
    private func setupUI() {
        // Yorumlar için tablo görünümü
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Yorum metin kutusu
        commentTextField.placeholder = "Yorum yazın"
        commentTextField.borderStyle = .roundedRect
        commentTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(commentTextField)
        
        // Gönder butonu
        sendButton.setTitle("Gönder", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(sendCommentTapped), for: .touchUpInside)
        view.addSubview(sendButton)
        
        // Otomatik yerleşim
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: commentTextField.topAnchor, constant: -10),
            
            commentTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            commentTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10),
            commentTextField.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            commentTextField.heightAnchor.constraint(equalToConstant: 40),
            
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            sendButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            sendButton.widthAnchor.constraint(equalToConstant: 80),
            sendButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc private func sendCommentTapped() {
        guard let commentText = commentTextField.text, !commentText.isEmpty,
              let user = Auth.auth().currentUser,
              let cityName = cityName,
              let landmarkId = landmarkId else {
            print("Hata: Yorum veya gerekli veriler eksik.")
            return
        }
        
        // Kullanıcı adını çek
        db.collection("users").document(user.uid).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Kullanıcı bilgisi alınamadı: \(error.localizedDescription)")
                return
            }
            
            if let data = snapshot?.data(), let username = data["username"] as? String {
                let commentData: [String: Any] = [
                    "userId": user.uid,
                    "username": username,
                    "comment": commentText,
                    "timestamp": FieldValue.serverTimestamp()
                ]
                
                // Firestore'a yorum ekleme
                self.db.collection("cities").document(cityName)
                    .collection("landmarks").document(landmarkId)
                    .collection("comments").addDocument(data: commentData) { error in
                        if let error = error {
                            print("Yorum eklenirken hata oluştu: \(error.localizedDescription)")
                        } else {
                            print("Yorum başarıyla eklendi!")
                            DispatchQueue.main.async {
                                self.commentTextField.text = ""
                                self.loadComments()
                                
                                // Gönder butonuna basıldığında klavyeyi kapat
                                self.dismissKeyboard()
                            }
                        }
                    }
            }
        }
    }
    
    private func loadComments() {
        guard let cityName = cityName, let landmarkId = landmarkId else {
            print("Hata: Gerekli veriler eksik.")
            return
        }
        
        db.collection("cities").document(cityName)
            .collection("landmarks").document(landmarkId)
            .collection("comments")
            .order(by: "timestamp", descending: false)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Yorumlar yüklenirken hata oluştu: \(error.localizedDescription)")
                    return
                }
                
                self.comments = snapshot?.documents.compactMap { document in
                    let data = document.data()
                    let username = data["username"] as? String ?? "Bilinmeyen"
                    let comment = data["comment"] as? String ?? ""
                    let userId = data["userId"] as? String ?? "" // Kullanıcı ID'si
                    return (username: username, comment: comment, userId: userId)
                } ?? []
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
    }
    
    @objc private func deleteComment(_ sender: UIButton) {
        let index = sender.tag
        let comment = comments[index]
        
        guard let cityName = cityName, let landmarkId = landmarkId else {
            print("Hata: Gerekli veriler eksik.")
            return
        }

        // Firestore'dan yorumu sil
        db.collection("cities").document(cityName)
            .collection("landmarks").document(landmarkId)
            .collection("comments").whereField("comment", isEqualTo: comment.comment)
            .whereField("userId", isEqualTo: Auth.auth().currentUser?.uid ?? "")
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Yorum silinirken hata oluştu: \(error.localizedDescription)")
                    return
                }
                
                // Dokümanları sil
                snapshot?.documents.forEach { document in
                    document.reference.delete { error in
                        if let error = error {
                            print("Yorum silinemedi: \(error.localizedDescription)")
                        } else {
                            print("Yorum başarıyla silindi!")
                            DispatchQueue.main.async {
                                self.comments.remove(at: index)
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
    }

    // MARK: - TableView Delegate & DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let comment = comments[indexPath.row]
        
        cell.textLabel?.text = comment.comment
        cell.detailTextLabel?.text = comment.username

        // Sadece giriş yapan kullanıcıya ait yorumlar için silme butonu göster
        if let user = Auth.auth().currentUser, user.uid == comment.userId {
            let deleteButton = UIButton(type: .system)
            deleteButton.setTitle("Sil", for: .normal)
            deleteButton.addTarget(self, action: #selector(deleteComment(_:)), for: .touchUpInside)
            deleteButton.tag = indexPath.row
            deleteButton.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(deleteButton)
            
            // Silme butonunun konumunu ayarla
            NSLayoutConstraint.activate([
                deleteButton.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -15),
                deleteButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
            ])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Hücrenin seçimini kaldır
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
