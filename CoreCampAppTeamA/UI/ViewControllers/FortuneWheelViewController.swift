//
//  FortuneWheelViewController.swift
//  CoreCampAppTeamA
//
//  Created by Volodymyr Ostapyshyn on 16.10.2020.
//

import FirebaseFirestore
import UIKit

class FortuneWheelViewController: UIViewController {
    //  MARK: - IBOutlets and varibiables

    let randomizerStoryboardName = "Randomizer"
    var slices: [Slice] = [] {
        didSet {
            fortuneWheel.slices = slices
        }
    }

    @IBOutlet var fortuneWheel: SwiftFortuneWheel! {
        didSet {
            fortuneWheel.configuration = getFortuneWheelConfiguration()
            updateSlices()
            fortuneWheel.spinImage = "darkBlueCenterImage"
            fortuneWheel.isSpinEnabled = false
        }
    }

    @IBOutlet var gestureRecognizer: UIPanGestureRecognizer!

    // MARK: Imitate prises(need to fix)

    let colors = [#colorLiteral(red: 0.9420027733, green: 0.7658308744, blue: 0.136086911, alpha: 1),
                  #colorLiteral(red: 0.9099512696, green: 0.4911828637, blue: 0.1421333849, alpha: 1),
                  #colorLiteral(red: 0.8836082816, green: 0.3054297864, blue: 0.2412178218, alpha: 1),
                  #colorLiteral(red: 0.8722914457, green: 0.1358049214, blue: 0.382327497, alpha: 1),
                  #colorLiteral(red: 0.578535378, green: 0.6434150338, blue: 0.6437515616, alpha: 1),
                  #colorLiteral(red: 0.07094667107, green: 0.6180127263, blue: 0.5455638766, alpha: 1),
                  #colorLiteral(red: 0.1627037525, green: 0.4977462888, blue: 0.7221878171, alpha: 1),
                  #colorLiteral(red: 0.5330474377, green: 0.2909428477, blue: 0.6148440838, alpha: 1),
                  #colorLiteral(red: 0.5619059801, green: 0.2522692084, blue: 0.4293728471, alpha: 1),
                  #colorLiteral(red: 0.2041620612, green: 0.3005031645, blue: 0.3878828585, alpha: 1),
                  #colorLiteral(red: 0.5619059801, green: 0.2522692084, blue: 0.4293728471, alpha: 1),
                  #colorLiteral(red: 0.5330474377, green: 0.2909428477, blue: 0.6148440838, alpha: 1),
                  #colorLiteral(red: 0.1627037525, green: 0.4977462888, blue: 0.7221878171, alpha: 1),
                  #colorLiteral(red: 0.07094667107, green: 0.6180127263, blue: 0.5455638766, alpha: 1),
                  #colorLiteral(red: 0.578535378, green: 0.6434150338, blue: 0.6437515616, alpha: 1),
                  #colorLiteral(red: 0.8722914457, green: 0.1358049214, blue: 0.382327497, alpha: 1),
                  #colorLiteral(red: 0.8836082816, green: 0.3054297864, blue: 0.2412178218, alpha: 1),
                  #colorLiteral(red: 0.9099512696, green: 0.4911828637, blue: 0.1421333849, alpha: 1),
                  #colorLiteral(red: 0.9420027733, green: 0.7658308744, blue: 0.136086911, alpha: 1)]
    var prizes: [Prize] = [] {
        didSet {
            updateSlices()
        }
    }

    // MARK: - Get data from firebase

    func getAllDocuments() -> [Prize] {
        var docRef: DocumentReference!
        let db = Firestore.firestore()
        var prizesArray = [Prize]()
        db.collection("Prizes").getDocuments { [self] querySnapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let dict = document.data()
                    guard let name = dict["name"], let id = dict["id"], let quantity = dict["quantity"], let picturePath = dict["picturePath"]
                    else { return }

                    let intQuantity = quantity as! Int

                    let prize = Prize(id: id as! String, name: name as! String, quantity: intQuantity, picturePath: picturePath as! String)

                    prizes.append(prize)
//
//                    print("prize added, count \(prizesArray.count)")
//                    print(prize)
                }
            }
        }

