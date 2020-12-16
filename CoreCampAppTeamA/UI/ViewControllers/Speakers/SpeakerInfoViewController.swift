//
//  EditSpeakerViewController.swift
//  CoreCampAppTeamA
//
//  Created by MacBook on 13.12.2020.
//

import UIKit

protocol UIViewControllerWithTableView {
    var tableView: UITableView! { get }
}

class SpeakerInfoViewController: UIViewController {
    // MARK: Property

    private var imagePicker: UIImagePickerController!

    var lastViewController: UIViewControllerWithTableView!
    var currentSpeaker: Speaker?
    var imageFromGallery = UIImage()
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    @IBOutlet var saveButton: UIButton!
    @IBOutlet var closeEditModalButton: UIButton!

    @IBOutlet var photo: UIImageView!

    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var departmentTextField: UITextField!
    @IBOutlet var positionTextField: UITextField!

    // MARK: Business logic

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        activityIndicator.hidesWhenStopped = true

        view.layer.borderWidth = 5
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 20

        photo.layer.masksToBounds = true
        photo.layer.borderWidth = 1.5
        photo.layer.borderColor = UIColor.purple.cgColor
        photo.layer.cornerRadius = photo.bounds.width / 2

        saveButton.roundCorners(corners: .allCorners, radius: 10)
        saveButton.backgroundColor = UIColor(named: "speakers_hue")

        if currentSpeaker != nil {
            setupEditView()
        } else {
        }
    }

    private func setupAddView() {
        titleLabel.text = "Add Speaker"
    }

    private func setupEditView() {
        guard let speaker = currentSpeaker else { return }

        if speaker.picturePath == "" {
            photo.image = UIImage()
        } else {
            FirebaseDataManager.grabImage(url: speaker.picturePath) { image in
                self.photo.image = image
            }
        }

        titleLabel.text = "Edit"
        nameTextField.text = speaker.name
        departmentTextField.text = speaker.departmentName
        positionTextField.text = speaker.positionName
    }

    private func dismissReload() {
        dismiss(animated: true, completion: nil)
        lastViewController.tableView.reloadData()
    }

    private func updateData(pictureID: String, path: String) {
        let speaker = Speaker(id: currentSpeaker?.id ?? "", name: nameTextField.text ?? "", picturePath: path, pictureID: pictureID, departmentName: departmentTextField.text ?? "", positionName: positionTextField.text ?? "")

        FirebaseDataManager.update(value: speaker)
        TableViewDataManager.instance.editSpeaker(speaker)
    }

    private func addData(pictureID: String, path: String) {
        let speaker = Speaker(name: nameTextField.text ?? "", picturePath: currentSpeaker?.picturePath ?? path, pictureID: pictureID, departmentName: departmentTextField.text ?? "", positionName: positionTextField.text ?? "")

        FirebaseDataManager.create(value: speaker)
        TableViewDataManager.instance.addSpeaker(speaker)
        imageFromGallery = UIImage()
    }

    func uploadImage(_ image: UIImage, name: String, update: Bool) {
        FirebaseDataManager.upload(photo: image, toDirectory: "speakers", withName: name) { myresult in
            switch myresult {
            case let .success(url):
                if update {
                    self.updateData(pictureID: name, path: url.absoluteString)
                } else {
                    self.addData(pictureID: name, path: url.absoluteString)
                }
                self.activityIndicator.stopAnimating()
                self.dismissReload()
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }

    // IBActions

    @IBAction func editPicturePressed(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func saveButtonPressed(_ sender: Any) {
        activityIndicator.startAnimating()
        if currentSpeaker != nil {
            if imageFromGallery == UIImage() {
                updateData(pictureID: currentSpeaker?.pictureID ?? "", path: currentSpeaker?.picturePath ?? "")
                dismissReload()
            } else {
                FirebaseDataManager.deleteImageFromStorage(withDirectory: "speakers", name: currentSpeaker?.pictureID ?? "")
                uploadImage(imageFromGallery, name: UUID().uuidString, update: true)
            }
        } else {
            if imageFromGallery == UIImage() {
                addData(pictureID: "", path: "")
                dismissReload()
            } else {
                uploadImage(imageFromGallery, name: UUID().uuidString, update: false)
            }
        }
    }

    @IBAction func closeModalPressed(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
}

// MARK: UIImagePickerControllerDelegate

extension SpeakerInfoViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        photo.image = image
        imageFromGallery = image
    }
}

// MARK: UINavigationControllerDelegate

extension SpeakerInfoViewController: UINavigationControllerDelegate {
}
