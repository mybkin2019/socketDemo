//
//  SendMessageVC.h
//  Server1
//
//  Created by Huawei on 2021/8/30.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class Client;
@interface SendMessageVC : NSViewController

@property (nonatomic, strong) Client * client;

@end

NS_ASSUME_NONNULL_END
