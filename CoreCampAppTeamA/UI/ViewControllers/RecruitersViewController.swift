//
//  RecruitersViewController.swift
//  CoreCampAppTeamA
//
//  Created by Volodymyr Ostapyshyn on 16.10.2020.
//

import Kingfisher
import UIKit

class RecruitersViewController: UIViewController {
    //  MARK: - IBOutlets and varibiables

    @IBOutlet weak var addRecruiterBtn: UIButton!
    @IBOutlet weak var recruiterDataView: UIView!
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        addRecruiterBtn.layer.cornerRadius = 10
        recruiterDataView.backgroundColor = UIColor(red: 0.95, green: 0.99, blue: 1, alpha: 1)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(red: 0.95, green: 0.99, blue: 1, alpha: 1)
        checkForUpdates()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is AddViewController {
            let vc = segue.destination as? AddViewController
            vc?.tableReload = self
        }

        if segue.destination is EditViewController {
            let vc = segue.destination as? EditViewController
            vc?.tableReload = self
        }
        guard segue.identifier == "showDetails" else { return }
        guard let destVC = segue.destination as? RecruitersDetailsViewController else { return }
        guard let cell = sender as? UITableViewCell,
              let indexPath = tableView.indexPath(for: cell) else { return }
        let rec = TableViewDataManager.instance.recruiters[indexPath.row]
        destVC.recruiter = rec
    }

    func checkForUpdates() {
        FirebaseDataManager.readWithSnapshotListiner { (result: [Recruiter]) in
            TableViewDataManager.instance.recruiters = result
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    func loadData() {
        FirebaseDataManager.read { (result: [Recruiter]) in
            TableViewDataManager.instance.recruiters = result
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - IBActions

    @IBAction func AddRecruiterTap(_ sender: UIButton) {
        if Reachability.isConnectedToNetwork() {
            print("Network is connected")
            performSegue(withIdentifier: "add", sender: sender)
        } else {
            print("Network is not connected")
            AlertHelper.showAlert(title: "Info", message: "Please connect to the internet", over: self)
        }
    }

    @IBAction func configurationBtnPressed(_ sender: Any) {
        if Reachability.isConnectedToNetwork() {
            print("Network is connected")
            let alertController = UIAlertController(title: "Settings", message: "", preferredStyle: .alert)

            let editButton = UIAlertAction(title: "Edit", style: .default, handler: { (_) -> Void in
                let buttonPostion = (sender as AnyObject).convert((sender as AnyObject).bounds.origin, to: self.tableView)
                if let indexPath = self.tableView.indexPathForRow(at: buttonPostion) {
                    let item = TableViewDataManager.instance.recruiters[indexPath.row]
                    let editModal = self.storyboard?.instantiateViewController(withIdentifier: "EditModalViewController") as! EditViewController
                    editModal.tableReload = self
                    editModal.rec = item
                    self.present(editModal, animated: true)
                }
            })

            let deleteButton = UIAlertAction(title: "Delete", style: .destructive, handler: { (_) -> Void in
                let buttonPostion = (sender as AnyObject).convert((sender as AnyObject).bounds.origin, to: self.tableView)
                if let indexPath = self.tableView.indexPathForRow(at: buttonPostion) {
                    FirebaseDataManager.delete(value: TableViewDataManager.instance.recruiters[indexPath.row])

                    FirebaseDataManager.deleteImageFromStorage(withDirectory: "recruiters", name: TableViewDataManager.instance.recruiters[indexPath.row].pictureID)

                    TableViewDataManager.instance.recruiters.remove(at: indexPath.row)
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
            print("Network is not connected")
            AlertHelper.showAlert(title: "Info", message: "Please connect to the internet", over: self)
        }
    }
}

// TableView Function

// MARK: - Extensions

extension RecruitersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TableViewDataManager.instance.recruiters.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 279
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OlhaRecruiter", for: indexPath)
            as! TableViewCell

        cell.recruitersCellImage.kf.indicatorType = .activity
        let recruiter = TableViewDataManager.instance.recruiters[indexPath.row]
        if TableViewDataManager.instance.recruiters[indexPath.row].picturePath != "" {
            FirebaseDataManager.grabImage(url: TableViewDataManager.instance.recruiters[indexPath.row].picturePath) { image in

                cell.update(name: recruiter.name, image: image, subtitle: recruiter.subtitle, contact: recruiter.contact, qr: UIImage(), link: recruiter.link, email: recruiter.email, skype: recruiter.skype)
                cell.showQrCode()
            }
        } else {
            cell.update(name: recruiter.name, image: UIImage(), subtitle: recruiter.subtitle, contact: recruiter.contact, qr: UIImage(), link: recruiter.link, email: recruiter.email, skype: recruiter.skype)
        }
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
        return cell
    }
}
