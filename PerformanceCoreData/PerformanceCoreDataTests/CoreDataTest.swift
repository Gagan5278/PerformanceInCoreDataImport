//
//  CoreDataTest.swift
//  PerformanceCoreDataTests
//
//  Created by Gagan Vishal on 2020/01/09.
//  Copyright © 2020 Gagan Vishal. All rights reserved.
//

import XCTest
@testable import PerformanceCoreData

class CoreDataTest: XCTestCase {

    override func setUp() {
    }

    override func tearDown() {
    }
    
    //MARK:- Test Save Data
    func testimportDataFrom() {
        let fakeModel = FakeData.getFakeListModel()
        let managedObject = Earthquake.insertNewRecord(from: (fakeModel?.features.first!.properties)!, context: CoreDataStackInMemory.sharedInstance.managedObjectContext)
        XCTAssertNotNil(managedObject, "Unable to save/import item in core data")
    }
    
    //MARK:- Test Search or Create
    func testSerahcAndCreateObjectIfNotExistWithIdentifier() {
        //there is no data with id '123456'
       let model = Earthquake.findOrCreateNewInstance(into: CoreDataStackInMemory.sharedInstance.managedObjectContext, for: "123456")
        //an item will be addd
        XCTAssertNotNil(model)
    }
    
    //MARK:- Test insert/create a new object
    func testCreateNewObjectInContext()
    {
       XCTAssertNotNil(Earthquake.createANewInstance(in: CoreDataStackInMemory.sharedInstance.managedObjectContext))
    }

}
