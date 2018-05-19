//
//  FlairTemplate.swift
//  reddift-iOS
//
//  Created by Carlos Crane on 5/19/18.
//  Copyright © 2018 sonson. All rights reserved.
//

import Foundation

/**
 FlairTemplate object
 */
public struct FlairTemplate: Thing {
    /// identifier of Thing like 15bfi0.
    public let id: String

    public let cssClass: String
    
    /// Flair data
    public let editable: Boolean
    public let text: String
    
    public init(json: JSONDictionary) {
        id = json["flair_template_id"] as? String ?? ""
        cssClass = json["flair_css_class"] as? String ?? ""
        editable = json["flair_text_editable"] as? Boolean ?? false
        text = json["flair_text"] as? String ?? ""
    }
}
