//
//  EditViewController.swift
//  CoreCampAppTeamA
//
//  Created by Mykhailo Romanyshyn on 02.11.2020.
//

import UIKit

class EditViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    var tableReload: RecruitersViewController?
    private var imagePicker: UIImagePickerController!
    var rec: Recruiter?
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var editBtn: UIButton!
    @IBOutlet var closeEditModal: UIButton!
    @IBOutlet var editPhoto: UIImageView!
    @IBOutlet var editNameTxt: UITextField!
    @IBOutlet var editLevelTxt: UITextField!
    @IBOutlet var editPhoneTxt: UITextField!
    @IBOutlet var editEmailTxt: UITextField!
    @IBOutlet var editSkypeTxt: UITextField!
    @IBOutlet var editLinkTxt: UITextField!

    var imageFromGallery = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.borderWidth = 5
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 20
        activityIndicator?.hidesWhenStopped = true
        editPhoto.layer.masksToBounds = true
        editPhoto.layer.borderWidth = 1.5
        editPhoto.layer.borderColor = UIColor.purple.cgColor
        editPhoto.layer.cornerRadius = editPhoto.bounds.width / 2
        editBtn.layer.cornerRadius = 10

        if rec != nil {
            configView()
        }
    }

    private func configView() {
        guard let recruiter = rec else { return }
        editNameTxt.text = recruiter.name
        if recruiter.picturePath == "" {
            editPhoto.image = UIImage()
        } else {
            FirebaseDataManager.grabImage(url: recruiter.picturePath) { image in
                self.editPhoto.image = image
            }
        }
        editLevelTxt.text = recruiter.subtitle
        editPhoneTxt.text = recruiter.contact
        editEmailTxt.text = recruiter.email
        editSkypeTxt.text = recruiter.skype
        editLinkTxt.text = recruiter.link
    }

    @IBAction func closeModalPressed(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }

    @IBAction func editPicturePressed(_ sender: Any) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true

        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        editPhoto.image = image
        imageFromGallery = image
    }

    func dismissReload() {
        dismiss(animated: true, completion: nil)
        tableReload?.tableView.reloadData()
    }

    func uploadImage(_ image: UIImage, name: String) {
        FirebaseDataManager.upload(photo: image, toDirectory: "recruiters", withName: name) { myresult in
            switch myresult {
            case let .success(url):
                self.addData(pictureID: name, path: url.absoluteString)
                self.activityIndicator?.stopAnimating()
                self.dismissReload()
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }

    func addData(pictureID: String, path: String) {
        let editRecruiter = Recruiter(id: rec?.id ?? "", name: editNameTxt.text ?? "", picturePath: path, pictureID: pictureID, subtitle: editLevelTxt.text ?? "", contact: editPhoneTxt.text ?? "", link: editLinkTxt.text ?? "", email: editEmailTxt.text ?? "", skype: editSkypeTxt.text ?? "")
        FirebaseDataManager.update(value: editRecruiter)
        TableViewDataManager.instance.editRecruiter(editRecruiter)
    }

    @IBAction func editRecruiterPressed(_ sender: Any) {
        activityIndicator?.startAnimating()

        if imageFromGallery == UIImage() {
            addData(pictureID: rec?.pictureID ?? "", path: rec?.picturePath ?? "")
            dismissReload()
        } else {
            FirebaseDataManager.deleteImageFromStorage(withDirectory: "recruiters", name: rec?.pictureID ?? "")
            uploadImage(imageFromGallery, name: UUID().uuidString)
        }
    }
}
