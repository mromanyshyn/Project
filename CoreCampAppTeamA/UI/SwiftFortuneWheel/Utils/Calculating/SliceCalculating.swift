//
//  SliceCalculating.swift
//  SwiftFortuneWheel
//
//  Created by Sherzod Khashimov on 6/4/20.
// 
//

import Foundation
import CoreGraphics

/// Slice calculation protocol
protocol SliceCalculating {
    /// Slices
    var slices: [Slice] { get set }
}

extension SliceCalculating {
    /// Slice degree
    var sliceDegree: CGFloat {
        guard slices.count > 0 else {
            return 0
        }
        return 360.0 / CGFloat(slices.count)
    }
    
    /// Theta
    var theta: CGFloat {
        return sliceDegree * .pi / 180.0
    }
    
    /// Calculates radion for index
    /// - Parameter finishIndex: index
    /// - Returns: radia_
    func computeRadian(from finishIndex:Int) -> CGFloat {
        return CGFloat(finishIndex) * sliceDegree
    }
    
    //my
    func computeSliceIndex(from radian: CGFloat) -> Int? {
        let angle = radian
        if angle.truncatingRemainder(dividingBy: sliceDegree) == 0 {
            return nil
        }
        
        //lets find nearest slice center
        var min = CGFloat(999999999)
        var indexIfCountUp = 0
        
        for i in 0..<slices.count {
            if abs(CGFloat(i) * theta - angle) < min{
                min = abs(CGFloat(i) * theta - angle)
                indexIfCountUp = i
            }
        }
        
        //index count down(clockwise)
        switch indexIfCountUp {
        case 0:
            return 0
        default:
            return slices.count - 1 - (indexIfCountUp - 1)
        }
    }
    
    /// Segment height
    /// - Parameter radius: Radius
    /// - Returns: Segment height
    func segmentHeight(radius: CGFloat) -> CGFloat {
        return radius * (1 - cos(sliceDegree / 2 * CGFloat.pi / 180))
    }
}
