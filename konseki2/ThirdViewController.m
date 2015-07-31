//
//  ThirdViewController.m
//  konseki2
//
//  Created by takuho-sanpei on 13/02/14.
//  Copyright (c) 2013年 takuho-sanpei. All rights reserved.
//

#import "ThirdViewController.h"
#import "DetailViewController.h"
#import "PullRefreshTableViewController.h"

@interface ThirdViewController ()

@end

@implementation ThirdViewController
@synthesize delegate;

- (NSString *)UUIDString
{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    NSString *uuidStr = (NSString *)CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    return uuidStr;
}

- (id)initWithStyle:(UITableViewStyle)style{
    
    self = [super initWithStyle:style];
    if (self) {
        self.title = NSLocalizedString(@"足跡を探す", @"足跡を探す");
        self.tabBarItem.image = [UIImage imageNamed:@"magnify"];
        arrayData = [[NSMutableArray alloc]initWithObjects:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //User_id取得
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [ud stringForKey:@"USER_ID"];
    NSLog(@"user_id = %@",user_id);
    
    if(user_id == nil){
        NSString *uuid = [self UUIDString];
        [ud setObject:uuid forKey:@"USER_ID"];
        [ud synchronize];
        
        NSLog(@"user_id = %@",uuid);
    }
    
    BOOL locationServicesEnabled = '\0';
    locationManager = [[CLLocationManager alloc] init];
    
    if ([CLLocationManager respondsToSelector:@selector(locationServicesEnabled)]) {
		locationServicesEnabled = [CLLocationManager locationServicesEnabled];
	}
    
	if (locationServicesEnabled) {
		locationManager.delegate = self;
        
		// 位置情報取得開始
		[locationManager startUpdatingLocation];
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

    //UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    // 画面の中央に表示するようにframeを変更する
    //float w = indicator.frame.size.width;
    //float h = indicator.frame.size.height;
    //float x = self.view.frame.size.width/2 - w/2;
    //float y = self.view.frame.size.height/2 - h/2;
    //indicator.frame = CGRectMake(x, y, w, h);
    //indicator.color = [UIColor blackColor];
    
    //[self.view addSubview:indicator];
    
    // クルクルと回し始める
    //[indicator startAnimating];
    
    //delegete呼び出し
    list = [[ThirdViewController alloc]init];
    list.delegate = self;
	
    // 位置情報更新
	_longitude = newLocation.coordinate.longitude;
	_latitude = newLocation.coordinate.latitude;
    
    NSLog(@"%f",_longitude);
    NSLog(@"%f",_latitude);
    
    [locationManager stopUpdatingLocation];
    
    //オンライン時にリクエストを送付 オフライン時はplist内の情報を書き出し インターネット接続情報の確認
        //位置情報を元にリクエスト
        NSString *request_list = [[NSString alloc] initWithFormat:@"http://133.242.143.61/search?latitude=%f&longitude=%f",_latitude,_longitude];
        //NSString *request_list = @"http://ikdev.031.jp/rails/search?latitude=999.9999&longitude=999.9999";
        //NSString *request_list = @"http://133.242.143.61/search?latitude=123.12300&longitude=123.12300";
        NSLog(@"%@",request_list);
    
        NSURL *url = [NSURL URLWithString:request_list];
        NSURLRequest *req = [NSURLRequest requestWithURL:url];
        NSURLResponse *res = nil;
        NSError *error =nil;
        NSData* data = [NSURLConnection sendSynchronousRequest:req returningResponse:&res error:&error];
    
        arrayData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        [self.tableView reloadData];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	if (error) {
		NSString* message = nil;
		switch ([error code]) {
                // アプリでの位置情報サービスが許可されていない場合
			case kCLErrorDenied:
				// 位置情報取得停止
				[locationManager stopUpdatingLocation];
				message = [NSString stringWithFormat:@"このアプリは位置情報サービスが許可されていません。"];
				break;
			default:
				message = [NSString stringWithFormat:@"位置情報の取得に失敗しました。"];
				break;
		}
		if (message) {
			// アラートを表示
			UIAlertView* alert=[[[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil
                                                 cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
			[alert show];
		}
	}
}

- (void)createViewMethod{
    NSLog(@"createViewMethodが呼ばれました");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGRect r = [[UIScreen mainScreen] bounds];
    CGFloat h = r.size.height;
    NSLog(@"%f",h/5);
    
    return h/5;  // セクションの行の高さを160にする
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [arrayData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //内部的なID。IDとして文字列でセクションNOと行NOを設定しています。
    //別に各行でユニークなら何でも良いはずです。
    NSString *CellIdentifier = [NSString stringWithFormat:@"section : %d, row no : %d", indexPath.section, indexPath.row];
    
    //一度表示した行(セル)は内部でキャッシュしてくれるので、キャッシュが存在すればそれを使用し、なければ生成するイメージ。
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@",[[arrayData objectAtIndex:indexPath.row] valueForKeyPath:@"content"]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"時間:%@\n緯度:%@ 経度:%@",[[arrayData objectAtIndex:indexPath.row] valueForKeyPath:@"updated_at"],[[arrayData objectAtIndex:indexPath.row] valueForKeyPath:@"latitude"],[[arrayData objectAtIndex:indexPath.row] valueForKeyPath:@"longitude"]];
        cell.detailTextLabel.numberOfLines = 2;
        cell.textLabel.numberOfLines = 4;
        
        if(indexPath.row == 0) {
            cell.imageView.image = [UIImage imageNamed:@"second.png"];
        } else if(indexPath.row == 1){
            cell.imageView.image = [UIImage imageNamed:@"first.png"];
        } else {
            cell.imageView.image = [UIImage imageNamed:@"first.png"];
        }
        
        cell.textLabel.font = [UIFont fontWithName:@"Arial" size:12.0];
        cell.detailTextLabel.font = [UIFont fontWithName:@"Arial" size:8.0];
    }
    // Configure the cell...
    return cell;
}

// didSelectRowAtIndexPathはセルがタップされたらコールされる
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    NSString *filePath = [directory stringByAppendingPathComponent:@"cell_data.plist"];
    
    //メッセージplistへ保存
    NSArray *message_array = [[NSArray alloc]initWithObjects:cell.textLabel.text,cell.detailTextLabel.text, nil];
    
    BOOL successful = [message_array writeToFile:filePath atomically:NO];
    
    if (successful) {
        NSLog(@"%@", @"データの保存に成功しました。");
    } else{
        NSLog(@"%@", @"データの保存に失敗しました。");
    }
    
    NSLog(@"%@",filePath);
    
    NSMutableString *str = [NSMutableString stringWithCapacity: 0];
    //[str appendFormat:@"%@\n",@"メッセージ:"];
    
    NSArray *array = [[NSArray alloc] initWithContentsOfFile:filePath];
    if (array) {
        for (NSString *data in array) {
            [str appendFormat:@"%@\n",data];
        }
    } else {
        NSLog(@"%@", @"データが存在しません。");
    }
    
    UIViewController *detail_view = [[DetailViewController alloc]initWithNibName:@"DetailViewController" bundle:nil];
    UINavigationController *detail_nav = [[UINavigationController alloc]initWithRootViewController:detail_view];
    [self presentViewController:detail_nav animated:YES completion:nil];
    
}

-(void)refresh{
    
    BOOL locationServicesEnabled = '\0';
    locationManager = [[CLLocationManager alloc] init];
    
    if ([CLLocationManager respondsToSelector:@selector(locationServicesEnabled)]) {
		locationServicesEnabled = [CLLocationManager locationServicesEnabled];
	}
    
	if (locationServicesEnabled) {
		locationManager.delegate = self;
        
		// 位置情報取得開始
		[locationManager startUpdatingLocation];
	}
    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:2.0];
}

- (void)dealloc{
    //データの解放
    NSLog(@"dealloc");
    [arrayData release];
    [super dealloc];
}

@end
