//
//  Category.swift
//  future-v2
//
//  Created by kangyonggan on 8/25/17.
//  Copyright © 2017 kangyonggan. All rights reserved.
//

import Foundation

// 分类
class Category: NSObject {
    
    override init() {
        
    }
    
    init(_ cc: NSDictionary) {
        self.code = cc["code"] as? String;
        self.name = cc["name"] as? String;
        self.bookCnt = cc["bookCnt"] as? Int;
    }
    
    // 分类代码
    var code: String!;
    
    // 分类名称
    var name: String!;
    
    // 此分类小说数量
    var bookCnt: Int!;
    
}

