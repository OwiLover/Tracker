//
//  CustomCollectionHelperDelegate.swift
//  Tracker
//
//  Created by Owi Lover on 11/29/24.
//
import UIKit

protocol TrackerCreatorCollectionHelperDelegate: AnyObject {
    func cellWasPressed(content: String)
    
    func cellWasPressed(content: UIColor)
}
