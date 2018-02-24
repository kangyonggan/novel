//
//  FavoriteCollectionView.swift
//  future-v2
//
//  Created by kangyonggan on 8/25/17.
//  Copyright © 2017 kangyonggan. All rights reserved.
//

import UIKit
import Just

class FavoriteCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // 常量
    let CELL_ID = "FavoriteCollectionCell";
    
    // 收藏的小说
    var books = [Book]();
    
    // 加载中菊花
    var loadingView: UIActivityIndicatorView!;
    
    // 选中的小说
    var selectedBook: Book!;
    
    // 数据库
    let bookDao = BookDao();
    let sectionDao = SectionDao();
    
    var viewController: UIViewController!;
    
    // 加载数据
    func loadData(_ books: [Book]) {
        self.books = books;
        self.reloadData();
    }
    
    // collection view //
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_ID, for: indexPath) as! FavoriteCollectionCell;
        
        cell.initData(books[indexPath.row]);
        
        return cell;
    }
    
    // 选中事件
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isLoading() {
            return;
        }
        
        selectedBook = books[indexPath.row];
        
        // 尝试从本地获取章节
        let section = sectionDao.findSection((selectedBook.lastSectionCode)!);
        
        if section != nil {// 本地有缓存此章节，直接跳到章节详情
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SectionDetailController") as! SectionDetailController;
            vc.book = self.selectedBook;
            vc.section = section;
            viewController.navigationController?.pushViewController(vc, animated: true);
        } else {// 本地没有缓存此章节，调接口
            // 加载中菊花
            loadingView = ViewUtil.loadingView(viewController.view);
            
            // 异步加载
            Http.post(UrlConstants.SECTION, params: ["code": selectedBook.lastSectionCode!], callback: sectionCallback);
        }
        
    }
    
    // 查找章节的回调
    func sectionCallback(res: HTTPResult) {
        stopLoading();
        
        let result = Http.parse(res);
        
        var section: Section!;
        if result.0 {
            let ss = result.2["section"] as! NSDictionary;
            section = Section(ss);
        } else {
            Toast.showMessage(result.1, onView: self)
            return;
        }
        
        DispatchQueue.main.async {
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SectionDetailController") as! SectionDetailController;
            vc.book = self.selectedBook;
            vc.section = section;
            self.viewController.navigationController?.pushViewController(vc, animated: true);
        }
    }
    
    // 判断是否正在加载
    func isLoading() -> Bool {
        return loadingView != nil && loadingView.isAnimating;
    }
    
    // 停止加载中动画
    func stopLoading() {
        DispatchQueue.main.async {
            self.loadingView.stopAnimating();
            self.loadingView.removeFromSuperview();
        }
    }
    
    
}

