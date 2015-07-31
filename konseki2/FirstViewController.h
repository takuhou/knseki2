//
//  FirstViewController.h
//  konseki2
//
//  Created by takuho-sanpei on 13/02/14.
//  Copyright (c) 2013年 takuho-sanpei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FirstViewController : UITableViewController<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray *self_arrayData;
    NSUserDefaults *ud;
    FirstViewController *firstview;
    UINavigationController *nav;
}

@end
