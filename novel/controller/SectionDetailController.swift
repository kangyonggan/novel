//
//  SectionDetailController.swift
//  future-v2
//
//  Created by kangyonggan on 8/25/17.
//  Copyright © 2017 kangyonggan. All rights reserved.
//

import UIKit
import Just

class SectionDetailController: UIViewController, UIWebViewDelegate  {
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var favoriteBtn: UIBarButtonItem!
    
    // 数据
    var book: Book!;
    var section: Section!;
    var sections = [Section]();
    
    // 标识, 后台缓存标识
    var isCacheTerminalTask = false;
    
    // 加载中菊花图标
    var loadingView: UIActivityIndicatorView!;
    
    // 是否显示导航条
    var isShowBar = false;
    
    // 数据库
    let bookDao = BookDao();
    let sectionDao = SectionDao();
    let dictionaryDao = DictionaryDao();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        initView();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        // 更新字体大小和主题
        updateSizeAndTheme();
        
        // 不显示导航条
        self.navigationController?.setNavigationBarHidden(true, animated: false);
    }
    
    // 更新字体大小和主题
    func updateSizeAndTheme() {
        let sizeDict = dictionaryDao.findDictionaryBy(type: DictionaryKey.TYPE_DEFAULT, key: DictionaryKey.FONT_SIZE);
        
        var size = 22;
        if sizeDict != nil {
            let fSize = Float((sizeDict!.value)!);
            size = Int(fSize!);
        }
        
        webView.stringByEvaluatingJavaScript(from: "document.getElementsByTagName('body')[0].style.fontSize='\(size)px'");
        
        let themeDict = dictionaryDao.findDictionaryBy(type: DictionaryKey.TYPE_DEFAULT, key: DictionaryKey.THEME);
        
        var theme = "#FFFFFF";
        if themeDict != nil {
            theme = (themeDict!.value)!;
        }
        
        webView.stringByEvaluatingJavaScript(from: "document.getElementsByTagName('body')[0].style.background='\(theme)'");
        
    }
    
    // 初始化界面
    func initView() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "返回", style: .done, target: nil, action: nil)
        
        webView.delegate = self;
        
        setFavoriteIcon();
        
        updateContent();
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        updateSizeAndTheme();
        webView.stringByEvaluatingJavaScript(from: "document.getElementsByTagName('body')[0].style.webkitTextFillColor='#555555'");
    }
    
    // 更新内容
    func updateContent() {
        DispatchQueue.main.async {
            self.navigationItem.title = self.section.title;
            self.webView.loadHTMLString(self.section.title + "<br/><br/>" + self.section.content, baseURL: nil);
        }
    }
    
    // 设置是否是收藏的图标
    func setFavoriteIcon() {
        if book.isFavorite {
            self.favoriteBtn.image = UIImage(named: "favorite");
        } else {
            self.favoriteBtn.image = UIImage(named: "favorite-no");
        }
    }
    
    // 收藏/取消收藏
    @IBAction func setFavorite(_ sender: Any) {
        bookDao.delete(code: book.code);
        
        book.isFavorite = !book.isFavorite;
        book.lastSectionCode = section.code;
        bookDao.save(book);
        
        setFavoriteIcon();
        
        if book.isFavorite {
            Toast.showMessage("收藏成功", onView: self.view)
        } else {
            Toast.showMessage("取消收藏", onView: self.view)
        }
    }
    
    // 下一章
    @IBAction func nextSection(_ sender: Any) {
        if isLoading() {
            return;
        }
        
        if (section.nextSectionCode == 0) {
            Toast.showMessage("已经是最后一章了", onView: self.view);
            // 清空这本小说的章节缓存，这样的话，下次就会去走接口获取最新的有下一章的章节
            sectionDao.deleteSections(book.code);
            return;
        }
        
        // 先走缓存，如果缓存有，直接使用
        // 如果缓存中没有，则调接口，如果开启了缓存，后台缓存后面100章
        let tSection = sectionDao.findSection(section.nextSectionCode);
        if tSection == nil {
            // 没缓存，走接口查询
            loadSection(section.nextSectionCode)
            
            // 判断是否是自动缓存，如果是，则后台缓存后面100章
            let autoCacheDict = dictionaryDao.findDictionaryBy(type: DictionaryKey.TYPE_DEFAULT, key: DictionaryKey.AUTO_CACHE)
            if autoCacheDict == nil || autoCacheDict!.value! == "1" {
                // 后台缓存100章，并标志“正在缓存”，防止重复调用后台缓存
                if !isCacheTerminalTask {
                    isCacheTerminalTask = true;
                    // 后台缓存100章
                    Http.post(UrlConstants.SECTION_CACHE, params: ["code": section.nextSectionCode], callback: sectionCacheCallback)
                }
            }
        } else {
            // 有缓存, 直接显示章节内容
            self.section = tSection;
            self.updateContent();
            
            // 更新本地小说的最后阅读章节
            updateLastBookSection();
        }
    }
    
    // 缓存章节回调
    func sectionCacheCallback(res: HTTPResult) {
        isCacheTerminalTask = false;
        
        let result = Http.parse(res);
        if result.0 {
            var secs = [Section]();
            let resSections = result.2["sections"] as! NSArray;
            for s in resSections {
                let ss = s as! NSDictionary
                let section = Section(ss);
                
                secs.append(section);
            }
            
            // 先删后存
            sectionDao.deleteSections(self.book.code);
            sectionDao.save(secs);
            
            Toast.showMessage("后面100章节已经缓存", onView: self.view);
        } else {
            Toast.showMessage("网络异常，无法自动缓存后面100章节", onView: self.view);
        }
    }
    
    // 加载章节
    func loadSection(_ code: Int) {
        // 启动加载中菊花
        loadingView = ViewUtil.loadingView(self.view);
        
        // 使用异步请求
        Http.post(UrlConstants.SECTION, params: ["code": code], callback: sectionCallback)
    }
    
    // 加载章节的回调
    func sectionCallback(res: HTTPResult) {
        stopLoading();
        
        let result = Http.parse(res);
        
        if result.0 {
            let ss = result.2["section"] as! NSDictionary;
            self.section = Section(ss);
        } else {
            Toast.showMessage(result.1, onView: self.view);
            return;
        }
        
        updateContent();
        
        updateLastBookSection();
    }
    
    // 更新本地小说的最后阅读章节
    func updateLastBookSection() {
        DispatchQueue.main.async {
            self.book.lastSectionCode = self.section.code;
            self.bookDao.delete(code: self.book.code);
            self.bookDao.save(self.book);
        }
    }
    
    // 上一章
    @IBAction func prevSection(_ sender: Any) {
        if isLoading() {
            return;
        }
        
        if (section.prevSectionCode == 0) {
            Toast.showMessage("已经是第一章了", onView: self.view);
            return;
        }
        
        // 先走缓存，如果缓存有，直接使用
        // 如果缓存中没有，则调接口
        let tSection = sectionDao.findSection(section.prevSectionCode);
        if tSection == nil {
            // 没缓存，走接口查询
            loadSection(section.prevSectionCode)
        } else {
            // 有缓存, 直接显示章节内容
            self.section = tSection;
            self.updateContent();
            
            // 更新本地小说的最后阅读章节
            updateLastBookSection();
        }
    }
    
    // 显示/隐藏 导航栏
    @IBAction func hiddenBar(_ sender: Any) {
        changeBarState();
    }
    
    // 修改导航条状态
    func changeBarState() {
        if isShowBar {
            // 不显示
            self.navigationController?.setNavigationBarHidden(true, animated: false);
        } else {
            // 显示
            self.navigationController?.setNavigationBarHidden(false, animated: false);
        }
        
        isShowBar = !isShowBar;
    }
    
    // 设置
    @IBAction func showSetting(_ sender: Any) {
        if isLoading() {
            return;
        }
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SettingController") as! SettingController;
        vc.book = self.book;
        self.navigationController?.pushViewController(vc, animated: true);
    }
    
    // 判断是否正在加载
    func isLoading() -> Bool {
        return loadingView != nil && loadingView.isAnimating;
    }
    
    // 章节列表
    @IBAction func sectionList(_ sender: Any) {
        if isLoading() {
            return;
        }
        
        if sections.isEmpty {
            // 启动加载中菊花
            loadingView = ViewUtil.loadingView(self.view);
            
            // 使用异步请求
            Http.post(UrlConstants.SECTION_ALL, params: ["bookCode": book.code], callback: sectionsCallback)
        } else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SectionTableViewController") as! SectionTableViewController;
            vc.sections = self.sections;
            vc.selectedSection = self.section;
            vc.book = self.book;
            vc.viewController = self;
            vc.refreshNav(self.book.name!);
            self.navigationController?.pushViewController(vc, animated: true);
        }
    }
    
    // 加载章节列表的回调
    func sectionsCallback(res: HTTPResult) {
        stopLoading();
        
        let result = Http.parse(res);
        
        if result.0 {
            let resSections = result.2["sections"] as! NSArray;
            for s in resSections {
                let ss = s as! NSDictionary
                let section = Section(ss);
                
                self.sections.append(section);
            }
            
            DispatchQueue.main.async {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "SectionTableViewController") as! SectionTableViewController;
                vc.sections = self.sections;
                vc.selectedSection = self.section;
                vc.book = self.book;
                vc.viewController = self;
                vc.refreshNav(self.book.name);
                self.navigationController?.pushViewController(vc, animated: true);
            }
        } else {
            Toast.showMessage(result.1, onView: self.view);
        }
    }
    
    // 停止加载中动画
    func stopLoading() {
        DispatchQueue.main.async {
            self.loadingView.stopAnimating();
            self.loadingView.removeFromSuperview();
        }
    }
}

