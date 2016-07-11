//
//  SwitchTest.m
//  EthanolUIComponents
//
//  Created by Bastien Falcou on 8/19/15.
//  Copyright (c) 2015 Fueled Digital Media, LLC.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <XCTest/XCTest.h>

#import "ETHSwitch.h"
#import "TestViewController.h"

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
  TestViewController *testViewController = [storyboard instantiateViewControllerWithIdentifier:@"TestsViewControllerID"];
  [testViewController loadView];
  
  XCTAssertNotNil(testViewController.testSwitch);
  XCTAssertTrue([testViewController.testSwitch isKindOfClass:[ETHSwitch class]]);
}

- (void)testTurnSwitchOnColorOnSwitch {
  ETHSwitch *theSwitch = [[ETHSwitch alloc] init];
  theSwitch.onTintColor = [UIColor redColor];
  theSwitch.on = YES;
  
  XCTAssertEqualObjects(theSwitch.backgroundColor, [UIColor redColor]);
}

- (void)testTurnSwitchOffColorOffSwitch {
  ETHSwitch *theSwitch = [[ETHSwitch alloc] init];
  theSwitch.offTintColor = [UIColor redColor];
  theSwitch.on = NO;
  
  XCTAssertEqualObjects(theSwitch.backgroundColor, [UIColor redColor]);
}

- (void)testTurnSwitchOnColorOffSwitch {
  ETHSwitch *theSwitch = [[ETHSwitch alloc] init];
  theSwitch.onTintColor = [UIColor redColor];
  theSwitch.on = NO;
  
  XCTAssertNotEqualObjects(theSwitch.backgroundColor, [UIColor redColor]);
}

- (void)testTurnSwitchOffColorOnSwitch {
  ETHSwitch *theSwitch = [[ETHSwitch alloc] init];
  theSwitch.offTintColor = [UIColor redColor];
  theSwitch.on = YES;
  
  XCTAssertNotEqualObjects(theSwitch.backgroundColor, [UIColor redColor]);
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

- (void)testOnBackgroundPictureOffStatus {
  ETHSwitch *theSwitch = [[ETHSwitch alloc] init];
  theSwitch.onImage = self.image;
  theSwitch.on = NO;
  
  XCTAssertNotEqualObjects(theSwitch.backgroundImage.image, self.image);
}

- (void)testOffBackgroundPictureOnStatus {
  ETHSwitch *theSwitch = [[ETHSwitch alloc] init];
  theSwitch.offImage = self.image;
  theSwitch.on = YES;
  
  XCTAssertNotEqualObjects(theSwitch.backgroundImage.image, self.image);
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

- (void)testSwitchOnImageOffOnly {
  ETHSwitch *theSwitch = [[ETHSwitch alloc] init];
  theSwitch.on = YES;
  theSwitch.offImage = self.image;
  theSwitch.onImage = nil;
  
  XCTAssertNil(theSwitch.backgroundColor);
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
  
  XCTAssertEqualObjects(theSwitch.backgroundColor, [UIColor blueColor]);
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

- (void)testSwitchExtensiveProcess3 {
  ETHSwitch *theSwitch = [[ETHSwitch alloc] init];
  theSwitch.on = YES;
  theSwitch.onTintColor = [UIColor greenColor];
  theSwitch.onImage = self.image;
  theSwitch.on = NO;
  theSwitch.onTintColor = nil;
  theSwitch.onImage = nil;
  theSwitch.on = YES;
  
  XCTAssertNotEqualObjects(theSwitch.backgroundColor, nil); // Default ON color
}

@end