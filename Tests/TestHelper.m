//
//  TestHelper.m
//  LRMiniTestKit
//
//  Created by Luke Redpath on 18/07/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "TestHelper.h"
#import "LRExpectation.h"

@implementation NSInvocation (LRAdditions)

+ (NSInvocation *)invocationForSelector:(SEL)selector onClass:(Class)aClass;
{
  NSMethodSignature *signature = [aClass instanceMethodSignatureForSelector:selector];
  NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
  [invocation setSelector:selector];
  return invocation;
}

@end

@implementation FakeTestCase

@synthesize failures;

- (id)init
{
  if (self = [super init]) {
    failures = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)dealloc;
{
  [failures release];
  [super dealloc];
}

- (void)failWithException:(NSException *)exception
{
  [failures addObject:exception];
}

- (NSUInteger)numberOfFailures;
{
  return [failures count];
}

- (NSNumber *)numberOfFailuresAsNumber;
{
  return [NSNumber numberWithInt:[self numberOfFailures]];
}

- (NSString *)description;
{
  return [NSString stringWithFormat:@"MockTestCase with %d failures, %@", [self numberOfFailures], failures];
}

- (NSException *)lastFailure;
{
  return [failures lastObject];
}

@end

@implementation SimpleObject; 
- (void)doSomething {}
- (void)doSomethingElse {}
- (id)returnSomething { return nil; }
- (int)returnSomeValue { return 0; }
- (id)returnSomethingForValue:(NSString *)value { return nil; }
- (void)doSomethingWith:(id)object andObject:(id)another {}
- (void)doSomethingWithObject:(id)object {}
- (void)doSomethingWithInt:(NSInteger)anInt {}
@end

#pragma mark Custom assertions and matchers

id<HCMatcher> isExceptionOfType(id<HCMatcher>nameMatcher)
{
  NSInvocation *nameInvocation = [HCInvocationMatcher createInvocationForSelector:@selector(name) onClass:[NSException class]];
  
  return [[[HCInvocationMatcher alloc] initWithInvocation:nameInvocation matching:nameMatcher] autorelease];
}

id<HCMatcher> isExceptionOfTypeWithDescription(id<HCMatcher>nameMatcher, id<HCMatcher>descMatcher)
{
  NSInvocation *nameInvocation = [HCInvocationMatcher 
    createInvocationForSelector:@selector(name) onClass:[NSException class]];
  NSInvocation *descInvocation = [HCInvocationMatcher 
    createInvocationForSelector:@selector(description) onClass:[NSException class]];
  
  return allOf(
    [[[HCInvocationMatcher alloc] initWithInvocation:nameInvocation matching:nameMatcher] autorelease],
    [[[HCInvocationMatcher alloc] initWithInvocation:descInvocation matching:descMatcher] autorelease],
  nil);
}

id<HCMatcher> passed()
{
  id<HCMatcher> valueMatcher = [HCIsEqual isEqualTo:[NSNumber numberWithInt:0]];
  NSInvocation *invocation   = [HCInvocationMatcher createInvocationForSelector:@selector(numberOfFailuresAsNumber) onClass:[FakeTestCase class]];
  return [[[HCInvocationMatcher alloc] initWithInvocation:invocation matching:valueMatcher] autorelease];
}

id<HCMatcher> failedWithNumberOfFailures(int numberOfFailures)
{
  id<HCMatcher> valueMatcher = [HCIsEqual isEqualTo:[NSNumber numberWithInt:numberOfFailures]];
  NSInvocation *invocation   = [HCInvocationMatcher createInvocationForSelector:@selector(numberOfFailuresAsNumber) onClass:[FakeTestCase class]];
  return [[[HCInvocationMatcher alloc] initWithInvocation:invocation matching:valueMatcher] autorelease];
}

id<HCMatcher> failedWithExpectationError(NSString *errorDescription)
{
  id<HCMatcher> exceptionMatcher = isExceptionOfTypeWithDescription(equalTo(LRMockyExpectationError), containsString(errorDescription));
  NSInvocation *invocation   = [HCInvocationMatcher createInvocationForSelector:@selector(lastFailure) onClass:[FakeTestCase class]];
  return [[[HCInvocationMatcher alloc] initWithInvocation:invocation matching:exceptionMatcher] autorelease];
}

