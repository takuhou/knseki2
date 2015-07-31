//
//  SecondViewController.m
//  konseki2
//
//  Created by takuho-sanpei on 13/02/14.
//  Copyright (c) 2013年 takuho-sanpei. All rights reserved.
//

#import "SecondViewController.h"
#import "FirstViewController.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"足跡を残す", @"足跡を残す");
        self.tabBarItem.image = [UIImage imageNamed:@"footprint"];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"送信" style:UIBarButtonItemStylePlain target:self action:@selector(send)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"クリア" style:UIBarButtonItemStylePlain target:self action:@selector(clear)];
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    CGRect rect = CGRectMake(10, 10, 300, 180);
    
    tv = [[[UITextView alloc] initWithFrame:rect] autorelease];
    tv.editable = YES;
    tv.delegate = self;
    tv.layer.borderWidth = 2.0f;    //ボーダーの幅
    tv.layer.cornerRadius = 3.0f;    //ボーダーの角の丸み
    tv.font = [UIFont fontWithName:@"Helvetica" size:20];
    tv.returnKeyType = UIReturnKeyDone;
    tv.layer.borderColor = [[UIColor lightGrayColor] CGColor]; //ボーダーの色
    tv.keyboardType = UIKeyboardTypeDefault;

    [tv becomeFirstResponder];
    [self.view addSubview:tv];
}

//テキスト変更時に呼ばれる
- (BOOL)textView:(UITextView*)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text {
    if (text.length>0 && textView.text.length+text.length > 100) {
        return NO;
        NSLog(@"100文字以上です");
    }
    return YES;
}

//メッセージ送信用
- (void)send{
    //送信メッセージ数の制御
    ud = [NSUserDefaults standardUserDefaults];
    NSInteger message_num = [ud integerForKey:@"MESSAGE_NUM"];
    
    NSLog(@"%d",message_num);
    
    if(tv.text.length > 0){
     if(message_num < 10){
        //message送信処理
        //位置情報取得
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
     }else{
        //message数がオーバーしている場合
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"アラート" message:@"メッセージを登録できるのは\n10件までです\n登録メッセージを削除してください" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
        [alert show];
        [alert release];
     }
    } else{
        //コンテンツがnullの時
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"アラート" message:@"メッセージを入力してください" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    [tv resignFirstResponder];
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    // 画面の中央に表示するようにframeを変更する
    float w = indicator.frame.size.width;
    float h = indicator.frame.size.height;
    float x = self.view.frame.size.width/2 - w/2;
    float y = self.view.frame.size.height/2 - h/2;
    indicator.frame = CGRectMake(x, y, w, h);
    indicator.color = [UIColor blackColor];
    
    [self.view addSubview:indicator];
    
    // クルクルと回し始める
    [indicator startAnimating];
    
    // 位置情報更新
	_longitude = newLocation.coordinate.longitude;
	_latitude = newLocation.coordinate.latitude;
    
    NSLog(@"%f",_longitude);
    NSLog(@"%f",_latitude);
    
    [locationManager stopUpdatingLocation];
    
    // message取得
    NSMutableString *str = (NSMutableString *)tv.text;
    
    NSString *user_id = [ud stringForKey:@"USER_ID"];
    NSInteger message_num = [ud integerForKey:@"MESSAGE_NUM"];
    
    //位置情報を元にリクエスト、レスポンスにmesageidを返却するように変更
    NSString *request_list = [[NSString alloc] initWithFormat:@"http://133.242.143.61/regist?user_id=%@&latitude=%f&longitude=%f&content=%@",user_id,_latitude,_longitude,str];
    //NSString *request_list = [[NSString alloc] initWithFormat:@"http://ikdev.031.jp/rails/regist?user_id=2&latitude=%f&longitude=%f&content=%@",_latitude,_longitude,str];
    NSLog(@"%@",request_list);
    
    //URLエンコード
    NSString *escapedUrlString = [request_list stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:escapedUrlString];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    //NSURLResponse *res = nil;
    //NSError *error =nil;
    //NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&res error:&error];
    
    //登録のリクエストを送信
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response,NSData *data,NSError *error){
    
    //json形式のlist情報を受け取る
        NSArray *resoponse_array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        //NSLog(@"jsonObject = %@", [resoponse_array description]);
        
        //レスポンスをplistに保存
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *directory = [paths objectAtIndex:0];
        NSString *filePath = [directory stringByAppendingPathComponent:@"data.plist"];
        
        BOOL successful = [resoponse_array writeToFile:filePath atomically:NO];
        if (successful) {
            [indicator stopAnimating];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"アラート" message:@"データを送信しました" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
            [alert show];
            NSLog(@"request_message = %@",resoponse_array);
            
            tv.text = nil;
            
            //自分のメッセージ一覧表示画面に遷移
            self.tabBarController.selectedIndex = 2;
            [alert release];
            
        } else{
            [indicator stopAnimating];
            NSLog(@"%@", @"データの保存に失敗しました。");
        }
    }];
    
    //メッセージ数
    message_num++;
    
    //messageデータ保存
    [ud setInteger:message_num forKey:@"MESSAGE_NUM"];
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


//メッセージ削除用
- (void)clear{
    tv.text = nil;
    [tv resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
