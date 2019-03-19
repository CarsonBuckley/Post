//
//  Post.swift
//  Post
//
//  Created by Carson Buckley on 3/18/19.
//  Copyright © 2019 Launch. All rights reserved.
//

import Foundation

struct Post: Codable {
    
    let text: String
    let username: String
    let timestamp: TimeInterval
    
    init(text: String, username: String, timestamp: TimeInterval = Date().timeIntervalSince1970) {
        self.text = text
        self.username = username
        self.timestamp = timestamp
    }
    
    var queryTimestamp: TimeInterval {
        return self.timestamp - 0.00001
    }
    
    var date: String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: Date(timeIntervalSince1970: timestamp))
    }
}

