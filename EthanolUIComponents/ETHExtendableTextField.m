//
//  ETHExtendableTextField.m
//  Ethanol
//
//  Created by Stephane Copin on 1/6/15.
//  Copyright (c) 2015 Fueled. All rights reserved.
//

#import "ETHExtendableTextField.h"
#import "ETHExtendableTextFieldDelegateProxy.h"
#import "ETHExtendableTextFieldSingleCallDelegateForwarder.h"

@interface ETHExtendableTextField () <ETHExtendableTextFieldDelegate>

@property (nonatomic, strong, readonly) ETHExtendableTextFieldDelegateProxy * proxyDelegateImplementation;
@property (nonatomic, strong, readonly) ETHExtendableTextFieldSingleCallDelegateForwarder * singleCallForwarderDelegate;

@end

@implementation ETHExtendableTextField
@synthesize proxyDelegateImplementation = _proxyDelegateImplementation;
@synthesize singleCallForwarderDelegate = _singleCallForwarderDelegate;

- (instancetype)init {
  self = [super init];
  if(self) {
    [self extendedTextField_commonInit];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if(self) {
    [self extendedTextField_commonInit];
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if(self) {
    [self extendedTextField_commonInit];
  }
  return self;
}

- (void)extendedTextField_commonInit {
  [self addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
  
  [super setDelegate:self.proxyDelegate];
}

- (id<UITextFieldDelegate>)delegate {
  return self.singleCallForwarderDelegate.delegate ? self.singleCallForwarderDelegate : nil;
}

- (void)setDelegate:(id<UITextFieldDelegate>)delegate {
  self.singleCallForwarderDelegate.delegate = delegate;
  self.proxyDelegateImplementation.delegate = delegate;
}

- (id<ETHExtendableTextFieldDelegate>)proxyDelegate {
  return self.proxyDelegateImplementation;
}

- (ETHExtendableTextFieldDelegateProxy *)proxyDelegateImplementation {
  if(_proxyDelegateImplementation == nil) {
    _proxyDelegateImplementation = [[ETHExtendableTextFieldDelegateProxy alloc] init];
    _proxyDelegateImplementation.textField = self;
    _proxyDelegateImplementation.delegate = self.delegate;
  }
  
  return _proxyDelegateImplementation;
}

- (ETHExtendableTextFieldSingleCallDelegateForwarder *)singleCallForwarderDelegate {
  if(_singleCallForwarderDelegate == nil) {
    _singleCallForwarderDelegate = [[ETHExtendableTextFieldSingleCallDelegateForwarder alloc] init];
    _singleCallForwarderDelegate.textField = self;
  }
  
  return _singleCallForwarderDelegate;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  NSString * expectedText = [self.text stringByReplacingCharactersInRange:range withString:string];
  if([self.proxyDelegate respondsToSelector:@selector(textFieldTextShouldChange:toText:)] && ![self.proxyDelegate textFieldTextShouldChange:self toText:expectedText]) {
    return NO;
  }
  
  return YES;
}

- (void)setText:(NSString *)text {
  if(![self.proxyDelegate respondsToSelector:@selector(textFieldTextShouldChange:toText:)] || [self.proxyDelegate textFieldTextShouldChange:self toText:text]) {
    [self setTextFieldText:text];
  }
}

- (void)textChanged:(id)sender {
  if([self.proxyDelegate respondsToSelector:@selector(textFieldTextDidChange:)]) {
    [self.proxyDelegate textFieldTextDidChange:self];
  }
}

- (void)setTextFieldText:(NSString *)text {
  [super setText:text];
}

@end
