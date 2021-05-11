//
//  HomeController.swift
//  UberClone
//
//  Created by Renato Mateus on 04/05/21.
//

import UIKit
import MapKit

private enum ActionButtonConfiguration {
    case showManu
    case dismissActionView
    
    init(){
        self = .showManu
    }
}

class HomeController : UIViewController {
    // MARK: Properties
    private let mapView = MKMapView()
    private let locationManager = LocationHandler.shared.locationManger
    private let inputActivationView = LocationinputActivationView()
    private let rideActionView = RideActionView()
    private let locationInputView = LocationInputView()
    private let tableView = UITableView()
    private var searchResults = [MKPlacemark]()
    private var actionButtonConfig = ActionButtonConfiguration()
    private var route: MKRoute?
    private final let rideActionViewHeight: CGFloat = 300
    
    private final let locationInputViewHeight: CGFloat = 200
    var isLogged: Bool = false
    
    private var user: User? {
        didSet {
                locationInputView.user = user
        }
    }
    
    var drivers: [User]? {
        didSet{
            setUpAnnotation()
        }
    }
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(didTapMenuButton), for: .touchUpInside)
        return button
    }()
    
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
        configureRideActionView()
        fetchDrivers()
        
        view.addSubview(actionButton)
        actionButton.anchor(top: self.view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 16, paddingLeft: 16, width: 30, height: 30)
        
        view.addSubview(inputActivationView)
        inputActivationView.centerX(inView: view)
        inputActivationView.setDimensions(height: 50, width: view.frame.width - 64)
        inputActivationView.anchor(top: actionButton.bottomAnchor, paddingTop: 32)
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
    
    func dismissLocationInputView(completion: ((Bool) -> Void)? = nil){
        UIView.animate(withDuration: 0.3, animations: {
            self.locationInputView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
            self.locationInputView.removeFromSuperview()
           
        }, completion: completion)
        
    }
    
    fileprivate func configureActionButton(config: ActionButtonConfiguration){
        switch config {
        case .showManu:
            self.actionButton.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
        case .dismissActionView:
            self.actionButton.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
        }
        self.actionButtonConfig = config
    }
    
    func configureRideActionView(){
        view.addSubview(rideActionView)
        rideActionView.frame =  CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: rideActionViewHeight)
        rideActionView.delegate = self
    }
    
    func animateRideActionView(should: Bool, destination: MKPlacemark? = nil)
    {
        let animateShow = should ? self.view.frame.height - self.rideActionViewHeight : self.view.frame.height
        
        if should {
            guard let destination = destination else {return}
            rideActionView.destination = destination
        }
        
        UIView.animate(withDuration: 0.3) {
            self.rideActionView.frame.origin.y =  animateShow
        }
    }
    
    // MARK: Selectors
    
    @objc func didTapMenuButton(){
        switch actionButtonConfig {
        case .showManu:
            print("DEBUG: Menu pressed")
        case .dismissActionView:
            removeAnnotationAndOverlays()
            self.mapView.showAnnotations(mapView.annotations, animated: true)
            UIView.animate(withDuration: 0.3){
                self.inputActivationView.alpha = 1
                self.configureActionButton(config: .showManu)
                self.animateRideActionView(should: false)
            }
            
            
        }
        
    }
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
        
        dismissLocationInputView { _ in
            UIView.animate(withDuration: 0.3, animations: {
                self.inputActivationView.alpha = 1
            })
        }

    }
}

// MARK: UITableView
extension HomeController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlacemark = searchResults[indexPath.row]
        var annotations = [MKAnnotation]()
        configureActionButton(config: .dismissActionView)
        
        let destination = MKMapItem(placemark: selectedPlacemark)
        generatePolyline(toDestination: destination)
        
        dismissLocationInputView { _ in
            let annotation = MKPointAnnotation()
            annotation.coordinate = selectedPlacemark.coordinate
            self.mapView.addAnnotation(annotation)
            self.mapView.selectAnnotation(annotation, animated: true)
            
            self.mapView.annotations.forEach { (annotation) in
                if let anno = annotation as? MKUserLocation {
                    annotations.append(anno)
                }
                
                if let anno = annotation as? MKPointAnnotation {
                    annotations.append(anno)
                }
                self.mapView.zoomToFit(annotations: annotations)
                self.animateRideActionView(should: true, destination: selectedPlacemark)
            }
           
            
        }
    }
}

// MARK: MKMapViewDelegate
extension HomeController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: DriverAnnotation.identifier)
            
            let pinImage = UIImage(named: "uber_car.png")
            let size = CGSize(width: 40, height: 25)
            UIGraphicsBeginImageContext(size)
            pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            
            view.image = resizedImage
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route {
            let polyline = route.polyline
            let lineRenderer = MKPolylineRenderer(overlay: polyline)
            lineRenderer.strokeColor = .mainBlueTint
            lineRenderer.lineWidth = 5
            return lineRenderer
        }
        return MKOverlayRenderer()
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
    
    func generatePolyline(toDestination destination: MKMapItem){
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        request.transportType = .automobile
        
        let directionRequest = MKDirections(request: request)
        directionRequest.calculate { (response, error) in
            guard let response = response else { return }
            self.route = response.routes[0]
            guard let polyline = self.route?.polyline else {return}
            self.mapView.addOverlay(polyline)
        }
    }
    
    func generateDriverPolyline(fromMe from: MKMapItem, toDestination: MKMapItem){
        let request = MKDirections.Request()
        request.source = from
        request.destination = toDestination
        request.transportType = .automobile
        
        let directionRequest = MKDirections(request: request)
        directionRequest.calculate { (response, error) in
            guard let response = response else { return }
            self.route = response.routes[0]
            guard let polyline = self.route?.polyline else {return}
            self.mapView.addOverlay(polyline)
        }
    }
    
    func removeAnnotationAndOverlays(){
        self.mapView.annotations.forEach { (annotation) in
            if let anno = annotation as? MKPointAnnotation {
                mapView.removeAnnotation(anno)
            }
        }
        if mapView.overlays.count > 0 {
            mapView.removeOverlay(mapView.overlays[0])
        }
    }
    
    func removeOverlays(){
        if mapView.overlays.count > 0 {
            mapView.removeOverlay(mapView.overlays[0])
        }
    }
    
}


extension HomeController : RideActionViewDelegate {
    func didTapConfirmUber() {
        animateRideActionView(should: false)
        removeOverlays()
        guard let drivers = self.drivers else {return}
        guard let coordinate = drivers[0].location?.coordinate else {return}
        let driverPlaceMark = MKPlacemark(coordinate: coordinate)
        let driverMkMapItem = MKMapItem(placemark: driverPlaceMark)
        self.generateDriverPolyline(fromMe: driverMkMapItem, toDestination: MKMapItem.forCurrentLocation())
        self.mapView.zoomToFit(annotations: mapView.annotations)
        
    }
    
    
}
