//
//  AddressSearchTableViewCell.swift
//  BaiduMapDemo
//
//  Created by ning on 2018/8/24.
//  Copyright © 2018年 ning. All rights reserved.
//

import UIKit

class AddressSearchTableViewCell: UITableViewCell {
    //地址
    @IBOutlet weak var addressLabel: UILabel!
    //详细地址
    @IBOutlet weak var addressDetailLabel: UILabel!
    //距离
    @IBOutlet weak var distanceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
