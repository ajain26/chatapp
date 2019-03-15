//
//  Language.swift
//  Chat
//
//  Created by AnshulJain on 02/11/2018.
//  Copyright © 2018 AnshulJain. All rights reserved.
//

import UIKit

class Language: NSObject {
    
    var language: String?
    var code: String?
    
    init(response:[String:String]?) {
//        self.language = response?.object(forKey: "Language")
//        self.code = response?.object(forKey: "Code")
        
        self.language = response?["Language"]
        self.code = response?["Code"]
    }

}
