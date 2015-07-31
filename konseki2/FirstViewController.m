//
//  FirstViewController.m
//  konseki2
//
//  Created by takuho-sanpei on 13/02/14.
//  Copyright (c) 2013年 takuho-sanpei. All rights reserved.
//

#import "FirstViewController.h"
#import "MapViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewWillAppear:(BOOL)animated
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    NSString *filePath = [directory stringByAppendingPathComponent:@"data.plist"];
    
    self_arrayData = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
    //NSLog(@"%@",self_arrayData);
    
    [self.tableView reloadData];
}

- (id)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self) {
        self.title = NSLocalizedString(@"過去の足跡", @"過去の足跡");
        self.tabBarItem.image = [UIImage imageNamed:@"notepad"];
        self_arrayData = [[NSMutableArray alloc]initWithObjects:nil];
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"編集" style:UIBarButtonItemStylePlain target:self action:@selector(edit)] autorelease];
        //self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"更新" style:UIBarButtonItemStylePlain target:self action:@selector(reload)] autorelease];
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    NSString *filePath = [directory stringByAppendingPathComponent:@"data.plist"];
    
    self_arrayData = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
    
    NSLog(@"jsonObject = %@", [self_arrayData description]);
    //NSLog(@"plist = %@", filePath);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGRect r = [[UIScreen mainScreen] bounds];
    CGFloat h = r.size.height;
    //NSLog(@"%f",h/5);
    
    return h/5;  // セクションの行の高さを160にする
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSLog(@"%lu",(unsigned long)[self_arrayData count]);
    return [self_arrayData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //内部的なID。IDとして文字列でセクションNOと行NOを設定しています。
    //別に各行でユニークなら何でも良いはずです。
    NSString *CellIdentifier = [NSString stringWithFormat:@"section : %d, row no : %d", indexPath.section, indexPath.row];
    
    //一度表示した行(セル)は内部でキャッシュしてくれるので、キャッシュが存在すればそれを使用し、なければ生成するイメージ。
    //殆どスケルトンのコードです。
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@",[[self_arrayData objectAtIndex:indexPath.row] valueForKeyPath:@"content"]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"時間:%@\n緯度:%@ 経度:%@",[[self_arrayData objectAtIndex:indexPath.row] valueForKeyPath:@"updated_at"],[[self_arrayData objectAtIndex:indexPath.row] valueForKeyPath:@"latitude"],[[self_arrayData objectAtIndex:indexPath.row] valueForKeyPath:@"longitude"]];
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
    //}
    // Configure the cell...
    return cell;
}

- (void)edit
{
    [self.tableView setEditing:YES animated:YES];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"完了" style:UIBarButtonItemStylePlain target:self action:@selector(finish)] autorelease];
}

-(void)finish
{
    [self.tableView setEditing:NO animated:YES];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"編集" style:UIBarButtonItemStylePlain target:self action:@selector(edit)] autorelease];
}

-(void)reload
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    NSString *filePath = [directory stringByAppendingPathComponent:@"data.plist"];
    
    self_arrayData = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
    //NSLog(@"%@",self_arrayData);
    
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        //message数確認
        ud = [NSUserDefaults standardUserDefaults];
        int message_num = [ud integerForKey:@"MESSAGE_NUM"];
        
        NSLog(@"before = %@",self_arrayData);

        //リクエスト用パラメータ
        NSString *user_id = [ud stringForKey:@"USER_ID"];
        NSString *message_id_str = [[self_arrayData objectAtIndex:indexPath.row] valueForKeyPath:@"message_id"];
        
        NSInteger message_id=[message_id_str intValue];
        
        //NSLog(@"user_id = %@",user_id);
        //NSLog(@"message_id = %d",message_id);

        // Delete the row from the data source
        NSInteger row = [indexPath row];
        [self_arrayData removeObjectAtIndex: row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]  withRowAnimation:UITableViewRowAnimationFade];
        
        NSLog(@"after = %@",self_arrayData);
        
        //メッセージ数を減らす
        message_num--;
        
        //メッセージ数を更新する
        [ud setInteger:message_num forKey:@"MESSAGE_NUM"];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *directory = [paths objectAtIndex:0];
        NSString *filePath = [directory stringByAppendingPathComponent:@"data.plist"];
        
        BOOL successful = [self_arrayData writeToFile:filePath atomically:NO];
        if (successful) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"アラート" message:@"データを保存しました" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            
            //位置情報を元にリクエスト、レスポンスにmesageidを返却するように変更 //http://ikdev.031.jp/rails/delete?message_id=26&user_id=3
            NSString *request_delete = [[NSString alloc] initWithFormat:@"http://133.242.143.61/delete?message_id=%d&user_id=%@",message_id,user_id];
            //NSString *request_list = [[NSString alloc] initWithFormat:@"http://ikdev.031.jp/rails/regist?user_id=2&latitude=%f&longitude=%f&content=%@",_latitude,_longitude,str];
            
            NSLog(@"%@",request_delete);
            
            NSURL *url = [NSURL URLWithString:request_delete];
            NSURLRequest *req = [NSURLRequest requestWithURL:url];

            //[NSURLConnection sendSynchronousRequest:req returningResponse:&res error:&err];
            [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response,NSData *data,NSError *error){
            //error処理を入れる。レスポンスは気にしないためエラー処理は特にいれていない
                
            }];
            
            [self.tableView setEditing:NO animated:YES];
            self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"編集" style:UIBarButtonItemStylePlain target:self action:@selector(edit)] autorelease];
            
            //NSArray *array = [[NSArray alloc] initWithContentsOfFile:filePath];
            
        } else{
            NSLog(@"%@", @"データの保存に失敗しました。");
        }
    }
}

// didSelectRowAtIndexPathはセルがタップされたらコールされる
// メッセージがタップされた際に地図上にメッセージ内容を表示する
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    NSString *filePath = [directory stringByAppendingPathComponent:@"cell_map_data.plist"];
    
    //メッセージplistへ保存
    NSArray *message_array = [[NSArray alloc]initWithObjects:cell.textLabel.text,cell.detailTextLabel.text, nil];
    
    BOOL successful = [message_array writeToFile:filePath atomically:NO];
    
    if (successful) {
        NSLog(@"%@", @"データの保存に成功しました。");
    } else{
        NSLog(@"%@", @"データの保存に失敗しました。");
    }
    
    //NSLog(@"%@",filePath);
    
    NSMutableString *str = [NSMutableString stringWithCapacity: 0];
    [str appendFormat:@"%@\n",@"メッセージ:"];
    
    NSArray *array = [[NSArray alloc] initWithContentsOfFile:filePath];
    if (array) {
        for (NSString *data in array) {
            [str appendFormat:@"%@\n",data];
        }
    } else {
        NSLog(@"%@", @"データが存在しません。");
    }
    
    UIViewController *detail_view = [[MapViewController alloc]initWithNibName:@"MapViewController" bundle:nil];
    UINavigationController *detail_nav = [[UINavigationController alloc]initWithRootViewController:detail_view];
    [self presentViewController:detail_nav animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
