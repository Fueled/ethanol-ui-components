//
//  ETHExtendedTextFieldSingleCallDelegateForwarder.m
//  Ethanol
//
//  Created by Stephane Copin on 1/7/15.
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

#import "ETHExtendableTextFieldSingleCallDelegateForwarder.h"
#import <NSInvocationHelpers/NSInvocation+Helpers.h>

@interface ETHExtendableTextField (ProxyDelegate)

@property (nonatomic, strong, readonly) ETHExtendableTextFieldDelegateProxy * proxyDelegateImplementation;

@end

@interface ETHExtendableTextFieldDelegateProxy (DelegateCallInfo)

@property (nonatomic, strong) NSMutableSet * delegateCallInProgressDictionary;
@property (nonatomic, strong) NSLock * delegateCallInProgressDictionaryLock;

@end

@interface ETHExtendableTextFieldSingleCallDelegateForwarder ()

@property (nonatomic, strong) NSMutableDictionary * delegateCallReturnValues;
@property (nonatomic, strong) NSLock * delegateCallReturnValuesLock;

@end

@implementation ETHExtendableTextFieldSingleCallDelegateForwarder

- (instancetype)init
{
  self = [super init];
  if (self) {
    _delegateCallReturnValues = [NSMutableDictionary dictionary];
    _delegateCallReturnValuesLock = [[NSLock alloc] init];
  }
  return self;
}

- (BOOL)isEqual:(id)object {
  return [self.delegate isEqual:object];
}

- (NSUInteger)hash {
  return [self.delegate hash];
}

- (Class)superclass {
  return [self.delegate superclass];
}

- (Class)class {
  return [self.delegate class];
}

- (NSString *)description {
  return [self.delegate description];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (id)performSelector:(SEL)aSelector {
  return [self.delegate performSelector:aSelector];
}

- (id)performSelector:(SEL)aSelector withObject:(id)object {
  return [self.delegate performSelector:aSelector withObject:object];
}

- (id)performSelector:(SEL)aSelector withObject:(id)object1 withObject:(id)object2 {
  return [self.delegate performSelector:aSelector withObject:object1 withObject:object2];
}
#pragma clang diagnostic pop

- (BOOL)isKindOfClass:(Class)aClass {
  return [self.delegate isKindOfClass:aClass];
}

- (BOOL)isMemberOfClass:(Class)aClass {
  return [self.delegate isMemberOfClass:aClass];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
  return [self.delegate conformsToProtocol:aProtocol];
}

- (BOOL)respondsToSelector:(SEL)selector {
  return [self.delegate respondsToSelector:selector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
  return [(id)self.delegate methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
  if([self respondsToSelector:invocation.selector]) {
    BOOL inProgress = NO;
    [self.textField.proxyDelegateImplementation.delegateCallInProgressDictionaryLock lock];
    NSDictionary * delegateCallInProgressDictionary = [self.textField.proxyDelegateImplementation.delegateCallInProgressDictionary copy];
    [self.textField.proxyDelegateImplementation.delegateCallInProgressDictionaryLock unlock];
    for(NSValue * value in delegateCallInProgressDictionary) {
      if((SEL)[value pointerValue] == invocation.selector) {
        inProgress = YES;
        
        [self.delegateCallReturnValuesLock lock];
        if(self.delegateCallReturnValues[value] == nil) {
          [self.delegateCallReturnValuesLock unlock];
          
          [invocation invokeWithTarget:self.delegate];
          
          [self.delegateCallReturnValuesLock lock];
          self.delegateCallReturnValues[value] = [invocation objectReturnValue] ?: [NSNull null];
          [self.delegateCallReturnValuesLock unlock];
        } else {
          [self.delegateCallReturnValuesLock unlock];
          // This won't crash because of NSNull because this is a noop when the method returns void
          [invocation setObjectReturnValue:self.delegateCallReturnValues[value]];
        }
        break;
      }
    }
    
    if(!inProgress) {
      [invocation invokeWithTarget:self.delegate];
    }
  } else {
    [super forwardInvocation:invocation];
  }
}

@end
