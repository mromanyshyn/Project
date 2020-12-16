//
//  RecruitersDetailsViewController.swift
//  CoreCampAppTeamA
//
//  Created by Mykhailo Romanyshyn on 16.11.2020.
//

import UIKit

class RecruitersDetailsViewController: UIViewController {
    @IBOutlet weak var recruiterNameDetail: UILabel!
    @IBOutlet weak var recruiterLevelDetail: UILabel!
    @IBOutlet weak var recruiterPhotoDetail: UIImageView!
    @IBOutlet weak var backBtn: UIButton!
    var recruiter: Recruiter?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let path = recruiter?.picturePath, path != "" {
            FirebaseDataManager.grabImage(url: path) { image in
                self.recruiterPhotoDetail.image = image
            }
        }
        recruiterLevelDetail.text = recruiter?.subtitle
        recruiterNameDetail.text = recruiter?.name
        backBtn.layer.cornerRadius = 10
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
