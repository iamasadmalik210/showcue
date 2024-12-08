//
//  HelperMethods.swift
//  ShowCue
//
//  Created by mac on 08/12/2024.
//

import Foundation
import UIKit

func showNoInternetAlert(on viewController: UIViewController, retryHandler: @escaping () -> Void) {
    // Create the alert controller
    let alertController = UIAlertController(
        title: "No Internet Connection",
        message: "Please check your internet connection and try again.",
        preferredStyle: .alert
    )
    
    // Add a Retry action
    let retryAction = UIAlertAction(title: "Retry", style: .default) { _ in
        retryHandler()
    }
    alertController.addAction(retryAction)
    
    // Add a Cancel action
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    alertController.addAction(cancelAction)
    
    // Present the alert
    viewController.present(alertController, animated: true, completion: nil)
}
