//
//  BookListController.swift
//  future-v2
//
//  Created by kangyonggan on 8/25/17.
//  Copyright © 2017 kangyonggan. All rights reserved.
//

import UIKit
import Just

class BookTableViewController: UITableViewController {
    
    let CELL_ID = "BookTableViewCell";
    var books = [Book]();
    
    // 加载中菊花
    var loadingView: UIActivityIndicatorView!;
    
    // 选中的小说
    var selectedBook: Book!;
    
    // 数据库
    let bookDao = BookDao();
    let sectionDao = SectionDao();
    
    override func viewDidLoad() {
        super.viewDidLoad();
    }
    
    func refreshNav(_ title: String) {
        self.navigationItem.title = title;
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "返回", style: .done, target: nil, action: nil)
    }
    
    // MARK: - Table View
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID, for: indexPath) as! BookTableViewCell;
        
        let book = books[indexPath.row]
        
        cell.initView(book);
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isLoading() {
            return;
        }
        
        selectedBook = books[indexPath.row];
        
        // 从本地读取book，获取用户最后读取的章节代码
        let book = bookDao.findBookByCode(selectedBook.code);
        
        // 如果本地没有，走接口获取小说第一章节
        if book == nil {
            // 加载中菊花
            loadingView = ViewUtil.loadingView(self.view);
            
            // 异步加载第一章
            Http.post(UrlConstants.SECTION_FIRST, params: ["bookCode": selectedBook.code], callback: sectionCallback);
        } else {
            selectedBook.isFavorite = book!.isFavorite;
            
            // 尝试从本地获取章节
            let section = sectionDao.findSection((book?.lastSectionCode)!);
            
            if section != nil {// 本地有缓存此章节，直接跳到章节详情
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SectionDetailController") as! SectionDetailController;
                vc.book = self.selectedBook;
                vc.section = section;
                self.navigationController?.pushViewController(vc, animated: true);
            } else {// 本地没有缓存此章节，调接口
                // 加载中菊花
                loadingView = ViewUtil.loadingView(self.view);
                
                // 异步加载
                Http.post(UrlConstants.SECTION, params: ["code": book!.lastSectionCode!], callback: sectionCallback);
            }
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
            Toast.showMessage(result.1, onView: self.tableView)
            return;
        }
        
        DispatchQueue.main.async {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SectionDetailController") as! SectionDetailController;
            vc.book = self.selectedBook;
            vc.section = section;
            self.navigationController?.pushViewController(vc, animated: true);
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

