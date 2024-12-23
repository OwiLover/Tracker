//
//  CustomSpacing.swift
//  Tracker
//
//  Created by Owi Lover on 11/21/24.
//

import Foundation

class CustomSpacing {
    let leftInset: CGFloat
    let rightInset: CGFloat
    let topInset: CGFloat
    let elementHeight: CGFloat
    
    init(leftInset: CGFloat, rightInset: CGFloat, topInset: CGFloat, elementHeight: CGFloat) {
        self.leftInset = leftInset
        self.rightInset = rightInset
        self.topInset = topInset
        self.elementHeight = elementHeight
    }
}
