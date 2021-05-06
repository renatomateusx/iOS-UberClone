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
    private let locationManager = CLLocationManager()
    private let inputActivationView = LocationinputActivationView()
    private let locationInputView = LocationInputView()
    private let tableView = UITableView()
    private final let locationInputViewHeight: CGFloat = 200
    var isLogged: Bool = false
    
    private var user: User? {
        didSet {
                locationInputView.user = user
        }
    }
    
    // MARK: Lifecyle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUser()
        //UserDefaults.standard.set([], forKey: "user")
        configureTabBar()
        initializeUser()
    }
    
    // MARK: Helpers
    func configureTabBar(){
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }
    func configureUI(){
        view.backgroundColor = .backgroundColor
        enableLocationServices()
        configureMap()
        
        view.addSubview(inputActivationView)
        inputActivationView.centerX(inView: view)
        inputActivationView.setDimensions(height: 50, width: view.frame.width - 64)
        inputActivationView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        inputActivationView.alpha = 0
        inputActivationView.delegate = self
        UIView.animate(withDuration: 2) {
            self.inputActivationView.alpha = 1
        }
        
        configureTableView()
    }
    
    
    func configureMap(){
        view.addSubview(mapView)
        mapView.frame = view.frame
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
    
    func fetchUser(){
        Service.shared.fetchUserData { user in
            self.user = user
        }
    }
    
    func initializeUser(){
        let user = UserDefaults.standard.object(forKey: "user") as? [String: String] ?? [String: String]()
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
    
    func configureLocationInputView(){
        locationInputView.delegate = self
        view.addSubview(locationInputView)
        locationInputView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: locationInputViewHeight)
        locationInputView.alpha = 0
        
        UIView.animate(withDuration: 0.5, animations: {
            self.locationInputView.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                self.tableView.frame.origin.y = self.locationInputViewHeight
            }
        }
    }
    
    func configureTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LocationCell.self, forCellReuseIdentifier: LocationCell.identifier)
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView() // Para remover linhas em branco
        
        let height = view.frame.height - locationInputViewHeight
        tableView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
        view.addSubview(tableView)
    }
    
    // MARK: Selectors
}

extension HomeController: LoginControllerDelegate {
    func didUserLogged(controller: LoginController, completion: () -> Void) {
        self.configureUI()
        completion()
    }
    

}

extension HomeController: CLLocationManagerDelegate {
    func enableLocationServices(){
        locationManager.delegate = self
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        }
    }
}

// MARK: LocationinputActivationViewDelegate

extension HomeController: LocationinputActivationViewDelegate{
    func presentLocationInpuView() {
        inputActivationView.alpha = 0
       configureLocationInputView()
    }
}

// MARK: LocationInputViewDelegate

extension HomeController : LocationInputViewDelegate {
    func didTapBackButton() {
        
        UIView.animate(withDuration: 0.3) {
            self.locationInputView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
        } completion: { (_) in
            self.locationInputView.removeFromSuperview()
            UIView.animate(withDuration: 0.3) {
                self.inputActivationView.alpha = 1
            }
        }

    }
}

// MARK: UITableView
extension HomeController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Test"
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LocationCell.identifier, for: indexPath) as! LocationCell
        
        return cell
    }
}
