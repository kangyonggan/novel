//
//  BookDao.swift
//  future-v2
//
//  Created by kangyonggan on 8/25/17.
//  Copyright © 2017 kangyonggan. All rights reserved.
//


import UIKit
import CoreData

class BookDao: NSObject {
    
    var managedObjectContext: NSManagedObjectContext!
    let entityName = "TBook";
    
    override init() {
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    // 保存小说
    func save(_ book: Book) {
        let newEntity = NSEntityDescription.insertNewObject(forEntityName: entityName, into: managedObjectContext);
        
        newEntity.setValue(book.code, forKey: "code");
        newEntity.setValue(book.name, forKey: "name");
        newEntity.setValue(book.author, forKey: "author");
        newEntity.setValue(book.categoryCode, forKey: "categoryCode");
        newEntity.setValue(book.categoryName, forKey: "categoryName");
        newEntity.setValue(book.picUrl, forKey: "picUrl");
        newEntity.setValue(book.descp, forKey: "descp");
        newEntity.setValue(book.isFinished, forKey: "isFinished");
        newEntity.setValue(book.newSectionCode, forKey: "newSectionCode");
        newEntity.setValue(book.newSectionTitle, forKey: "newSectionTitle");
        newEntity.setValue(book.lastSectionCode, forKey: "lastSectionCode");
        newEntity.setValue(book.isFavorite, forKey: "isFavorite");
        newEntity.setValue(Date(), forKey: "createdTime");
        
        do {
            try managedObjectContext.save()
        } catch {
            fatalError();
        }
    }
    
    // 删除小说
    func delete(code: Int) {
        do{
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName);
            let predicate = NSPredicate(format: "code=%@", String(code));
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
    
    // 查找收藏的小说
    func findAllFavoriteBooks() -> [Book] {
        var books = [Book]();
        do{
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName);
            let predicate = NSPredicate(format: "isFavorite == %@", NSNumber(value: true))
            request.predicate = predicate;
            
            // 倒序
            var sorts = [NSSortDescriptor]();
            sorts.append(NSSortDescriptor(key: "createdTime", ascending: false));
            request.sortDescriptors = sorts;
            
            let rows = try managedObjectContext.fetch(request) as! [NSManagedObject];
            
            
            for row in rows {
                let dict = Book();
                dict.code = (row.value(forKey: "code") as? Int)!;
                dict.name = (row.value(forKey: "name") as? String)!;
                dict.author = (row.value(forKey: "author") as? String)!;
                dict.categoryCode = (row.value(forKey: "categoryCode") as? String)!;
                dict.categoryName = (row.value(forKey: "categoryName") as? String)!;
                dict.picUrl = (row.value(forKey: "picUrl") as? String)!;
                dict.descp = (row.value(forKey: "descp") as? String)!;
                dict.isFinished = (row.value(forKey: "isFinished") as? Bool)!;
                dict.newSectionCode = (row.value(forKey: "newSectionCode") as? Int);
                dict.newSectionTitle = (row.value(forKey: "newSectionTitle") as? String);
                dict.lastSectionCode = (row.value(forKey: "lastSectionCode") as? Int);
                dict.isFavorite = (row.value(forKey: "isFavorite") as? Bool);
                
                books.append(dict);
            }
        }catch{
            fatalError();
        }
        
        return books;
    }
    
    // 查询小说
    func findBookByCode(_ code: Int) -> Book? {
        do{
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName);
            let predicate = NSPredicate(format: "code=%@", String(code));
            request.predicate = predicate;
            
            let rows = try managedObjectContext.fetch(request) as! [NSManagedObject];
            
            let dict = Book();
            for row in rows {
                dict.code = (row.value(forKey: "code") as? Int)!;
                dict.name = (row.value(forKey: "name") as? String)!;
                dict.author = (row.value(forKey: "author") as? String)!;
                dict.categoryCode = (row.value(forKey: "categoryCode") as? String)!;
                dict.categoryName = (row.value(forKey: "categoryName") as? String)!;
                dict.picUrl = (row.value(forKey: "picUrl") as? String)!;
                dict.descp = (row.value(forKey: "descp") as? String)!;
                dict.isFinished = (row.value(forKey: "isFinished") as? Bool)!;
                dict.newSectionCode = (row.value(forKey: "newSectionCode") as? Int);
                dict.newSectionTitle = (row.value(forKey: "newSectionTitle") as? String);
                dict.lastSectionCode = (row.value(forKey: "lastSectionCode") as? Int);
                dict.isFavorite = (row.value(forKey: "isFavorite") as? Bool);
                
                return dict;
            }
        }catch{
            fatalError();
        }
        
        return nil;
    }
}

