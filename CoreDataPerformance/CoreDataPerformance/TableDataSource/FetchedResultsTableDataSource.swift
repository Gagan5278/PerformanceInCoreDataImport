//
//  FetchedResultsTableDataSource.swift
//  CoreDataPerformance
//
//  Created by Gagan Vishal on 2019/12/13.
//  Copyright © 2019 Gagan Vishal. All rights reserved.
//

import Foundation
import UIKit
import CoreData
typealias ConfigureBlock = (CustomTableViewCell, DataEntity) -> Void

class FetchedResultsTableDataSource: NSObject {
    //cellIdentifer
    let cellIdentifier = "independentPersistentCellIdentifier"
    //
    let tableView: UITableView!
    let fetchedResultsController: NSFetchedResultsController<DataEntity>!
    var configureCellBlock: ConfigureBlock?
    //MARK:- Init
    init(tableView: UITableView, fetchResult: NSFetchedResultsController<DataEntity>) {
        self.tableView = tableView
        self.fetchedResultsController = fetchResult
        super.init()
        self.setupTableView()
    }
    
    //MARK:- Setup TableView
    fileprivate func setupTableView(){
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.fetchedResultsController.delegate = self
        do {
            _ = try self.fetchedResultsController.performFetch()
        }
        catch {
            print("error is :\(error)")
        }
    }
    
    //MARK:- Get item at given indexPath
    fileprivate func getItem(at indexPath: IndexPath) -> DataEntity
    {
        return self.fetchedResultsController.object(at: indexPath)
    }
    
    //MARK:- Prepare cell item
    fileprivate func prepare(Cell cell:CustomTableViewCell, at indexPath: IndexPath)  {
        let dataEntity = self.getItem(at: indexPath)
        if configureCellBlock != nil {
            configureCellBlock!(cell, dataEntity)
        }
    }
}

//MARK:- UITableViewDataSource
extension FetchedResultsTableDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let sectoinsInfo = sections[section]
            print(sectoinsInfo.numberOfObjects)
            return sectoinsInfo.numberOfObjects
        }
        print("FInd zero")
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CustomTableViewCell else {
            return UITableViewCell()
        }
        prepare(Cell: cell, at: indexPath)
        print("indexPath :\(indexPath.row)")
        return cell
    }
}

//MARK:- UITableViewDelegate
extension FetchedResultsTableDataSource: UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

//MARK:- NSFetchedResultsControllerDelgate
extension FetchedResultsTableDataSource: NSFetchedResultsControllerDelegate {
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
                _ = self.prepare(Cell: self.tableView.cellForRow(at: indexPath! as IndexPath)! as! CustomTableViewCell, at: indexPath!)
            }
        @unknown default:
            print("Default")
        }
    }
}
