//
//  FortuneWheelViewController.swift
//  CoreCampAppTeamA
//
//  Created by Volodymyr Ostapyshyn on 16.10.2020.
//
import AVFoundation
import UIKit

class FortuneWheelViewControllerV: UIViewController, SpinWheelControlDataSource, SpinWheelControlDelegate {
    //  MARK: - IBOutlets and varibiables

    @IBOutlet var spinWheelControl: SpinWheelControl!
    @IBOutlet var spinButton: UIButton!

    let colors = [#colorLiteral(red: 0.9420027733, green: 0.7658308744, blue: 0.136086911, alpha: 1),
                  #colorLiteral(red: 0.9099512696, green: 0.4911828637, blue: 0.1421333849, alpha: 1),
                  #colorLiteral(red: 0.8836082816, green: 0.3054297864, blue: 0.2412178218, alpha: 1),
                  #colorLiteral(red: 0.8722914457, green: 0.1358049214, blue: 0.382327497, alpha: 1),
                  #colorLiteral(red: 0.578535378, green: 0.6434150338, blue: 0.6437515616, alpha: 1),
                  #colorLiteral(red: 0.07094667107, green: 0.6180127263, blue: 0.5455638766, alpha: 1),
                  #colorLiteral(red: 0.1627037525, green: 0.4977462888, blue: 0.7221878171, alpha: 1),
                  #colorLiteral(red: 0.5330474377, green: 0.2909428477, blue: 0.6148440838, alpha: 1),
                  #colorLiteral(red: 0.5619059801, green: 0.2522692084, blue: 0.4293728471, alpha: 1),
                  #colorLiteral(red: 0.2041620612, green: 0.3005031645, blue: 0.3878828585, alpha: 1)]

    var winSoundEffect: AVAudioPlayer?
    var prizes: [Prize] = []

    // MARK: - Functions

    override func viewDidLoad() {
        super.viewDidLoad()
        spinWheelControl.addTarget(self, action: #selector(spinWheelDidChangeValue), for: UIControl.Event.valueChanged)

        checkForUpdates()

        spinWheelControl.dataSource = self
        spinWheelControl.reloadData()

        spinWheelControl.delegate = self

        setRoundCorners()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }

    func checkForUpdates() {
        FirebaseDataManager.readWithSnapshotListiner { (result: [Prize]) in
            self.prizes = result
            DispatchQueue.main.async {
                self.spinWheelControl.reloadData()
            }
        }
    }

    @objc func spinWheelDidChangeValue(sender: AnyObject) {
        let index = spinWheelControl.selectedIndex
        let title = "You win \(prizes[index].name)!"
        let iconText = "🎁"
        let body = "Swiping to dismiss!"

        debugPrint(spinWheelControl.speed, "SPEED")
        if prizes.count > 1 {
            if spinWheelControl.velocity == 0 && spinWheelControl.speed < 1 {
                AlertHelper.showMessage(title: "Make a fast spin", body: body, iconImage: nil, iconText: "💨")
            } else {
                playSound()

                if prizes[index].picturePath == "" {
                    AlertHelper.showMessage(title: title, body: body, iconImage: nil, iconText: iconText)
                } else {
                    FirebaseDataManager.grabImage(url: prizes[index].picturePath) { image in
                        AlertHelper.showMessage(title: title, body: body, iconImage: image, iconText: iconText)
                    }
                }

                prizes[index].quantity -= 1
                FirebaseDataManager.update(value: prizes[index])

                if prizes[index].quantity == 0 {
                    FirebaseDataManager.delete(value: prizes[index])
                    FirebaseDataManager.deleteImageFromStorage(withDirectory: "prizes", name: prizes[index].name)
                    prizes.remove(at: index)
                }

                if prizes.count == 1 {
                    AlertHelper.showAlert(title: "Info", message: "Add more prizes!", over: self)
                }

                spinWheelControl.reloadData()
            }
        }
    }

    func numberOfWedgesInSpinWheel(spinWheel: SpinWheelControl) -> UInt {
        return UInt(prizes.count)
    }

    func wedgeForSliceAtIndex(index: UInt) -> SpinWheelWedge {
        let wedge = SpinWheelWedge()

        wedge.shape.fillColor = colors[Int(index)].cgColor
        let count = String(prizes[Int(index)].quantity)
        wedge.label.text = prizes[Int(index)].name + " " + count

        return wedge
    }

    private func setRoundCorners() {
        spinButton.roundCorners(corners: .allCorners)
    }

    func playSound() {
        let path = Bundle.main.path(forResource: "win.mp3", ofType: nil)!
        let url = URL(fileURLWithPath: path)

        do {
            winSoundEffect = try AVAudioPlayer(contentsOf: url)
            winSoundEffect?.play()
        } catch {
            debugPrint(error, "Couldn't load file")
        }
    }

    func spinWheelDidRotateByRadians(radians: Radians) {
        debugPrint("Rotating: " + String(describing: radians))
    }

    func spinWheelDidEndDecelerating(spinWheel: SpinWheelControl) {
        debugPrint("End")
    }

    // MARK: - IBActions

    @IBAction func pressSpin(_ sender: UIControl) {
        if prizes.count > 1 {
            spinWheelControl.randomSpin()
        } else {
            AlertHelper.showAlert(title: "Info", message: "Add more prizes!", over: self)
        }
    }
}
