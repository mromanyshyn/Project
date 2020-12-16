//
//  SpeakersViewController.swift
//  CoreCampAppTeamA
//
//  Created by Volodymyr Ostapyshyn on 16.10.2020.
//

import UIKit

class SpeakersViewController: UIViewController {
    // MARK: IBoutlets

    @IBOutlet var addButton: UIButton!
    @IBOutlet var tableView: UITableView!

    // MARK: Business logic

    override func viewDidLoad() {
        super.viewDidLoad()
        setupColors()

        tableView.delegate = self
        tableView.dataSource = self

        checkForUpdates()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addButton.roundCorners(corners: .allCorners, radius: 10)
        tableView.reloadData()
    }

    func setupColors() {
        view.backgroundColor = UIColor(red: 0.95, green: 0.99, blue: 1, alpha: 1)
        addButton.backgroundColor = UIColor(named: "speakers_hue")
        tableView.backgroundColor = UIColor(red: 0.95, green: 0.99, blue: 1, alpha: 1)
    }

    func checkForUpdates() {
        FirebaseDataManager.readWithSnapshotListiner { (result: [Speaker]) in
            TableViewDataManager.instance.speakers = result
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: IBActions

    @IBAction func speakerSettingsButtonPressed(_ sender: Any) {
        if Reachability.isConnectedToNetwork() {
            // Alert controller when user tapped into "..." button
            let alertController = UIAlertController(title: "Settings", message: "", preferredStyle: .alert)

            let editButton = UIAlertAction(title: "Edit", style: .default, handler: { (_) -> Void in
                let buttonPosition = (sender as AnyObject).convert((sender as AnyObject).bounds.origin, to: self.tableView)
                if let indexPath = self.tableView.indexPathForRow(at: buttonPosition) {
                    let selectedSpeaker = TableViewDataManager.instance.speakers[indexPath.row]
                    let editModal = self.storyboard?.instantiateViewController(withIdentifier: "EditModalViewController") as! SpeakerInfoViewController

                    editModal.lastViewController = self
                    editModal.currentSpeaker = selectedSpeaker
                    self.present(editModal, animated: true)
                }
            })

            let deleteButton = UIAlertAction(title: "Delete", style: .destructive, handler: { (_) -> Void in
                let buttonPostion = (sender as AnyObject).convert((sender as AnyObject).bounds.origin, to: self.tableView)
                if let indexPath = self.tableView.indexPathForRow(at: buttonPostion) {
                    FirebaseDataManager.delete(value: TableViewDataManager.instance.speakers[indexPath.row])

                    FirebaseDataManager.deleteImageFromStorage(withDirectory: "speakers", name: TableViewDataManager.instance.speakers[indexPath.row].pictureID)

                    TableViewDataManager.instance.speakers.remove(at: indexPath.row)

                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }
            })

            let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) -> Void in
                self.tableView.reloadData()
            })

            alertController.addAction(editButton)
            alertController.addAction(deleteButton)
            alertController.addAction(cancelButton)

            present(alertController, animated: true, completion: nil)
        } else {
            AlertHelper.showAlert(title: "Info", message: "Please connect to the internet", over: self)
        }
    }

    @IBAction func AddButtonPressed(_ sender: UIButton) {
        if Reachability.isConnectedToNetwork() {
            print("Network is connected")

            let addModal = storyboard?.instantiateViewController(withIdentifier: "EditModalViewController") as! SpeakerInfoViewController

            addModal.lastViewController = self
            addModal.currentSpeaker = nil
            present(addModal, animated: true)
        } else {
            print("Network is not connected")
            AlertHelper.showAlert(title: "Info", message: "Please connect to the internet", over: self)
        }
    }
}

// MARK: UITableViewDelegate

extension SpeakersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TableViewDataManager.instance.speakers.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 279
    }
}

// MARK: UITableViewDataSource

extension SpeakersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "speakerCell", for: indexPath)
            as! SpeakersCell

        cell.speakerImage.kf.indicatorType = .activity

        let speaker = TableViewDataManager.instance.speakers[indexPath.row]

        if TableViewDataManager.instance.speakers[indexPath.row].picturePath != "" {
            FirebaseDataManager.grabImage(url: TableViewDataManager.instance.speakers[indexPath.row].picturePath) { image in

                cell.update(name: speaker.name, image: image, speakerDepartment: speaker.departmentName, speakerPosition: speaker.positionName)
            }
        } else {
            cell.update(name: speaker.name, image: UIImage(), speakerDepartment: speaker.departmentName, speakerPosition: speaker.positionName)
        }

        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
        return cell
    }
}

// MARK: UIViewControllerWithTableView

extension SpeakersViewController: UIViewControllerWithTableView {
}
