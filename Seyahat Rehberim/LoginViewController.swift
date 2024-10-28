//
//  LoginViewController.swift
//  Seyahat Rehberim
//
//  Created by Görkem Karagöz on 29.10.2024.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.isSecureTextEntry = true
    }
    
    let db = Firestore.firestore()
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        if let username = usernameTextField.text, !username.isEmpty,
           let password = passwordTextField.text, !password.isEmpty {
            
            // Kullanıcı adıyla e-posta arama
            db.collection("users").whereField("username", isEqualTo: username).getDocuments { [weak self] (snapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    self.showAlert(title: "Giriş Hatası", message: "Kullanıcı bulunamadı: \(error.localizedDescription)")
                    return
                }
                
                if let document = snapshot?.documents.first,
                   let email = document.data()["email"] as? String {
                    
                    // Firebase Authentication ile e-posta ve şifre kullanarak giriş
                    Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                        if let error = error {
                            self.showAlert(title: "Giriş Hatası", message: error.localizedDescription)
                            return
                        }
                        
                        // Giriş başarılı
                        self.performSegue(withIdentifier: "toMainVc", sender: nil)
                    }
                } else {
                    self.showAlert(title: "Hata", message: "Kullanıcı adı bulunamadı.")
                }
            }
        } else {
            showAlert(title: "Hata", message: "Kullanıcı adı ve şifre boş olamaz.")
        }
    }
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "toRegisterVc", sender: nil)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
