//
//  ViewController.swift
//  InventORY Manager
//
//  Created by Влад Карагодин on 06.03.2025.
//

import UIKit

class LoginController: UIViewController {
    var userData: [String: String] = [:]
    
    @IBOutlet weak var passwEl: UITextField!
    @IBOutlet weak var loginEl: UITextField!
    
    @IBOutlet weak var labelGreeting: UILabel!
    @IBOutlet weak var goButton: UIButton!
    
    @IBOutlet weak var registerOrLogin: UISegmentedControl!
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task {
            self.userData = UserDefaultsManager.shared.loadUserData()
            
            if self.userData.isEmpty == false {
                goButton.isHidden = true
                loginEl.text = self.userData["login"]
                passwEl.text = self.userData["password"]
                
                goButton.isEnabled = false
                await autoLogin()
            }
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func goButtonPressed(_ sender: Any) {
        Task { @MainActor in
            let server = Server(login: loginEl.text ?? "", password: passwEl.text ?? "")
            dismissKeyboard()
            goButton.isEnabled = false
            
            if registerOrLogin.selectedSegmentIndex == 0 {
                if await (server.tryToLog()){
                    ifRegistered()
                } else {
                    labelGreeting.text = "Wrong login or password"
                    goButton.isHidden = false
                }
            } else if await (server.register()) {
                labelGreeting.text = "Registered, \(loginEl.text!)!"
                await autoLogin()
            } else {
                labelGreeting.text = "Try another login or password"
                goButton.isHidden = false
            }
            goButton.isEnabled = true
        }
    }
    
    private func ifRegistered() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MainViewController")
        
        self.navigationController?.setViewControllers([vc], animated: true)
    }

    private func autoLogin() async {
        goButtonPressed(self)
    }
}

