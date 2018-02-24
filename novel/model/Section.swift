//
//  Section.swift
//  future-v2
//
//  Created by kangyonggan on 8/25/17.
//  Copyright © 2017 kangyonggan. All rights reserved.
//

import Foundation

// 章节
class Section: NSObject {
    
    override init() {
        
    }
    
    init(_ ss: NSDictionary) {
        self.bookCode = ss["bookCode"] as? Int;
        self.code = ss["code"] as? Int;
        self.title = ss["title"] as? String;
        self.content = ss["content"] as? String;
        self.prevSectionCode = ss["prevSectionCode"] as? Int;
        self.nextSectionCode = ss["nextSectionCode"] as? Int;
    }
    
    // 书籍代码
    var bookCode:Int!;
    
    // 章节代码
    var code: Int!;
    
    // 标题
    var title: String!;
    
    // 内容
    var content: String!;
    
    // 上一章节代码
    var prevSectionCode: Int!
    
    // 下一章节代码
    var nextSectionCode: Int!
}

