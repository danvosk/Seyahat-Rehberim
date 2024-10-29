//
//  CityViewController.swift
//  Seyahat Rehberim
//
//  Created by Görkem Karagöz on 29.10.2024.
//

//import UIKit
//
//class CityViewController: UIViewController {
//
//    @IBOutlet weak var navigationBar: UINavigationBar!
//    @IBOutlet weak var cityName: UINavigationItem!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//    }
//}
import UIKit

class CityViewController: UIViewController {

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var cityName: UINavigationItem!
    
    var selectedCityName: String? // Şehrin adını alacak değişken
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Şehrin adını navigation bar'a yerleştir
        cityName.title = selectedCityName
    }
}
