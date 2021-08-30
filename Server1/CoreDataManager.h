//
//  CoreDataManager.h
//  Server1
//
//  Created by Huawei on 2021/8/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NSManagedObjectContext;
@interface CoreDataManager : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@property (nonatomic, strong) NSManagedObjectContext * managerContext;

+(instancetype)sharedManager;

@end

NS_ASSUME_NONNULL_END
