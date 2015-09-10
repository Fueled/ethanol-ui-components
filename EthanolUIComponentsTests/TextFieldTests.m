//
//  TextFieldTests.m
//  EthanolUIComponents
//
//  Created by Stephane Copin on 9/8/15.
//  Copyright © 2015 Stephane Copin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ETHTextField.h"
#import "ETHExtendableTextField+Subclass.h"
#import "TestViewController.h"

@import EthanolValidationFormatting;

@interface TextFieldTestDelegateValidateWithoutDid : NSObject <ETHTextFieldDelegate>

@property (nonatomic, assign) BOOL shouldShouldReturnYes;
@property (nonatomic, assign) BOOL shouldDelegateCalled;

@end

@implementation TextFieldTestDelegateValidateWithoutDid

- (BOOL)textField:(ETHTextField *)textField shouldFormat:(NSString *)text {
	self.shouldDelegateCalled = YES;
	return self.shouldShouldReturnYes;
}

- (BOOL)textField:(ETHTextField *)textField shouldValidateText:(NSString *)text forReason:(ETHTextFieldValidationReason)reason {
	self.shouldDelegateCalled = YES;
	return self.shouldShouldReturnYes;
}

@end

@interface TextFieldTestDelegateValidateWithDid : TextFieldTestDelegateValidateWithoutDid

@property (nonatomic, assign) BOOL didDelegateCalled;

@end

@implementation TextFieldTestDelegateValidateWithDid

- (void)textField:(ETHTextField *)textField didFormat:(NSString *)text {
	self.didDelegateCalled = YES;
}

- (BOOL)textField:(ETHTextField *)textField didValidateText:(nonnull NSString *)text withReason:(ETHTextFieldValidationReason)reason withSuccess:(BOOL)success error:(nonnull NSError *)error {
	self.didDelegateCalled = YES;
	return error != nil;
}

@end

@interface TextFieldTests : XCTestCase

@end

@implementation TextFieldTests

#pragma mark - Test Load View

- (void)testTextFieldInView {
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Tests" bundle:[NSBundle bundleForClass:[self class]]];
	TestViewController *testViewController = [storyboard instantiateViewControllerWithIdentifier:@"TestsViewControllerID"];
	[testViewController loadView];
	
	XCTAssertNotNil(testViewController.view);
	XCTAssertTrue([testViewController.testTextField isKindOfClass:[ETHTextField class]]);
}

#pragma mark - User input tests (Faked)

- (void)testUserTestInputWithEverything {
	ETHTextField * textField = [[ETHTextField alloc] init];
	NSString * textToBeReplaced = @"should be replaced by \"text\"'s variable content";
	
	// Emulate user input
#define USER_INPUT(textString) \
	if([textField textField:textField shouldChangeCharactersInRange:NSMakeRange(0, textField.text.length) replacementString:textString]) { \
		textField.text = textString; \
	}
	
#define TEST_USER_INPUT(textString, resultString) \
	USER_INPUT(textString); \
	XCTAssertEqualObjects(textField.text, resultString);
	
	textField.text = textToBeReplaced;
	TEST_USER_INPUT(@"text", @"text");
	
	textField.text = textToBeReplaced;
	
	textField.formatter = [[ETHCreditCardNumberFormatter alloc] init];
	textField.validator = [ETHSelectorValidator validatorWithSelector:@selector(eth_isValidCreditCardNumber) error:@"unused"];
	textField.maximumLength = 9;
	textField.allowedCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"14"];
	
	textField.text = textToBeReplaced;
	TEST_USER_INPUT(@"41 1818 181818 11 81", @"4111 1111 1");
}

#pragma mark - Text Validation

- (void)testTextFieldValidateSilently {
	TextFieldTestDelegateValidateWithoutDid * delegate = [[TextFieldTestDelegateValidateWithoutDid alloc] init];
	delegate.shouldShouldReturnYes = YES;
	ETHTextField * textField = [[ETHTextField alloc] init];
	textField.delegate = delegate;
	textField.validator = [[ETHUSAStateValidator alloc] init];
	[textField validateInputSilently];
	XCTAssertFalse(delegate.shouldDelegateCalled);
}

- (void)testTextFieldValidateWithoutDidValidates {
	TextFieldTestDelegateValidateWithDid * delegate = [[TextFieldTestDelegateValidateWithDid alloc] init];
	ETHTextField * textField = [[ETHTextField alloc] init];
	textField.delegate = delegate;
	textField.validator = [[ETHUSAStateValidator alloc] init];
	textField.text = @"NY";
	XCTAssertTrue([textField validateInput]);
	XCTAssertTrue(delegate.shouldDelegateCalled);
	XCTAssertFalse(delegate.didDelegateCalled);
}

