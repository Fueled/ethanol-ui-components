//
//  NibViewTests.m
//  EthanolUIComponents
//
//  Created by Stephane Copin on 9/10/15.
//  Copyright © 2015 Stephane Copin. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NibViewTest.h"
#import "TestViewController.h"

@interface NibViewTests : XCTestCase

@end

@implementation NibViewTests

- (void)testNibViewInit {
	NibViewTest * nibView = [[NibViewTest alloc] init];
	
	XCTAssertNotNil(nibView.contentView);
	XCTAssertNotNil(nibView.textView);
	XCTAssertTrue([nibView.textView isKindOfClass:[UITextView class]]);
}

- (void)testNibViewInitWithFrame {
	NibViewTest * nibView = [[NibViewTest alloc] initWithFrame:CGRectZero];
	
	XCTAssertNotNil(nibView.contentView);
	XCTAssertNotNil(nibView.textView);
	XCTAssertTrue([nibView.textView isKindOfClass:[UITextView class]]);
}

- (void)testNibViewInitWithCoder {
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Tests" bundle:[NSBundle bundleForClass:[self class]]];
	TestViewController *testViewController = [storyboard instantiateViewControllerWithIdentifier:@"TestsViewControllerID"];
	[testViewController loadView];
	
	XCTAssertNotNil(testViewController.testNibView);
	XCTAssertTrue([testViewController.testNibView isKindOfClass:[ETHNibView class]]);
	XCTAssertNotNil(testViewController.testNibView.contentView);
	XCTAssertNotNil(testViewController.testNibView.textView);
	XCTAssertTrue([testViewController.testNibView.textView isKindOfClass:[UITextView class]]);
}

@end
