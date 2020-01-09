//
//  IndependentPersistentStoreViewController.swift
//  CoreDataPerformance
//
//  Created by Gagan Vishal on 2019/12/09.
//  Copyright © 2019 Gagan Vishal. All rights reserved.
//

import UIKit
import CoreData

class IndependentPersistentStoreViewController: UITableViewController {
    //IBoutlets
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var importButton: UIBarButtonItem!
    //OperationQueue observer name
    let observerNameString: String = "operationCount"
    //PersistentStack Object
    var persistentStackObject: PersistentStack!
    lazy var fetchResultController : NSFetchedResultsController<DataEntity> = {
        ///create NSFetchRequest obejct
        let fetchRequest : NSFetchRequest<DataEntity> = DataEntity.getFetchRequest()
       // fetchRequest.fetchLimit = 20
        ///sort items by city name
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Constants.KeysConstants.UFO_KEY_COREDATA_SIGHTED, ascending: false)]
        var fetchController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.persistentStackObject.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        ///set delegate
        return fetchController
    }()
    //IBOutlets
    lazy var independentOperationQueue: OperationQueue = {
        let operationQueue =   OperationQueue()
        operationQueue.name = "com.independent.operation"
        operationQueue.qualityOfService = .userInitiated
        operationQueue.addObserver(self, forKeyPath: observerNameString, options: [.new, .old], context: nil)
        return operationQueue
    }()
    
    //MARK:- View Controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //1.
        initalizePersistenceStack()
        //2.
        NotificationCenter.default.addObserver(self, selector: #selector(importOperationCompleted), name: NSNotification.Name(rawValue: Constants.NotificationConstants.notificationImportOperationCompleted), object: nil)
        //3.
        setupTableDataSource()
    }
    
    //MARK:- initalize Persistence Stack
    fileprivate func initalizePersistenceStack() {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let storeURL = documentDirectory.appendingPathComponent(Constants.FileConstants.sqliteFileName)
            if let modelURL = Bundle.main.url(forResource: Constants.FileConstants.josnModelFileName, withExtension: Constants.FileConstants.josnModelFileExtension) {
                self.persistentStackObject = PersistentStack(modelURL: modelURL, storeURL: storeURL)
            }
            else {
                assert(true, "Unable to create directory")
            }
        }
        catch {
            assert(true, "Unable to create directory")
        }
    }
    
    //MARK:- Setup Table Datasource
    @objc fileprivate func setupTableDataSource() {
      print(Thread.current.isMainThread)
//       let fetchRequest : NSFetchRequest<DataEntity> = DataEntity.getFetchRequest()
//        // fetchRequest.fetchLimit = 20
//         ///sort items by city name
//         fetchRequest.sortDescriptors = [NSSortDescriptor(key: Constants.KeysConstants.UFO_KEY_COREDATA_SIGHTED, ascending: false)]
//       let fetchController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.persistentStackObject.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        let dataSource = FetchedResultsTableDataSource(tableView: self.tableView, fetchResult: self.fetchResultController)
        dataSource.configureCellBlock =  { [weak self](cell, data) in
            self?.display(data: data, in: cell)
        }
        self.tableView.dataSource = dataSource
        self.tableView.reloadData()
    }
    
    //MARK:- Dispaly Data in Cell
    fileprivate func display(data: DataEntity, in cell: CustomTableViewCell){
        cell.textLabel?.text = data.desc
        cell.detailTextLabel?.text = data.location
        print(Thread.current.isMainThread)

    }
    
    //MARK:- Import operation Completed
    @objc fileprivate func importOperationCompleted() {
        self.performSelector(onMainThread: #selector(setupTableDataSource), with: nil, waitUntilDone: true)
    }
    
    //MARK:- OoperationQueue Observer
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == observerNameString {
            self.performSelector(onMainThread: #selector(self.updateRightBarButtonItemTitle(with:)), with: change, waitUntilDone: false)
        }
    }
    
    //MARK:- Set rightbar button title
    @objc func updateRightBarButtonItemTitle(with dict: [NSKeyValueChangeKey : Any]?) {
        if let newKeyValue = dict?[.newKey] as? Int, newKeyValue >= 1 {
            self.navigationItem.rightBarButtonItem?.title = "Cancel"
        }
        else {
            self.navigationItem.rightBarButtonItem?.title = "Import"
        }
    }
    
    //MARK:- create an import opration
    fileprivate func createImportOperation(){
       let operation = IndependentOperation(stack: self.persistentStackObject, fileName: "jsonData")
        operation.progressBlock = { [weak self](value) in
            DispatchQueue.main.async {
                self?.progressBar.progress = value
            }
        }
        self.independentOperationQueue.addOperation(operation)
    }
    
    //MARK:- Right bar button action
    @IBAction func importButtonClicked(_ sender: Any) {
        if independentOperationQueue.operations.count == 0 {
            self.createImportOperation()
        }
        else {
            CustomAlert.showAlertWith(title: Constants.AlertMessage.cancelImportTitle, message: Constants.AlertMessage.cancelImportMessage, firstButtonTitle: "YES", secondButtonTitle: "NO", onViewController: self, withFirstCallback: self.cancelImportOperation(action:), withSecondCallback: nil)
        }
    }
    
    //MARK:- Cancel all import operation
    fileprivate func cancelImportOperation(action: UIAlertAction) {
        self.independentOperationQueue.cancelAllOperations()
//        GlobalTimer.sharedInstance.stopTimer()
//        counter = 0
    }
}
