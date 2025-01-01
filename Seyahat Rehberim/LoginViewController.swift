//
//  LoginViewController.swift
//  Seyahat Rehberim
//
//  Created by Görkem Karagöz on 29.10.2024.
//

//import UIKit
//import FirebaseAuth
//import FirebaseFirestore
//
//class LoginViewController: UIViewController, UITextFieldDelegate {
//
//    @IBOutlet weak var usernameTextField: UITextField!
//    @IBOutlet weak var passwordTextField: UITextField!
//    @IBOutlet weak var loginButton: UIButton!
//
//    // Firestore referansı
//    let db = Firestore.firestore()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        configureTextFields()
//
//        // Klavyeyi kapatmak için dokunmayı algıla
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
//        view.addGestureRecognizer(tapGesture)
//
//        // TextField'ların delegelerini ayarla
//        usernameTextField.delegate = self
//        passwordTextField.delegate = self
//    }
//
//    @IBAction func loginButtonTapped(_ sender: Any) {
//        guard let username = usernameTextField.text, !username.isEmpty,
//              let password = passwordTextField.text, !password.isEmpty else {
//            showAlert(title: "Hata", message: "Kullanıcı adı ve şifre boş olamaz.")
//            return
//        }
//
//        // Kullanıcı adıyla e-posta bulma işlemi
//        db.collection("users").whereField("username", isEqualTo: username).getDocuments { [weak self] (snapshot, error) in
//            guard let self = self else { return }
//
//            if let error = error {
//                self.showAlert(title: "Hata", message: "Kullanıcı bulunamadı: \(error.localizedDescription)")
//                return
//            }
//
//            // Kullanıcı e-posta adresini al
//            if let document = snapshot?.documents.first,
//               let email = document.data()["email"] as? String {
//
//                // Firebase Authentication ile giriş yap
//                Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
//                    if let error = error {
//                        self.showAlert(title: "Hata", message: "Giriş yapılamadı: \(error.localizedDescription)")
//                        return
//                    }
//
//                    // Giriş başarılı
//                    self.performSegue(withIdentifier: "toMainVc", sender: nil)
//                }
//            } else {
//                self.showAlert(title: "Hata", message: "Kullanıcı adı veya şifre hatalı.")
//            }
//        }
//    }
//
//    @IBAction func registerButtonTapped(_ sender: Any) {
//        performSegue(withIdentifier: "toRegisterVc", sender: nil)
//    }
//
//    func showAlert(title: String, message: String) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
//        present(alert, animated: true, completion: nil)
//    }
//
//    // MARK: - Klavyeyi kapatma
//    @objc func dismissKeyboard() {
//        view.endEditing(true) // Klavyeyi kapatır
//    }
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder() // Klavyeyi kapatır
//        return true
//    }
//
//    // MARK: - TextField Tasarımı
//    private func configureTextFields() {
//        configureTextField(usernameTextField, placeholder: "Kullanıcı Adı")
//        configureTextField(passwordTextField, placeholder: "Parola")
//        passwordTextField.isSecureTextEntry = true
//    }
//
//    private func configureTextField(_ textField: UITextField, placeholder: String) {
//        textField.placeholder = placeholder
//        textField.backgroundColor = UIColor.black.withAlphaComponent(0.05) // Hafif gri arka plan
//        textField.layer.cornerRadius = 10 // Köşe yuvarlatma
//        textField.layer.borderWidth = 0 // Çerçeve yok
//        textField.textAlignment = .left // Yazılar solda hizalı
//        textField.font = UIFont.systemFont(ofSize: 16) // Yazı boyutu
//        textField.clearButtonMode = .whileEditing // Silme butonu
//        textField.frame.size.height = 50 // Yükseklik
//    }
//}

//  LoginViewController.swift
//  Seyahat Rehberim
//
//  Created by Görkem Karagöz on 29.10.2024.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var orLabel: UILabel! // Or eklemek için bir UILabel
    
    // Firestore referansı
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextFields()
        configureOrLabel()

        // Klavyeyi kapatmak için dokunmayı algıla
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)

        // TextField'ların delegelerini ayarla
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }

    @IBAction func loginButtonTapped(_ sender: Any) {
        guard let username = usernameTextField.text, !username.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(title: "Hata", message: "Kullanıcı adı ve şifre boş olamaz.")
            return
        }

        // Kullanıcı adıyla e-posta bulma işlemi
        db.collection("users").whereField("username", isEqualTo: username).getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }

            if let error = error {
                self.showAlert(title: "Hata", message: "Kullanıcı bulunamadı: \(error.localizedDescription)")
                return
            }

            // Kullanıcı e-posta adresini al
            if let document = snapshot?.documents.first,
               let email = document.data()["email"] as? String {

                // Firebase Authentication ile giriş yap
                Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                    if let error = error {
                        self.showAlert(title: "Hata", message: "Giriş yapılamadı: \(error.localizedDescription)")
                        return
                    }

                    // Giriş başarılı
                    self.performSegue(withIdentifier: "toMainVc", sender: nil)
                }
            } else {
                self.showAlert(title: "Hata", message: "Kullanıcı adı veya şifre hatalı.")
            }
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

    // MARK: - Klavyeyi kapatma
    @objc func dismissKeyboard() {
        view.endEditing(true) // Klavyeyi kapatır
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Klavyeyi kapatır
        return true
    }

    // MARK: - TextField Tasarımı
    private func configureTextFields() {
        configureTextField(usernameTextField, placeholder: "Kullanıcı Adı", imageName: "person.fill")
        configureTextField(passwordTextField, placeholder: "Parola", imageName: "lock.fill")
        passwordTextField.isSecureTextEntry = true
    }

    private func configureTextField(_ textField: UITextField, placeholder: String, imageName: String) {
        textField.placeholder = placeholder
        textField.backgroundColor = UIColor.black.withAlphaComponent(0.05) // Hafif gri arka plan
        textField.layer.cornerRadius = 10 // Köşe yuvarlatma
        textField.layer.borderWidth = 0 // Çerçeve yok
        textField.textAlignment = .left // Yazılar solda hizalı
        textField.font = UIFont.systemFont(ofSize: 16) // Yazı boyutu
        textField.clearButtonMode = .whileEditing // Silme butonu
        textField.frame.size.height = 50 // Yükseklik
        
        // Sol tarafta ikon ekle
        let iconSize: CGFloat = 24 // İkon boyutu
        let iconView = UIImageView(frame: CGRect(x: 10, y: 13, width: iconSize, height: iconSize)) // Tam hizalamak için y: 13
        iconView.image = UIImage(systemName: imageName)
        iconView.tintColor = .gray
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50)) // Geniş padding için width: 50
        paddingView.addSubview(iconView)
        textField.leftView = paddingView
        textField.leftViewMode = .always
    }

    // MARK: - Or Label Tasarımı
    private func configureOrLabel() {
        orLabel.text = "veya"
        orLabel.textColor = .gray
        orLabel.textAlignment = .center
        orLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    }
}
