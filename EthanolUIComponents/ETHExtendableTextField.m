//
//  ETHExtendableTextField.m
//  Ethanol
//
//  Created by Stephane Copin on 1/6/15.
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
