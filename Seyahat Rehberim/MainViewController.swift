//
//  MainViewController.swift
//  Seyahat Rehberim
//
//  Created by Görkem Karagöz on 29.10.2024.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "toLoginVC", sender: nil)
    }

}
