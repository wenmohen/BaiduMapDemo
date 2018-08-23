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
    //周边搜索
    var poiSearch = BMKPoiSearch()
    //地点输入提示检索
    var suggestionSearch = BMKSuggestionSearch()
    //定位
    var locationService = BMKLocationService()
    //当前页数
    var currentPageIndex: Int = 0
    let city = "珠海"
    let keyword = "学校/小区/大厦"
    var targetCoordinate = CLLocationCoordinate2D.init(latitude: 22.212243, longitude: 113.544817) {
        didSet {
             addressArr.removeAll()
             reverseGeoSearch(targetCoordinate)
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
        poiSearch.delegate = self
        locationService.delegate = self
        suggestionSearch.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bmkMapView.delegate = nil
        geocodeSearch.delegate = nil
        poiSearch.delegate = nil
        locationService.delegate = nil
        suggestionSearch.delegate = nil
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
       currentPageIndex = currentPageIndex + 1
       sendPoiNearSearchRequest(targetCoordinate)
    }
}

extension MapViewController {
    fileprivate func setupView() {
        setupMapView()
        setupTableView()
    }
    
    fileprivate func setupMapView() {
        bmkMapView.zoomLevel = 18
        setupLocationService()
        reverseGeoSearch(targetCoordinate)
//        sendPoiNearSearchRequest(targetCoordinate)
//        sendSuggestionSearchRequest(targetCoordinate)
    }
    
    fileprivate func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    func setupLocationService() {
        locationService.allowsBackgroundLocationUpdates = true
        locationService.desiredAccuracy = kCLLocationAccuracyBest
        locationService.pausesLocationUpdatesAutomatically = false
        bmkMapView.showsUserLocation = true
        locationService.distanceFilter = 10
        setupLocationAccuracyCircle()
        startLocation()
    }
    //设置精度圈
    func setupLocationAccuracyCircle() {
        let parm = BMKLocationViewDisplayParam()
        parm.accuracyCircleFillColor = UIColor.clear
        parm.accuracyCircleStrokeColor = UIColor.clear
        bmkMapView.updateLocationView(with: parm)
    }
    
    func setupLocationManager() {
        
    }
}

extension MapViewController {
    //开始定位
    func startLocation() {
        locationService.startUserLocationService()
        bmkMapView.userTrackingMode = BMKUserTrackingModeNone
    }
    //停止定位
    func stopLocation() {
        locationService.stopUserLocationService()
    }
    
    //编码：根据地址查找经纬度
    func geoSearch() {
        let geocodeSearchOption = BMKGeoCodeSearchOption()
        geocodeSearchOption.city = city
        geocodeSearchOption.address = "利时大厦"
        let flag = geocodeSearch.geoCode(geocodeSearchOption)
        if flag {
            print("geo 检索发送成功")
        } else {
            print("geo 检索发送失败")
        }
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
    
    //城市内检索：POI行政区划检索:行政区划检索是根据关键字检索适用于在「某个行政区划，如北京市、四川省等」搜索某个名称相关的POI，例如：查找北京市的“小吃”。
    func sendPoiCitySearchRequest() {
        let citySearchOption = BMKPOICitySearchOption()
        citySearchOption.pageIndex = currentPageIndex
        citySearchOption.pageSize = 10
        citySearchOption.city = city
        citySearchOption.keyword = keyword
        if poiSearch.poiSearch(inCity: citySearchOption) {
            print("城市内检索发送成功！")
        }else {
            print("城市内检索发送失败！")
        }
    }
    //POI圆形区域检索:圆形区域检索是一个圆形范围，适用于以某个位置为中心点，自定义检索半径值，搜索某个位置附近的POI。
    func sendPoiNearSearchRequest(_ coordinate: CLLocationCoordinate2D) {
        let nearSearchOption = BMKPOINearbySearchOption()
        nearSearchOption.pageIndex = currentPageIndex
        nearSearchOption.pageSize = 10
        nearSearchOption.location = coordinate
        nearSearchOption.keywords = ["大厦","小区","学校","酒店","餐馆","银行","商场"]
        nearSearchOption.tags = ["大厦","小区","学校","酒店","餐馆","银行","商场"]
        if poiSearch.poiSearchNear(by: nearSearchOption) {
            print("周边检索发送成功！")
        }else {
            print("周边检索发送失败！")
        }
    }
    //地点输入提示检索（Sug检索）
    func sendSuggestionSearchRequest(_ coordinate: CLLocationCoordinate2D) {
        let suggestionSearchOption = BMKSuggestionSearchOption()
        suggestionSearchOption.keyword = "大厦"
        suggestionSearchOption.cityname = "珠海"
        if suggestionSearch.suggestionSearch(suggestionSearchOption) {
            print("Sug检索发送成功！")
        }else {
            print("Sug检索发送失败！")
        }
    }
}

// MARK: 定位- BMKLocationServiceDelegate
extension MapViewController: BMKLocationServiceDelegate {

    /**
     *在地图View将要启动定位时，会调用此函数
     *@param mapView 地图View
     */
    func willStartLocatingUser() {
        print("willStartLocatingUser");
    }
    /**
     *用户方向更新后，会调用此函数
     *@param userLocation 新的用户位置
     */
    func didUpdateUserHeading(_ userLocation: BMKUserLocation!) {
  
    }
    /**
     *用户方向更新后，会调用此函数
     *@param userLocation 新的用户位置
     */
    func didUpdate(_ userLocation: BMKUserLocation!) {
        bmkMapView.updateLocationData(userLocation)
        bmkMapView.centerCoordinate = userLocation.location.coordinate
        targetCoordinate = userLocation.location.coordinate
        stopLocation()
    }
    
