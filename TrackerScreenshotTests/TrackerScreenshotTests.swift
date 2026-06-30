//
//  TrackerScreenshotTests.swift
//  TrackerScreenshotTests
//
//  Created by Игорь Глебов on 28.06.2026.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerScreenshotTests: XCTestCase {

    func testViewController() {
        let vc = TrackersViewController()
        let navigationViewController = UINavigationController(rootViewController: vc)
        
        assertSnapshot(of: navigationViewController, as: .image)
    }

}
