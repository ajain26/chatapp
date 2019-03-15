//
//  UserLIstTableViewCell.swift
//  Chat
//
//  Created by AnshulJain on 06/08/18.
//  Copyright © 2018 AnshulJain. All rights reserved.
//

import UIKit

class UserLIstTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var viewCircle: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        viewCircle.makeCircular();
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
