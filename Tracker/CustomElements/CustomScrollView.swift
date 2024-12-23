//
//  CustomScrollView.swift
//  Tracker
//
//  Created by Owi Lover on 11/30/24.
//

import UIKit

final class CustomScrollView: UIScrollView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        self.endEditing(true)
    }
}
