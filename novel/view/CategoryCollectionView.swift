//
//  CategoryCollectionView.swift
//  future-v2
//
//  Created by kangyonggan on 8/25/17.
//  Copyright © 2017 kangyonggan. All rights reserved.
//

import UIKit
import Just

class CategoryCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // 常量
    let CELL_ID = "CategoryCollectionCell";
    
    // 全部分类
    var categories = [Category]();
    
    // 选中的分类
    var selectedCategory: Category!;
    
    // 加载中菊花
    var loadingView: UIActivityIndicatorView!;
    var viewController: UIViewController!;
    
    // 加载数据
    func loadData(_ categories: [Category]) {
        self.categories = categories;
        self.reloadData();
    }
    
    // collection view //
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_ID, for: indexPath) as! CategoryCollectionCell;
        
        cell.initData(categories[indexPath.row]);
        
        return cell;
    }
    
    // 选中事件
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isLoading() {
            return;
        }
        
        selectedCategory = categories[indexPath.row];
        
        // 启动加载中菊花
        loadingView = ViewUtil.loadingView(viewController.view);
        
        // 使用异步请求
        Http.post(UrlConstants.BOOK_CATEGORY, params: ["categoryCode": selectedCategory.code], callback: bookCategoryCallback)
    }
    
    // 回调
    func bookCategoryCallback(res: HTTPResult) {
        stopLoading();
        
        let result = Http.parse(res);
        
        var resBooks = [Book]();
        if result.0 {
            let books = result.2["books"] as! NSArray;
            for b in books {
                let bk = b as! NSDictionary
                let book = Book(bk);
                
                resBooks.append(book);
            }
        } else {
            Toast.showMessage(result.1, onView: self)
            return;
        }
        
//        DispatchQueue.main.async {
//            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BookTableViewController") as! BookTableViewController;
//            vc.books = resBooks;
//            vc.refreshNav(self.selectedCategory.name)
//            self.viewController.navigationController?.pushViewController(vc, animated: true);
//        }
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

