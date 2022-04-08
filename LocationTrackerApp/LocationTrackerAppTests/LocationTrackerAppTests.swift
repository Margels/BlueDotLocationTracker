//
//  LocationTrackerAppTests.swift
//  LocationTrackerAppTests
//
//  Created by Martina on 06/04/22.
//

import XCTest
@testable import LocationTrackerApp
import CoreLocation

var sut: ViewController!

class LocationTrackerAppTests: XCTestCase {

    override func setUpWithError() throws {
        
        try super.setUpWithError()
        sut = ViewController()
        
    }

    override func tearDownWithError() throws {
        
        sut = nil
        try super.tearDownWithError()
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        
        self.measure {
            // Put the code you want to measure the time of here.
            
        }
    }
    
    func testLocationName() throws {
        
        // 1 - set location to Cupertino
        let cl = CLLocationCoordinate2D(latitude: 37.33019912,
                                        longitude: -122.02535325)
        
        // 2 - convert location to string
        var str = String()
        sut.convert(lat: cl.latitude, lon: cl.longitude) { string in
            str = string
            
            // 3 - check string contains location name
            XCTAssertTrue(str.contains("Cupertino"))
            XCTAssert(str.contains("Infinite Loop"))
            
        }
        
    }
    
    
    func testDistance() throws {
        
        // 1 - set locations: Piccadilly & Hard Rock Cafe London
        sut.lastLocation = CLLocationCoordinate2D(latitude: 51.50998,
                                                  longitude: -0.1337)
        let cl = CLLocation(latitude: 51.50998,
                            longitude: -0.1344)
        
        // 2 - calculate distance between locations
        let distance = sut.calculateDistance(location: cl)
        
        // 3 - result should be 48m
        XCTAssert(distance==48)
        
    }
    
    
    func testNotRecordingEvents() throws {
        
        // 1 - create two locations 6 meters apart
        sut.lastLocation = CLLocationCoordinate2D(latitude: 51.50998,
                                                  longitude: -0.1337)
        let ll = CLLocation(latitude: sut.lastLocation.latitude,
                            longitude: sut.lastLocation.longitude)
        let cl = CLLocation(latitude: 51.50998,
                            longitude: -0.1338)
        sut.events.append(ViewController.event(location: ll.coordinate,
                                               time: Date()))
        
        // 2 - call function to record event
        sut.displayMovementMessage(meters: sut.calculateDistance(location: cl), location: cl)
        
        
        // 3 - event is <10mt and should not be recorded
        XCTAssert(sut.events.count==1)
        
    }
    
    
    func testDistanceSoFar() throws {
        
        // 1 -
        sut.distance = 100
        sut.events.append(contentsOf: [ViewController.event(), ViewController.event()])
        
        // 2 -
        sut.updateDistance(meters: 50)
        
        // 3 -
        XCTAssert(sut.distance==150)
        
    }
    
    
    func testRecordingEvents() throws {
        
        // 1 - create two locations 14 meters apart
        sut.lastLocation = CLLocationCoordinate2D(latitude: 51.50998,
                                                  longitude: -0.1337)
        let ll = CLLocation(latitude: sut.lastLocation.latitude,
                            longitude: sut.lastLocation.longitude)
        let cl = CLLocation(latitude: 51.50998,
                            longitude: -0.1339)
        sut.events.append(ViewController.event(location: ll.coordinate,
                                               time: Date()))
        
        // 2 - call function to record event
        sut.displayMovementMessage(meters: sut.calculateDistance(location: cl), location: cl)
            
        // 3 - event is >10mt and should be recorded
        XCTAssert(sut.events.count>1)
        
    }
    
    
    


}
