//
//  TestNetworking.swift
//  PerformanceCoreDataTests
//
//  Created by Gagan Vishal on 2020/01/09.
//  Copyright © 2020 Gagan Vishal. All rights reserved.
//

import XCTest
@testable import PerformanceCoreData

class TestNetworking: XCTestCase {

    var networkCommunicator: Networking!
    override func setUp() {
        networkCommunicator = Networking()
    }

    override func tearDown() {
        networkCommunicator =  nil
    }

    //MARK:- Test Repo List
    func testEarthQuakeListFetch()
    {
        let expectationObeject = expectation(description: "Fetch Contributers")
        var fakeModel: EarthquakeModel?
        self.networkCommunicator.getEarthqaukeData(value: EarthquakeModel.self) { (result) in
            switch result {
             case .success(let item):
                      fakeModel = item
            case .failuer(_):
                break
            }
            expectationObeject.fulfill()
        }
        waitForExpectations(timeout: 5.0, handler: nil)
        XCTAssertNotNil(fakeModel)
    }
}
