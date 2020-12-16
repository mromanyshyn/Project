//
//  AddViewController.swift
//  CoreCampAppTeamA
//
//  Created by Mykhailo Romanyshyn on 02.11.2020.
//

import UIKit

class AddViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var tableReload: RecruitersViewController?

    private var imagePicker: UIImagePickerController!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var addRecruiterImage: UIImageView!
    @IBOutlet weak var addRecruiterPressed: UIButton!
    @IBOutlet weak var recruiterNameTxt: UITextField!
    @IBOutlet weak var  recruiterLevelTxt: UITextField!
    @IBOutlet weak var  recruiterPhoneTxt: UITextField!
    @IBOutlet weak var  recruiterEmailTxt: UITextField!
    @IBOutlet weak var  recruiterSkypeTxt: UITextField!
    @IBOutlet weak var  recruiterLinkTxt: UITextField!

    var imageFromGallery = UIImage()

    var imageURL = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layer.borderWidth = 5
        self.view.layer.borderColor = UIColor.lightGray.cgColor
        self.view.layer.cornerRadius = 20
        activityIndicator?.hidesWhenStopped = true
        addRecruiterImage.layer.masksToBounds = true
        addRecruiterImage.layer.borderWidth = 1.5
        addRecruiterImage.layer.borderColor = UIColor.purple.cgColor
        addRecruiterImage.layer.cornerRadius = addRecruiterImage.bounds.width / 2
        addRecruiterPressed.layer.cornerRadius = 10
    }

    @IBAction func closeModalPressed(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }

    @IBAction func addPictureClick(_ sender: Any) {
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }

    func addData(pictureID: String, path: String) {
        let addRecruiter = Recruiter(name: recruiterNameTxt.text ?? "", picturePath: path, pictureID: pictureID, subtitle: recruiterLevelTxt.text ?? "", contact: recruiterPhoneTxt.text ?? "", link: recruiterLinkTxt.text ?? "", email: recruiterEmailTxt.text ?? "", skype: recruiterSkypeTxt.text ?? "")
        FirebaseDataManager.create(value: addRecruiter)
        TableViewDataManager.instance.addRecruiter(addRecruiter)
        imageFromGallery = UIImage()
    }

    func uploadImage(_ image: UIImage, name: String) {
        FirebaseDataManager.upload(photo: image, toDirectory: "recruiters", withName: name) { myresult in
            switch myresult {
            case let .success(url):
                self.addData(pictureID: name, path: url.absoluteString)
                self.activityIndicator.stopAnimating()
                self.dismissReload()
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        addRecruiterImage.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        imageFromGallery = image
    }

    func dismissReload() {
        dismiss(animated: true, completion: nil)
        tableReload?.tableView.reloadData()
    }

    @IBAction func addRecruiterPressed(_ sender: Any) {
        activityIndicator?.startAnimating()
        if imageFromGallery == UIImage() {
            addData(pictureID: "", path: "")
            dismissReload()
        } else {
            uploadImage(imageFromGallery, name: UUID().uuidString)
        }
    }
}
