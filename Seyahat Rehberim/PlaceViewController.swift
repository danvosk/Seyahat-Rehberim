//
//  PlaceViewController.swift
//  Seyahat Rehberim
//
//  Created by Görkem Karagöz on 19.11.2024.
//
//
import UIKit
import Firebase

class PlaceViewController: UIViewController {

    @IBOutlet weak var textView: UITextView! // TextView bağlantısı
    
    var cityName: String? // CityViewController'dan gelen şehir adı
    var landmarkName: String? // CityViewController'dan gelen landmark adı
    var landmarkDescription: String? // Landmark açıklaması

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = landmarkName // Navigation başlığına landmark adını yaz
        displayDescription() // Açıklamayı göster
    }

    func displayDescription() {
        // Eğer landmark açıklaması varsa onu göster
        if let description = landmarkDescription {
            textView.text = description
        } else {
            textView.text = "Açıklama bulunamadı."
        }
    }
}
