//
//  ViewController.swift
//  novel
//
//  Created by kangyonggan on 2/24/18.
//  Copyright © 2018 kangyonggan. All rights reserved.
//

import UIKit
import Just;

class IndexViewController: UIViewController {

    // 搜索框
    @IBOutlet weak var searchTextField: UITextField!
    
    // 搜索按钮
    @IBOutlet weak var searchButton: UIButton!
    
    // 小说分类视图
    @IBOutlet weak var categoryCollectionView: CategoryCollectionView!
    
    // 小说分类数据
    var categories = [Category]();
    
    // 加载中菊花
    var loadingView: UIActivityIndicatorView!;
    
    // 我的收藏
    @IBOutlet weak var favoriteCollectionView: FavoriteCollectionView!
    
    // 数据库
    let bookDao = BookDao();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView();
        
        initData();
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // 加载我的收藏
        let books = bookDao.findAllFavoriteBooks();
        self.favoriteCollectionView.loadData(books);
    }

    // 初始化界面
    func initView() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "返回", style: .done, target: nil, action: nil)
        
        // 修改返回按钮
        self.navigationController?.navigationBar.tintColor = UIColor.white;
        
        // 搜索框
        searchTextField.layer.borderWidth = 1;
        searchTextField.layer.cornerRadius = 3;
        searchTextField.layer.borderColor = UIColor(red: 191/255, green: 191/255, blue: 191/255, alpha: 1).cgColor;
        ViewUtil.addLeftView(searchTextField, withIcon: "search", width: 25, height: 25);
        
        // 搜索按钮
        searchButton.layer.cornerRadius = 5;
        
        // 绑定
        categoryCollectionView.delegate = categoryCollectionView;
        categoryCollectionView.dataSource = categoryCollectionView;
        
        favoriteCollectionView.delegate = favoriteCollectionView;
        favoriteCollectionView.dataSource = favoriteCollectionView;
        
        // 引用传递
        categoryCollectionView.viewController = self;
        favoriteCollectionView.viewController = self
        
    }
    
    // 初始化数据
    func initData() {
        // 加载小说分类
        if categories.isEmpty {
            // 使用异步请求
            Http.post(UrlConstants.CATEGORY_ALL, callback: categoryCallback);
            
        }
        
        // 加载我的收藏
        let books = bookDao.findAllFavoriteBooks();
        self.favoriteCollectionView.loadData(books);
    }
    
    // 加载小说分类的回调
    func categoryCallback(res: HTTPResult) {
        let result = Http.parse(res);
        
        if result.0 {
            self.categories = [];
            let categories = result.2["categories"] as! NSArray;
            DispatchQueue.main.async {
                for c in categories {
                    let cc = c as! NSDictionary
                    let category = Category(cc);
                    
                    self.categories.append(category);
                }
                
                // 渲染
                self.categoryCollectionView.loadData(self.categories);
            }
        } else {
            Toast.showMessage("网络错误，无法加载小说分类", onView: self.view);
        }
    }
    
    // 结束输入（立即搜索）
    @IBAction func end(_ sender: Any) {
        search(sender);
    }
    
    // 搜索
    @IBAction func search(_ sender: Any) {
        if isLoading() {
            return;
        }
        
        // 收起键盘
        UIApplication.shared.keyWindow?.endEditing(true);
        
        // 焦点给搜索按钮
        searchButton.becomeFirstResponder();
        
        // 关键字
        let key = searchTextField.text!;
        
        // 判断非空
        if key.isEmpty {
            Toast.showMessage("请输入搜索内容！", onView: self.view);
            return;
        }
        
        // 加载中菊花
        loadingView = ViewUtil.loadingView(self.view);
        
        // 异步加载
        Http.post(UrlConstants.BOOK_SEARCH, params: ["key": key], callback: bookSearchCallback)
    }
    
    // 搜索小说的回调
    func bookSearchCallback(res: HTTPResult) {
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
            Toast.showMessage(result.1, onView: self.view)
            return;
        }
        
        if resBooks.isEmpty {
            Toast.showMessage("没有符合条件的小说", onView: self.view);
            return;
        }
        
        DispatchQueue.main.async {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "BookTableViewController") as! BookTableViewController;
            vc.books = resBooks;
            vc.refreshNav("搜索结果")
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

