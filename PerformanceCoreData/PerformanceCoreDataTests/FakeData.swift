//
//  FakeData.swift
//  PerformanceCoreDataTests
//
//  Created by Gagan Vishal on 2020/01/09.
//  Copyright © 2020 Gagan Vishal. All rights reserved.
//

import Foundation
@testable import PerformanceCoreData

class FakeData {
    
    //Faking Data
    fileprivate class func createFakeListData() -> Data {
        let fakeRepoListModel = Data("""
        {
            "type": "FeatureCollection",
            "metadata": {
                "generated": 1578577479000,
                "url": "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.geojson",
                "title": "USGS All Earthquakes, Past Month",
                "status": 200,
                "api": "1.8.1",
                "count": 11171
            },
            "features": [{
                "type": "Feature",
                "properties": {
                    "mag": 0.75,
                    "place": "20km ESE of Little Lake, CA",
                    "time": 1578576880260,
                    "updated": 1578577098700,
                    "tz": -480,
                    "url": "https://earthquake.usgs.gov/earthquakes/eventpage/ci39030095",
                    "detail": "https://earthquake.usgs.gov/earthquakes/feed/v1.0/detail/ci39030095.geojson",
                    "felt": null,
                    "cdi": null,
                    "mmi": null,
                    "alert": null,
                    "status": "automatic",
                    "tsunami": 0,
                    "sig": 9,
                    "net": "ci",
                    "code": "39030095",
                    "ids": ",ci39030095,",
                    "sources": ",ci,",
                    "types": ",geoserve,nearby-cities,origin,phase-data,scitech-link,",
                    "nst": 8,
                    "dmin": 0.072969999999999993,
                    "rms": 0.23999999999999999,
                    "gap": 75,
                    "magType": "ml",
                    "type": "earthquake",
                    "title": "M 0.8 - 20km ESE of Little Lake, CA"
                },
                "geometry": {
                    "type": "Point",
                    "coordinates": [-117.7025, 35.861166699999998, 8.1199999999999992]
                },
                "id": "ci39030095"
            }]
        }
        """.utf8)
        return fakeRepoListModel
    }

    
    //MARK:- get Fake Repo model
    class func getFakeListModel() -> EarthquakeModel?
    {
        let data = FakeData.createFakeListData()
        do {
            let decoder = JSONDecoder()
            let genericModel = try decoder.decode(EarthquakeModel.self, from: data)
            return genericModel
        } catch  {
            print(error)
            return nil
        }
    }
}

