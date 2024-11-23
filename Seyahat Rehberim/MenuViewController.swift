//
//  MenuViewController.swift
//  Seyahat Rehberim
//

import UIKit

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
        
    let menuItems = [("Profil Ayarları", "person.crop.circle"), ("Favori Yerlerim", "star")]

    override func viewDidLoad() {
        super.viewDidLoad()

        // TableView DataSource ve Delegate atama
        tableView.dataSource = self
        tableView.delegate = self
        
        // Kaydırma özelliğini devre dışı bırak
        tableView.isScrollEnabled = false
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        // Uyarı mesajı oluştur
        let alert = UIAlertController(title: "Çıkış Yap", message: "Hesabınızdan çıkmak istediğinize emin misiniz?", preferredStyle: .alert)
        
        // Tamam butonunu ekle
        let confirmAction = UIAlertAction(title: "Tamam", style: .destructive) { _ in
            // Segue'yi gerçekleştir
            self.performSegue(withIdentifier: "toLoginVC", sender: nil)
        }
        
        // İptal butonunu ekle
        let cancelAction = UIAlertAction(title: "İptal", style: .cancel, handler: nil)
        
        // Butonları uyarıya ekle
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        // Uyarıyı göster
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - TableView DataSource
      
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
      
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let (title, imageName) = menuItems[indexPath.row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as? MenuViewCell else {
            return UITableViewCell()
        }
        
        cell.titleLabel.text = title
        
        // SF Symbols ile storyboard'da ayarlanmışsa ekstra kod yazmaya gerek yok
        cell.iconImageView.image = UIImage(systemName: imageName)
        
        return cell
    }

    
    // MARK: - TableView Delegate
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            // Profil Ayarları ekranına yönlendirme
            print("Profil Ayarları seçildi.")
            performSegue(withIdentifier: "toProfileVc", sender: indexPath)
        } else if indexPath.row == 1 {
            // Favori Yerlerim ekranına yönlendirme
            print("Favori Yerlerim seçildi.")
            performSegue(withIdentifier: "toFavouritesVc", sender: indexPath)
        }
    }
    
    // MARK: - Segue Preparation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = sender as? IndexPath {
            let selectedMenuItem = menuItems[indexPath.row].0 // Menü öğesinin başlığını al
            
            if segue.identifier == "toProfileVc",
               let destinationVC = segue.destination as? ProfileViewController {
                destinationVC.navigationTitle = selectedMenuItem // Başlığı aktar
            } else if segue.identifier == "toFavouritesVc",
                      let destinationVC = segue.destination as? FavouritesViewController {
                destinationVC.navigationTitle = selectedMenuItem // Başlığı aktar
            }
        }
    }
        
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60 // İstediğin yüksekliği belirle
    }
    
}
