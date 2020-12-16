//
//  SetPrizesViewController.swift
//  CoreCampAppTeamA
//
//  Created by Volodymyr Ostapyshyn on 14.11.2020.
//

import UIKit
import Firebase

class SetPrizesViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var quantityTextField: UITextField!
    @IBOutlet var tableView: UITableView!
    
    public var completionHandler: (([Prize]) -> Void)?
    var docRef: DocumentReference!
    let db = Firestore.firestore()
    
    var imageURL = ""
    var prizes = [Prize]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 100
        checkForUpdates()
    }
    
    func loadData() {
        FirebaseDataManager.read { (result: [Prize]) in
            self.prizes = result
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func checkForUpdates() {
        FirebaseDataManager.readWithSnapshotListiner { (result: [Prize]) in
            self.prizes = result
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func addToTheListOfPrizes(_ sender: UIButton) {
        if let name = nameTextField.text, let quantityText = quantityTextField.text,
           let quantity = Int(quantityText) {
            let newPrize = Prize(name: name, quantity: quantity, picturePath: imageURL)
            FirebaseDataManager.create(value: newPrize)
        }
    }
    
    @IBAction func updateTap(_ sender: UIButton) {
        FirebaseDataManager.update(value: Prize(name: "Mac", quantity: 1, picturePath: imageURL))
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
        completionHandler?(prizes)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addImage(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }

        FirebaseDataManager.upload(photo: image, name: "prizes") { myresult in
            switch myresult {
            case .success(let url):
                self.imageURL = url.absoluteString
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

extension SetPrizesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return prizes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "prizes", for: indexPath)
        cell.textLabel?.text = prizes[indexPath.row].name + " - \(prizes[indexPath.row].quantity)" + " - \(prizes[indexPath.row].picturePath)"
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(prizes[indexPath.row].id ?? "Empty")
        FirebaseDataManager.delete(value: prizes[indexPath.row])
    }
}
