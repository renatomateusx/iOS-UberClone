//
//  HomeController.swift
//  UberClone
//
//  Created by Renato Mateus on 04/05/21.
//

import UIKit
import MapKit

class HomeController : UIViewController {
    // MARK: Properties
    private let mapView = MKMapView()
    var isLogged: Bool = false
    
    // MARK: Lifecyle
    override func viewDidLoad() {
        super.viewDidLoad()
        //UserDefaults.standard.set([], forKey: "user")
        configureTabBar()
        configureUI()
        initializeUser()
    }
    
    // MARK: Helpers
    func configureTabBar(){
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }
    func configureUI(){
        view.backgroundColor = .backgroundColor
        view.addSubview(mapView)
        mapView.frame = view.frame
    }
    
    func initializeUser(){
        let user = UserDefaults.standard.stringArray(forKey: "user") ?? [String]()
        if user.count > 0 {
            self.isLogged = true;
        }
        if(!isLogged){
            DispatchQueue.main.async {
                let controller = LoginController()
                controller.delegate = self
                let nav = UINavigationController(rootViewController: controller)
                self.present(nav, animated: true, completion: nil)
            }
        }else{
            configureUI()
        }
    }
    
    // MARK: Selectors
}

extension HomeController: LoginControllerDelegate {
    func didUserLogged(controller: LoginController) {
        self.configureUI()
    }

}
