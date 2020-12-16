//
//  SpinningWheelAnimator.swift
//  SwiftFortuneWheel
//
//  Created by Sherzod Khashimov on 6/4/20.
// 
//

import Foundation
import CoreGraphics

#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// Spinning animator protocol
protocol SpinningAnimatorProtocol: class, CollisionProtocol  {
    /// Layer that animates
    var layerToAnimate: SpinningAnimatable? { get }
}


/// Spinning wheel animator
class SpinningWheelAnimator: NSObject {
    
    /// Animation object
    weak var animationObject: SpinningAnimatorProtocol?
    
    /// Edge Collision Detector
    lazy var edgeCollisionDetector: CollisionDetector = CollisionDetector(animationObjectLayer: animationObject?.layerToAnimate)
    
    /// Center Collision Detector
    lazy var centerCollisionDetector: CollisionDetector = CollisionDetector(animationObjectLayer: animationObject?.layerToAnimate)
    
    /// Animation Completion Block
    var completionBlock: ((Bool) -> Void)?
    
    /// Current rotation position used to know where is last time rotation stopped
    var currentRotationPosition: CGFloat?
    
    /// Rotation direction offset
    var rotationDirectionOffset: CGFloat {
        #if os(macOS)
        return -1
        #else
        return 1
        #endif
    }
    
    /// Counts started animations
    private var startedAnimationCount: Int = 0
    
    /// Initialize spinning wheel animator
    /// - Parameter animationObject: Animation object
    init(withObjectToAnimate animationObject: SpinningAnimatorProtocol) {
        super.init()
        self.animationObject = animationObject
    }
    
    /// Start indefinite rotation animation
    /// - Parameter speed: Rotation speed, speed is equal to full rotation quantity in one second
    func addIndefiniteRotationAnimation(speed: CGFloat = 1,
                                        onEdgeCollision: ((_ progress: Double?) -> Void)? = nil,
                                        onCenterCollision: ((_ progress: Double?) -> Void)? = nil) {
        
        let fullRotationDegree: CGFloat = 360
        let speedAcceleration: CGFloat = 1
        
        prepareAllCollisionDetectorsIfNeeded(with: fullRotationDegree,
                                             speed: speed,
                                             speedAcceleration: speedAcceleration,
                                             onEdgeCollision: onEdgeCollision,
                                             onCenterCollision: onCenterCollision)
        
        let fillMode : String = CAMediaTimingFillMode.forwards.rawValue
        let starTransformAnim      = CAKeyframeAnimation(keyPath:"transform.rotation.z")
        
        starTransformAnim.values   = [0, fullRotationDegree * speed * speedAcceleration * CGFloat.pi/180 * rotationDirectionOffset]
        starTransformAnim.keyTimes = [0, 1]
        starTransformAnim.duration = 1
        
        let starRotationAnim : CAAnimationGroup = CAAnimationGroup(animations: [starTransformAnim], fillMode:fillMode)
        starRotationAnim.repeatCount = Float.infinity
        starRotationAnim.delegate = self
        animationObject?.layerToAnimate?.add(starRotationAnim, forKey:"starRotationIndefiniteAnim")
        
        startedAnimationCount += 1
        startCollisionDetectorsIfNeeded()
        
    }
    
