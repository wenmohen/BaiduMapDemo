//
//  PlaceModel.swift
//  BaiduMapDemo
//
//  Created by ning on 2018/8/23.
//  Copyright © 2018年 ning. All rights reserved.
//

import UIKit
struct PlaceEntity {
    var addressDetail: String = ""
    var addressName: String = ""
    var location: CLLocationCoordinate2D 
    var city: String = ""
    init(location: CLLocationCoordinate2D, addressName: String, addressDetail: String, city: String = "") {
        self.location = location
        self.addressName = addressName
        self.addressDetail = addressDetail
        self.city = city
    }
}
