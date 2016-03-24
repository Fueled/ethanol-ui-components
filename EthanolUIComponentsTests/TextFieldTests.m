//
//  TextFieldTests.m
//  EthanolUIComponents
//
//  Created by Stephane Copin on 9/8/15.
//  Copyright © 2015 Stephane Copin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ETHTextField.h"
#import "ETHTextField+Subclass.h"
#import "ETHExtendableTextField+Subclass.h"
#import "TestViewController.h"

@import EthanolValidationFormatting;

@interface ETHExtendableTextField (Private)

- (void)textChanged:(id)sender;

@end

@interface TestCustomTextFieldCallDidChange : ETHExtendableTextField

@end

@implementation TestCustomTextFieldCallDidChange

- (void)textFieldTextDidChange:(ETHExtendableTextField *)textField {
  [self.delegate textFieldTextDidChange:textField];
}

@end

@interface TestCustomTextFieldDontCallDidChange : ETHExtendableTextField

@end

@implementation TestCustomTextFieldDontCallDidChange

- (void)textFieldTextDidChange:(ETHExtendableTextField *)textField {
  
}

@end

@interface TestCustomTextFieldMultipleDelegateCalledOnlyOnce : ETHTextField <ETHTextFieldDelegate>

@end

@implementation TestCustomTextFieldMultipleDelegateCalledOnlyOnce

- (BOOL)textField:(ETHTextField *)textField shouldFormat:(NSString *)text {
  // The delegate should always be called once
  if([self.delegate textField:textField shouldFormat:text]) {
    return [self.delegate textField:textField shouldFormat:text];
  }
  
  return [self.delegate textField:textField shouldFormat:text];
}

@end

@interface TestCustomTextFieldShouldChange : ETHTextField <ETHTextFieldDelegate>

@property (nonatomic, assign) BOOL shouldShouldReturnYes;
@property (nonatomic, assign) BOOL shouldCalled;

@end

@implementation TestCustomTextFieldShouldChange

- (BOOL)textFieldTextShouldChange:(ETHExtendableTextField *)textField toText:(NSString *)text {
  self.shouldCalled = YES;
  return self.shouldShouldReturnYes;
}

@end

@interface TextFieldTestDelegateShouldNotFormat : NSObject <ETHTextFieldDelegate>

@property (nonatomic, assign) BOOL shouldDelegateCalled;

@end

@implementation TextFieldTestDelegateShouldNotFormat

- (BOOL)textField:(ETHTextField *)textField shouldFormat:(NSString *)text {
  self.shouldDelegateCalled = YES;
  return NO;
}

@end

@interface TextFieldTestDelegateValidateWithoutDid : NSObject <ETHTextFieldDelegate>

@property (nonatomic, assign) BOOL shouldShouldReturnYes;
@property (nonatomic, assign) BOOL shouldDelegateCalled;
@property (nonatomic, assign) BOOL shouldReturnShouldReturnYes;
@property (nonatomic, assign) BOOL shouldReturnDelegateCalled;
@property (nonatomic, assign) NSInteger shouldDelegateCallAmount;

@end

@implementation TextFieldTestDelegateValidateWithoutDid

- (BOOL)textField:(ETHTextField *)textField shouldFormat:(NSString *)text {
  self.shouldDelegateCalled = YES;
  ++self.shouldDelegateCallAmount;
  return self.shouldShouldReturnYes;
}

- (BOOL)textField:(ETHTextField *)textField shouldValidateText:(NSString *)text forReason:(ETHTextFieldValidationReason)reason {
  self.shouldDelegateCalled = YES;
  return self.shouldShouldReturnYes;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  self.shouldReturnDelegateCalled = YES;
  return self.shouldReturnShouldReturnYes;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
  self.shouldReturnDelegateCalled = YES;
  return self.shouldReturnShouldReturnYes;
}

@end

@interface TextFieldTestDelegateValidateWithDid : TextFieldTestDelegateValidateWithoutDid

@property (nonatomic, assign) BOOL didDelegateCalled;

@end

