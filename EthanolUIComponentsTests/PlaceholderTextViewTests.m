//
//  PlaceholderTextViewTests.m
//  EthanolUIComponents
//
//  Created by Stephane Copin on 2/17/16.
//  Copyright © 2016 Stephane Copin. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ETHPlaceholderTextView.h"
#import "TestViewController.h"

@interface ETHPlaceholderTextView (Private)

@property (nonatomic, weak) UILabel * placeholderLabel;

@end

@interface PlaceholderTextViewTests : XCTestCase

@end

@implementation PlaceholderTextViewTests

- (void)testPlaceholderInitWithFrame {
	ETHPlaceholderTextView * textView = [[ETHPlaceholderTextView alloc] initWithFrame:CGRectZero];
	XCTAssertFalse(textView.placeholderLabel.hidden);
	textView.text = @"placeholder should disappear";
	XCTAssertTrue(textView.placeholderLabel.hidden);
	textView.text = @"placeholder should appear";
	XCTAssertFalse(textView.placeholderLabel.hidden);
}

- (void)testPlaceholderInitWithCoder {
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Tests" bundle:[NSBundle bundleForClass:[self class]]];
	TestViewController *testViewController = [storyboard instantiateViewControllerWithIdentifier:@"TestsViewControllerID"];
	[testViewController loadView];
	
	XCTAssertNotNil(testViewController.testPlaceholderTextView);
	XCTAssertFalse(testViewController.testPlaceholderTextView.placeholderLabel.hidden);
	testViewController.testPlaceholderTextView.text = @"placeholder should disappear";
	XCTAssertTrue(testViewController.testPlaceholderTextView.placeholderLabel.hidden);
	testViewController.testPlaceholderTextView.text = @"placeholder should appear";
	XCTAssertFalse(testViewController.testPlaceholderTextView.placeholderLabel.hidden);
}

@end
