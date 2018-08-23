//
//  UserAddressMapTableViewCell.swift
//  iFoodMacau
//
//  Created by ning on 2018/8/22.
//  Copyright © 2018年 CYCON.com. All rights reserved.
//

import UIKit

class AddressAddMapTableViewCell: UITableViewCell {
    //地址
    @IBOutlet weak var addressLabel: UILabel!
    //详细地址
    @IBOutlet weak var addressDetailLabel: UILabel!
    //图标
    @IBOutlet weak var iconImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
