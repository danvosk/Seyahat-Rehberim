//
//  MainViewController.swift
//  Seyahat Rehberim
//
//  Created by Görkem Karagöz on 29.10.2024.
//
//import UIKit
//
//class MainViewController: UIViewController {
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//    }
//    @IBAction func backButtonTapped(_ sender: Any) {
//        performSegue(withIdentifier: "toLoginVC", sender: nil)
//    }
//}
import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        // Uyarı oluşturma
        let alert = UIAlertController(title: "Çıkış Yap", message: "Çıkış yapmak istediğinize emin misiniz?", preferredStyle: .alert)
        
        // "Tamam" butonunu ekleme
        let confirmAction = UIAlertAction(title: "Tamam", style: .default) { [weak self] _ in
            self?.performSegue(withIdentifier: "toLoginVC", sender: nil)
        }
        
        // "İptal" butonunu ekleme
        let cancelAction = UIAlertAction(title: "İptal", style: .cancel, handler: nil)
        
        // Uyarıya butonları ekleme
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        // Uyarıyı gösterme
        present(alert, animated: true, completion: nil)
    }
}
