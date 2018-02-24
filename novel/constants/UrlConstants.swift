//
//  UrlConstants.swift
//  future-v2
//
//  Created by kangyonggan on 8/24/17.
//  Copyright © 2017 kangyonggan. All rights reserved.
//

import Foundation

// 请求地址常量
class UrlConstants: NSObject {
    
    // 域名
//    static let DOMAIN = "https://kangyonggan.com/";
    static let DOMAIN = "http://127.0.0.1:8081/";
    
    // 手机端前缀
    static let MOBILE = "mobile/";
    
    // 全部分类
    static let CATEGORY_ALL = MOBILE + "category/all";
    
    // 推荐小说
    static let BOOK_HOTS = MOBILE + "book/hots";
    
    // 搜索小说
    static let BOOK_SEARCH = MOBILE + "book/search";
    
    // 分类小说
    static let BOOK_CATEGORY = MOBILE + "book/category";
    
    // 小说第一章
    static let SECTION_FIRST = MOBILE + "section/first";
    
    // 查找章节
    static let SECTION = MOBILE + "section";
    
    // 章节缓存
    static let SECTION_CACHE = MOBILE + "section/cache";
    
    // 全部章节
    static let SECTION_ALL = MOBILE + "section/all";
    
}

