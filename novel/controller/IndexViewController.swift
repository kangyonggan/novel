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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView();
        
        initData();
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // 初始化界面
    func initView() {
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
        
        // 引用传递
        categoryCollectionView.viewController = self;
    }
    
    // 初始化数据
    func initData() {
        // 加载小说分类
        if categories.isEmpty {
            // 使用异步请求
            Http.post(UrlConstants.CATEGORY_ALL, callback: categoryCallback);
            
        }
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
}

