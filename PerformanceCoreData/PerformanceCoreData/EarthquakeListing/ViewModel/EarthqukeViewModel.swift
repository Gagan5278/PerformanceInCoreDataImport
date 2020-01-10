//
//  EarthqukeViewModel.swift
//  PerformanceCoreData
//
//  Created by Gagan Vishal on 2020/01/01.
//  Copyright © 2020 Gagan Vishal. All rights reserved.
//

import Foundation
import CoreData

protocol EarthquakeProprtyProtocol {
    var earthquakeItem: Properties {get}
    var humanReadableDate: String {get}
    var getRoundedMagnitude: Float {get}
    var getName: String {get}
}

extension Properties: EarthquakeProprtyProtocol {
    var earthquakeItem: Properties {
        return self
    }
    var getName: String {
        return self.properties.place
    }
    
    var getRoundedMagnitude: Float {
        return self.properties.mag.roundTo(places: 4)
    }
    
    var humanReadableDate: String {
        let doubleTimeLong = self.properties.time/100
        return doubleTimeLong.toHumanReadable
    }
}

class EarthqukeViewModel {
    
    var showLoadingHud: Bindable = Bindable(false)
    let tableCells = Bindable([EarthquakeTableViewCellType]())
    let appServerClient = Networking()
    
    // MARK: - NSFetchedResultsController
    /**
     A fetched results controller delegate to give consumers a chance to update
     the user interface when content changes.
     */
    weak var fetchedResultsControllerDelegate: NSFetchedResultsControllerDelegate?
    /**
     A fetched results controller to fetch Quake records sorted by time.
     */
    lazy var fetchedResultsController: NSFetchedResultsController<Earthquake> = {
        // Create a fetched results controller and set its fetch request, context, and delegate.
        let controller = NSFetchedResultsController(fetchRequest: Earthquake.getFetchRequest(),
                                                    managedObjectContext: CoreDataManager.sharedInstance.mainManagedContext,
                                                    sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = fetchedResultsControllerDelegate

        // Perform the fetch.
        do {
            try controller.performFetch()
        } catch {
            fatalError("Unresolved error \(error)")
        }
        return controller
    }()
    
    //MARK:- Get all records
    func getEarthquakeRecords() {
        showLoadingHud.value = true
        
        appServerClient.getEarthqaukeData(value: EarthquakeModel.self) { (result) in
            switch result {
            case .success(let model):
                //print("Model is :\(model.features)")
                guard model.features.count > 0 else {
                    /**********************MVVM******************************/
                        //self.tableCells.value = [.empty]
                    /**********************MVVM******************************/
                    self.showLoadingHud.value = false
                    return
                }
                /**********************MVVM******************************/
                  // self.tableCells.value = model.features.compactMap { .normal(cellViewModel: $0 as EarthquakeProprtyProtocol)}
                /**********************MVVM******************************/

                self.importData(properties: model.features)
            case .failuer(let error):
                print(error)
                /**********************MVVM******************************/
                    //self.tableCells.value = [.error(message:error.customDescription)]
               /**********************MVVM******************************/
            }
            //Hide hud view
            self.showLoadingHud.value = false
        }
    }

    /**********************MVVM******************************/
    enum EarthquakeTableViewCellType {
        case normal(cellViewModel: EarthquakeProprtyProtocol)
        case error(message: String)
        case empty
    }
    /**********************MVVM******************************/

    //MARK:- Import items in CoreData
    fileprivate func importData(properties: [Properties]){
        //1. Get total Count
        let totalCount = properties.count
        //2. Get Batch size
        var totalBatches = totalCount/Constants.Batch_Size.batch_size
        //3. If there is a remainder then add +1
        totalBatches += totalCount%Constants.Batch_Size.batch_size > 0 ? 1 : 0
        //4. Run a loop on totalBatches count
        for batchNumber in 0..<totalBatches {
            //determine a range for this batch
            let batchStart = batchNumber*Constants.Batch_Size.batch_size
            //Batch end
            let batchEnd = batchStart + min(Constants.Batch_Size.batch_size, totalCount - batchNumber*Constants.Batch_Size.batch_size)
            //create range
            let range = batchStart..<batchEnd
            //get items for this range
            let batchItems =  Array(properties[range])
            if !importBatch(properties: batchItems, in: CoreDataManager.sharedInstance.privateQueueContext) {
                break
            }
        }
    }
    
    //MARK:- Import items in coredata on private context
    fileprivate func importBatch(properties: [Properties], in context: NSManagedObjectContext) -> Bool {
        var isImportSuccess: Bool = false
        
        for item in properties {
           _ = Earthquake.insertNewRecord(from: item.properties, context: context)
        }
        
        if context.hasChanges {
            do {
                try context.save()
                isImportSuccess = true
            }
            catch {
                print("Core data save error :\(error)")
                isImportSuccess = false
            }
            //Clear he taskContext to free the cache and lower the memory footprint.
            context.reset()
        }
        return isImportSuccess
    }
}
