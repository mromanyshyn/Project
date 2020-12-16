//
//  WinnersViewController.swift
//  CoreCampAppTeamA
//
//  Created by MacBook on 03.11.2020.
//

import UIKit

class WinnersViewController: UIViewController {
    //  MARK: - IBOutlets and varibiables
    
    var prize: Prize?
    var winnersList: [String] = []
    var confettiView: SAConfettiView!
    var isRedirectedFromFortuneWheel: Bool?
    
    @IBOutlet var congratulationLabel: UILabel! {
        didSet {
            congratulationLabel.layer.cornerRadius = 10
            congratulationLabel.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var winnersContainerView: UIView! {
        didSet {
            winnersContainerView.layer.cornerRadius = 22
            winnersContainerView.backgroundColor = UIColor(displayP3Red: 0xFFFFFF, green: 0xFFFFFF, blue: 0xFFFFFF, alpha: 0.7)
        }
    }
    
    @IBOutlet var winnersStackView: UIStackView!
    
    // MARK: - Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(patternImage: UIImage(named: "bgBaloons") ?? UIImage())
        
        if isRedirectedFromFortuneWheel ?? false {
            guard let prize = self.prize else { return }
            congratulationLabel.text = "Congratulations!! \n you win "
            setupPriseWinningStackView(prise: prize)
        } else {
            setupWinnersStackview(winners: winnersList)
        }
        setConfetti()
    }
    
    func setConfetti() {
        confettiView = SAConfettiView(frame: view.bounds)
        confettiView.colors = [UIColor.red, UIColor.blue, UIColor.purple, UIColor.brown]
        confettiView.intensity = 0.85
        confettiView.type = .Diamond
        // For custom image
        confettiView.type = .Image(UIImage(named: "diamond")!)
        confettiView.startConfetti()
        view.addSubview(confettiView)
    }
    
    private func setupWinnersStackview(winners: [String]) {
        winnersStackView.clearStackView()
        
        for i in 0 ..< winners.count {
            // Stack view to contain placement and winner name
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.distribution = .fillProportionally
            stackView.spacing = 6
            
            let placeLabel = UILabel()
            placeLabel.textAlignment = .right
            placeLabel.text = String(i + 1) + "."
            placeLabel.font = UIFont(name: "TTHoves-Bold", size: 43.0)
            
            // stack view to set placement label on top of his frame
            let lStackView = UIStackView()
            lStackView.axis = .horizontal
            lStackView.alignment = .top
            lStackView.addArrangedSubview(placeLabel)
            stackView.addArrangedSubview(lStackView)
            
            let label = UILabel()
            label.textAlignment = .left
            label.numberOfLines = 2
            label.text = winners[i]
            label.font = UIFont(name: "TTHoves-Bold", size: 43.0)
            stackView.addArrangedSubview(label)
            
            winnersStackView.addArrangedSubview(stackView)
        }
    }
    
    private func setupPriseWinningStackView(prise: Prize) {
        winnersStackView.clearStackView()
        winnersStackView.axis = .vertical
        winnersStackView.distribution = .fill
        winnersStackView.spacing = 20
        
        if prise.picturePath != "" {
            FirebaseDataManager.grabImage(url: prise.picturePath) { image in
                
                let stackView = UIStackView()
                stackView.axis = .vertical
                stackView.distribution = .fill
                stackView.spacing = 20
                
                let label = UILabel()
                label.textAlignment = .center
                label.numberOfLines = 1
                label.text = prise.name
                label.font = UIFont(name: "TTHoves-Bold", size: 150.0)
                label.adjustsFontSizeToFitWidth = true
                label.minimumScaleFactor = 0.1
                stackView.addArrangedSubview(label)
                
                let stackView2 = UIStackView()
                
                let priseImage = UIImageView(image: image)
                priseImage.contentMode = .scaleAspectFit
                
                stackView2.addArrangedSubview(priseImage)
                
                self.winnersStackView.addArrangedSubview(stackView)
                self.winnersStackView.addArrangedSubview(stackView2)
            }
        } else {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.distribution = .fillProportionally
            stackView.spacing = 20
            
            let label = UILabel()
            label.textAlignment = .center
            label.numberOfLines = 1
            label.text = prise.name
            label.font = UIFont(name: "TTHoves-Bold", size: 150.0)
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.1
            stackView.addArrangedSubview(label)
            
            self.winnersStackView.addArrangedSubview(stackView)
        }
    }
}
