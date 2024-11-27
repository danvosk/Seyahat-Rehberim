//
//  RegisterViewController.swift
//  Seyahat Rehberim
//
//  Created by Görkem Karagöz on 29.10.2024.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    // Firestore referansı
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextFields()
        configureGestureToDismissKeyboard()

        // TextField'ların delegelerini ayarla
        nameTextField.delegate = self
        surnameTextField.delegate = self
        mailTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }

    @IBAction func backButton(_ sender: Any) {
        performSegue(withIdentifier: "toLoginVc", sender: nil)
    }
    
    @IBAction func registerButton(_ sender: Any) {
        view.endEditing(true) // Klavyeyi kapat
        
        guard let name = nameTextField.text, !name.isEmpty,
              let surname = surnameTextField.text, !surname.isEmpty,
              let email = mailTextField.text, !email.isEmpty,
              let username = usernameTextField.text, !username.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Hata", message: "Tüm alanlar doldurulmalıdır.")
            return
        }
        
        // Kullanıcı adı veya e-posta daha önce kullanılmış mı kontrol et
        checkIfUsernameOrEmailExists(username: username, email: email) { [weak self] exists in
            guard let self = self else { return }
            
            if exists {
                self.showAlert(title: "Kayıt Hatası", message: "Kullanıcı adı veya e-posta zaten kullanımda.")
            } else {
                self.createUser(name: name, surname: surname, email: email, username: username, password: password)
            }
        }
    }
    
    private func createUser(name: String, surname: String, email: String, username: String, password: String) {
        // Firebase Authentication ile kullanıcı oluştur
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                self.showAlert(title: "Kayıt Hatası", message: error.localizedDescription)
                return
            }
            
            // Kullanıcı başarıyla oluşturulduysa bilgileri Firestore'a kaydet
            if let userID = authResult?.user.uid {
                self.db.collection("users").document(userID).setData([
                    "name": name,
                    "surname": surname,
                    "email": email,
                    "username": username
                ]) { error in
                    if let error = error {
                        self.showAlert(title: "Hata", message: "Kullanıcı bilgileri kaydedilirken hata oluştu: \(error.localizedDescription)")
                    } else {
                        self.showAlert(title: "Başarılı", message: "Kayıt başarılı, giriş yapabilirsiniz.")
                    }
                }
            }
        }
    }
    
    private func checkIfUsernameOrEmailExists(username: String, email: String, completion: @escaping (Bool) -> Void) {
        // Firestore'da username veya email eşleşmesini kontrol et
        let usernameQuery = db.collection("users").whereField("username", isEqualTo: username)
        
        usernameQuery.getDocuments { (snapshot, error) in
            if let error = error {
                print("Hata: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            if let snapshot = snapshot, !snapshot.isEmpty {
                completion(true) // Kullanıcı adı mevcut
            } else {
                let emailQuery = self.db.collection("users").whereField("email", isEqualTo: email)
                
                emailQuery.getDocuments { (snapshot, error) in
                    if let error = error {
                        print("Hata: \(error.localizedDescription)")
                        completion(false)
                        return
                    }
                    
                    if let snapshot = snapshot, !snapshot.isEmpty {
                        completion(true) // E-posta mevcut
                    } else {
                        completion(false) // Kullanıcı adı ve e-posta kullanılabilir
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

    // MARK: - TextField Tasarımı
    private func configureTextFields() {
        configureTextField(nameTextField, placeholder: "İsim")
        configureTextField(surnameTextField, placeholder: "Soy İsim")
        configureTextField(mailTextField, placeholder: "E-posta")
        configureTextField(usernameTextField, placeholder: "Kullanıcı Adı")
        configureTextField(passwordTextField, placeholder: "Parola", isSecure: true)
    }
    
    private func configureTextField(_ textField: UITextField, placeholder: String, isSecure: Bool = false) {
        textField.placeholder = placeholder
        textField.backgroundColor = UIColor.black.withAlphaComponent(0.05) // Hafif gri arka plan
        textField.layer.cornerRadius = 10 // Köşe yuvarlatma
        textField.layer.borderWidth = 0 // Çerçeve yok
        textField.textAlignment = .left // Yazılar solda hizalı
        textField.font = UIFont.systemFont(ofSize: 16) // Yazı boyutu
        textField.clearButtonMode = .whileEditing // Silme butonu
        textField.frame.size.height = 50 // Yükseklik
        textField.isSecureTextEntry = isSecure // Parola için gizleme
    }
}
