//
//
//  CommentsViewController.swift
//  Seyahat Rehberim
//
//  Created by Görkem Karagöz on 25.11.2024.
//

//import UIKit
//import Firebase
//import FirebaseAuth
//import DZNEmptyDataSet
//
//class CommentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
//
//    private var tableView = UITableView()
//    private var commentInputView = UIView()
//    private var commentTextField = UITextField()
//    private var sendButton = UIButton(type: .system)
//    private var comments: [(username: String, comment: String, userId: String, timestamp: String)] = []
//    
//    var cityName: String?
//    var landmarkId: String?
//
//    var isLoading: Bool = true // Yüklenme durumu kontrolü
//
//    let db = Firestore.firestore()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
//        
//        // CommentCell kaydı
//        tableView.register(CommentCell.self, forCellReuseIdentifier: "CommentCell")
//        
//        // TableView hücre yüksekliği otomatik olsun
//        tableView.estimatedRowHeight = 100
//        tableView.rowHeight = UITableView.automaticDimension
//        
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.emptyDataSetSource = self
//        tableView.emptyDataSetDelegate = self
//        tableView.tableFooterView = UIView() // Boş satırları gizler
//        
//        setupUI()
//        loadComments()
//    }
//    
//    private func setupUI() {
//        // TableView ayarları
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(tableView)
//        
//        // Yorum Giriş Görünümü
//        commentInputView.backgroundColor = .secondarySystemBackground
//        commentInputView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(commentInputView)
//        
//        // Yorum metin kutusu
//        commentTextField.placeholder = "Yorum yazın..."
//        commentTextField.borderStyle = .roundedRect
//        commentTextField.translatesAutoresizingMaskIntoConstraints = false
//        commentInputView.addSubview(commentTextField)
//        
//        // Gönder butonu
//        sendButton.setTitle("Gönder", for: .normal)
//        sendButton.translatesAutoresizingMaskIntoConstraints = false
//        sendButton.addTarget(self, action: #selector(sendCommentTapped), for: .touchUpInside)
//        commentInputView.addSubview(sendButton)
//        
//        NSLayoutConstraint.activate([
//            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            tableView.bottomAnchor.constraint(equalTo: commentInputView.topAnchor),
//            
//            commentInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            commentInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            commentInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
//            commentInputView.heightAnchor.constraint(equalToConstant: 60),
//            
//            commentTextField.leadingAnchor.constraint(equalTo: commentInputView.leadingAnchor, constant: 10),
//            commentTextField.centerYAnchor.constraint(equalTo: commentInputView.centerYAnchor),
//            commentTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10),
//            commentTextField.heightAnchor.constraint(equalToConstant: 40),
//            
//            sendButton.trailingAnchor.constraint(equalTo: commentInputView.trailingAnchor, constant: -10),
//            sendButton.centerYAnchor.constraint(equalTo: commentInputView.centerYAnchor),
//            sendButton.widthAnchor.constraint(equalToConstant: 70)
//        ])
//    }
//    
//    @objc private func sendCommentTapped() {
//        guard let commentText = commentTextField.text, !commentText.isEmpty,
//              let user = Auth.auth().currentUser,
//              let cityName = cityName,
//              let landmarkId = landmarkId else {
//            print("Hata: Yorum veya gerekli veriler eksik.")
//            return
//        }
//        
//        db.collection("users").document(user.uid).getDocument { [weak self] snapshot, error in
//            guard let self = self else { return }
//            if let error = error {
//                print("Kullanıcı bilgisi alınamadı: \(error.localizedDescription)")
//                return
//            }
//            
//            if let data = snapshot?.data(), let username = data["username"] as? String {
//                let commentData: [String: Any] = [
//                    "userId": user.uid,
//                    "username": username,
//                    "comment": commentText,
//                    "timestamp": FieldValue.serverTimestamp()
//                ]
//                
//                self.db.collection("Comments").document(cityName)
//                    .collection(landmarkId)
//                    .addDocument(data: commentData) { error in
//                        if let error = error {
//                            print("Yorum eklenirken hata oluştu: \(error.localizedDescription)")
//                        } else {
//                            DispatchQueue.main.async {
//                                self.commentTextField.text = ""
//                                self.loadComments()
//                            }
//                        }
//                    }
//            }
//        }
//    }
//    
//    private func loadComments() {
//        guard let cityName = cityName, let landmarkId = landmarkId else {
//            print("Hata: Gerekli veriler eksik.")
//            return
//        }
//        
//        db.collection("Comments").document(cityName)
//            .collection(landmarkId)
//            .order(by: "timestamp", descending: false)
//            .getDocuments { [weak self] snapshot, error in
//                guard let self = self else { return }
//                if let error = error {
//                    print("Yorumlar yüklenirken hata oluştu: \(error.localizedDescription)")
//                    return
//                }
//                
//                self.comments = snapshot?.documents.compactMap { document in
//                    let data = document.data()
//                    let username = data["username"] as? String ?? "Bilinmeyen"
//                    let comment = data["comment"] as? String ?? ""
//                    let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
//                    let formattedDate = DateFormatter.localizedString(from: timestamp, dateStyle: .short, timeStyle: .short)
//                    let userId = data["userId"] as? String ?? ""
//                    return (username: username, comment: comment, userId: userId, timestamp: formattedDate)
//                } ?? []
//                
//                self.isLoading = false // Yüklenme tamamlandı
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                    self.tableView.reloadEmptyDataSet() // Boş veri setini kontrol et
//                }
//            }
//    }
//    
//    // MARK: - UITableViewDataSource
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return comments.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentCell else {
//            return UITableViewCell()
//        }
//        let comment = comments[indexPath.row]
//        cell.configure(with: comment)
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        // Hücre seçimini kaldır
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
//    
//    // MARK: - Yorum Silme
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        let comment = comments[indexPath.row]
//        if let user = Auth.auth().currentUser {
//            return comment.userId == user.uid // Yalnızca giriş yapan kullanıcının yorumları düzenlenebilir
//        }
//        return false
//    }
//    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            let alertController = UIAlertController(title: "Yorumu Sil", message: "Bu yorumu silmek istediğinizden emin misiniz?", preferredStyle: .alert)
//            
//            let confirmAction = UIAlertAction(title: "Evet", style: .destructive) { [weak self] _ in
//                guard let self = self else { return }
//                let comment = self.comments[indexPath.row]
//                guard let cityName = self.cityName, let landmarkId = self.landmarkId else { return }
//                
//                self.db.collection("Comments").document(cityName)
//                    .collection(landmarkId)
//                    .whereField("userId", isEqualTo: comment.userId)
//                    .whereField("comment", isEqualTo: comment.comment)
//                    .getDocuments { snapshot, error in
//                        if let error = error {
//                            print("Yorum silinirken hata oluştu: \(error.localizedDescription)")
//                            return
//                        }
//                        
//                        guard let document = snapshot?.documents.first else {
//                            print("Silinecek yorum bulunamadı.")
//                            return
//                        }
//                        
//                        document.reference.delete { error in
//                            if let error = error {
//                                print("Yorum silinirken hata oluştu: \(error.localizedDescription)")
//                            } else {
//                                DispatchQueue.main.async {
//                                    self.comments.remove(at: indexPath.row)
//                                    tableView.deleteRows(at: [indexPath], with: .fade)
//                                }
//                            }
//                        }
//                    }
//            }
//            
//            let cancelAction = UIAlertAction(title: "Hayır", style: .cancel, handler: nil)
//            
//            alertController.addAction(confirmAction)
//            alertController.addAction(cancelAction)
//            
//            present(alertController, animated: true, completion: nil)
//        }
//    }
//    
//    // MARK: - DZNEmptyDataSetSource
//    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
//        return !isLoading && comments.isEmpty
//    }
//
//    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
//        let title = "Henüz Yorum Yok"
//        let attributes: [NSAttributedString.Key: Any] = [
//            .font: UIFont.boldSystemFont(ofSize: 18),
//            .foregroundColor: UIColor.darkGray
//        ]
//        return NSAttributedString(string: title, attributes: attributes)
//    }
//
//    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
//        let description = "Henüz bu mekana ait bir yorum eklenmemiş.\nİlk yorumu siz yapabilirsiniz!"
//        let attributes: [NSAttributedString.Key: Any] = [
//            .font: UIFont.systemFont(ofSize: 14),
//            .foregroundColor: UIColor.lightGray
//        ]
//        return NSAttributedString(string: description, attributes: attributes)
//    }
//
//    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
//        return UIImage(named: "empty_comments")
//    }
//}

import UIKit
import Firebase
import FirebaseAuth
import DZNEmptyDataSet

class CommentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    private var tableView = UITableView()
    private var commentInputView = UIView()
    private var commentTextField = UITextField()
    private var sendButton = UIButton(type: .system)
    private var comments: [(username: String, comment: String, userId: String, timestamp: String)] = []
    
    var cityName: String?
    var landmarkId: String?

    var isLoading: Bool = true // Yüklenme durumu kontrolü

    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        configureGestureToDismissKeyboard()
        
        // CommentCell kaydı
        tableView.register(CommentCell.self, forCellReuseIdentifier: "CommentCell")
        
        // TableView hücre yüksekliği otomatik olsun
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView() // Boş satırları gizler
        
        setupUI()
        loadComments()
    }
    
    private func setupUI() {
        // TableView ayarları
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Yorum Giriş Görünümü
        commentInputView.backgroundColor = .secondarySystemBackground
        commentInputView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(commentInputView)
        
        // Yorum metin kutusu
        commentTextField.placeholder = "Yorum yazın..."
        commentTextField.borderStyle = .roundedRect
        commentTextField.translatesAutoresizingMaskIntoConstraints = false
        commentInputView.addSubview(commentTextField)
        
        // Gönder butonu
        sendButton.setTitle("Gönder", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(sendCommentTapped), for: .touchUpInside)
        commentInputView.addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: commentInputView.topAnchor),
            
            commentInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            commentInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            commentInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            commentInputView.heightAnchor.constraint(equalToConstant: 60),
            
            commentTextField.leadingAnchor.constraint(equalTo: commentInputView.leadingAnchor, constant: 10),
            commentTextField.centerYAnchor.constraint(equalTo: commentInputView.centerYAnchor),
            commentTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10),
            commentTextField.heightAnchor.constraint(equalToConstant: 40),
            
            sendButton.trailingAnchor.constraint(equalTo: commentInputView.trailingAnchor, constant: -10),
            sendButton.centerYAnchor.constraint(equalTo: commentInputView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 70)
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
                
                self.db.collection("Comments").document(cityName)
                    .collection(landmarkId)
                    .addDocument(data: commentData) { error in
                        if let error = error {
                            print("Yorum eklenirken hata oluştu: \(error.localizedDescription)")
                        } else {
                            DispatchQueue.main.async {
                                self.commentTextField.text = ""
                                self.loadComments()
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
        
        db.collection("Comments").document(cityName)
            .collection(landmarkId)
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
                    let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    let formattedDate = DateFormatter.localizedString(from: timestamp, dateStyle: .short, timeStyle: .short)
                    let userId = data["userId"] as? String ?? ""
                    return (username: username, comment: comment, userId: userId, timestamp: formattedDate)
                } ?? []
                
                self.isLoading = false // Yüklenme tamamlandı
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.tableView.reloadEmptyDataSet() // Boş veri setini kontrol et
                }
            }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentCell else {
            return UITableViewCell()
        }
        let comment = comments[indexPath.row]
        cell.configure(with: comment)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Hücre seçimini kaldır
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Yorum Silme
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let comment = comments[indexPath.row]
        if let user = Auth.auth().currentUser {
            return comment.userId == user.uid // Yalnızca giriş yapan kullanıcının yorumları düzenlenebilir
        }
        return false
    }
    
    // MARK: - Klavyeyi kapatma
    private func configureGestureToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true) // Klavyeyi kapatır
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Klavyeyi kapatır
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alertController = UIAlertController(title: "Yorumu Sil", message: "Bu yorumu silmek istediğinizden emin misiniz?", preferredStyle: .alert)
            
            let confirmAction = UIAlertAction(title: "Evet", style: .destructive) { [weak self] _ in
                guard let self = self else { return }
                let comment = self.comments[indexPath.row]
                guard let cityName = self.cityName, let landmarkId = self.landmarkId else { return }
                
                self.db.collection("Comments").document(cityName)
                    .collection(landmarkId)
                    .whereField("userId", isEqualTo: comment.userId)
                    .whereField("comment", isEqualTo: comment.comment)
                    .getDocuments { snapshot, error in
                        if let error = error {
                            print("Yorum silinirken hata oluştu: \(error.localizedDescription)")
                            return
                        }
                        
                        guard let document = snapshot?.documents.first else {
                            print("Silinecek yorum bulunamadı.")
                            return
                        }
                        
                        document.reference.delete { error in
                            if let error = error {
                                print("Yorum silinirken hata oluştu: \(error.localizedDescription)")
                            } else {
                                DispatchQueue.main.async {
                                    self.comments.remove(at: indexPath.row)
                                    tableView.deleteRows(at: [indexPath], with: .fade)
                                }
                            }
                        }
                    }
            }
            
            let cancelAction = UIAlertAction(title: "Hayır", style: .cancel, handler: nil)
            
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - DZNEmptyDataSetSource
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
        return !isLoading && comments.isEmpty
    }

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let title = "Henüz Yorum Yok"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor.darkGray
        ]
        return NSAttributedString(string: title, attributes: attributes)
    }

    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let description = "Henüz bu mekana ait bir yorum eklenmemiş.\nİlk yorumu siz yapabilirsiniz!"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.lightGray
        ]
        return NSAttributedString(string: description, attributes: attributes)
    }

    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "empty_comments")
    }
}