        return prizesArray
    }

    // MARK: - Businnes logic

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        prizes.removeAll()
        getAllDocuments()
    }

    func wheelFinishRotation() {
        gestureRecognizer.isEnabled = true
    }

    func wheelStartRotation() {
        gestureRecognizer.isEnabled = false
    }

    private var newTranslation = CGPoint()
    private var oldTranslation = CGPoint()
    private var startTime = Date()
    private var swipeTimeInterval = 0.0
    private var swipeChangedAngle = 0.0
    private var wheelAngle = 0.0
    private var isWheelDirectionClockwise = true {
        willSet {
            if isWheelDirectionClockwise == false && newValue == true {
                startTime = Date(timeIntervalSinceNow: 0)
            }
        }
    }

    // MARK: Gesture Recognizer

    @IBAction func swipeWheelOccured(_ sender: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began {
            // starting swipe
            startTime = Date(timeIntervalSinceNow: 0)

            newTranslation = gestureRecognizer.location(in: fortuneWheel)
            oldTranslation = newTranslation
        }

        if gestureRecognizer.state == .changed {
            // checking for clockwise rotation
            oldTranslation = newTranslation
            newTranslation = gestureRecognizer.location(in: fortuneWheel)

            // count finger current angle(rad)
            let addedAngle = getAngleInRad(a: (
                Double(newTranslation.x) - Double(fortuneWheel.center.x),
                Double(newTranslation.y) - Double(fortuneWheel.center.y)),
            b: (
                Double(oldTranslation.x) - Double(fortuneWheel.center.x),
                Double(oldTranslation.y) - Double(fortuneWheel.center.y))
            )

            wheelAngle = wheelAngle + addedAngle

            if isWheelDirectionClockwise {
                UIView.animate(withDuration: 0.0000001) {
                    self.fortuneWheel.layerToAnimate?.transform = CATransform3DMakeRotation(CGFloat(self.wheelAngle), 0.0, 0.0, 1.0)
                }
            } else {
                UIView.animate(withDuration: 0.0000001) {
                    self.fortuneWheel.layerToAnimate?.transform = CATransform3DMakeRotation(CGFloat(-self.wheelAngle), 0.0, 0.0, 1.0)
                }
            }

            swipeChangedAngle = swipeChangedAngle + getAngleInRad(a: (
                Double(newTranslation.x) - Double(fortuneWheel.center.x),
                Double(newTranslation.y) - Double(fortuneWheel.center.y)),
            b: (
                Double(oldTranslation.x) - Double(fortuneWheel.center.x),
                Double(oldTranslation.y) - Double(fortuneWheel.center.y))
            )

            let oldAngle = getAngleInRad(a: (Double(oldTranslation.x) - Double(fortuneWheel.center.x),
                                             Double(oldTranslation.y) - Double(fortuneWheel.center.y)),
                                         b: (Double(fortuneWheel.bounds.maxX) - Double(fortuneWheel.center.x),
                                             Double(fortuneWheel.center.y) - Double(fortuneWheel.center.y))
            )
            let newAngle = getAngleInRad(a: (Double(newTranslation.x) - Double(fortuneWheel.center.x),
                                             Double(newTranslation.y) - Double(fortuneWheel.center.y)),
                                         b: (Double(fortuneWheel.bounds.maxX) - Double(fortuneWheel.center.x),
                                             Double(fortuneWheel.center.y) - Double(fortuneWheel.center.y))
            )

            if newTranslation.y > fortuneWheel.center.y && oldTranslation.y < fortuneWheel.center.y {
            } else if newTranslation.y > fortuneWheel.center.y && oldTranslation.y < fortuneWheel.center.y {
            } else {
                switch newTranslation.y < fortuneWheel.center.y {
                case true:
                    if oldAngle < newAngle {
                        isWheelDirectionClockwise = false
                    } else {
                        isWheelDirectionClockwise = true
                    }
                case false:
                    if oldAngle > newAngle {
                        isWheelDirectionClockwise = false
                    } else {
                        isWheelDirectionClockwise = true
                    }
                }
            }
        }

        if gestureRecognizer.state == .ended {
            // ending swipe
            swipeTimeInterval = Date().timeIntervalSince(startTime)

            if isWheelDirectionClockwise {
                // counting rotation speed
                let speed = rad2deg(swipeChangedAngle) / swipeTimeInterval / 360
                rotateWheelWithSpeed(speed)
            } else {
                showWrongDirectionnAlert()
                oldTranslation = CGPoint()
                newTranslation = CGPoint()
            }
            swipeChangedAngle = 0.0
        }
    }

    // MARK: Angle functions

    func rad2deg(_ number: Double) -> Double {
        return number * 180 / .pi
    }

    func getAngleInRad(a: (Double, Double), b: (Double, Double)) -> Double {
        let d = (a.0 * b.0 + a.1 * b.1)

        let q = (sqrt(pow(a.0, 2) + pow(a.1, 2)) * sqrt(pow(b.0, 2) + pow(b.1, 2)))

        if q != 0 {
            var cosPhi = d / q

            if cosPhi > 1 {
                cosPhi = 1
            }
            return acos(cosPhi)
        } else {
            return 0
        }
    }

    // MARK: Main Wheel Functions

    func rotateWheelWithSpeed(_ speed: Double) {
        var wheelSpeed = speed

        switch (wheelSpeed < 0.5, wheelSpeed > 7) {
        case (true, _): // too slow
            showSlowRotationAlert()
        case (_, true):
            wheelSpeed = 7
        default:
            wheelStartRotation()
            let index = fortuneWheel.startRotationAndGetFinishIndex(from: CGFloat(wheelAngle), with: speed)

            DispatchQueue.main.asyncAfter(deadline: .now() + wheelSpeed * 6 + 1) {
                self.wheelFinishRotation()
                if index == nil {
                    self.showEdgeAlert()
                } else {
                    self.showWinningPriseView(prise: self.prizes[index!])
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
                        
                        self.prizes[index!].quantity -= 1
                        
                        FirebaseDataManager.updatePrizes(value: self.prizes[index!])
                        
                        if self.prizes[index!].quantity == 0 {
                            FirebaseDataManager.deletePrize(value: self.prizes[index!])
                            FirebaseDataManager.deleteImageFromStorage(withDirectory: "prizes", name: self.prizes[index!].name)
                            
                            prizes.remove(at: index!)
                            fortuneWheel.reloadData()
                        }
                    }
                }
            }
        }
    }

    func removePrise(priseIndex: Int) {
        if prizes.count <= 1 {
            prizes.remove(at: priseIndex)
            updateSlices()
        } else {
            updateSlices()
        }
    }

    func updateSlices() {
        let slices: [Slice] = {
            var slices: [Slice] = []
            for i in 0 ..< prizes.count {
                let sliceContent = [Slice.ContentType.text(text: prizes[i].name, preferences: getTextPreferences(textColor: .black))]
                let slice = Slice(contents: sliceContent, backgroundColor: colors[i % 10])

                slices.append(slice)
            }
            return slices
        }()

        self.slices = slices
        fortuneWheel.slices = slices
        wheelAngle = 0.0
    }

    // MARK: Alerts

    func showWrongDirectionnAlert() {
        AlertHelper.showAlert(title: "Wrong direction", message: "try again", over: self)
    }

    func showSlowRotationAlert() {
        AlertHelper.showAlert(title: "Too slow", message: "try faster", over: self)
    }

    func showEdgeAlert() {
        AlertHelper.showAlert(title: "Edge!!", message: "try again", over: self)
    }

    // MARK: Navigation

    func showWinningPriseView(prise: Prize) {
        let storyboard = UIStoryboard(name: randomizerStoryboardName, bundle: nil)
        let dvc = storyboard.instantiateViewController(identifier: "WinnersViewController") as! WinnersViewController
        dvc.isRedirectedFromFortuneWheel = true
        dvc.prize = prise
        present(dvc, animated: true, completion: nil)
    }

    // MARK: WheelConfiguration

    func getFortuneWheelConfiguration() -> SFWConfiguration {
        let sliceColorType = SFWConfiguration.ColorType.customPatternColors(colors: nil, defaultColor: .white)

        let slicePreferences = SFWConfiguration.SlicePreferences(backgroundColorType: sliceColorType, strokeWidth: 4, strokeColor: .white)

        let circlePreferences = SFWConfiguration.CirclePreferences(strokeWidth: 22, strokeColor: UIColor(red: 32 / 255, green: 93 / 255, blue: 97 / 255, alpha: 1))

        let wheelPreferences = SFWConfiguration.WheelPreferences(circlePreferences: circlePreferences, slicePreferences: slicePreferences, startPosition: .right)

        let configuration = SFWConfiguration(wheelPreferences: wheelPreferences, spinButtonPreferences: .none)

        return configuration
    }

    func getTextPreferences(textColor: UIColor) -> TextPreferences {
        let textColorType = SFWConfiguration.ColorType.customPatternColors(colors: nil, defaultColor: textColor)

        var font = UIFont.systemFont(ofSize: 9, weight: .semibold)
        var horizontalOffset: CGFloat = 0

        if let customFont = UIFont(name: "TTHoves-Black", size: 16) {
            font = customFont
            horizontalOffset = 2
        }

        var textPreferences = TextPreferences(textColorType: textColorType,
                                              font: font,
                                              verticalOffset: 10)

        textPreferences.horizontalOffset = horizontalOffset
        textPreferences.orientation = .vertical
        textPreferences.alignment = .right

        return textPreferences
    }
}
