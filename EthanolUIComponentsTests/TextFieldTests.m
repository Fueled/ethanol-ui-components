//
//  TextFieldTests.m
//  EthanolUIComponents
//
//  Created by Stephane Copin on 9/8/15.
//  Copyright © 2015 Stephane Copin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ETHTextField.h"

@import EthanolValidationFormatting;

@interface TextFieldTestDelegateValidateWithoutDid : NSObject <ETHTextFieldDelegate>

@property (nonatomic, assign) BOOL delegateCalled;

@end

@implementation TextFieldTestDelegateValidateWithoutDid

- (BOOL)textField:(ETHTextField *)textField shouldValidateText:(NSString *)text forReason:(ETHTextFieldValidationReason)reason {
	self.delegateCalled = YES;
	return YES;
}

@end

@interface TextFieldTestDelegateWithDid : TextFieldTestDelegateValidateWithoutDid

@end

@implementation TextFieldTestDelegateWithDid

- (BOOL)textField:(ETHTextField *)textField didValidateText:(nonnull NSString *)text withReason:(ETHTextFieldValidationReason)reason withSuccess:(BOOL)success error:(nonnull NSError *)error {
	return error != nil;
}

@end


@interface TextFieldTests : XCTestCase

@end

@implementation TextFieldTests

#pragma mark - Test Load View

- (void)textTextFieldInView {
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Tests" bundle:[NSBundle bundleForClass:[self class]]];
	UIViewController *testViewController = [storyboard instantiateViewControllerWithIdentifier:@"TestsViewControllerID"];
	[testViewController loadView];
	
	XCTAssertNotNil(testViewController.view);
}

#pragma mark - Text Validation

- (void)testTextFieldValidateSilently {
	TextFieldTestDelegateValidateWithoutDid * delegate = [[TextFieldTestDelegateValidateWithoutDid alloc] init];
	ETHTextField * textField = [[ETHTextField alloc] init];
	textField.delegate = delegate;
	textField.validator = [[ETHUSAStateValidator alloc] init];
	[textField validateInputSilently];
	XCTAssertFalse(delegate.delegateCalled);
}

- (void)testTextFieldValidateWithoutDidValidate {
	TextFieldTestDelegateValidateWithoutDid * delegate = [[TextFieldTestDelegateValidateWithoutDid alloc] init];
	ETHTextField * textField = [[ETHTextField alloc] init];
	textField.delegate = delegate;
	textField.validator = [[ETHUSAStateValidator alloc] init];
	textField.text = @"NY";
	XCTAssertTrue([textField validateInput]);
	XCTAssertTrue(delegate.delegateCalled);
}

- (void)testTextFieldValidateWithDidValidate {
	TextFieldTestDelegateWithDid * delegate = [[TextFieldTestDelegateWithDid alloc] init];
	ETHTextField * textField = [[ETHTextField alloc] init];
	textField.delegate = delegate;
	textField.validator = [[ETHUSAStateValidator alloc] init];
	textField.text = @"NY";
	XCTAssertFalse([textField validateInput]);
	XCTAssertTrue(delegate.delegateCalled);
}

#pragma mark - Text Formatting

- (void)testTextFieldTextIsFormattedAutomatically {
	ETHTextField * textField = [[ETHTextField alloc] init];
	textField.text = @"411111 11111 111 11";
	XCTAssertEqualObjects(textField.text, @"411111 11111 111 11");
	textField.formatter = [[ETHCreditCardNumberFormatter alloc] init];
	XCTAssertEqualObjects(textField.text, @"4111 1111 1111 1111");
	textField.text = @"411111 11111 111 11";
	XCTAssertEqualObjects(textField.text, @"4111 1111 1111 1111");
	textField.formatter = nil;
	XCTAssertEqualObjects(textField.text, @"4111 1111 1111 1111");
	textField.text = @"411111 11111 111 11";
	XCTAssertEqualObjects(textField.text, @"411111 11111 111 11");
}

#pragma mark - Text Allowed Characters

- (void)testTextFieldAllowedCharacters {
	ETHTextField * textField = [[ETHTextField alloc] init];
	textField.text = @"abcdef 123456";
	XCTAssertEqualObjects(textField.text, @"abcdef 123456");
	textField.allowedCharacterSet = [NSCharacterSet letterCharacterSet];
	XCTAssertEqualObjects(textField.text, @"abcdef");
	textField.text = @"abcdef 123456";
	XCTAssertEqualObjects(textField.text, @"abcdef");
	textField.allowedCharacterSet = [NSCharacterSet decimalDigitCharacterSet];
	XCTAssertEqualObjects(textField.text, @"");
	textField.text = @"abcdef 123456";
	XCTAssertEqualObjects(textField.text, @"123456");
	textField.text = @"abcdef 123456";
	textField.allowedCharacterSet = [NSCharacterSet decimalDigitCharacterSet];
	XCTAssertEqualObjects(textField.text, @"123456");
	textField.allowedCharacterSet = [NSCharacterSet alphanumericCharacterSet];
	textField.text = @"abcdef 123456";
	XCTAssertEqualObjects(textField.text, @"abcdef123456");
	textField.allowedCharacterSet = [NSCharacterSet alphanumericCharacterSet];
	XCTAssertEqualObjects(textField.text, @"abcdef123456");
	textField.allowedCharacterSet = nil;
	XCTAssertEqualObjects(textField.text, @"abcdef123456");
}

@end
