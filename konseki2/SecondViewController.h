//
//  SecondViewController.h
//  konseki2
//
//  Created by takuho-sanpei on 13/02/14.
//  Copyright (c) 2013年 takuho-sanpei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreLocation/CoreLocation.h>

@interface SecondViewController : UIViewController<UITextViewDelegate,CLLocationManagerDelegate>{
    UITextView *tv;
    
    CLLocationManager *locationManager;
    
    // 現在位置記録用
	CLLocationDegrees _longitude;
	CLLocationDegrees _latitude;
    
    NSUserDefaults *ud;
}

@end
