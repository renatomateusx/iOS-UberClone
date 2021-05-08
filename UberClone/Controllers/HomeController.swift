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
    private let locationManager = LocationHandler.shared.locationManger
    private let inputActivationView = LocationinputActivationView()
    private let locationInputView = LocationInputView()
    private let tableView = UITableView()
    private var searchResults = [MKPlacemark]()
    
    private final let locationInputViewHeight: CGFloat = 200
    var isLogged: Bool = false
    
    private var user: User? {
        didSet {
                locationInputView.user = user
        }
    }
    
    private var drivers: [User]? {
        didSet{
            setUpAnnotation()
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
        fetchDrivers()
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
        mapView.delegate = self
    }
    
    func fetchUser(){
        Service.shared.fetchUserData { user in
            self.user = user
        }
    }
    
    func fetchDrivers(){
        Service.shared.fetchDrivers { drivers in
            self.drivers = drivers
        }
    }
    
    func setUpAnnotation(){
        guard let drivers = self.drivers else {return}
        for driver in drivers {
            guard let coordinate = driver.location?.coordinate else {return}
            let driverAnnotation = DriverAnnotation(withUID: driver.uid, coordinate: coordinate)
            
            var driverIsVisible: Bool {
                return self.mapView.annotations.contains(where: { annotation -> Bool in
                    guard let driverAnno = annotation as? DriverAnnotation else {return false}
                    if driverAnno.uid == driver.uid {
                        return true
                    }
                    return false
                })
            }
            
            if !driverIsVisible {
                self.mapView.addAnnotation(driverAnnotation)
            }
        }
//        updateAnnotation()
    }
    
    func updateAnnotation(){
        DispatchQueue.main.async {
            guard let drivers = self.drivers else {return}
            guard let userLocation = self.locationManager?.location else {return}
            Service.shared.updateAnnotation(withMe: userLocation, drivers: drivers) { drivers in
                self.drivers = drivers
            }
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
        switch locationManager?.authorizationStatus {
        case .notDetermined:
            locationManager?.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways:
            locationManager?.startUpdatingLocation()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            locationManager?.requestAlwaysAuthorization()
        case .none:
            break
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            locationManager?.requestAlwaysAuthorization()
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
    func executeQuery(query: String) {
        searchBy(naturalLanguageQuery: query) { (resultsPlacemarks) in
            self.searchResults = resultsPlacemarks
            self.tableView.reloadData()
        }
    }
    
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
        return section == 0 ? 2 : self.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LocationCell.identifier, for: indexPath) as! LocationCell
        if indexPath.section == 1 {
            cell.configure(withPlacemark: searchResults[indexPath.row])
        }
        return cell
    }
}

// MARK: MKMapViewDelegate
extension HomeController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: DriverAnnotation.identifier)
            view.image = #imageLiteral(resourceName: "chevron-sign-to-right")
            return view
        }
        return nil
    }
}


// MARK: Map Helper Functions

private extension HomeController {
    func searchBy(naturalLanguageQuery: String, completion: @escaping([MKPlacemark]) -> Void){
        var results = [MKPlacemark]()
        let request = MKLocalSearch.Request()
        request.region = mapView.region
        request.naturalLanguageQuery = naturalLanguageQuery
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else {return}
            
            response.mapItems.forEach ({ item  in
                results.append(item.placemark)
            })
            completion(results)
        }
    }
}
