//
//  IO_LeftMenuTableViewCell.swift
//  IO Left Menu
//
//  Created by ilker özcan on 28/08/15.
//  Copyright (c) 2015 ilkerozcan. All rights reserved.
//
//

import UIKit
import Foundation

/// Left menu UITableViewCell
public class IO_LeftMenuTableViewCell: UITableViewCell {

	@IBOutlet public weak var cellButton: UIButton!
	
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override public func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
