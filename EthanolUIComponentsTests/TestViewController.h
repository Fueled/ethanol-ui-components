//
//  TestViewController.h
//  EthanolUIComponents
//
//  Created by Stephane Copin on 9/10/15.
//  Copyright © 2015 Stephane Copin. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ETHSwitch.h"
#import "ETHPageControl.h"
#import "ETHTextField.h"
#import "NibViewTest.h"

@interface TestViewController : UIViewController

@property (strong, nonatomic) IBOutlet ETHSwitch *testSwitch;
@property (strong, nonatomic) IBOutlet ETHPageControl *testPageControl;
@property (strong, nonatomic) IBOutlet ETHTextField *testTextField;
@property (strong, nonatomic) IBOutlet NibViewTest *testNibView;

@end
