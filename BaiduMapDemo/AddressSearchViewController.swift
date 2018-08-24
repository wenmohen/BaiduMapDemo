//
//  AddressSearchViewController.swift
//  BaiduMapDemo
//
//  Created by ning on 2018/8/24.
//  Copyright © 2018年 ning. All rights reserved.
//

import UIKit

class AddressSearchViewController: UIViewController {
    //地址列表
    @IBOutlet weak var tableView: UITableView!
    //搜索所在的view
    @IBOutlet weak var searchView: UIView!
    //搜索
    @IBOutlet weak var searchTextField: UITextField!
    //周边搜索
    var poiSearch = BMKPoiSearch()
    //当前页数
    var currentPageIndex: Int = 0
    var city = "珠海"
    var keyword = "大厦"
    var targetCoordinate = CLLocationCoordinate2D.init(latitude: 22.212243, longitude: 113.544817)
    var addressArr = [PlaceEntity]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavigateView()
        setupTableView()
        sendPoiNearSearchRequest(targetCoordinate)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        poiSearch.delegate = self
        searchTextField.delegate = self
        searchTextField.becomeFirstResponder()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        poiSearch.delegate = nil
        searchTextField.delegate = nil
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    //搜索
    @IBAction func didSearchButtonTouchUpInside(_ sender: UIButton) {
        searchTextField.resignFirstResponder()
        doSearch(searchTextField)
    }
}

extension AddressSearchViewController {
    
    func setupNavigateView() {
        navigationItem.titleView = searchView
        searchView.layer.cornerRadius = 15
        searchView.layer.masksToBounds = true
        searchTextField.addTarget(self, action: #selector(textFieldDidChanged), for: .editingChanged)
    }
    
    fileprivate func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
}
extension AddressSearchViewController {

    //城市内检索：POI行政区划检索:行政区划检索是根据关键字检索适用于在「某个行政区划，如北京市、四川省等」搜索某个名称相关的POI，例如：查找北京市的“小吃”。
    func sendPoiCitySearchRequest() {
        let citySearchOption = BMKPOICitySearchOption()
        citySearchOption.pageIndex = currentPageIndex
        citySearchOption.pageSize = 20
        citySearchOption.city = city
        citySearchOption.keyword = keyword
        citySearchOption.isCityLimit = true
        if poiSearch.poiSearch(inCity: citySearchOption) {
            print("城市内检索发送成功！")
        }else {
            print("城市内检索发送失败！")
            addressArr.removeAll()
            tableView.reloadData()
        }
    }
    //POI圆形区域检索:圆形区域检索是一个圆形范围，适用于以某个位置为中心点，自定义检索半径值，搜索某个位置附近的POI。
    func sendPoiNearSearchRequest(_ coordinate: CLLocationCoordinate2D) {
        let nearSearchOption = BMKPOINearbySearchOption()
        nearSearchOption.pageIndex = currentPageIndex
        nearSearchOption.pageSize = 20
        nearSearchOption.location = coordinate
        nearSearchOption.keywords = ["大厦","小区","学校","酒店","餐馆","银行","商场"]
        nearSearchOption.tags = ["大厦","小区","学校","酒店","餐馆","银行","商场"]
        if poiSearch.poiSearchNear(by: nearSearchOption) {
            print("周边检索发送成功！")
        }else {
            print("周边检索发送失败！")
            addressArr.removeAll()
            tableView.reloadData()
        }
    }
}
// MARK: UITextField- UITextFieldDelegate
extension AddressSearchViewController: UITextFieldDelegate {
    @objc func textFieldDidChanged(_ textField: UITextField) {
       doSearch(textField)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        doSearch(textField)
        return true
    }
    //搜索
    func doSearch(_ textField: UITextField) {
        keyword = textField.text ?? ""
        if (textField.text?.count ?? 0) > 0 {
            sendPoiCitySearchRequest()
        }else {
            sendPoiNearSearchRequest(targetCoordinate)
        }
    }
}

// MARK: 周围检索- BMKPoiSearchDelegate
extension AddressSearchViewController: BMKPoiSearchDelegate{
    /**
     *返回POI搜索结果
     *@param searcher 搜索对象
     *@param poiResult 搜索结果列表
     *@param errorCode 错误号，@see BMKSearchErrorCode
     */
    func onGetPoiResult(_ searcher: BMKPoiSearch!, result poiResult: BMKPOISearchResult!, errorCode: BMKSearchErrorCode) {
        if errorCode == BMK_SEARCH_NO_ERROR {
            addressArr.removeAll()
            for (index,poi) in poiResult.poiInfoList.enumerated() {
                let distance = BMKMetersBetweenMapPoints(BMKMapPointForCoordinate(targetCoordinate), BMKMapPointForCoordinate(poi.pt))
                var place = PlaceEntity.init(location: poi.pt, addressName: poi.name, addressDetail: poi.address)
                place.distance = distance
                addressArr.append(place)
            }
            tableView.reloadData()
        } else if errorCode == BMK_SEARCH_AMBIGUOUS_KEYWORD {
            //检索词有歧义
            addressArr.removeAll()
            tableView.reloadData()
        } else {
            // 各种情况的判断……
            addressArr.removeAll()
            tableView.reloadData()
        }
    }
}

// MARK: - Delegate, Datasource of tableview
extension AddressSearchViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddressSearchTableViewCell") as? AddressSearchTableViewCell  else {
            return UITableViewCell()
        }
        cell.addressLabel.text = addressArr[indexPath.row].addressName
        cell.addressDetailLabel.text = addressArr[indexPath.row].addressDetail
        cell.distanceLabel.text = "\(addressArr[indexPath.row].distanceString)"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
