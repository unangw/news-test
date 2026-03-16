//
//  AppCoordinator.swift
//  News
//
//  Created by BTS.id on 02/03/26.
//

import UIKit

// Define what type of flows can be started from this Coordinator
protocol AppCoordinatorProtocol: Coordinator {
    func showMainFlow()
}

// App coordinator is the only one coordinator which will exist during app's life cycle
class AppCoordinator: AppCoordinatorProtocol {
    weak var finishDelegate: CoordinatorFinishDelegate?
    
    var navigationController: UINavigationController
    
    var childCoordinators = [Coordinator]()
    
    var type: CoordinatorType { .app }
    
    required init(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
        navigationController.setNavigationBarHidden(false, animated: true)
    }
    
    func start() {
        return showMainFlow()
    }
    
    func showMainFlow() {
        // Implement Main FLow
        let mainCoordinator = MainCoordinator.init(navigationController)
        mainCoordinator.finishDelegate = self
        UIView.transition(
            with: navigationController.view,
            duration: 0.5,
            options: [.transitionCrossDissolve],
            animations: nil,
            completion: nil
        )
        mainCoordinator.start()
        childCoordinators.append(mainCoordinator)
    }
}

extension AppCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter({ $0.type != childCoordinator.type })
        
    }
}
