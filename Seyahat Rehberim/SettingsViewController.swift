//
//  SettingsViewController.swift
//  Seyahat Rehberim
//
//  Created by Görkem Karagöz on 22.11.2024.
//

import UIKit

class SettingsViewController: UIViewController {

    var navigationTitle: String? // Menüden gelen başlık
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Navigation bar başlığı ayarla
        self.title = navigationTitle
    }
}
