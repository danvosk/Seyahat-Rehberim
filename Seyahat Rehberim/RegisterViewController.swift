//
//  RegisterViewController.swift
//  Seyahat Rehberim
//
//  Created by Görkem Karagöz on 29.10.2024.
//
//
//import UIKit
//import FirebaseAuth
//import FirebaseFirestore
//
//class RegisterViewController: UIViewController {
//    
//    @IBOutlet weak var nameTextField: UITextField!
//    @IBOutlet weak var surnameTextField: UITextField!
//    @IBOutlet weak var mailTextField: UITextField!
//    @IBOutlet weak var usernameTextField: UITextField!
//    @IBOutlet weak var passwordTextField: UITextField!
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//    }
//
//    @IBAction func backButton(_ sender: Any) {
//        performSegue(withIdentifier: "toLoginVc", sender: nil)
//    }
//    
//    let db = Firestore.firestore()
//    
//    @IBAction func registerButton(_ sender: Any) {
//        if let email = mailTextField.text, !email.isEmpty,
//               let password = passwordTextField.text, !password.isEmpty,
//               let username = usernameTextField.text, !username.isEmpty {
//                
//                Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
//                    guard let self = self else { return }
//                    
//                    if let error = error {
//                        self.showAlert(title: "Kayıt Hatası", message: error.localizedDescription)
//                        return
//                    }
//                    
//                    // Kullanıcı adı ve diğer bilgileri Firestore’da saklama
//                    if let userID = authResult?.user.uid {
//                        self.db.collection("users").document(userID).setData([
//                            "username": username,
//                            "email": email,
//                            "name": self.nameTextField.text ?? "",
//                            "surname": self.surnameTextField.text ?? ""
//                        ]) { error in
//                            if let error = error {
//                                print("Kullanıcı verisi kaydedilemedi: \(error.localizedDescription)")
//                            } else {
//                                self.showAlert(title: "Başarılı", message: "Kayıt başarılı, giriş yapabilirsiniz.")
//                            }
//                        }
//                    }
//                }
//            } else {
//                showAlert(title: "Hata", message: "Tüm alanlar doldurulmalıdır.")
//            }
//        
//    }
//    
//    func showAlert(title: String, message: String) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
//        present(alert, animated: true, completion: nil)
//    }
//    
//}

//
//  RegisterViewController.swift
//  Seyahat Rehberim
//
//  Created by Görkem Karagöz on 29.10.2024.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func backButton(_ sender: Any) {
        performSegue(withIdentifier: "toLoginVc", sender: nil)
    }
    
    @IBAction func registerButton(_ sender: Any) {
        guard let email = mailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let username = usernameTextField.text, !username.isEmpty else {
            showAlert(title: "Hata", message: "Tüm alanlar doldurulmalıdır.")
            return
        }
        
        checkIfUsernameOrEmailExists(username: username, email: email) { [weak self] exists in
            guard let self = self else { return }
            
            if exists {
                self.showAlert(title: "Kayıt Hatası", message: "Kullanıcı adı veya e-posta zaten kullanımda.")
            } else {
                self.createUser(email: email, password: password, username: username)
            }
        }
    }
    
    private func checkIfUsernameOrEmailExists(username: String, email: String, completion: @escaping (Bool) -> Void) {
        // Kullanıcı adı kontrolü
        let usernameQuery = db.collection("users").whereField("username", isEqualTo: username)
        
        usernameQuery.getDocuments { (snapshot, error) in
            if let error = error {
                print("Hata: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if let snapshot = snapshot, !snapshot.isEmpty {
                // Kullanıcı adı mevcutsa
                completion(true)
            } else {
                // E-posta kontrolü
                let emailQuery = self.db.collection("users").whereField("email", isEqualTo: email)
                
                emailQuery.getDocuments { (snapshot, error) in
                    if let error = error {
                        print("Hata: \(error.localizedDescription)")
                        completion(false)
                        return
                    }
                    
                    if let snapshot = snapshot, !snapshot.isEmpty {
                        // E-posta mevcutsa
                        completion(true)
                    } else {
                        // Ne kullanıcı adı ne de e-posta mevcut değil
                        completion(false)
                    }
                }
            }
        }
    }
    
    private func createUser(email: String, password: String, username: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Kayıt Hatası", message: error.localizedDescription)
                return
            }
            
            // Kullanıcı adı ve diğer bilgileri Firestore’da saklama
            if let userID = authResult?.user.uid {
                self.db.collection("users").document(userID).setData([
                    "username": username,
                    "email": email,
                    "name": self.nameTextField.text ?? "",
                    "surname": self.surnameTextField.text ?? ""
                ]) { error in
                    if let error = error {
                        print("Kullanıcı verisi kaydedilemedi: \(error.localizedDescription)")
                    } else {
                        self.showAlert(title: "Başarılı", message: "Kayıt başarılı, giriş yapabilirsiniz.")
                    }
                }
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
