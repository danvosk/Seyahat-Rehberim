//
//  City.swift
//  Seyahat Rehberim
//
//  Created by Görkem Karagöz on 29.10.2024.
//

import Foundation
import UIKit

struct City {
    let title: String
    let image: UIImage
}

class CityData {
    static let cities: [City] = [
        City(title: "İstanbul", image: UIImage(named: "istanbul")!),
        City(title: "Ankara", image: UIImage(named: "ankara")!),
        City(title: "İzmir", image: UIImage(named: "izmir")!),
        City(title: "Antalya", image: UIImage(named: "antalya")!),
        City(title: "Muğla", image: UIImage(named: "mugla")!),
        City(title: "Mardin", image: UIImage(named: "mardin")!),
        City(title: "Nevşehir", image: UIImage(named: "nevsehir")!),
        City(title: "Bursa", image: UIImage(named: "bursa")!),
        City(title: "Çanakkale", image: UIImage(named: "canakkale")!),
        City(title: "Konya", image: UIImage(named: "konya")!),
        City(title: "Trabzon", image: UIImage(named: "trabzon")!),
        City(title: "Eskişehir", image: UIImage(named: "eskisehir")!),
        City(title: "Denizli", image: UIImage(named: "denizli")!),
        City(title: "Rize", image: UIImage(named: "rize")!)
    ]
}
