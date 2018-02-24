//
//  SettingController.swift
//  future-v2
//
//  Created by kangyonggan on 8/25/17.
//  Copyright © 2017 kangyonggan. All rights reserved.
//

import UIKit

class SettingController: UIViewController {
    
    // 控件
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var themeLabel: UILabel!
    @IBOutlet weak var cacheSwitch: UISwitch!
    
    // 数据库
    let dictionaryDao = DictionaryDao();
    let sectionDao = SectionDao();
    
    // 数据
    var book:Book!;
    
    // 主题
    var themes = [(String, String)]();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView();
    }
    
    // 初始化界面
    func initView() {
        self.navigationController?.setNavigationBarHidden(false, animated: false);
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "返回", style: .done, target: nil, action: nil)
        themes = AppConstants.themes();
        
        // 初始化字体大小控件
        let fontDict = dictionaryDao.findDictionaryBy(type: DictionaryKey.TYPE_DEFAULT, key: DictionaryKey.FONT_SIZE);
        
        if fontDict == nil {
            slider.setValue(22, animated: false);
        } else {
            slider.setValue(Float((fontDict!.value)!)!, animated: true);
        }
        
        // 初始化开关
        let cacheDict = dictionaryDao.findDictionaryBy(type: DictionaryKey.TYPE_DEFAULT, key: DictionaryKey.AUTO_CACHE);
        if cacheDict == nil {
            cacheSwitch.isOn = true;
        } else {
            if cacheDict!.value == "1" {
                cacheSwitch.isOn = true;
            } else {
                cacheSwitch.isOn = false;
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        updateThemeLabel();
    }
    
    func updateThemeLabel() {
        let dict = dictionaryDao.findDictionaryBy(type: DictionaryKey.TYPE_DEFAULT, key: DictionaryKey.THEME);
        
        if dict != nil {
            for theme in themes {
                if theme.1 == dict!.value {
                    themeLabel.text = theme.0;
                    break;
                }
            }
        }
    }
    
    // 修改字体大小
    @IBAction func changeSize(_ sender: Any) {
        dictionaryDao.delete(type: DictionaryKey.TYPE_DEFAULT, key: DictionaryKey.FONT_SIZE)
        
        let dict = Dictionary();
        dict.type = DictionaryKey.TYPE_DEFAULT;
        dict.key = DictionaryKey.FONT_SIZE;
        dict.value = String(slider.value);
        
        dictionaryDao.save(dict);
    }
    
    // 开启缓存
    @IBAction func openCache(_ sender: Any) {
        let isOn = (sender as? UISwitch)?.isOn;
        
        dictionaryDao.delete(type: DictionaryKey.TYPE_DEFAULT, key: DictionaryKey.AUTO_CACHE);
        
        let dict = Dictionary();
        dict.type = DictionaryKey.TYPE_DEFAULT;
        dict.key = DictionaryKey.AUTO_CACHE;
        dict.value = isOn! ? "1" : "0";
        
        dictionaryDao.save(dict);
    }
    
    // 清空缓存
    @IBAction func clearCache(_ sender: Any) {
        sectionDao.deleteSections(self.book.code);
        Toast.showMessage("缓存已经清空", onView: self.view);
    }
}

