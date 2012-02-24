//
//  SBAppDelegate.h
//  SBPullToRefreshHeaderView
//
//  Created by Takuya Otani on 24/02/12.
//  Copyright (c) 2012 SerendipityNZ Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SBViewController;

@interface SBAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) SBViewController *viewController;

@end
