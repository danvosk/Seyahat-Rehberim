//
//  FavouritesViewController.swift
//  Seyahat Rehberim
//
//
import UIKit
import Firebase
import FirebaseAuth
import DZNEmptyDataSet

class FavouritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    @IBOutlet weak var favouritesTableView: UITableView!

    var favouriteLandmarks: [(documentID: String, landmarkName: String)] = [] // Favori mekan isimlerini saklıyor
    var navigationTitle: String? // Menüden gelen başlığı saklamak için

    var isLoading: Bool = true // Yüklenme durumu kontrolü

    override func viewDidLoad() {
        super.viewDidLoad()

        favouritesTableView.dataSource = self
        favouritesTableView.delegate = self
        favouritesTableView.emptyDataSetSource = self
        favouritesTableView.emptyDataSetDelegate = self
        favouritesTableView.tableFooterView = UIView() // Boş satırları gizler

        // Başlığı navigation bar'a atayın
        self.title = "Favori Yerlerim"
        
        fetchFavourites()
    }
    
    func fetchFavourites() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        let favouritesRef = db.collection("favourites").document(userID).collection("favourites")
        
        favouritesRef.getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            if let error = error {
                print("Favoriler alınırken hata oluştu: \(error.localizedDescription)")
                self.isLoading = false
                DispatchQueue.main.async {
                    self.favouritesTableView.reloadEmptyDataSet()
                }
                return
            }
            
            // Firestore'dan gelen favori yerleri ve belge ID'lerini kaydet
            self.favouriteLandmarks = snapshot?.documents.compactMap { doc in
                let documentID = doc.documentID // Belge ID'sini kaydet
                let landmarkName = doc.data()["landmarkName"] as? String ?? "Bilinmeyen Yer"
                return (documentID: documentID, landmarkName: landmarkName)
            } ?? []
            
            self.isLoading = false // Yüklenme tamamlandı
            DispatchQueue.main.async {
                self.favouritesTableView.reloadData()
                self.favouritesTableView.reloadEmptyDataSet() // Boş veri setini kontrol et
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favouriteLandmarks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavouritesCell", for: indexPath)
        let favourite = favouriteLandmarks[indexPath.row]
        cell.textLabel?.text = favourite.landmarkName // Sadece landmark adını göster
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // Seçili durumu kaldır
        let selectedPlace = favouriteLandmarks[indexPath.row].landmarkName
        print("Seçilen yer: \(selectedPlace)")
    }
    
    // Yana kaydırarak silme özelliği
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let documentID = favouriteLandmarks[indexPath.row].documentID
            
            // Firebase'den sil
            guard let userID = Auth.auth().currentUser?.uid else { return }
            let db = Firestore.firestore()
            let favouritesRef = db.collection("favourites").document(userID).collection("favourites").document(documentID)
            
            favouritesRef.delete { [weak self] error in
                if let error = error {
                    print("Favori silinirken hata oluştu: \(error.localizedDescription)")
                } else {
                    print("Favori başarıyla silindi.")
                    // Local array'den kaldır ve tableView'u güncelle
                    self?.favouriteLandmarks.remove(at: indexPath.row)
                    DispatchQueue.main.async {
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                        self?.favouritesTableView.reloadEmptyDataSet() // Boş veri setini yeniden yükle
                    }
                }
            }
        }
    }
    
    // Yana kaydırma sırasında görünen "Sil" butonunu özelleştir
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Kaldır"
    }
    
    // MARK: - DZNEmptyDataSet
    
    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
        return !isLoading && favouriteLandmarks.isEmpty // Yüklenme tamamlandıysa ve liste boşsa göster
    }

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let title = "Favorileriniz Boş"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor.darkGray
        ]
        return NSAttributedString(string: title, attributes: attributes)
    }

    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let description = "Henüz favorilere herhangi bir yer eklemediniz.\nFavorilere yer eklemek için bir yer seçin ve favorilere ekleyin!"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.lightGray
        ]
        return NSAttributedString(string: description, attributes: attributes)
    }

    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "empty_favourites") // Anlamlı bir görsel ekleyin
    }
}