    /**
     *在地图View停止定位后，会调用此函数
     *@param mapView 地图View
     */
    func didStopLocatingUser() {
        print("didStopLocatingUser")
    }
}

// MARK: 地理编码和反地理编码- BMKGeoCodeSearchDelegate
extension MapViewController: BMKGeoCodeSearchDelegate {
    /**
     *返回地址信息搜索结果
     *@param searcher 搜索对象
     *@param result 搜索结BMKGeoCodeSearch果
     *@param error 错误号，@see BMKSearchErrorCode
     */
    func onGetGeoCodeResult(_ searcher: BMKGeoCodeSearch!, result: BMKGeoCodeSearchResult!, errorCode error: BMKSearchErrorCode) {
        print("onGetGeoCodeResult error: \(error)")
        
        if error == BMK_SEARCH_NO_ERROR {
            print("地理编码定位坐标：-----\(result.location)")
//            bmkMapView.centerCoordinate = result.location
        }
    }
    
    /**
     *返回反地理编码搜索结果
     *@param searcher 搜索对象
     *@param result 搜索结果
     *@param error 错误号，@see BMKSearchErrorCode
     */
    func onGetReverseGeoCodeResult(_ searcher: BMKGeoCodeSearch!, result: BMKReverseGeoCodeSearchResult!, errorCode error: BMKSearchErrorCode) {
        print("onGetReverseGeoCodeResult error: \(error)")
        if error == BMK_SEARCH_NO_ERROR {
//            print("反地理编码定位坐标：-----\(result.location)")
//            print("反地理编码定位地址：------\(result.address)")
            guard let pois = result.poiList as? [BMKPoiInfo] else {
                 return
            }
//            addressArr.removeAll()
            for (_,poiInfo) in pois.enumerated(){
//                print("地址名--\(poiInfo.address)---\(poiInfo.name)---")
                let place = PlaceEntity.init(location: poiInfo.pt, addressName: poiInfo.name, addressDetail: poiInfo.address)
                addressArr.append(place)
            }
            tableView.reloadData()
        }
    }
}
// MARK: 周围检索- BMKPoiSearchDelegate
extension MapViewController: BMKPoiSearchDelegate{
    /**
     *返回POI搜索结果
     *@param searcher 搜索对象
     *@param poiResult 搜索结果列表
     *@param errorCode 错误号，@see BMKSearchErrorCode
     */
    func onGetPoiResult(_ searcher: BMKPoiSearch!, result poiResult: BMKPOISearchResult!, errorCode: BMKSearchErrorCode) {
        print("onGetPoiResult code: \(errorCode)");
        if errorCode == BMK_SEARCH_NO_ERROR {
            for i in 0..<poiResult.poiInfoList.count {
                let poi = poiResult.poiInfoList[i]
//                print("地址名--\(poi.name)")
//                print("城市检索结果------坐标--\(poi.pt)------地址名--\(poi.name)--详细地址--\(poi.address)")
                let place = PlaceEntity.init(location: poi.pt, addressName: poi.name, addressDetail: poi.address)
                addressArr.append(place)
            }
            tableView.reloadData()
        } else if errorCode == BMK_SEARCH_AMBIGUOUS_KEYWORD {
            print("检索词有歧义")
        } else {
            // 各种情况的判断……
            print("各种情况的判断")
        }
    }
}
//MARK:--Sug检索--BMKSuggestionSearchDelegate
extension MapViewController: BMKSuggestionSearchDelegate {
    func onGetSuggestionResult(_ searcher: BMKSuggestionSearch!, result: BMKSuggestionResult!, errorCode error: BMKSearchErrorCode) {
        print("onGetSuggestionResult code: \(error)");
        if error == BMK_SEARCH_NO_ERROR {
            guard let names = result.keyList as? [String],names.count > 0, let addresss = result.districtList as? [String], let coordinates = result.ptList as? [NSValue] else {
                return
            }
            for i in 0..<coordinates.count {
                let value = coordinates[i]
                let coordinate = CLLocationCoordinate2D.init(latitude:CLLocationDegrees(CGFloat(value.cgPointValue.x)), longitude: CLLocationDegrees(CGFloat(value.cgPointValue.y)))
                let name = i <= names.count ? names[i] : ""
//                let address = i <= addresss.count ? addresss[i] : ""
                print(addresss)
                let place = PlaceEntity.init(location: coordinate, addressName: name, addressDetail: "")
                addressArr.append(place)
            }
            tableView.reloadData()
        } else if error == BMK_SEARCH_AMBIGUOUS_KEYWORD {
            print("检索词有歧义")
        } else {
            // 各种情况的判断……
            print("各种情况的判断")
        }
    }
}
//MARK:--地图--BMKMapViewDelegate
extension MapViewController: BMKMapViewDelegate {

    func mapView(_ mapView: BMKMapView!, regionDidChangeAnimated animated: Bool) {
       let coordinate = bmkMapView.convert(bmkMapView.center, toCoordinateFrom: bmkMapView)
       
        targetCoordinate = coordinate
    }
    
    func mapViewDidFinishLoading(_ mapView: BMKMapView!) {
       bmkMapView.centerCoordinate = targetCoordinate
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
