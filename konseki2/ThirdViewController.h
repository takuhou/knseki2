//
//  ThirdViewController.h
//  konseki2
//
//  Created by takuho-sanpei on 13/02/14.
//  Copyright (c) 2013年 takuho-sanpei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "PullRefreshTableViewController.h"

@protocol ListDelegate <NSObject>
- (void) createViewMethod;
@end

@interface ThirdViewController : PullRefreshTableViewController<CLLocationManagerDelegate,ListDelegate,UITableViewDelegate,UITableViewDataSource,NSURLConnectionDataDelegate>
{
    CLLocationManager *locationManager;
    
    // 現在位置記録用
	CLLocationDegrees _longitude;
	CLLocationDegrees _latitude;
    id<ListDelegate> delegate;
    
    //viewmake用
    ThirdViewController *list;
    
    //TbaleViewデータ格納用
    NSMutableArray *arrayData;
}

@property(retain,nonatomic)id<ListDelegate> delegate;

@end