@implementation TextFieldTestDelegateValidateWithDid

- (void)textField:(ETHTextField *)textField didFormat:(NSString *)text {
  self.didDelegateCalled = YES;
}

- (BOOL)textField:(ETHTextField *)textField didValidateText:(nonnull NSString *)text withReason:(ETHTextFieldValidationReason)reason withSuccess:(BOOL)success error:(nullable NSError *)error {
  self.didDelegateCalled = YES;
  return error == nil;
}

- (void)textFieldTextDidChange:(ETHExtendableTextField *)textField {
  self.didDelegateCalled = YES;
}

@end

@interface TextFieldTestShouldChangeCharactersInRangeDelegate : NSObject <ETHTextFieldDelegate>

@end

@implementation TextFieldTestShouldChangeCharactersInRangeDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  return NO;
}

- (BOOL)textField:(ETHTextField *)textField shouldFormat:(NSString *)text {
  return YES;
}

@end

@interface CustomValidator : ETHValidator

@property (nonatomic, assign) BOOL validateCalled;
@property (nonatomic, assign) BOOL shouldValidate;

@end

@implementation CustomValidator

- (BOOL)validateObject:(id)object error:(NSError **)error {
  self.validateCalled = YES;
  return self.shouldValidate;
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

// Emulate user input
#define USER_INPUT(textString) \
  if([textField textField:textField shouldChangeCharactersInRange:NSMakeRange(0, textField.text.length) replacementString:textString]) { \
    textField.text = textString; \
  }

#define TEST_USER_INPUT(textString, resultString) \
  USER_INPUT(textString); \
  XCTAssertEqualObjects(textField.text, resultString);

- (void)testUserTestInputWithEverything {
  NSString * textToBeReplaced = @"should be replaced by \"text\"'s variable content";
  
  ETHTextField * textField = [[ETHTextField alloc] init];
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

- (void)testTextFieldTextInputPreventTextChange {
  NSString * textToBeReplaced = @"should be replaced by \"text\"'s variable content";
  
  TextFieldTestShouldChangeCharactersInRangeDelegate * delegate = [[TextFieldTestShouldChangeCharactersInRangeDelegate alloc] init];
  ETHTextField * textField = [[ETHTextField alloc] init];
  textField.delegate = delegate;
  textField.text = textToBeReplaced;
  textField.formatter = [[ETHCreditCardNumberFormatter alloc] init];
  XCTAssertEqualObjects(textField.text, textToBeReplaced);
  textField.text = @"4111111111111111";
  XCTAssertEqualObjects(textField.text, @"4111 1111 1111 1111");
  
  textField.text = textToBeReplaced;
  TEST_USER_INPUT(@"4111111111111111", textToBeReplaced);
}

- (void)testTextFieldTextInputShouldFormatEvenIfDisallowedCharactersEmpty {
  TextFieldTestDelegateShouldNotFormat * delegate = [[TextFieldTestDelegateShouldNotFormat alloc] init];
  ETHTextField * textField = [[ETHTextField alloc] init];
  textField.formatter = [[ETHCreditCardNumberFormatter alloc] init];
  textField.allowedCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@""];
  textField.delegate = delegate;
  TEST_USER_INPUT(@"4111111111111111", @"");
  XCTAssertTrue(delegate.shouldDelegateCalled);
}

- (void)testTextFieldUserInputShouldChange {
  NSString * textToBeReplaced = @"should be replaced by \"text\"'s variable content";
  
  TestCustomTextFieldShouldChange * textField = [[TestCustomTextFieldShouldChange alloc] init];
  textField.shouldShouldReturnYes = YES;
  textField.formatter = [[ETHCreditCardNumberFormatter alloc] init];
  textField.text = textToBeReplaced;
  TEST_USER_INPUT(@"4111111111111111", @"4111 1111 1111 1111");
  XCTAssertTrue(textField.shouldCalled);
}

- (void)testTextFieldUserInputShouldNotChange {
  NSString * textToBeReplaced = @"should be replaced by \"text\"'s variable content";
  
  TestCustomTextFieldShouldChange * textField = [[TestCustomTextFieldShouldChange alloc] init];
  textField.formatter = [[ETHCreditCardNumberFormatter alloc] init];
  textField.shouldShouldReturnYes = YES;
  textField.text = textToBeReplaced;
  textField.shouldShouldReturnYes = NO;
  TEST_USER_INPUT(@"4111111111111111", textToBeReplaced);
  XCTAssertTrue(textField.shouldCalled);
}

- (void)testTextFieldReturn {
  ETHTextField * textField = [[ETHTextField alloc] init];
  XCTAssertTrue([textField textFieldShouldReturn:textField]);
  
  textField.formatter = [[ETHCreditCardNumberFormatter alloc] init];
  textField.validator = [ETHSelectorValidator validatorWithSelector:@selector(eth_isValidCreditCardNumber) error:@"unused"];
}

- (void)testTextFieldReturnDelegate {
  TextFieldTestDelegateValidateWithoutDid * delegate = [[TextFieldTestDelegateValidateWithoutDid alloc] init];
  ETHTextField * textField = [[ETHTextField alloc] init];
  textField.delegate = delegate;
  XCTAssertFalse([textField textFieldShouldReturn:textField]);
  XCTAssertTrue(delegate.shouldReturnDelegateCalled);
}

- (void)testTextFieldReturnDoValidate {
  ETHTextField * textField = [[ETHTextField alloc] init];
  textField.validateOnReturn = YES;
  CustomValidator * validator = [CustomValidator validator];
  validator.shouldValidate = NO;
  textField.validator = validator;
  XCTAssertFalse([textField textFieldShouldReturn:textField]);
  XCTAssertTrue(validator.validateCalled);
}

- (void)testTextFieldReturnDoNotValidate {
  ETHTextField * textField = [[ETHTextField alloc] init];
  textField.validateOnReturn = NO;
  CustomValidator * validator = [CustomValidator validator];
  validator.shouldValidate = NO;
  textField.validator = validator;
  XCTAssertTrue([textField textFieldShouldReturn:textField]);
  XCTAssertFalse(validator.validateCalled);
}

- (void)testTextFieldReturnDoValidateWithValidateDelegate {
  TextFieldTestDelegateValidateWithoutDid * delegate = [[TextFieldTestDelegateValidateWithoutDid alloc] init];
  delegate.shouldShouldReturnYes = YES;
  delegate.shouldReturnShouldReturnYes = YES;
  ETHTextField * textField = [[ETHTextField alloc] init];
  textField.delegate = delegate;
  CustomValidator * validator = [CustomValidator validator];
  validator.shouldValidate = YES;
  textField.validator = validator;
  XCTAssertTrue([textField textFieldShouldReturn:textField]);
  XCTAssertTrue(validator.validateCalled);
}

- (void)testTextFieldReturnDoValidateWithValidateDelegateAndValidateOnReturnFalse {
  TextFieldTestDelegateValidateWithoutDid * delegate = [[TextFieldTestDelegateValidateWithoutDid alloc] init];
  delegate.shouldShouldReturnYes = YES;
  delegate.shouldReturnShouldReturnYes = YES;
  ETHTextField * textField = [[ETHTextField alloc] init];
  textField.validateOnReturn = NO;
  textField.delegate = delegate;
  CustomValidator * validator = [CustomValidator validator];
  validator.shouldValidate = YES;
  textField.validator = validator;
  XCTAssertTrue([textField textFieldShouldReturn:textField]);
  XCTAssertTrue(validator.validateCalled);
}

- (void)testTextFieldReturnDoValidateWithNoValidateDelegate {
  TextFieldTestDelegateValidateWithoutDid * delegate = [[TextFieldTestDelegateValidateWithoutDid alloc] init];
  delegate.shouldShouldReturnYes = YES;
  delegate.shouldReturnShouldReturnYes = NO;
  ETHTextField * textField = [[ETHTextField alloc] init];
  textField.delegate = delegate;
  CustomValidator * validator = [CustomValidator validator];
  validator.shouldValidate = YES;
  textField.validator = validator;
  XCTAssertFalse([textField textFieldShouldReturn:textField]);
  XCTAssertTrue(validator.validateCalled);
}

- (void)testTextFieldReturnDoValidateWithValidateDelegateDid {
  TextFieldTestDelegateValidateWithDid * delegate = [[TextFieldTestDelegateValidateWithDid alloc] init];
  delegate.shouldShouldReturnYes = YES;
  delegate.shouldReturnShouldReturnYes = YES;
  ETHTextField * textField = [[ETHTextField alloc] init];
  textField.delegate = delegate;
  CustomValidator * validator = [CustomValidator validator];
  validator.shouldValidate = YES;
  textField.validator = validator;
  XCTAssertTrue([textField textFieldShouldReturn:textField]);
  XCTAssertTrue(validator.validateCalled);
}

- (void)testTextFieldEndEditing {
  ETHTextField * textField = [[ETHTextField alloc] init];
  XCTAssertTrue([textField textFieldShouldEndEditing:textField]);
  
  textField.formatter = [[ETHCreditCardNumberFormatter alloc] init];
  textField.validator = [ETHSelectorValidator validatorWithSelector:@selector(eth_isValidCreditCardNumber) error:@"unused"];
}

- (void)testTextFieldEndEditingDelegate {
  TextFieldTestDelegateValidateWithoutDid * delegate = [[TextFieldTestDelegateValidateWithoutDid alloc] init];
  ETHTextField * textField = [[ETHTextField alloc] init];
  textField.delegate = delegate;
  XCTAssertFalse([textField textFieldShouldEndEditing:textField]);
  XCTAssertTrue(delegate.shouldReturnDelegateCalled);
}

- (void)testTextFieldEndEditingDoValidate {
  ETHTextField * textField = [[ETHTextField alloc] init];
  textField.validateOnLostFocus = YES;
  CustomValidator * validator = [CustomValidator validator];
  validator.shouldValidate = NO;
  textField.validator = validator;
  XCTAssertFalse([textField textFieldShouldEndEditing:textField]);
  XCTAssertTrue(validator.validateCalled);
}

- (void)testTextFieldEndEditingDoNotValidate {
  ETHTextField * textField = [[ETHTextField alloc] init];
  textField.validateOnLostFocus = NO;
  CustomValidator * validator = [CustomValidator validator];
  validator.shouldValidate = NO;
  textField.validator = validator;
  XCTAssertTrue([textField textFieldShouldEndEditing:textField]);
  XCTAssertFalse(validator.validateCalled);
}

- (void)testTextFieldEndEditingDoValidateWithValidateDelegate {
  TextFieldTestDelegateValidateWithoutDid * delegate = [[TextFieldTestDelegateValidateWithoutDid alloc] init];
  delegate.shouldShouldReturnYes = YES;
  delegate.shouldReturnShouldReturnYes = YES;
  ETHTextField * textField = [[ETHTextField alloc] init];
  textField.delegate = delegate;
  CustomValidator * validator = [CustomValidator validator];
  validator.shouldValidate = YES;
  textField.validator = validator;
  XCTAssertTrue([textField textFieldShouldEndEditing:textField]);
  XCTAssertTrue(validator.validateCalled);
}

- (void)testTextFieldEndEditingDoValidateWithValidateDelegateAndValidateOnReturnFalse {
  TextFieldTestDelegateValidateWithoutDid * delegate = [[TextFieldTestDelegateValidateWithoutDid alloc] init];
  delegate.shouldShouldReturnYes = YES;
  delegate.shouldReturnShouldReturnYes = YES;
  ETHTextField * textField = [[ETHTextField alloc] init];
  textField.validateOnLostFocus = NO;
  textField.delegate = delegate;
  CustomValidator * validator = [CustomValidator validator];
  validator.shouldValidate = YES;
  textField.validator = validator;
  XCTAssertTrue([textField textFieldShouldEndEditing:textField]);
  XCTAssertTrue(validator.validateCalled);
}

- (void)testTextFieldEndEditingDoValidateWithNoValidateDelegate {
  TextFieldTestDelegateValidateWithoutDid * delegate = [[TextFieldTestDelegateValidateWithoutDid alloc] init];
  delegate.shouldShouldReturnYes = YES;
  delegate.shouldReturnShouldReturnYes = NO;
  ETHTextField * textField = [[ETHTextField alloc] init];
  textField.delegate = delegate;
  CustomValidator * validator = [CustomValidator validator];
  validator.shouldValidate = YES;
  textField.validator = validator;
  XCTAssertFalse([textField textFieldShouldEndEditing:textField]);
  XCTAssertTrue(validator.validateCalled);
}

- (void)testTextFieldEndEditingDoValidateWithValidateDelegateDid {
  TextFieldTestDelegateValidateWithDid * delegate = [[TextFieldTestDelegateValidateWithDid alloc] init];
  delegate.shouldShouldReturnYes = YES;
  delegate.shouldReturnShouldReturnYes = YES;
  ETHTextField * textField = [[ETHTextField alloc] init];
  textField.delegate = delegate;
  CustomValidator * validator = [CustomValidator validator];
  validator.shouldValidate = YES;
  textField.validator = validator;
  XCTAssertTrue([textField textFieldShouldEndEditing:textField]);
  XCTAssertTrue(validator.validateCalled);
}

- (void)testTextDidChangeDelegateDidCalled {
  TextFieldTestDelegateValidateWithDid * delegate = [[TextFieldTestDelegateValidateWithDid alloc] init];
  TestCustomTextFieldCallDidChange * textField = [[TestCustomTextFieldCallDidChange alloc] init];
  textField.delegate = delegate;
  [textField textChanged:nil];
  XCTAssertTrue(delegate.didDelegateCalled);
}

- (void)testTextDidChangeDelegateDidNotCalled {
  TextFieldTestDelegateValidateWithDid * delegate = [[TextFieldTestDelegateValidateWithDid alloc] init];
  TestCustomTextFieldDontCallDidChange * textField = [[TestCustomTextFieldDontCallDidChange alloc] init];
  textField.delegate = delegate;
  [textField textChanged:nil];
  XCTAssertFalse(delegate.didDelegateCalled); // Delegate won't be called if the text field doesn't explicitely call them
}

- (void)testTextFieldMultipleDelegateCallShouldCalledFormatting {
  TextFieldTestDelegateValidateWithDid * delegate = [[TextFieldTestDelegateValidateWithDid alloc] init];
  delegate.shouldShouldReturnYes = YES;
  TestCustomTextFieldMultipleDelegateCalledOnlyOnce * textField = [[TestCustomTextFieldMultipleDelegateCalledOnlyOnce alloc] init];
  textField.formatter = [[ETHCreditCardNumberFormatter alloc] init];
  textField.delegate = delegate;
  textField.text = @"4111111111111111";
  XCTAssertTrue(delegate.shouldDelegateCalled);
  XCTAssertEqual(delegate.shouldDelegateCallAmount, 1);
  XCTAssertEqualObjects(textField.text, @"4111 1111 1111 1111");
}

- (void)testTextFieldMultipleDelegateCallShouldCalledNoFormatting {
  TextFieldTestDelegateValidateWithDid * delegate = [[TextFieldTestDelegateValidateWithDid alloc] init];
  TestCustomTextFieldMultipleDelegateCalledOnlyOnce * textField = [[TestCustomTextFieldMultipleDelegateCalledOnlyOnce alloc] init];
  textField.formatter = [[ETHCreditCardNumberFormatter alloc] init];
  textField.delegate = delegate;
  textField.text = @"4111111111111111";
  XCTAssertTrue(delegate.shouldDelegateCalled);
  XCTAssertEqual(delegate.shouldDelegateCallAmount, 1);
  XCTAssertEqualObjects(textField.text, @"4111111111111111");
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
  XCTAssertTrue([textField validateInput]);
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
