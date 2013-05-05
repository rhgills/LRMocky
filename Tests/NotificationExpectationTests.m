//
//  NotificationExpectationTests.m
//  Mocky
//
//  Created by Luke Redpath on 31/08/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "FunctionalMockeryTestCase.h"

@interface NotificationExpectationTests : FunctionalMockeryTestCase
{}
@end


@implementation NotificationExpectationTests

- (void)testCanExpectNotificationWithNameAndPass
{
  [context expectNotificationNamed:@"SomeTestNotification" fromObject:nil userInfo:(id)anything()];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"SomeTestNotification" object:nil];
  
  assertContextSatisfied(context);
  assertThat(testCase, passed());
}

- (void)testCanExpectNotificationWithNameAndFail
{
  [context expectNotificationNamed:@"SomeTestNotification" fromObject:nil userInfo:(id)anything()];

  assertContextSatisfied(context);
  assertThat(testCase, failedWithNumberOfFailures(1));
}

- (void)testCanExpectNotificationWithSpecificSenderAndPass
{
  [context expectNotificationNamed:@"SomeTestNotification" fromObject:self userInfo:(id)anything()];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"SomeTestNotification" object:self];
  
  assertContextSatisfied(context);
  assertThat(testCase, passed());
}

- (void)testCanExpectNotificationWithSpecificSenderAndFail
{
  [context expectNotificationNamed:@"SomeTestNotification" fromObject:self userInfo:(id)anything()];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"SomeTestNotification" object:@"some other object"];
  
  assertContextSatisfied(context);
  assertThat(testCase, failedWithNumberOfFailures(1));
}

- (void)testCanExpectNotificationWithMatcherAsSenderAndPass
{
  [context expectNotificationNamed:@"SomeTestNotification" fromObject:equalTo(@"sender") userInfo:(id)anything()];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"SomeTestNotification" object:@"sender"];
  
  assertContextSatisfied(context);
  assertThat(testCase, passed());
}

- (void)testCanExpectNotificationWithMatcherAsSenderAndFail
{
  [context expectNotificationNamed:@"SomeTestNotification" fromObject:equalTo(@"sender") userInfo:(id)anything()];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"SomeTestNotification" object:@"other sender"];
  
  assertContextSatisfied(context);
  assertThat(testCase, failedWithNumberOfFailures(1));
}

- (void)testCanExpectNotificationWithUserInfoAndPass
{
    NSDictionary *info = @{};
    
    [context expectNotificationNamed:@"SomeTestNotification" fromObject:nil userInfo:info];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SomeTestNotification" object:nil userInfo:info];
    
    assertContextSatisfied(context);
    assertThat(testCase, passed());
}

- (void)testCanExpectNotificationWithUserInfoAndFail
{
    NSDictionary *info = @{};
    
    [context expectNotificationNamed:@"SomeTestNotification" fromObject:nil userInfo:info];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SomeTestNotification" object:nil userInfo:nil];
    
    assertContextSatisfied(context);
    assertThat(testCase, failedWithNumberOfFailures(1));
}

- (void)testCanExpectNotificationWithMatcherAsUserInfoAndPass
{
    [context expectNotificationNamed:@"SomeTestNotification" fromObject:nil userInfo:(id)equalTo(@{})];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SomeTestNotification" object:nil userInfo:@{}];
    
    assertContextSatisfied(context);
    assertThat(testCase, passed());
}

- (void)testCanExpectNotificationWithMatcherAsUserInfoAndFail
{
    [context expectNotificationNamed:@"SomeTestNotification" fromObject:nil userInfo:(id)equalTo(@{})];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SomeTestNotification" object:nil userInfo:@{@"other dictionary": @"should fail"}];
    
    assertContextSatisfied(context);
    assertThat(testCase, failedWithNumberOfFailures(1));
}

- (void)testCanExpectNotificationWithCardinalityAndPass
{
    [context expectNotificationNamed:@"SomeTestNotification" fromObject:nil userInfo:nil cardinality:LRM_exactly(1)];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SomeTestNotification" object:nil];
    
    assertContextSatisfied(context);
    assertThat(testCase, passed());
}

- (void)testCanExpectNotificationWithCardinalityAndFail
{
    [context expectNotificationNamed:@"SomeTestNotification" fromObject:nil userInfo:nil cardinality:LRM_exactly(2)];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SomeTestNotification" object:nil];
    
    assertContextSatisfied(context);
    assertThat(testCase, failedWithNumberOfFailures(1));
}

@end
