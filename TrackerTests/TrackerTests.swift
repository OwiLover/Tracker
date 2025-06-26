//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Owi Lover on 11/5/24.
//

import XCTest
import Testing
import SnapshotTesting
@testable import Tracker


final class TrackerTests: XCTestCase {

    func testScreenShotTrackerMainScreenEmpty() {
        let viewController = TrackerViewController(trackerStorage: nil)
        
        assertSnapshot(of: viewController, as: .image(traits: .init(userInterfaceStyle: .light)))
    }
    
    func testScreenShotTrackerMainScreenWithTrackers() {
        let trackerStorageMock = TrackerStorageMock()
        let viewController = TrackerViewController(trackerStorage: trackerStorageMock)
        
        assertSnapshot(of: viewController, as: .image(traits: .init(userInterfaceStyle: .light)))
    }
    
    func testScreenShotTrackerMainScreenEmptyDarkTheme() {
        let viewController = TrackerViewController(trackerStorage: nil)
        
        assertSnapshot(of: viewController, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
    
    func testScreenShotTrackerMainScreenWithTrackersDarkTheme() {
        let trackerStorageMock = TrackerStorageMock()
        let viewController = TrackerViewController(trackerStorage: trackerStorageMock)
        
        assertSnapshot(of: viewController, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