    /// Start rotation animation
    /// - Parameters:
    ///   - fullRotationsCount: Full rotations until start deceleration
    ///   - animationDuration: Animation duration
    ///   - rotationOffset: Rotation offset
    ///   - completionBlock: Completion block
    func addRotationAnimation(fullRotationsCount: Int,
                              animationDuration: CFTimeInterval,
                              rotationOffset: CGFloat = 0.0,
                              completionBlock: ((_ finished: Bool) -> Void)? = nil,
                              onEdgeCollision: ((_ progress: Double?) -> Void)? = nil,
                              onCenterCollision: ((_ progress: Double?) -> Void)? = nil) {
        
        let rotation: CGFloat = CGFloat(fullRotationsCount) * 360.0 + rotationOffset
        
        prepareAllCollisionDetectorsIfNeeded(with: rotation,
                                             animationDuration: animationDuration,
                                             onEdgeCollision: onEdgeCollision,
                                             onCenterCollision: onCenterCollision)
        
        ////Star animation
        let starTransformAnim            = CAKeyframeAnimation(keyPath:"transform.rotation.z")
        
        if currentRotationPosition ?? 0 < rotation * rotationDirectionOffset * CGFloat.pi/180 {
            starTransformAnim.values         = [currentRotationPosition ?? 0, rotation * rotationDirectionOffset * CGFloat.pi/180]
        } else {
            starTransformAnim.values         = [rotation * rotationDirectionOffset * CGFloat.pi/180, currentRotationPosition ?? 0]
        }
        
        starTransformAnim.keyTimes       = [0, 1]
        starTransformAnim.duration       = animationDuration
        starTransformAnim.timingFunction = CAMediaTimingFunction(controlPoints: 0.165, 0.84, 0.44, 1)
        starTransformAnim.fillMode = CAMediaTimingFillMode.forwards
        starTransformAnim.isRemovedOnCompletion = false
        if completionBlock != nil {
            starTransformAnim.delegate = self
            self.completionBlock = completionBlock
        }

        animationObject?.layerToAnimate?.add(starTransformAnim, forKey:"starRotationAnim")
        
        // to fix the problem of the layer's presentation becoming nil in detectors
        edgeCollisionDetector.animationObjectLayer = animationObject?.layerToAnimate
        centerCollisionDetector.animationObjectLayer = animationObject?.layerToAnimate
        
        currentRotationPosition = rotationOffset
        startedAnimationCount += 1
        startCollisionDetectorsIfNeeded()
    }
    
    // my
    func addRotation(rotationOffset: CGFloat = 0.0){
        let rotation: CGFloat =  rotationOffset
        
        let starTransformAnim            = CAKeyframeAnimation(keyPath:"transform.rotation.z")
        starTransformAnim.values = [rotation * rotationDirectionOffset]
        
        starTransformAnim.keyTimes       = [0, 1]
        starTransformAnim.duration       = CFTimeInterval(0.00001)
        starTransformAnim.timingFunction = CAMediaTimingFunction.init(name: .linear)
        starTransformAnim.fillMode = CAMediaTimingFillMode.forwards
        starTransformAnim.isRemovedOnCompletion = false
        
        animationObject?.layerToAnimate?.add(starTransformAnim, forKey:"starRotationAnim")
        currentRotationPosition = rotationOffset
    }
    
    //my
    func addRotationAnimationAndGetFinishRotationAngle(with rotationPower: Double, from currentAngle : CGFloat) -> CGFloat{
        
        currentRotationPosition = currentAngle
        
        let rotation: CGFloat = CGFloat(rotationPower) * 2 * 360
        
        let starTransformAnim = CAKeyframeAnimation(keyPath:"transform.rotation.z")
        
        let start = currentRotationPosition ?? 0
        let finish = start + rotation * rotationDirectionOffset * CGFloat.pi/180
        starTransformAnim.values = [start, finish]
        
        currentRotationPosition = finish
        
        starTransformAnim.keyTimes       = [0, 1]
        starTransformAnim.duration       = rotationPower * 6
        starTransformAnim.timingFunction = CAMediaTimingFunction(controlPoints:  0.19, 1, 0.22, 1)
        starTransformAnim.fillMode = CAMediaTimingFillMode.forwards
        starTransformAnim.isRemovedOnCompletion = false
        
        animationObject?.layerToAnimate?.add(starTransformAnim, forKey:"starRotationAnim")
        
        print("turn -- \(currentRotationPosition?.truncatingRemainder(dividingBy: 2 * CGFloat.pi))")
        return currentRotationPosition?.truncatingRemainder(dividingBy: 2 * CGFloat.pi) ?? 0
    }
    
    /// Stops animations and collisions detectors if needed
    func stop() {
        self.animationObject?.layerToAnimate?.removeAllAnimations()
        stopCollisionDetectorsIfNeeded()
    }
}

// MARK: - CAAnimationDelegate

extension SpinningWheelAnimator: CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool){
        if let completionBlock = self.completionBlock {
            completionBlock(flag)
            self.completionBlock = nil
        }
        startedAnimationCount -= 1
        if startedAnimationCount < 1 {
            stopCollisionDetectorsIfNeeded()
        }
    }
}

// MARK: - Collision Detection Support

extension SpinningWheelAnimator: CollisionDetectable {}
