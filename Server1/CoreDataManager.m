//
//  CoreDataManager.m
//  Server1
//
//  Created by Huawei on 2021/8/30.
//

#import "CoreDataManager.h"
#import <CoreData/CoreData.h>

@implementation CoreDataManager

static CoreDataManager * sharedManager = nil;

/// 获取管理者单例, 但还没有屏蔽单独实例化
+(instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[CoreDataManager alloc] init];
    });
    return sharedManager;
}

- (NSManagedObjectContext *)managerContext {
    if (_managerContext == nil) {
        // 创建上下文
        _managerContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSMainQueueConcurrencyType];
        
        // 设置持久化存储协调器
        // 创建模型文件
        NSURL * url = [[NSBundle mainBundle] URLForResource: @"Server1" withExtension: @"momd"];
        // 通过路径拿到 momd 中所有的 model
        NSManagedObjectModel * model = [[NSManagedObjectModel alloc] initWithContentsOfURL: url];
        NSPersistentStoreCoordinator * per = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: model];
        
        // 数据库文件
        NSError * err;
        // 指定数据库的路径
        // FIXME: 这里路径需要替换!!!
        #warning 这里的数据库保存路径需要更换为自己需要的路径记得保留最后的client.db
        NSURL * dbUrl = [NSURL fileURLWithPath: @"/Users/mabc/Desktop/GitHub/20210827/Server1/client.db"];
        // 设置数据库的类型 以及管理条件 inout 错误
        [per addPersistentStoreWithType: NSSQLiteStoreType configuration: nil URL: dbUrl options:nil error: &err];
        
        // 设置上下文的调度者
        _managerContext.persistentStoreCoordinator = per;
    }
    return _managerContext;
}

@end
