//
//  BookTableCell.swift
//  future-v2
//
//  Created by kangyonggan on 8/25/17.
//  Copyright © 2017 kangyonggan. All rights reserved.
//

import UIKit

class BookTableViewCell: UITableViewCell {
    
    // 组件
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    // 初始化
    func initView(_ book: Book) {
        nameLabel.text = book.name;
        authorLabel.text = book.author;
        descLabel.text = book.descp.isEmpty ? "暂无简介" : book.descp;
        if book.isFinished! {
            statusLabel.text = "完结";
        } else {
            statusLabel.text = "连载";
        }
        
        statusLabel.layer.borderColor = AppConstants.MASTER_COLOR.cgColor;
        statusLabel.layer.borderWidth = 1;
        statusLabel.layer.cornerRadius = 3;
        
        // 异步加载封面
        CacheImage().load(named: book.picUrl, to: coverImage, withDefault: AppConstants.NO_COVER_IMAGE);
    }
    
    
}

