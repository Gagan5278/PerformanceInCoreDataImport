//
//  NotificationViewController.swift
//  CoreDataPerformance
//
//  Created by Gagan Vishal on 2019/12/09.
//  Copyright © 2019 Gagan Vishal. All rights reserved.
//

import UIKit
import CoreData

class NotificationViewController: UITableViewController {
    let cellIdentifier = "NotificationViewCellIdentifier"
    //OperationQueue observer name
    let observerNameString: String = "operationCount"
    //IBOutlets
    @IBOutlet weak var progressBar: UIProgressView!
    lazy var notificationOperationQueue: OperationQueue = {
        let operationQueue =   OperationQueue()
        operationQueue.name = "com.notification"
        operationQueue.qualityOfService = .userInitiated
        operationQueue.addObserver(self, forKeyPath: observerNameString, options: [.new, .old], context: nil)
        return operationQueue
    }()
    var counter : Int = 0
    //managed object context
    var managedObjectContext = CoreDataManager.sharedInstance.managedObjectContext
    //Fetch Rquest
    lazy var fetchResultController : NSFetchedResultsController<DataEntity> = {
        ///create NSFetchRequest obejct
        let fetchRequest : NSFetchRequest<DataEntity> = DataEntity.getFetchRequest()
        ///sort items by city name
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: Constants.KeysConstants.UFO_KEY_COREDATA_SIGHTED, ascending: false)]
        var fetchController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        ///set delegate
        fetchController.delegate = self
        return fetchController
    }()
    
    //MARK:- ViewControllere life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //1. Add a floating button on Window
        self.navigationController!.addFloatingButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    deinit {
        self.removeObserver(self, forKeyPath: observerNameString)
    }
    
    fileprivate func newBackgroundTimer()  {
      DispatchQueue.global(qos: .background).async { [weak self] in
        GlobalTimer.sharedInstance.startTimer(withInterval: 1.0, controller: self!, andJob: #selector(self?.updateTimerValue))
        let runLoop = RunLoop.current
        runLoop.add(GlobalTimer.sharedInstance.internalTimer!, forMode: .default)
        runLoop.run()
      }
    }
    
    @objc func perfomrTaskOnBackgroundThread(){
        let controller =  NotificationImporter(context: CoreDataManager.sharedInstance.managedObjectContext, fileName: "jsonData")
        self.notificationOperationQueue.addOperation(controller)
        controller.progressBlock = {(value) in
              DispatchQueue.main.async {[weak self] in
                self?.progressBar.progress = value
                print(value.getNearestFloatValue())
                if (value.getNearestFloatValue() as NSString).doubleValue == 1.0 {
                    GlobalTimer.sharedInstance.stopTimer()
                }
              }
          }
    }
    
    //MARK:- Update seconds value
    @objc func updateTimerValue(){
        counter += 1
        DispatchQueue.main.async { [weak self] in
            self?.navigationController?.floatingButton?.setTitle("\((self?.counter)!)s", for: .normal)
        }
    }
    
    //MARK:- FetchRessultController Fetch
    fileprivate func pereformFetch() {
        do
        {
            _ = try self.fetchResultController.performFetch()
        }
        catch let error as NSError
        {
            print("error is : \(error.localizedDescription)")
        }
    }
    //MARK:- Import button action
    @IBAction func importButtonPreessed(_ sender: Any) {
        if self.notificationOperationQueue.operations.count >= 1 {
            //App crashes here due to number of cell in UITableView. Please find a work around
            CustomAlert.showAlertWith(title: Constants.AlertMessage.cancelImportTitle, message: Constants.AlertMessage.cancelImportMessage, firstButtonTitle: "YES", secondButtonTitle: "NO", onViewController: self, withFirstCallback: self.cancelImportOperation(action:), withSecondCallback: nil)
        }
        else {
            //delete all items from core data
            CoreDataManager.sharedInstance.deleteAllItemsOnViewLoad { [weak self] in
                //1.
//               self?.tableView.reloadData()
                //2.
                self?.newBackgroundTimer()
                //3.
                DispatchQueue.global(qos: .background).async{[weak self] in
                    self?.perfomrTaskOnBackgroundThread()
                }
//                self?.performSelector(inBackground: #selector(self?.perfomrTaskOnBackgroundThread), with: nil)
                //4.
                self?.pereformFetch()
            }
        }
    }
    
    //MARK:- Cancel all import operation
    fileprivate func cancelImportOperation(action: UIAlertAction) {
        self.notificationOperationQueue.cancelAllOperations()
        GlobalTimer.sharedInstance.stopTimer()
        counter = 0
    }
    
    //MARK:- Update bar button status
    @objc func updateRightBarButtonItemStatus(with dict: [NSKeyValueChangeKey : Any]?) {
        if let newKeyVal = dict?[.newKey] as? Int, newKeyVal == 1 {
            self.navigationItem.rightBarButtonItem?.title = "Cancel"
        }
        else {
            self.navigationItem.rightBarButtonItem?.title = "Import"
        }
    }
    
    //MARK:- OoperationQueue Observer
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == observerNameString {
            self.performSelector(onMainThread: #selector(self.updateRightBarButtonItemStatus(with:)), with: change, waitUntilDone: false)
        }
    }
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchResultController.sections
        {
            return sections.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchResultController.sections {
            let sectoinsInfo = sections[section]
            return sectoinsInfo.numberOfObjects
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath as IndexPath)
        self.prepareCell(cell: cell, indexPath: indexPath as NSIndexPath)
        return cell
    }
    
    func prepareCell(cell : UITableViewCell, indexPath : NSIndexPath)
    {
        let dataEntity = self.fetchResultController.object(at: NSIndexPath(row: indexPath.row, section: indexPath.section) as IndexPath)
        cell.textLabel!.text = dataEntity.desc
        cell.detailTextLabel?.text = dataEntity.location
    }
}

extension NotificationViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch (type)
        {
        case .insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
        case .delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
        default :
            print("None")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type)
        {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath! as IndexPath], with: .fade)
        case .delete:
            self.tableView.deleteRows(at: [indexPath! as IndexPath], with: .fade)
        case .move:
            self.tableView.deleteRows(at: [indexPath! as IndexPath], with: .fade)
            self.tableView.insertRows(at: [newIndexPath! as IndexPath], with: .fade)
        case . update :
            if self.tableView.indexPathsForVisibleRows?.firstIndex(of: indexPath!) != NSNotFound
            {
                self.prepareCell(cell: self.tableView.cellForRow(at: indexPath! as IndexPath)!, indexPath: indexPath! as NSIndexPath)
            }
        @unknown default:
            print("Default")
        }
    }
}