- (void)testTextFieldValidateWithoutDidValidate {
	TextFieldTestDelegateValidateWithoutDid * delegate = [[TextFieldTestDelegateValidateWithoutDid alloc] init];
	delegate.shouldShouldReturnYes = YES;
	ETHTextField * textField = [[ETHTextField alloc] init];
	textField.delegate = delegate;
	textField.validator = [[ETHUSAStateValidator alloc] init];
	textField.text = @"NY";
	XCTAssertTrue([textField validateInput]);
	XCTAssertTrue(delegate.shouldDelegateCalled);
}

- (void)testTextFieldValidateWithDidValidate {
	TextFieldTestDelegateValidateWithDid * delegate = [[TextFieldTestDelegateValidateWithDid alloc] init];
	delegate.shouldShouldReturnYes = YES;
	ETHTextField * textField = [[ETHTextField alloc] init];
	textField.delegate = delegate;
	textField.validator = [[ETHUSAStateValidator alloc] init];
	textField.text = @"NY";
	XCTAssertFalse([textField validateInput]);
	XCTAssertTrue(delegate.shouldDelegateCalled);
	XCTAssertTrue(delegate.didDelegateCalled);
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

- (void)testTextFieldTextFormattingDelegateWithoutDid {
	TextFieldTestDelegateValidateWithoutDid * delegate = [[TextFieldTestDelegateValidateWithoutDid alloc] init];
	delegate.shouldShouldReturnYes = YES;
	ETHTextField * textField = [[ETHTextField alloc] init];
	textField.delegate = delegate;
	textField.formatter = [[ETHCreditCardNumberFormatter alloc] init];
	textField.text = @"411111 11111 111 11";
	XCTAssertEqualObjects(textField.text, @"4111 1111 1111 1111");
	XCTAssertTrue(delegate.shouldDelegateCalled);
}

- (void)testTextFieldTextFormattingDelegateWithDidShouldReturnNO {
	TextFieldTestDelegateValidateWithDid * delegate = [[TextFieldTestDelegateValidateWithDid alloc] init];
	ETHTextField * textField = [[ETHTextField alloc] init];
	textField.delegate = delegate;
	textField.formatter = [[ETHCreditCardNumberFormatter alloc] init];
	textField.text = @"411111 11111 111 11";
	XCTAssertEqualObjects(textField.text, @"411111 11111 111 11");
	XCTAssertTrue(delegate.shouldDelegateCalled);
	XCTAssertFalse(delegate.didDelegateCalled);
}

- (void)testTextFieldTextFormattingDelegateWithDid {
	TextFieldTestDelegateValidateWithDid * delegate = [[TextFieldTestDelegateValidateWithDid alloc] init];
	delegate.shouldShouldReturnYes = YES;
	ETHTextField * textField = [[ETHTextField alloc] init];
	textField.delegate = delegate;
	textField.formatter = [[ETHCreditCardNumberFormatter alloc] init];
	textField.text = @"411111 11111 111 11";
	XCTAssertEqualObjects(textField.text, @"4111 1111 1111 1111");
	XCTAssertTrue(delegate.shouldDelegateCalled);
	XCTAssertTrue(delegate.didDelegateCalled);
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

#pragma mark - Text Maximum Number of Characters

- (void)testMaximumNumberOfCharacters {
	ETHTextField * textField = [[ETHTextField alloc] init];
	textField.text = @"abcdef 123456";
	XCTAssertEqualObjects(textField.text, @"abcdef 123456");
	textField.maximumLength = 10;
	XCTAssertEqualObjects(textField.text, @"abcdef 123");
	textField.text = @"abcdef 123456";
	XCTAssertEqualObjects(textField.text, @"abcdef 123");
	textField.maximumLength = 0;
	XCTAssertEqualObjects(textField.text, @"abcdef 123");
	textField.text = @"abcdef 123456";
	XCTAssertEqualObjects(textField.text, @"abcdef 123456");
	textField.maximumLength = 13;
	XCTAssertEqualObjects(textField.text, @"abcdef 123456");
	textField.text = @"abcdef 123456";
	XCTAssertEqualObjects(textField.text, @"abcdef 123456");
	textField.maximumLength = 12;
	XCTAssertEqualObjects(textField.text, @"abcdef 12345");
	textField.text = @"abcdef 123456";
	XCTAssertEqualObjects(textField.text, @"abcdef 12345");
}

@end
