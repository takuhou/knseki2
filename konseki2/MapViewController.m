//
//  MapViewController.m
//  konseki2
//
//  Created by takuho-sanpei on 13/07/03.
//  Copyright (c) 2013年 takuho-sanpei. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>

@interface MapViewController ()<MKMapViewDelegate>{
    MKMapView *_mapView;
    CLLocationCoordinate2D center;
}

@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //self.title = NSLocalizedString(@"過去の足跡", @"過去の足跡");
        //self.tabBarItem.image = [UIImage imageNamed:@"second"];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"戻る" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    NSString *filePath = [directory stringByAppendingPathComponent:@"cell_map_data.plist"];
    
    NSArray *array = [[NSArray alloc] initWithContentsOfFile:filePath];
    
    //改行でパース
    NSArray *lines = [array[1] componentsSeparatedByString:@"\n"];
    NSArray *location = [lines[1] componentsSeparatedByString:@" "];
    
    //緯度経度パース
    NSArray *latitude_arr = [location[0] componentsSeparatedByString:@":"];
    NSArray *longitude_arr = [location[1] componentsSeparatedByString:@":"];
    
    _mapView=[[MKMapView alloc]initWithFrame:self.view.frame];
    _mapView.delegate = self;
    
    //京都　latitude：35.0212466 longitude：135.7555968
    center = CLLocationCoordinate2DMake([latitude_arr[1] doubleValue], [longitude_arr[1] doubleValue]);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(center, 10000.0, 10000.0);
    _mapView.region = region;  //  アニメーション抜き
    
    MKPointAnnotation* pin = [[MKPointAnnotation alloc] init];
    pin.coordinate = CLLocationCoordinate2DMake([latitude_arr[1] doubleValue], [longitude_arr[1] doubleValue]);
    pin.title = [NSString stringWithFormat:@"%@",array[0]];
    [_mapView addAnnotation:pin];
    [self.view addSubview:_mapView];
}

- (void)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id )annotation
{
    static NSString* Identifier = @"PinAnnotationIdentifier";
    MKPinAnnotationView* pinView = (MKPinAnnotationView *)[mapView
                                                           dequeueReusableAnnotationViewWithIdentifier:Identifier];
    if (pinView == nil) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                  reuseIdentifier:Identifier];
        pinView.animatesDrop = YES;
        pinView.canShowCallout = YES;
        return pinView;
    }
    pinView.annotation = annotation;
    return pinView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
