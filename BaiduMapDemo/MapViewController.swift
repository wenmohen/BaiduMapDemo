//
//  MapViewController.swift
//  BaiduMapDemo
//
//  Created by ning on 2018/8/23.
//  Copyright © 2018年 ning. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {
    //地图定位附近地址列表
    @IBOutlet weak var tableView: UITableView!
    //地图所在View
    @IBOutlet weak var bmkMapView: BMKMapView!
    //定位当前位置按钮
    @IBOutlet weak var relocationButton: UIButton!
    //搜索
    @IBOutlet weak var searchLabel: UILabel!
    //地图中间大头针
    @IBOutlet weak var middlePinImageView: UIImageView!
    //地理编码/反地理编码
    var geocodeSearch = BMKGeoCodeSearch()
    //定位
    lazy var locationService: BMKLocationService = {
        let service = BMKLocationService()
        service.allowsBackgroundLocationUpdates = true
        service.desiredAccuracy = kCLLocationAccuracyBest
        service.pausesLocationUpdatesAutomatically = false
        service.distanceFilter = 100
        return service
    }()
    var targetCoordinate = CLLocationCoordinate2D.init(latitude: 22.212243, longitude: 113.544817)
    //用户已经选择的地址
    var userCoordinate: CLLocationCoordinate2D? {
        didSet {
            guard let coordinate = userCoordinate else {
                return
            }
            targetCoordinate = coordinate
        }
    }
    var addressArr = [PlaceEntity]()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bmkMapView.delegate = self
        geocodeSearch.delegate = self
        locationService.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bmkMapView.delegate = nil
        geocodeSearch.delegate = nil
        locationService.delegate = nil
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    //重定位当前位置
    @IBAction func didRelocationButtonTouchUpInside(_ sender: UIButton) {
        startLocation()
    }
    
    //搜索
    @IBAction func didSearchButtonTouchUpInside(_ sender: UIButton) {
        guard let targetVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "AddressSearchViewController") as? AddressSearchViewController else {
            return
        }
        targetVC.targetCoordinate = targetCoordinate
        self.navigationController?.pushViewController(targetVC, animated: true)
    }
}

extension MapViewController {
    fileprivate func setupView() {
        setupMapView()
        setupTableView()
    }
   
    fileprivate func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    //地图
    fileprivate func setupMapView() {
        bmkMapView.zoomLevel = 18
        bmkMapView.showsUserLocation = true
        bmkMapView.userTrackingMode = BMKUserTrackingModeNone
        let parm = BMKLocationViewDisplayParam()
        parm.accuracyCircleFillColor = UIColor.clear
        parm.accuracyCircleStrokeColor = UIColor.clear
        bmkMapView.updateLocationView(with: parm)
        if userCoordinate == nil {
            startLocation()
        }
        bmkMapView.setCenter(targetCoordinate, animated: true)
    }
}

extension MapViewController {
    //开始定位
    func startLocation() {
        locationService.startUserLocationService()
    }
    //结束定位
    func stopLocation() {
        locationService.stopUserLocationService()
    }
    
    //反编码：根据经纬度获取地址信息
    func reverseGeoSearch(_ coordinate: CLLocationCoordinate2D) {
        let reverseGeocodeSearchOption = BMKReverseGeoCodeSearchOption()
        reverseGeocodeSearchOption.location = coordinate
        let flag = geocodeSearch.reverseGeoCode(reverseGeocodeSearchOption)
        if flag {
            print("反geo 检索发送成功")
        } else {
            print("反geo 检索发送失败")
        }
    }
}

// MARK: 定位- BMKLocationServiceDelegate
extension MapViewController: BMKLocationServiceDelegate {
    /**
     *用户方向更新后，会调用此函数
     *@param userLocation 新的用户位置
     */
    func didUpdate(_ userLocation: BMKUserLocation!) {
        targetCoordinate = userLocation.location.coordinate
        bmkMapView.updateLocationData(userLocation)
        bmkMapView.setCenter(targetCoordinate, animated: true)
        reverseGeoSearch(targetCoordinate)
        //必须结束了定位才可以重新定位
        stopLocation()
    }
}

// MARK: 地理编码和反地理编码- BMKGeoCodeSearchDelegate
extension MapViewController: BMKGeoCodeSearchDelegate {
    /**
     *返回反地理编码搜索结果
     *@param searcher 搜索对象
     *@param result 搜索结果
     *@param error 错误号，@see BMKSearchErrorCode
     */
    func onGetReverseGeoCodeResult(_ searcher: BMKGeoCodeSearch!, result: BMKReverseGeoCodeSearchResult!, errorCode error: BMKSearchErrorCode) {
        print("onGetReverseGeoCodeResult error: \(error)")
        if error == BMK_SEARCH_NO_ERROR {
            guard let pois = result.poiList as? [BMKPoiInfo] else {
                 return
            }
            addressArr.removeAll()
            for (_,poiInfo) in pois.enumerated(){
                let place = PlaceEntity.init(location: poiInfo.pt, addressName: poiInfo.name, addressDetail: poiInfo.address)
                addressArr.append(place)
            }
            tableView.reloadData()
        }
    }
}

//MARK:--地图--BMKMapViewDelegate
extension MapViewController: BMKMapViewDelegate {
    //移动地图调用
    func mapView(_ mapView: BMKMapView!, regionDidChangeAnimated animated: Bool) {
       var region = BMKCoordinateRegion()
        region.center = mapView.region.center
        targetCoordinate = region.center
        reverseGeoSearch(targetCoordinate)
    }
    //地图渲染完调用
    func mapViewDidFinishLoading(_ mapView: BMKMapView!) {
        var region = BMKCoordinateRegion()
        region.center = mapView.region.center
        targetCoordinate = region.center
        reverseGeoSearch(targetCoordinate)
    }
}
// MARK: - Delegate, Datasource of tableview
extension MapViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddressAddMapTableViewCell") as? AddressAddMapTableViewCell  else {
            return UITableViewCell()
        }
        cell.iconImageView.isHidden = indexPath.row == 0 ? false : true
        cell.addressLabel.textColor = indexPath.row == 0 ? UIColor.green : UIColor.darkGray
        cell.addressLabel.text = addressArr[indexPath.row].addressName
        cell.addressDetailLabel.text = addressArr[indexPath.row].addressDetail
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
