//
//  SwitchTest.m
//  EthanolUIComponents
//
//  Created by Bastien Falcou on 8/19/15.
//  Copyright © 2015 Stephane Copin. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ETHSwitch.h"

@interface ETHSwitch (PrivateTests)

@property (nonatomic, retain, readwrite) UIImageView* backgroundImage;

@end

@interface SwitchTests : XCTestCase

@end

@implementation SwitchTests

- (void)testLoadSwitchInView {
  UIView *view = [[[NSBundle bundleForClass:[self class]] loadNibNamed:@"SwitchTestsView" owner:self options:nil] objectAtIndex:0];
  UIWindow *window = [[UIWindow alloc] init];
  UIViewController *viewController = [[UIViewController alloc] init];
  [viewController.view addSubview:view];
  window.rootViewController = viewController;
  
  XCTAssertNotNil(view);
}

- (void)testTurnSwitchOnColorOnSwitch {
  ETHSwitch *theSwitch = [[ETHSwitch alloc] init];
  UIColor *color = [UIColor redColor];
  theSwitch.onTintColor = color;
  theSwitch.on = YES;
  
  XCTAssertEqualObjects(theSwitch.onTintColor, color);
}

- (void)testTurnSwitchOffColorOffSwitch {
  ETHSwitch *theSwitch = [[ETHSwitch alloc] init];
  UIColor *color = [UIColor redColor];
  theSwitch.offTintColor = color;
  theSwitch.on = NO;
  
  XCTAssertEqualObjects(theSwitch.backgroundColor, color);
}

- (void)testTurnSwitchOnColorOffSwitch {
  ETHSwitch *theSwitch = [[ETHSwitch alloc] init];
  UIColor *color = [UIColor redColor];
  theSwitch.onTintColor = color;
  theSwitch.on = NO;
  
  XCTAssertNotEqualObjects(theSwitch.backgroundColor, color);
}

- (void)testTurnSwitchOffColorOnSwitch {
  ETHSwitch *theSwitch = [[ETHSwitch alloc] init];
  UIColor *color = [UIColor redColor];
  theSwitch.offTintColor = color;
  theSwitch.on = YES;
  
  XCTAssertNotEqualObjects(theSwitch.backgroundColor, color);
}

- (void)testOnBackgroundPicture {
  ETHSwitch *theSwitch = [[ETHSwitch alloc] init];
  UIImage *image = [UIImage imageNamed:@"Switch-Test-Image" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
  theSwitch.onImage = image;
  theSwitch.on = YES;
  
  XCTAssertEqualObjects(theSwitch.backgroundImage.image, image);
}

- (void)testOffBackgroundPicture {
  ETHSwitch *theSwitch = [[ETHSwitch alloc] init];
  UIImage *image = [UIImage imageNamed:@"Switch-Test-Image" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
  theSwitch.offImage = image;
  theSwitch.on = NO;
  
  XCTAssertEqualObjects(theSwitch.backgroundImage.image, image);
}

- (void)testResetOnColor {
  ETHSwitch *theSwitch = [[ETHSwitch alloc] init];
  UIColor *color = [UIColor redColor];
  theSwitch.onTintColor = color;
  theSwitch.on = YES;
  theSwitch.onTintColor = nil;
  
  XCTAssertNotEqualObjects(theSwitch.backgroundColor, color);
}

- (void)testResetOffColor {
  ETHSwitch *theSwitch = [[ETHSwitch alloc] init];
  UIColor *color = [UIColor redColor];
  theSwitch.offTintColor = color;
  theSwitch.on = NO;
  theSwitch.offTintColor = nil;
  
  XCTAssertNotEqualObjects(theSwitch.backgroundColor, color);
}

- (void)testResetOnBackgroundPicture {
  ETHSwitch *theSwitch = [[ETHSwitch alloc] init];
  UIImage *image = [UIImage imageNamed:@"Switch-Test-Image" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
  theSwitch.onImage = image;
  theSwitch.on = YES;
  theSwitch.onImage = nil;
  
  XCTAssertEqualObjects(theSwitch.backgroundImage.image, nil);
}

- (void)testResetOffBackgroundPicture {
  ETHSwitch *theSwitch = [[ETHSwitch alloc] init];
  UIImage *image = [UIImage imageNamed:@"Switch-Test-Image" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
  theSwitch.offImage = image;
  theSwitch.on = NO;
  theSwitch.offImage = nil;
  
  XCTAssertEqualObjects(theSwitch.backgroundImage.image, nil);
}

- (void)testValueChanged {
  ETHSwitch *theSwitch = [[ETHSwitch alloc] init];
  theSwitch.on = YES;
  [theSwitch sendActionsForControlEvents:UIControlEventValueChanged];
  
  XCTAssertEqual(theSwitch.on, NO);
}

- (void)testEdgeCaseSwitch {
  
}





@end