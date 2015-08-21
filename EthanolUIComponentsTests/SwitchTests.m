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

- (void)switchValueChanged:(id)sender;

@end

@interface SwitchTests : XCTestCase

@property (nonatomic, strong) UIImage *image;

@end

@implementation SwitchTests

- (void)setUp {
  [super setUp];
  
  self.image = [UIImage imageNamed:@"Switch-Test-Image" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil];
}

- (void)testLoadSwitchInView {
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Tests" bundle:[NSBundle bundleForClass:[self class]]];
  UIViewController *testViewController = [storyboard instantiateViewControllerWithIdentifier:@"TestsViewControllerID"];
  [testViewController loadView];
  
  XCTAssertNotNil(testViewController.view);
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
  theSwitch.onImage = self.image;
  theSwitch.on = YES;
  
  XCTAssertEqualObjects(theSwitch.backgroundImage.image, self.image);
}

- (void)testOffBackgroundPicture {
  ETHSwitch *theSwitch = [[ETHSwitch alloc] init];
  theSwitch.offImage = self.image;
  theSwitch.on = NO;
  
  XCTAssertEqualObjects(theSwitch.backgroundImage.image, self.image);
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
  theSwitch.onImage = self.image;
  theSwitch.on = YES;
  theSwitch.onImage = nil;
  
  XCTAssertEqualObjects(theSwitch.backgroundImage.image, nil);
}

- (void)testResetOffBackgroundPicture {
  ETHSwitch *theSwitch = [[ETHSwitch alloc] init];
  theSwitch.offImage = self.image;
  theSwitch.on = NO;
  theSwitch.offImage = nil;
  
  XCTAssertEqualObjects(theSwitch.backgroundImage.image, nil);
}

- (void)testSwitchOnImage {
  ETHSwitch *theSwitch = [[ETHSwitch alloc] init];
  theSwitch.on = YES;
  theSwitch.offImage = self.image;
  theSwitch.onImage = self.image;
  
  XCTAssertEqualObjects(theSwitch.backgroundImage.image, self.image);
}

- (void)testSwitchOnImageNilOffImageSet {
  ETHSwitch *theSwitch = [[ETHSwitch alloc] init];
  theSwitch.on = YES;
  theSwitch.offImage = self.image;
  theSwitch.onImage = nil;
  
  XCTAssert(theSwitch.backgroundColor != nil);
}

- (void)testSwitchChangeImage {
  ETHSwitch *theSwitch = [[ETHSwitch alloc] init];
  theSwitch.on = YES;
  theSwitch.onImage = self.image;
  theSwitch.onImage = self.image;
  
  XCTAssertEqualObjects(theSwitch.backgroundImage.image, self.image);
}

- (void)testSwitchRemoveImage {
  ETHSwitch *theSwitch = [[ETHSwitch alloc] init];
  theSwitch.on = YES;
  theSwitch.onImage = self.image;
  theSwitch.onImage = nil;
  
  XCTAssertEqualObjects(theSwitch.backgroundImage.image, nil);
}

- (void)testSwitchRemoveImageWithColors {
  ETHSwitch *theSwitch = [[ETHSwitch alloc] init];
  theSwitch.on = YES;
  theSwitch.onTintColor = [UIColor greenColor];
  theSwitch.offTintColor = [UIColor redColor];
  theSwitch.onImage = self.image;
  theSwitch.onImage = nil;
  
  XCTAssertEqualObjects(theSwitch.backgroundImage.image, nil);
}

- (void)testSwitchSetOffImageWhenOn {
  ETHSwitch *theSwitch = [[ETHSwitch alloc] init];
  theSwitch.on = YES;
  theSwitch.offImage = self.image;
  
  XCTAssertEqualObjects(theSwitch.backgroundImage.image, nil);
}

- (void)testSwitchRenewOnTintColor {
  ETHSwitch *theSwitch = [[ETHSwitch alloc] init];
  theSwitch.on = YES;
  theSwitch.onImage = self.image;
  theSwitch.onTintColor = [UIColor redColor];
  theSwitch.onTintColor = [UIColor blueColor];
  
  XCTAssertEqualObjects(theSwitch.backgroundColor, [UIColor clearColor]); // Clear when image
}

- (void)testSwitchOffTintColorOffSwitch {
  ETHSwitch *theSwitch = [[ETHSwitch alloc] init];
  theSwitch.on = NO;
  theSwitch.offTintColor = [UIColor blueColor];
  
  XCTAssertEqualObjects(theSwitch.backgroundColor, [UIColor blueColor]);
}

- (void)testChangeSwitchValue {
  ETHSwitch *theSwitch = [[ETHSwitch alloc] init];
  theSwitch.on = NO;
  theSwitch.offTintColor = [UIColor redColor];
  [theSwitch switchValueChanged:nil];
  
  XCTAssertEqualObjects(theSwitch.backgroundColor, [UIColor redColor]);
}

- (void)testSwitchExtensiveProcess1 {
  ETHSwitch *theSwitch = [[ETHSwitch alloc] init];
  theSwitch.on = YES;
  theSwitch.onTintColor = [UIColor greenColor];
  theSwitch.offTintColor = [UIColor redColor];
  theSwitch.onImage = self.image;
  theSwitch.offImage = self.image;
  theSwitch.on = NO;
  theSwitch.onTintColor = nil;
  theSwitch.offTintColor = nil;
  theSwitch.onImage = nil;
  theSwitch.offImage = nil;
  theSwitch.on = YES;
  theSwitch.onTintColor = [UIColor blueColor];
  
  XCTAssertEqualObjects(theSwitch.backgroundColor, [UIColor blueColor]);  // Is green instead
}

- (void)testSwitchExtensiveProcess2 {
  ETHSwitch *theSwitch = [[ETHSwitch alloc] init];
  theSwitch.on = YES;
  theSwitch.onTintColor = [UIColor greenColor];
  theSwitch.offImage = self.image;
  theSwitch.offImage = nil;
  theSwitch.on = YES;
  theSwitch.onImage = self.image;
  theSwitch.on = NO;
  theSwitch.onTintColor = nil;
  theSwitch.offTintColor = nil;
  theSwitch.offTintColor = [UIColor redColor];
  theSwitch.onImage = nil;
  theSwitch.offImage = nil;
  theSwitch.on = YES;
  theSwitch.onImage = self.image;
  theSwitch.onTintColor = [UIColor blueColor];
  theSwitch.onImage = nil;
  
  XCTAssertEqualObjects(theSwitch.backgroundColor, [UIColor blueColor]);
}

- (void)testOther {
  ETHSwitch *theSwitch = [[ETHSwitch alloc] init];
  theSwitch.onTintColor = [UIColor greenColor];
  theSwitch.onImage = self.image;
  theSwitch.on = NO;
  theSwitch.onImage = nil;
  theSwitch.on = YES;
  
  XCTAssertEqualObjects(theSwitch.backgroundColor, [UIColor blueColor]);  // Is green instead
}

@end