//
//  ViewController.m
//  Server1
//
//  Created by Huawei on 2021/8/27.
//

#import "MainVC.h"
#import "GCDAsyncSocket.h"
#import "Client+CoreDataProperties.h"
#import "CoreDataManager.h"

@interface MainVC()<GCDAsyncSocketDelegate>

@property (weak) IBOutlet NSTextField *portTF;

@property (nonatomic, strong) GCDAsyncSocket * socket;

@property (nonatomic, strong) NSMutableArray * socketArray;

@property (nonatomic, strong) NSTimer * readDataTimer;

@end

@implementation MainVC

// MARK: - Lazy Load
- (NSMutableArray *)socketArray {
    if (_socketArray == nil) {
        _socketArray = [NSMutableArray array];
    }
    return _socketArray;
}

- (GCDAsyncSocket *)socket {
    if (_socket == nil) {
        _socket = [[GCDAsyncSocket alloc] initWithDelegate: self delegateQueue: dispatch_get_main_queue()];
        [_socket setIPv4PreferredOverIPv6: NO];
    }
    return _socket;
}

- (NSTimer *)readDataTimer {
    if (_readDataTimer == nil) {
        _readDataTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(readData) userInfo:nil repeats:YES]; 
    }
    return _readDataTimer;
}

- (IBAction)listenPort:(NSButton *)sender {
    
    int portNumber = _portTF.intValue;
    NSLog(@"port => %d", portNumber);
    
    NSError * error = nil;
    [self.socket acceptOnPort: portNumber error: &error];
    
    if (error != nil) {
        NSLog(@"需要处理 error => %@", [error localizedDescription]);
    } else {
        NSLog(@"scoket bind success");
    }
    
    NSLog(@"开启读取 socket 数据");
    [[NSRunLoop currentRunLoop] addTimer: self.readDataTimer  forMode: NSRunLoopCommonModes];
}

- (void)readData {
    for (GCDAsyncSocket * socket in self.socketArray) {
        [socket readDataWithTimeout: -1 tag: 0];
    }
}

- (IBAction)stopReadMessageFromSocket:(id)sender {
    
    if (_readDataTimer != nil) {
        [_readDataTimer invalidate];
        _readDataTimer = nil;
    }
}

// 显示更多客户端
- (IBAction)showMoreClientVC:(id)sender {
    [self performSegueWithIdentifier:@"showMore" sender: nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self observeNotification];
}

- (void)observeNotification {
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(handleSendMessageNotification:) name: SendMessageNotification object: nil];
}

- (void)handleSendMessageNotification:(NSNotification *)noti {
    NSLog(@"发送信息回去 socket");
    NSDictionary * info = noti.userInfo;
    NSString * msgString = info[@"message"];
    Client * sendClient = info[@"client"];
    
    NSData * msgData = [msgString dataUsingEncoding: NSUTF8StringEncoding];
    
    NSLog(@"sendClient => %@", sendClient);
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"connectedHost = %@ and connectedPort = %@", sendClient.ipaddress, @(sendClient.port)];
    
    NSArray * sortedSocketsArr = [_socketArray filteredArrayUsingPredicate: predicate];
    
    NSLog(@"sorted => %lu", sortedSocketsArr.count);
    
    for (GCDAsyncSocket * socket in _socketArray) {
        [socket writeData: msgData withTimeout: -1 tag: 0];
    }
}

// MARK: - GCDSocketDelegate

// 收到新的 socket 连接 => 进行持久化存储
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    [self.socketArray addObject: newSocket];
    NSLog(@"newSocket => %@", newSocket);
    
    CoreDataManager * manager = [CoreDataManager sharedManager];
    
    // 存储
    Client * client = [NSEntityDescription insertNewObjectForEntityForName:@"Client" inManagedObjectContext:manager.managerContext];
    
    // 赋值
    client.ipaddress = newSocket.connectedHost;
    client.port = newSocket.connectedPort;
    client.connectTime = [[NSDate alloc] init];
    client.disconnectTime = nil;
    
    // 提交保存
    NSError *saveError = nil;
    [manager.managerContext save: &saveError];
    
    // 处理错误
    if (saveError != nil) {
        NSLog(@"处理 save error => %@", [saveError localizedDescription]);
    }
    
    // 通知更多客户端更新界面操作
    NSNotification * notification = [NSNotification notificationWithName: MoreClientConnectedNotification object: self userInfo: @{@"client":client}];
    [[NSNotificationCenter defaultCenter] postNotification: notification];
    NSLog(@"发送通知成功");
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString * msgString = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSLog(@"收到信息 => %@", msgString);
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
