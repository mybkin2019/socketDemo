//
//  SendMessageVC.m
//  Server1
//
//  Created by Huawei on 2021/8/30.
//

#import "SendMessageVC.h"
#import "Client+CoreDataProperties.h"

@interface SendMessageVC ()

@property (unsafe_unretained) IBOutlet NSTextView *messageTextView;

@end

@implementation SendMessageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *titleString = [NSString stringWithFormat:@"ip: %@ || port: %lld", self.client.ipaddress, self.client.port];
    self.title = titleString;
}

- (IBAction)sendMessageBtnClicked:(id)sender {
    
    // 发送数据
    NSDictionary * infoDict = @{
        @"client": _client,
        @"message": _messageTextView.string
    };
    
    // 发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName: SendMessageNotification object: self userInfo: infoDict];
}


@end
