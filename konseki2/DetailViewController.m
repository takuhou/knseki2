//
//  DetailViewController.m
//  konseki2
//
//  Created by takuho-sanpei on 13/02/20.
//  Copyright (c) 2013年 takuho-sanpei. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"足跡を共有", @"足跡を共有");
        //self.tabBarItem.image = [UIImage imageNamed:@"second"];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"戻る" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UILabel *label_message = [[UILabel alloc] initWithFrame:CGRectMake(10,5,100,30)];
    label_message.text = @"メッセージ";
    
    UILabel *label_sub = [[UILabel alloc] initWithFrame:CGRectMake(10,150,100,30)];
    label_sub.text = @"その他";
    
    UILabel *label_sub_content1 = [[UILabel alloc] initWithFrame:CGRectMake(10,180,300,30)];
    label_sub_content1.font = [UIFont fontWithName:@"Helvetica" size:14];
    UILabel *label_sub_content2 = [[UILabel alloc] initWithFrame:CGRectMake(10,200,300,30)];
    label_sub_content2.font = [UIFont fontWithName:@"Helvetica" size:14];
    
    CGRect rect_main = CGRectMake(10, 40, 300, 100);
    UITextView *tv_main = [[[UITextView alloc] initWithFrame:rect_main] autorelease];
    tv_main.editable = NO;
    tv_main.layer.borderWidth = 2.0f;    //ボーダーの幅
    tv_main.layer.cornerRadius = 3.0f;    //ボーダーの角の丸み
    tv_main.font = [UIFont fontWithName:@"Helvetica" size:14];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    NSString *filePath = [directory stringByAppendingPathComponent:@"cell_data.plist"];
    
    NSArray *array = [[NSArray alloc] initWithContentsOfFile:filePath];
    
    int count = [array count];
    
    //メッセージ取り出し
    if(count > 0){
        tv_main.text = array[0];
    } else{
        tv_main.text = @"データが存在しません";
    }
    
    //改行でパース
    NSArray *lines = [array[1] componentsSeparatedByString:@"\n"];
    
    //latutide,longitude
    label_sub_content1.text = [NSString stringWithFormat:@"%@",lines[0]];
    label_sub_content2.text = [NSString stringWithFormat:@"%@",lines[1]];
    
    [self.view addSubview:label_message];
    [self.view addSubview:label_sub];
    [self.view addSubview:label_sub_content1];
    [self.view addSubview:label_sub_content2];
    [self.view addSubview:tv_main];
    
    UIImage *img_t = [UIImage imageNamed:@"twitter.png"];  // ボタンにする画像を生成する
    UIButton *btn_t = [[[UIButton alloc] initWithFrame:CGRectMake(10, 240, 150, 150)] autorelease];  // ボタンのサイズを指定する
    [btn_t setBackgroundImage:img_t forState:UIControlStateNormal];  // 画像をセットする
    [btn_t addTarget:self action:@selector(twitter) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn_t];

    UIImage *img_f = [UIImage imageNamed:@"f_logo.png"];  // ボタンにする画像を生成する
    UIButton *btn_f = [[[UIButton alloc] initWithFrame:CGRectMake(180, 260, 100, 100)] autorelease];  // ボタンのサイズを指定する
    [btn_f setBackgroundImage:img_f forState:UIControlStateNormal];  // 画像をセットする
    [btn_f addTarget:self action:@selector(facebook) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn_f];
}

- (void)twitter{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    NSString *filePath = [directory stringByAppendingPathComponent:@"cell_data.plist"];
    
    NSArray *array = [[NSArray alloc] initWithContentsOfFile:filePath];
    
    NSString *social_text = [NSString stringWithFormat:@"%@\n%@ #toleeve",array[0],array[1]];

    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [controller setInitialText:[NSString stringWithFormat:@"%@",social_text]];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)facebook{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    NSString *filePath = [directory stringByAppendingPathComponent:@"cell_data.plist"];
    
    NSArray *array = [[NSArray alloc] initWithContentsOfFile:filePath];
    
    NSString *social_text = [NSString stringWithFormat:@"%@\n%@",array[0],array[1]];
    
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [controller setInitialText:[NSString stringWithFormat:@"%@",social_text]];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
