//
//  RegisterViewController.swift
//  Seyahat Rehberim
//
//  Created by Görkem Karagöz on 29.10.2024.
//

import UIKit

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func backButton(_ sender: Any) {
        performSegue(withIdentifier: "toLoginVc", sender: nil)
    }
    
    @IBAction func registerButton(_ sender: Any) {
        
    }
    

    
}
