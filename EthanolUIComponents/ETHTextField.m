//
//  ETHTextField.m
//  Ethanol
//
//  Created by Stephane Copin on 3/7/14.
//  Copyright (c) 2014 Fueled. All rights reserved.
//

#import "ETHTextField.h"
#import "ETHExtendableTextField+Subclass.h"
#import <EthanolValidationFormatting/ETHValidator.h>
#import <EthanolValidationFormatting/ETHFormatter.h>
#import <EthanolUtilities/NSString+EthanolUtils.h>

@interface ETHTextField ()

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
  return [self doValidate:&error];
}

- (BOOL)validateInput {
  NSError * error;
  BOOL success = [self doValidate:&error];
  
  if([self shouldValidateForReason:ETHTextFieldValidationReasonProgramatically] && [self.delegate respondsToSelector:@selector(textField:didValidateText:withReason:withSuccess:error:)]) {
    return [self.delegate textField:self didValidateText:self.text withReason:ETHTextFieldValidationReasonProgramatically withSuccess:success error:error];
  }
  
  return success;
}

- (BOOL)shouldFormat {
  return ![self.delegate respondsToSelector:@selector(textField:shouldFormat:)] || ([self.delegate respondsToSelector:@selector(textField:shouldFormat:)] && [self.delegate textField:self shouldFormat:self.text]);
}

- (BOOL)shouldValidateForReason:(ETHTextFieldValidationReason)reason {
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
  return (shouldValidate && ![self.delegate respondsToSelector:@selector(textField:shouldValidateText:forReason:)]) || ([self.delegate respondsToSelector:@selector(textField:shouldValidateText:forReason:)] && [self.delegate textField:self shouldValidateText:self.text forReason:reason]);
}

- (void)setFormatter:(ETHFormatter *)formatter {
  if(_formatter != formatter){
    UITextRange * selectedTextRange = [self selectedTextRange];
    NSInteger startCursor = [self offsetFromPosition:[self beginningOfDocument] toPosition:selectedTextRange.start];
    NSInteger endCursor = [self offsetFromPosition:[self beginningOfDocument] toPosition:selectedTextRange.end];
    NSString * text = [_formatter unformatString:self.text preserveCursor:&startCursor] ?: self.text;
    [_formatter unformatString:self.text preserveCursor:&endCursor];
    
    _formatter = formatter;
    
    self.text = [formatter formatObject:text preserveCursor:&startCursor changeInCharacterOffset:0] ?: text;
    [formatter formatObject:text preserveCursor:&endCursor changeInCharacterOffset:0];
    
    UITextPosition * startCursorPosition = [self positionFromPosition:[self beginningOfDocument] offset:MAX(0, MIN(((NSInteger)self.text.length), startCursor))];
    UITextPosition * endCursorPosition = [self positionFromPosition:[self beginningOfDocument] offset:MAX(0, MIN(((NSInteger)self.text.length), endCursor))];
    [self setSelectedTextRange:[self textRangeFromPosition:startCursorPosition toPosition:endCursorPosition]];
  }
}

- (BOOL)textFieldTextShouldChange:(ETHExtendableTextField *)textField {
  return [self tryToValidateWithDelegateForReason:ETHTextFieldValidationReasonKeyTapped];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
  if([self.delegate respondsToSelector:@selector(textFieldShouldEndEditing:)]) {
    return [self.delegate textFieldShouldEndEditing:textField];
  }
  
  return [self tryToValidateWithDelegateForReason:ETHTextFieldValidationReasonLostFocus];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  BOOL hasDisallowedCharacters = NO;
  if(self.allowedCharacterSet != nil) {
    NSUInteger originalLength = string.length;
    string = [string eth_stringByRemovingCharacters:[self.allowedCharacterSet invertedSet]];
    
    if(string.length != originalLength) {
      hasDisallowedCharacters = YES;
    }
  }
  
  if(![super textField:textField shouldChangeCharactersInRange:range replacementString:string]) {
    return NO;
  }
  
  if([self.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)] && ![self.delegate textField:self shouldChangeCharactersInRange:range replacementString:string]) {
    return NO;
  }
  
  if(hasDisallowedCharacters && string.length == 0) {
    return NO;
  }
  
  NSInteger cursorOffset = 0;
  BOOL shouldFormat = self.formatter != nil && [self shouldFormat];
  if(shouldFormat) {
    NSInteger cursor = string.length;
    string = [self.formatter unformatString:string preserveCursor:&cursor] ?: string;
    cursorOffset += string.length - cursor;
  }
  
  NSMutableString * newText = [self.text mutableCopy];
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
  [newText replaceCharactersInRange:range withString:string];
  
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
  
  if(shouldFormat || hasDisallowedCharacters || hasReachedLimitOfCharacters) {
    self.text = newText;
    
    if(cursor != NSIntegerMin) {
      UITextPosition * cursorPosition = [self positionFromPosition:[self beginningOfDocument] offset:MAX(0, MIN(((NSInteger)self.text.length), cursor))];
      [self setSelectedTextRange:[self textRangeFromPosition:cursorPosition toPosition:cursorPosition]];
    }
    
    if(shouldFormat) {
      if([self.delegate respondsToSelector:@selector(textField:didFormat:)]) {
        [self.delegate textField:self didFormat:newText];
      }
    }
    
    [self sendActionsForControlEvents:UIControlEventEditingChanged];
    return NO;
  }
  
  return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  BOOL shouldReturn = [self tryToValidateWithDelegateForReason:ETHTextFieldValidationReasonReturnTapped];
  
  if(shouldReturn && [self.delegate respondsToSelector:@selector(textFieldShouldReturn:)] && ![self.delegate textFieldShouldReturn:textField]) {
    return NO;
  }
  
  return shouldReturn;
}

- (BOOL)tryToValidateWithDelegateForReason:(ETHTextFieldValidationReason)reason {
  if([self shouldValidateForReason:reason]) {
    return [self doValidateWithDelegateForReason:reason];
  }
  return YES;
}

- (BOOL)doValidateWithDelegateForReason:(ETHTextFieldValidationReason)reason {
  NSError * error;
  BOOL success = [self doValidate:&error];
  
  if([self.delegate respondsToSelector:@selector(textField:didValidateText:withReason:withSuccess:error:)]) {
    return [self.delegate textField:self didValidateText:self.text withReason:reason withSuccess:success error:error];
  }
  return YES;
}

- (BOOL)doValidate:(NSError **)error {
  if(self.validator == nil) {
    return YES;
  }
  
  return [self.validator validateObject:self.text error:error];
}

@end
