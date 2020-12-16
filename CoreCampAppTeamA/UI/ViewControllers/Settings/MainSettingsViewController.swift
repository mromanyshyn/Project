//
//  MainSettingsViewController.swift
//  CoreCampAppTeamA
//
//  Created by Max on 07.12.2020.
//

import FirebaseAuth
import UIKit

class MainSettingsViewController: UIViewController {
    //  MARK: - IBOutlets and varibiables

    @IBOutlet var segmentedControl: UISegmentedControl!

    var storyV = UIStoryboard(name: "FortuneWheelV", bundle: nil).instantiateViewController(withIdentifier: "Wheel")
    var storyA = UIStoryboard(name: "FortuneWheel", bundle: nil).instantiateViewController(withIdentifier: "Wheel")

    var wheels = [UIViewController]()

    // MARK: - Functions

    override func viewDidLoad() {
        super.viewDidLoad()

        wheels.append(storyA)
        wheels.append(storyV)

        // Do any additional setup after loading the view.
    }

    // MARK: - IBActions

    @IBAction func logOutButtonPressed(_ sender: Any) {
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func singoutButtonPressed(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print("Log out successed")
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }

    @IBAction func wheelChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            NavigationViewController.viewControllers[1] = wheels[0]
        case 1:
            NavigationViewController.viewControllers[1] = wheels[1]
        default:
            NavigationViewController.viewControllers[1] = wheels[0]
        }
    }
}
