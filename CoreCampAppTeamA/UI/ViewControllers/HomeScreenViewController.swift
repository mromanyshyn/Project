//
//  HomeScreenViewController.swift
//  CoreCampAppTeamA
//
//  Created by Anton Melnychuk on 10.10.2020.
//
import UIKit

class HomeScreenViewController: UIViewController {
    // MARK: - Functions

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func openStoryboard(index: Int) {
        let storyboard = UIStoryboard(name: "NavigationScreen", bundle: nil)
        guard let viewcontroller = storyboard.instantiateViewController(withIdentifier: "NavigationViewController") as? NavigationViewController else { return }
        viewcontroller.currentViewControllerIndex = index
        viewcontroller.modalPresentationStyle = .fullScreen
        present(viewcontroller, animated: true)
    }

    // MARK: - IBActions

    @IBAction func fortuneWheelButton(_ sender: Any) {
        openStoryboard(index: 1)
    }

    @IBAction func speakersButton(_ sender: Any) {
        openStoryboard(index: 3)
    }

    @IBAction func randomizerButton(_ sender: Any) {
        openStoryboard(index: 0)
    }

    @IBAction func recruitersButton(_ sender: Any) {
        openStoryboard(index: 2)
    }
}
