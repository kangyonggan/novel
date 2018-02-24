//
//  SectionDao.swift
//  future-v2
//
//  Created by kangyonggan on 8/25/17.
//  Copyright © 2017 kangyonggan. All rights reserved.
//

import UIKit
import CoreData

class SectionDao: NSObject {
    
    var managedObjectContext: NSManagedObjectContext!
    let entityName = "TSection";
    
    override init() {
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    // 批量保存章节
    func save(_ sections: [Section]) {
        for section in sections {
            let newEntity = NSEntityDescription.insertNewObject(forEntityName: entityName, into: managedObjectContext);
            
            newEntity.setValue(section.code, forKey: "code");
            newEntity.setValue(section.title, forKey: "title");
            newEntity.setValue(section.bookCode, forKey: "bookCode");
            newEntity.setValue(section.content, forKey: "content");
            newEntity.setValue(section.nextSectionCode, forKey: "nextSectionCode");
            newEntity.setValue(section.prevSectionCode, forKey: "prevSectionCode");
        }
        
        do {
            try managedObjectContext.save()
        } catch {
            fatalError();
        }
    }
    
    // 删除某小说的缓存章节
    func deleteSections(_ byBookCode: Int) {
        do{
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName);
            let predicate = NSPredicate(format: "bookCode=%@", String(byBookCode));
            request.predicate = predicate;
            
            let rows = try managedObjectContext.fetch(request) as! [NSManagedObject];
            
            for row in rows {
                managedObjectContext.delete(row);
            }
            
            try managedObjectContext.save();
        }catch{
            fatalError();
        }
    }
    
    // 根据章节代码查找章节
    func findSection(_ byCode: Int) -> Section? {
        do{
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName);
            let predicate = NSPredicate(format: "code=%@", String(byCode));
            request.predicate = predicate;
            
            let rows = try managedObjectContext.fetch(request) as! [NSManagedObject];
            
            let dict = Section();
            for row in rows {
                dict.code = (row.value(forKey: "code") as? Int)!;
                dict.title = (row.value(forKey: "title") as? String)!;
                dict.content = (row.value(forKey: "content") as? String)!;
                dict.bookCode = (row.value(forKey: "bookCode") as? Int)!;
                dict.nextSectionCode = (row.value(forKey: "nextSectionCode") as? Int)!;
                dict.prevSectionCode = (row.value(forKey: "prevSectionCode") as? Int)!;
                
                return dict;
            }
        }catch{
            fatalError();
        }
        
        return nil;
    }
    
}

