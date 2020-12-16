//
//  RandomiserViewController.swift
//  CoreCampAppTeamA
//
//  Created by Volodymyr Ostapyshyn on 16.10.2020.
//

import GoogleSignIn
import UIKit

class RandomiserViewController: UIViewController, GIDSignInDelegate {
    //  MARK: - IBOutlets and varibiables

    @IBOutlet var openXLSButton: UIButton!
    @IBOutlet var getButton: UIButton!
    @IBOutlet var pickThreeWinnersButton: UIButton!
    @IBOutlet var pickFiveWinnersButton: UIButton!
    @IBOutlet var pickOneWinnerButton: UIButton!

    @IBOutlet var mainView: UIView! {
        didSet {
            setShadowAndCornerRadius(for: mainView)
        }
    }

    @IBOutlet var shadowView: UIView! {
        didSet {
            setShadowAndCornerRadius(for: shadowView)
        }
    }

    @IBOutlet var sheetLinkTextField: UITextField!
    @IBOutlet var sheetNameTextField: UITextField!

    @IBOutlet var tableView: UITableView!

    let signInButton = GIDSignInButton()
    var participants: [Participant] = []

    // MARK: - Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self

        setRoundCorners()

        tableView.layer.cornerRadius = 13
        configureGoogleSignIn()
        view.addSubview(signInButton)
        configureSignInButton()
    }

    private func setRoundCorners() {
        openXLSButton.roundCorners(corners: .allCorners)
        getButton.roundCorners(corners: .allCorners)
        pickOneWinnerButton.roundCorners(corners: .allCorners)
        pickThreeWinnersButton.roundCorners(corners: .allCorners)
        pickFiveWinnersButton.roundCorners(corners: .allCorners)
    }

    private func setShadowAndCornerRadius(for view: UIView) {
        view.layer.cornerRadius = 13

        view.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 20

        view.layer.shouldRasterize = true
    }

    private func displayWinners(amount: Int, participants: [Participant]) {
        if participants.isEmpty {
            AlertHelper.showAlert(title: "Error", message: "List of participants is empty.", over: self)
            print("List of participants is empty.")
            return
        }
        let winners = getNamesOfParticipants(participants)
        let dvc = storyboard?.instantiateViewController(identifier: "WinnersViewController") as! WinnersViewController
        dvc.winnersList = pickRandom(amount, from: winners)

        present(dvc, animated: true, completion: nil)
    }

    func configureGoogleSignIn() {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().scopes = GoogleSheetManager.shared.scopes
        GIDSignIn.sharedInstance().restorePreviousSignIn()
    }

    func configureSignInButton() {
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        signInButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        signInButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        signInButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -70).isActive = true
    }

    func getNamesOfParticipants(_ participants: [Participant]) -> [String] {
        var names: [String] = []
        for participant in participants {
            names.append(participant.name)
        }
        return names
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            AlertHelper.showAlert(title: "Authentication Error", message: error.localizedDescription, over: self)
            GoogleSheetManager.shared.service.authorizer = nil
        } else {
            signInButton.isHidden = true
            GoogleSheetManager.shared.service.authorizer = user.authentication.fetcherAuthorizer()
        }
    }

    // MARK: - IBActions

    @IBAction func getButtonPressed() {
        if let name = sheetNameTextField.text, !name.isEmpty {
            GoogleSheetManager.shared.sheetName = name
        } else {
            GoogleSheetManager.shared.sheetName = "Аркуш1"
        }
        print(GoogleSheetManager.shared.sheetName)
        tableView.reloadData()
    }

    @IBAction func pickOneWinnerButtonPressed() {
        displayWinners(amount: 1, participants: participants)
    }

    @IBAction func pickThreeWinnersButtonPressed() {
        displayWinners(amount: 3, participants: participants)
    }

    @IBAction func pickFiveWinnersButtonPressed() {
        displayWinners(amount: 5, participants: participants)
    }

    @IBAction func openXLSButtonButtonPressed() {
        guard let link = sheetLinkTextField.text, !link.isEmpty else {
            print("Empty field")
            return
        }
        print(link)

        GoogleSheetManager.shared.importParticipants(url: link) { result in
            switch result {
            case let .success(participants):
                self.participants = participants
                print("Participants Count ->", participants.count, participants)
                self.tableView.reloadData()
            case let .failure(error):
                AlertHelper.showAlert(title: "Error", message: error.rawValue, over: self)
            }
        }
    }
}

// MARK: - Extensions

extension RandomiserViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return participants.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "participiants", for: indexPath)
        cell.textLabel?.text = participants[indexPath.row].name
        cell.isUserInteractionEnabled = false
        return cell
    }
}
