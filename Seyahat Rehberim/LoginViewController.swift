//
//  LoginViewController.swift
//  Seyahat Rehberim
//
//  Created by Görkem Karagöz on 29.10.2024.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "toMainVc", sender: nil)
    }
    
    
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "toRegisterVc", sender: nil)
    }
    
    
}
