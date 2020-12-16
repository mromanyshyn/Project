//
//  ViewController.swift
//  CoreCampAppTeamA
//
//  Created by Maksym Horodivskyi on 10.10.2020.
//

import AuthenticationServices
import CryptoKit
import FirebaseAuth
import UIKit

class ViewController: UIViewController {
    //  MARK: - IBOutlets and varibiables

    @IBOutlet var signInWithAppleButton: UIButton!

    private var currentNonce: String? = ""

    // MARK: - Functions

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }

    // MARK: - IBAction methods

    @IBAction func signInButtonTapped(_ sender: Any) {
        #if targetEnvironment(simulator)
            // your simulator code
            Auth.auth().signInAnonymously { authResult, error in
                let user = authResult!.user
                if let error = error {
                    print("Sign in failed:", error.localizedDescription)

                } else {
                    print("Signed in with uid:", user.uid)
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let mainController = storyboard.instantiateViewController(identifier: "HomeScreenViewController")
                    self.view.window?.rootViewController = mainController
                }
            }

        #else
            startSignInWithAppleFlow()
        #endif

        // User is signed in to Firebase with Apple.
    }
}

// MARK: - Extensions

extension ViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { _, error in
                if error != nil {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure

                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print(error!.localizedDescription)
                    return
                }
            }
        }

        // User is signed in to Firebase with Apple.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainController = storyboard.instantiateViewController(identifier: "HomeScreenViewController")
        view.window?.rootViewController = mainController
    }
}

extension ViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}
