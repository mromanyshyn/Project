
import Firebase
import Kingfisher
import UIKit

class SettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //  MARK: - IBOutlets and varibiables

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var quantityTextField: UITextField!
    @IBOutlet var tableView: UITableView!

    @IBOutlet var prizePreview: UIImageView!

    public var completionHandler: (([Prize]) -> Void)?

    var docRef: DocumentReference!
    var imageFromGallery = UIImage()
    var imageURL = ""
    var prizes = [Prize]()

    let db = Firestore.firestore()

    // MARK: - Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 100
        prizePreview.contentMode = .scaleAspectFit
        prizePreview.layer.cornerRadius = prizePreview.frame.width / 2
        activityIndicator.hidesWhenStopped = true
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

    func uploadImage(_ image: UIImage, name: String) {
        FirebaseDataManager.upload(photo: image, toDirectory: "prizes", withName: name) { myresult in
            switch myresult {
            case let .success(url):
                self.addData(name: name, path: url.absoluteString)
                self.activityIndicator.stopAnimating()
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }

    func addData(name: String, path: String) {
        guard prizes.count < 10 else {
            nameTextField.text = ""
            quantityTextField.text = ""

            AlertHelper.showAlert(title: "Error", message: "You can't add more than 10 prizes", over: self)
            return
        }
        if let quantityText = quantityTextField.text,
           let quantity = Int(quantityText) {
            let newPrize = Prize(name: name, quantity: quantity, picturePath: path)
            FirebaseDataManager.create(value: newPrize)
        }
        nameTextField.text = ""
        quantityTextField.text = ""
        imageFromGallery = UIImage()
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        prizePreview.image = image
        imageFromGallery = image
    }

    // MARK: - IBActions

    @IBAction func settingsButtonPressed(_ sender: Any) {
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func addImage(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    @IBAction func addToTheListOfPrizes(_ sender: UIButton) {
        guard let name = nameTextField.text, name != "",
              let quantityText = quantityTextField.text, quantityText != "",
              let _ = Int(quantityText)
        else {
            AlertHelper.showAlert(title: "Error", message: "Please enter the name or quantity of the prizes", over: self)

            return
        }
        prizePreview.image = UIImage(named: "blackLogo")
        activityIndicator.startAnimating()
        if imageFromGallery == UIImage() {
            addData(name: name, path: "")
            activityIndicator.stopAnimating()
        } else {
            uploadImage(imageFromGallery, name: name)
        }
    }
}

// MARK: - Extensions

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return prizes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "prizes", for: indexPath) as! SettingsTableViewCell

        cell.textLabel?.numberOfLines = 0

        cell.prizeLabel.text = prizes[indexPath.row].name + " - \(prizes[indexPath.row].quantity)"
        cell.prizesImage.kf.indicatorType = .activity
        if prizes[indexPath.row].picturePath != "" {
            FirebaseDataManager.grabImage(url: prizes[indexPath.row].picturePath) { image in
                cell.prizesImage.image = image
            }
        } else {
            cell.prizesImage.image = UIImage()
        }
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print(prizes.count)
            FirebaseDataManager.delete(value: prizes[indexPath.row])
            FirebaseDataManager.deleteImageFromStorage(withDirectory: "prizes", name: prizes[indexPath.row].name)
        }
    }
}
