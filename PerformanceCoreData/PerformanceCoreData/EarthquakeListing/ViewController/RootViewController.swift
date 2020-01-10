//
//  ViewController.swift
//  PerformanceCoreData
//
//  Created by Gagan Vishal on 2019/12/31.
//  Copyright © 2019 Gagan Vishal. All rights reserved.
//

import UIKit
import CoreData

class RootViewController: UIViewController {
    //IBOutlets
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var earthquakeTableView: UITableView!
    let viewModel = EarthqukeViewModel()
    //cell identifier
    let cellIdentifier = "earthquakeCellIdentifier"
    //MARK:- View Controller Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //set delegate
        viewModel.fetchedResultsControllerDelegate = self
        //EarthqukeViewModel Binding
        bindData()
    }

    //MARK:- Bind Data
    fileprivate func bindData() {
        viewModel.tableCells.bindAndFire { (value) in
            if !value.isEmpty {
                DispatchQueue.main.async { [weak self] in
                    self?.earthquakeTableView.reloadData()
                }
            }
        }
        viewModel.showLoadingHud.bind { (isVisible) in
            DispatchQueue.main.async { [weak self] in
                if isVisible {
                    self?.spinner.startAnimating()
                }
                else {
                    self?.spinner.stopAnimating()
                }
            }
        }
    }
    
    //MARK:- Fetch records from server
    fileprivate func fetchRecord(with action: UIAlertAction?) {
        viewModel.getEarthquakeRecords()
    }
    
    //MARK:- get cell with message
    func prepareCommonCell(with message: String) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = message
        return cell
    }
    
    //MARK:- Import button action
    @IBAction func importButtonPressed(_ sender: Any) {
        fetchRecord(with: nil)
    }
}


//MARK:- UITableViewDataSource
extension RootViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as? EarthquakeTableViewCell else {
            return UITableViewCell()
        }
        if let viewModel = self.viewModel.fetchedResultsController.fetchedObjects?[indexPath.row] {
            cell.viewModelProperty = viewModel
        }
/****************************************MVVM Without Core Data***********************************************/
//        switch self.viewModel.tableCells.value[indexPath.row] {
//        case .normal(let viewModel):
//            cell.viewModel = viewModel
//            break
//        case .empty:
//            return prepareCommonCell(with: Constants.User_Message.empty_state_message)
//        case .error(let message):
//            return prepareCommonCell(with: message )
//        }
/****************************************MVVM Without Core Data***********************************************/
        return cell
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension RootViewController: NSFetchedResultsControllerDelegate {
    /**
     Reloads the table view when the fetched result controller's content changes.
     */
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.earthquakeTableView.reloadData()
    }
}
