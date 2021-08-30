//
//  MoreClient.m
//  Server1
//
//  Created by Huawei on 2021/8/30.
//

#import "MoreClientVC.h"
#import "CoreDataManager.h"
//#import "GCDAsyncSocket.h"
#import "Client+CoreDataProperties.h"
#import "SendMessageVC.h"

@interface MoreClientVC ()<NSTableViewDelegate, NSTableViewDataSource>

@property (weak) IBOutlet NSTableView *socketsTableView;

@property (nonatomic, strong) NSArray<Client *> * socketsArr;

@property (nonatomic, strong) NSDateFormatter * dateFormatter;

@end

@implementation MoreClientVC

- (NSDateFormatter *)dateFormatter {
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"mm - dd EEEE a hh:mm:ss.SSS";
//        _formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        _dateFormatter.locale = [NSLocale currentLocale];
    }
    return _dateFormatter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self fetchData];
    [_socketsTableView reloadData];
    
    self.title = @"连接过的 sockets";
    
    // 监听通知
    [[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(handleMoreMoreClientConnectedNotification:) name:MoreClientConnectedNotification object: nil];
}

- (void)handleMoreMoreClientConnectedNotification:(NSNotification *)noti {
    NSLog(@"有新的socket 连接进来, 刷新界面了");
    [self fetchData];
    [_socketsTableView reloadData];
}

- (void)fetchData {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Client" inManagedObjectContext: [CoreDataManager sharedManager].managerContext];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"", ];
//    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"connectTime"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [[CoreDataManager sharedManager].managerContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"fetch error => %@", [error localizedDescription]);
    }
    
    _socketsArr = fetchedObjects;
}

// MARK: - NSTableViewDelegate, NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _socketsArr.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    Client * client = _socketsArr[row];
    
    if ([tableColumn.title isEqualTo:@"ip"]) {
        return client.ipaddress;
    } else if ([tableColumn.title isEqualTo:@"port"]) {
        return [NSString stringWithFormat:@"%lld", client.port];
    } else if ([tableColumn.title isEqualTo:@"connect"]) {
        return [self.dateFormatter stringFromDate:client.connectTime];
    } else if ([tableColumn.title isEqualTo:@"disconnect"]) {
        return [self.dateFormatter stringFromDate:client.disconnectTime];
    } else {
        return @"nothing";
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    [self performSegueWithIdentifier:@"showSendMsg" sender: _socketsArr[_socketsTableView.selectedRow]];
}

- (void)prepareForSegue:(NSStoryboardSegue *)segue sender:(Client *)client {
    if ([segue.destinationController isKindOfClass: [SendMessageVC class]]) {
        SendMessageVC *vc = (SendMessageVC *)segue.destinationController;
        vc.client = client;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

@end
