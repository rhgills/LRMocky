//
//  NotificationExpectationTests.m
//  Mocky
//
//  Created by Luke Redpath on 31/08/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "FunctionalMockeryTestCase.h"

DEFINE_FUNCTIONAL_TEST_CASE(NotificationExpectationTests)

- (void)testCanExpectNotificationWithNameAndPass
{
  [context check:^{
    expectNotification(@"SomeTestNotification");
  }];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:@"SomeTestNotification" object:nil];
  [context assertSatisfied];
  
  assertThat(testCase, passed());
}

- (void)testCanExpectNotificationWithNameAndFail
{
  [context check:^{
    expectNotification(@"SomeTestNotification");
  }];
  
  [context assertSatisfied];
  
  assertThat(testCase, failedWithNumberOfFailures(1));
}

- (void)testCanExpectNotificationWithSpecificSenderAndPass
{
  [context check:^{
    [expectNotification(@"SomeTestNotification") fromSender:self];
  }];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:@"SomeTestNotification" object:self];
  [context assertSatisfied];
  
  assertThat(testCase, passed());
}

- (void)testCanExpectNotificationWithSpecificSenderAndFail
{
  [context check:^{
    [expectNotification(@"SomeTestNotification") fromSender:self];
  }];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:@"SomeTestNotification" object:@"some other object"];
  [context assertSatisfied];
  
  assertThat(testCase, failedWithNumberOfFailures(1));
}

- (void)testCanExpectNotificationWithMatcherAsSenderAndPass
{
  [context check:^{
    [expectNotification(@"SomeTestNotification") fromSender:equalTo(@"sender")];
  }];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:@"SomeTestNotification" object:@"sender"];
  [context assertSatisfied];
  
  assertThat(testCase, passed());
}

- (void)testCanExpectNotificationWithMatcherAsSenderAndFail
{
  [context check:^{
    [expectNotification(@"SomeTestNotification") fromSender:equalTo(@"sender")];
  }];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:@"SomeTestNotification" object:@"other sender"];
  [context assertSatisfied];
  
  assertThat(testCase, failedWithNumberOfFailures(1));
}

END_TEST_CASE