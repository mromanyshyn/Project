//
//  ViewController.swift
//  CoreCampAppTeamA
//
//  Created by Maksym Horodivskyi on 10.10.2020.
//

import UIKit
import AuthenticationServices
class LoginPageController: UIViewController {
    @IBAction func singInTapped(_ sender: Any)
        
        {
            
                    let appleIDProvider = ASAuthorizationAppleIDProvider()
                let request = appleIDProvider.createRequest()
                request.requestedScopes = [.fullName, .email]
                let authorizationController = ASAuthorizationController(authorizationRequests: [request])
                authorizationController.delegate = self
                authorizationController.performRequests()
            }
            
            override func viewDidLoad() {
                super.viewDidLoad()
                // Do any additional setup after loading the view.
            }
            
        }

        extension LoginPageController: ASAuthorizationControllerDelegate {
            func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
                if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                    let userIdentifier = appleIDCredential.user
                    let fullName = appleIDCredential.fullName
                    let email = appleIDCredential.email
                    
                
                    
                    print("User id is \(userIdentifier) \n Full Name is \(String(describing: fullName)) \n Email id is \(String(describing: email))") }
                
                
                
            }
            
            func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
                print(error.localizedDescription)
            
        }


}

