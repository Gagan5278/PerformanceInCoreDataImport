//
//  CustomAlert.swift
//  CoreDataPerformance
//
//  Created by Gagan Vishal on 2019/12/12.
//  Copyright © 2019 Gagan Vishal. All rights reserved.
//

import Foundation
import UIKit

class CustomAlert {
    //MARK:- Show alert with custom button titles
    class func showAlertWith(title : String, message : String, firstButtonTitle: String, secondButtonTitle: String, onViewController : UIViewController, withFirstCallback callBackFirst :((UIAlertAction) -> Void)?, withSecondCallback callBackSecond :((UIAlertAction) -> Void)?)
    {
        //1.
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        //2.
        alertController.addAction(UIAlertAction(title: firstButtonTitle, style: .default, handler: callBackFirst))
        //3.
        alertController.addAction(UIAlertAction(title: secondButtonTitle, style: .default, handler: callBackSecond))
        //4.
        onViewController.present(alertController, animated: true, completion: nil)
    }
}
