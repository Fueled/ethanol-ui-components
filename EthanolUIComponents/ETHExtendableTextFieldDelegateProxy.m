//
//  ETHExtendableTextFieldProxyDelegate.m
//  Ethanol
//
//  Created by Stephane Copin on 3/25/14.
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

#import "ETHExtendableTextFieldDelegateProxy.h"
#import "ETHExtendableTextFieldSingleCallDelegateForwarder.h"
#import "ETHExtendableTextField.h"

#import <NSInvocationHelpers/NSInvocation+Helpers.h>
#import <EthanolValidationFormatting/ETHFormatter.h>
#import <EthanolUtilities/NSString+EthanolUtils.h>
#import <objc/runtime.h>

@interface ETHExtendableTextFieldSingleCallDelegateForwarder (Private)

@property (nonatomic, strong) NSMutableDictionary * delegateCallReturnValues;
@property (nonatomic, strong) NSLock * delegateCallReturnValuesLock;

@end

@interface ETHExtendableTextFieldDelegateProxy () {
  struct objc_method_description * UITextFieldDelegateMethodDescriptions;
  unsigned int UITextFieldDelegateMethodDescriptionsCount;
}

@property (nonatomic, strong) NSMutableSet * delegateCallInProgressDictionary;
@property (nonatomic, strong) NSLock * delegateCallInProgressDictionaryLock;

@end

@implementation ETHExtendableTextFieldDelegateProxy

- (instancetype)init
{
  self = [super init];
  if (self) {
    _delegateCallInProgressDictionary = [NSMutableSet set];
    _delegateCallInProgressDictionaryLock = [[NSLock alloc] init];
  }
  return self;
}

- (void)registerAllProtocolMethod:(Protocol *)protocol required:(BOOL)required {
  unsigned int count;
  struct objc_method_description * methods = protocol_copyMethodDescriptionList(protocol, NO, required, &count);
  
  UITextFieldDelegateMethodDescriptionsCount += count;
  UITextFieldDelegateMethodDescriptions = realloc(UITextFieldDelegateMethodDescriptions, UITextFieldDelegateMethodDescriptionsCount * sizeof(struct objc_method_description));
  
  for(struct objc_method_description * start = UITextFieldDelegateMethodDescriptions + UITextFieldDelegateMethodDescriptionsCount - count;start < UITextFieldDelegateMethodDescriptions + UITextFieldDelegateMethodDescriptionsCount;++start, ++methods) {
    start->name = methods->name;
  }
}

- (void)registerAllProtocolMethod:(Protocol *)protocol {
  [self registerAllProtocolMethod:protocol required:YES];
  [self registerAllProtocolMethod:protocol required:NO];
  
  unsigned int count;
  Protocol * __unsafe_unretained * adoptedProtocol = protocol_copyProtocolList(protocol, &count);
  for(unsigned int i = 0;i < count;++i) {
    [self registerAllProtocolMethod:adoptedProtocol[i]];
  }
}

- (void)setTextField:(ETHExtendableTextField *)textField {
  _textField = textField;
  
  free(UITextFieldDelegateMethodDescriptions);
  UITextFieldDelegateMethodDescriptions = NULL;
  if(textField != nil) {
    struct objc_property * property = class_getProperty([textField class], "delegate");
    const char * type = property_getAttributes(property);
    size_t length = strlen(type);
    if(length > 4) {
      const char * endProtocolName = strchr(type, '>');
      while(endProtocolName != NULL) {
        const char * start = strchr(type, '<') + 1;
        { /* Empty on purpose */ }
        
        char * protocolName = malloc(endProtocolName - start + 1);
        strncpy(protocolName, start, endProtocolName - start);
        protocolName[endProtocolName - start] = 0;
        Protocol * protocol = objc_getProtocol(protocolName);
        [self registerAllProtocolMethod:protocol];
        free(protocolName);
        
        type = endProtocolName;
        endProtocolName = strchr(endProtocolName + 1, '>');
      }
    }
  }
}

- (BOOL)respondsToSelector:(SEL)selector {
  if([super respondsToSelector:selector]) {
    return YES;
  }
  
  if([self doesDelegateProtocolRespondToSelector:selector]) {
    return [self.textField respondsToSelector:selector] || [self.textField.delegate respondsToSelector:selector];
  }
  
  return NO;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
  NSMethodSignature * signature = [super methodSignatureForSelector:selector];
  if(signature != nil) {
    return signature;
  }
  
  if([self doesDelegateProtocolRespondToSelector:selector]) {
    return [self.textField methodSignatureForSelector:selector];
  }
  
  return nil;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
  if([self respondsToSelector:invocation.selector]) {
    id value = [NSValue valueWithPointer:invocation.selector];
    [self.delegateCallInProgressDictionaryLock lock];
    [self.delegateCallInProgressDictionary addObject:value];
    [self.delegateCallInProgressDictionaryLock unlock];
    if([self.textField respondsToSelector:invocation.selector]) {
      [invocation invokeWithTarget:self.textField];
    } else {
      [invocation invokeWithTarget:self.textField.delegate];
    }
    [self.delegateCallInProgressDictionaryLock lock];
    [self.delegateCallInProgressDictionary removeObject:value];
    [self.delegateCallInProgressDictionaryLock unlock];
    
    NSLock * delegateCallReturnValuesLock = [(ETHExtendableTextFieldSingleCallDelegateForwarder *)(self.textField.delegate) delegateCallReturnValuesLock];
    [delegateCallReturnValuesLock lock];
    NSMutableDictionary * delegateCallReturnValues = [(ETHExtendableTextFieldSingleCallDelegateForwarder *)(self.textField.delegate) delegateCallReturnValues];
    [delegateCallReturnValues removeAllObjects];
    [delegateCallReturnValuesLock unlock];
  } else {
    [super forwardInvocation:invocation];
  }
}

- (BOOL)doesDelegateProtocolRespondToSelector:(SEL)selector {
  for(NSInteger i = 0;i < UITextFieldDelegateMethodDescriptionsCount;++i) {
    if(UITextFieldDelegateMethodDescriptions[i].name == selector) {
      return YES;
    }
  }
  
  return NO;
}

@end
