//
//  ETHTextField.m
//  Ethanol
//
//  Created by Stephane Copin on 3/7/14.
//  Copyright (c) 2014 Fueled. All rights reserved.
//

#import "ETHTextField.h"
#import "ETHTextField+Subclass.h"
#import "ETHExtendableTextField+Subclass.h"
#import <EthanolValidationFormatting/ETHValidator.h>
#import <EthanolValidationFormatting/ETHFormatter.h>
#import <EthanolUtilities/NSString+EthanolUtils.h>

@interface ETHTextField ()

@property (nonatomic, copy, nonnull, readonly) NSString * nonNullableText;

@end

@implementation ETHTextField
@dynamic delegate;

+ (void)initialize {
  [super initialize];
}

- (instancetype)init {
  self = [super init];
  if(self) {
    [self textField_commonInit];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if(self) {
    [self textField_commonInit];
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if(self) {
    [self textField_commonInit];
  }
  return self;
}

- (void)textField_commonInit {
  _validateOnLostFocus = NO;
  _validateOnReturn = YES;
  _validateOnKeyTapped = NO;
}

- (BOOL)validateInputSilently {
  NSError * error;
  return [self doValidateText:self.nonNullableText error:&error];
}

- (BOOL)validateInput {
  NSError * error;
  BOOL success = [self doValidateText:self.nonNullableText error:&error];
  
  if([self shouldValidateText:self.nonNullableText forReason:ETHTextFieldValidationReasonProgramatically] && [self.proxyDelegate respondsToSelector:@selector(textField:didValidateText:withReason:withSuccess:error:)]) {
    return [self.proxyDelegate textField:self didValidateText:self.nonNullableText withReason:ETHTextFieldValidationReasonProgramatically withSuccess:success error:error];
  }
  
  return success;
}

- (BOOL)shouldFormatText:(NSString *)text {
  return ![self.proxyDelegate respondsToSelector:@selector(textField:shouldFormat:)] || ([self.proxyDelegate respondsToSelector:@selector(textField:shouldFormat:)] && [self.proxyDelegate textField:self shouldFormat:text]);
}

- (BOOL)shouldValidateText:(NSString *)text forReason:(ETHTextFieldValidationReason)reason {
  BOOL shouldValidate;
  switch (reason) {
    case ETHTextFieldValidationReasonKeyTapped:
      shouldValidate = self.validateOnKeyTapped;
      break;
    case ETHTextFieldValidationReasonLostFocus:
      shouldValidate = self.validateOnLostFocus;
      break;
    case ETHTextFieldValidationReasonReturnTapped:
      shouldValidate = self.validateOnReturn;
      break;
    default:
      shouldValidate = YES;
      break;
  }
  if([self.proxyDelegate respondsToSelector:@selector(textField:shouldValidateText:forReason:)]) {
    return [self.proxyDelegate textField:self shouldValidateText:text forReason:reason];
  }
  return shouldValidate;
}

- (void)setFormatter:(ETHFormatter *)formatter {
  if(formatter == nil) {
    _formatter = nil;
    return;
  }
  
  if(_formatter != formatter) {
    UITextRange * selectedTextRange = [self selectedTextRange];
    NSInteger startCursor = [self offsetFromPosition:[self beginningOfDocument] toPosition:selectedTextRange.start];
    NSInteger endCursor = [self offsetFromPosition:[self beginningOfDocument] toPosition:selectedTextRange.end];
    NSString * text = [_formatter unformatString:self.text preserveCursor:&startCursor] ?: self.text;
    [_formatter unformatString:self.text preserveCursor:&endCursor];
    
    _formatter = formatter;
    
    [super setText:[formatter formatObject:text preserveCursor:&startCursor changeInCharacterOffset:0] ?: text];
    [formatter formatObject:text preserveCursor:&endCursor changeInCharacterOffset:0];
    
    UITextPosition * startCursorPosition = [self positionFromPosition:[self beginningOfDocument] offset:MAX(0, MIN(((NSInteger)self.text.length), startCursor))];
    UITextPosition * endCursorPosition = [self positionFromPosition:[self beginningOfDocument] offset:MAX(0, MIN(((NSInteger)self.text.length), endCursor))];
    [self setSelectedTextRange:[self textRangeFromPosition:startCursorPosition toPosition:endCursorPosition]];
  }
}

- (void)setAllowedCharacterSet:(NSCharacterSet *)allowedCharacterSet {
  if(_allowedCharacterSet != allowedCharacterSet) {
    _allowedCharacterSet = allowedCharacterSet;
    
    self.text = [self.text eth_stringByRemovingCharacters:[_allowedCharacterSet invertedSet]];
  }
}

- (void)setMaximumLength:(NSUInteger)maximumLength {
  _maximumLength = maximumLength;
  
  if(_maximumLength != 0 && _maximumLength < self.text.length) {
    self.text = [self.text substringToIndex:maximumLength];
  }
}

- (BOOL)textFieldTextShouldChange:(ETHExtendableTextField *)textField toText:(NSString *)text {
  return [self tryToValidateText:text withDelegateForReason:ETHTextFieldValidationReasonKeyTapped];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
  BOOL shouldReturn = [self tryToValidateText:self.nonNullableText withDelegateForReason:ETHTextFieldValidationReasonLostFocus];
  
  if(shouldReturn && [self.delegate respondsToSelector:@selector(textFieldShouldEndEditing:)] && ![self.delegate textFieldShouldEndEditing:textField]) {
    return NO;
  }
  
  return shouldReturn;
}

- (void)setText:(NSString *)text {
  if([self tryToChangeCharactersInRange:NSMakeRange(0, self.text.length) withString:text callDependentMethods:NO]) {
    [super setText:text];
  }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  return [self tryToChangeCharactersInRange:range withString:string callDependentMethods:YES];
}

- (BOOL)tryToChangeCharactersInRange:(NSRange)range withString:(NSString *)string callDependentMethods:(BOOL)callDependentMethods {
  BOOL hasDisallowedCharacters = NO;
  if(self.allowedCharacterSet != nil) {
    NSUInteger originalLength = string.length;
    string = [string eth_stringByRemovingCharacters:[self.allowedCharacterSet invertedSet]];
    
    if(string.length != originalLength) {
      hasDisallowedCharacters = YES;
    }
  }
  
  if(callDependentMethods) {
    if([self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)] && ![self.delegate textField:self shouldChangeCharactersInRange:range replacementString:string]) {
      return NO;
    }
  }
  
  NSMutableString * expectedText = [self.text mutableCopy];
  [expectedText replaceCharactersInRange:range withString:string ?: @""];
  NSInteger cursorOffset = 0;
  BOOL shouldFormat = self.formatter != nil && [self shouldFormatText:expectedText];
  if(shouldFormat) {
    NSInteger cursor = string.length;
    string = [self.formatter unformatString:string preserveCursor:&cursor] ?: string;
    cursorOffset += string.length - cursor;
  }
  
  NSMutableString * newText = [self.text mutableCopy];
  [newText replaceCharactersInRange:range withString:string ?: @""];
  
  NSInteger cursor = NSIntegerMin;
  if(shouldFormat) {
    NSInteger rangeLocation = range.location;
    NSInteger rangeEnd = range.location + range.length;
    NSString * originalText = [newText copy];
    newText = [[self.formatter unformatString:originalText preserveCursor:&rangeLocation] mutableCopy] ?: newText;
    [self.formatter unformatString:originalText preserveCursor:&rangeEnd];
    
    UITextRange * selectedTextRange = [self selectedTextRange];
    NSInteger originalCursor = [self offsetFromPosition:[self beginningOfDocument] toPosition:selectedTextRange.start];
    cursor = originalCursor + cursorOffset;
    [self.formatter unformatString:originalText preserveCursor:&cursor];
    
    range.location = rangeLocation;
    range.length = rangeEnd - rangeLocation;
  }
  
  BOOL hasReachedLimitOfCharacters = NO;
  if(self.maximumLength != 0 && newText.length > self.maximumLength) {
    NSInteger charactersToRemove = newText.length - self.maximumLength;
    [newText deleteCharactersInRange:NSMakeRange(range.location + string.length - charactersToRemove, charactersToRemove)];
    hasReachedLimitOfCharacters = YES;
  }
  
  if(shouldFormat) {
    newText = [[self.formatter formatObject:newText
                             preserveCursor:&cursor
                    changeInCharacterOffset:string.length == 0 ? ((range.length == 1 && cursor != range.location) ? -1 : 0) : string.length] mutableCopy];
  }
  
  if(callDependentMethods) {
    if([self.proxyDelegate respondsToSelector:@selector(textFieldTextShouldChange:toText:)] && ![self.proxyDelegate textFieldTextShouldChange:self toText:newText]) {
      return NO;
    }
  }
  
  if(shouldFormat || hasDisallowedCharacters || hasReachedLimitOfCharacters) {
    [super setText:newText];
    
    if(cursor != NSIntegerMin) {
      UITextPosition * cursorPosition = [self positionFromPosition:[self beginningOfDocument] offset:MAX(0, MIN(((NSInteger)self.text.length), cursor))];
      [self setSelectedTextRange:[self textRangeFromPosition:cursorPosition toPosition:cursorPosition]];
    }
    
    if(shouldFormat) {
      if([self.proxyDelegate respondsToSelector:@selector(textField:didFormat:)]) {
        [self.proxyDelegate textField:self didFormat:newText];
      }
    }
    
    if(callDependentMethods) {
      [self sendActionsForControlEvents:UIControlEventEditingChanged];
    }
    return NO;
  }
  
  return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  BOOL shouldReturn = [self tryToValidateText:self.text withDelegateForReason:ETHTextFieldValidationReasonReturnTapped];
  
  if(shouldReturn && [self.delegate respondsToSelector:@selector(textFieldShouldReturn:)] && ![self.delegate textFieldShouldReturn:textField]) {
    return NO;
  }
  
  return shouldReturn;
}

- (BOOL)tryToValidateText:(NSString *)text withDelegateForReason:(ETHTextFieldValidationReason)reason {
  if([self shouldValidateText:text forReason:reason]) {
    return [self doValidateText:text withDelegateForReason:reason];
  }
  return YES;
}

- (BOOL)doValidateText:(NSString *)text withDelegateForReason:(ETHTextFieldValidationReason)reason {
  NSError * error;
  BOOL success = [self doValidateText:text error:&error];
  
  if([self.delegate respondsToSelector:@selector(textField:didValidateText:withReason:withSuccess:error:)]) {
    return [self.delegate textField:self didValidateText:text ?: @"" withReason:reason withSuccess:success error:error];
  }
  
  return success;
}

- (BOOL)doValidateText:(NSString *)text error:(NSError **)error {
  if(self.validator == nil) {
    return YES;
  }
  
  return [self.validator validateObject:text ?: @"" error:error];
}

- (NSString *)nonNullableText {
  return self.text ?: @"";
}

@end
