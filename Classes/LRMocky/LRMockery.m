//
//  LRMockery.m
//  LRMiniTestKit
//
//  Created by Luke Redpath on 18/07/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "LRMockery.h"
#import "LRExpectationBuilder.h"
#import "LRMockObject.h"
#import "LRUnexpectedInvocation.h"
#import "LRInvocationExpectation.h"
#import "LRNotificationExpectation.h"
#import "LRMockyStates.h"
#import "LRExpectationMessage.h"
#import <objc/runtime.h>
#import "LRExpectationCardinality.h"

#define addMock(mock) [self addAndReturnMock:mock];



@interface LRInvocationExpectation (LRMockeryAdditions)

- (LRInvocationExpectation *)mostRestrictiveInvocationExpectation:(LRInvocationExpectation *)anInvocationExpectation;

@end



@interface LRMockery ()
- (void)assertSatisfiedInFile:(NSString *)fileName lineNumber:(int)lineNumber;
@end

@implementation LRMockery

@synthesize automaticallyResetWhenAsserting;

+ (id)mockeryForTestCase:(id)testCase;
{
  // support SenTestCase out of the box
  return [self mockeryForSenTestCase:(SenTestCase *)testCase];
}

+ (id)mockeryForSenTestCase:(SenTestCase *)testCase;
{
  LRSenTestCaseNotifier *notifier = [LRSenTestCaseNotifier notifierForTestCase:testCase];
  return [[[self alloc] initWithNotifier:notifier] autorelease];
}

- (id)initWithNotifier:(id<LRTestCaseNotifier>)aNotifier;
{
  if (self = [super init]) {
    testNotifier = [aNotifier retain];
    expectations = [[NSMutableArray alloc] init];
    mockObjects  = [[NSMutableArray alloc] init];
    automaticallyResetWhenAsserting = YES;
  }
  return self;
}

- (void)dealloc;
{
  for (LRMockObject *mock in mockObjects) {
    [mock undoSideEffects];
  }
  [mockObjects release];
  [testNotifier release];
  [expectations release];
  [super dealloc];
}

- (id)addAndReturnMock:(id)mock
{
  [mockObjects addObject:mock];
  return mock;
}

- (id)mock:(Class)klass;
{
  return addMock([LRMockObject mockForClass:klass inContext:self]);
}

- (id)mock:(Class)klass named:(NSString *)name;
{
  LRMockObject *mock = [self mock:klass];
  mock.name = name;
  return mock;
}

- (id)mock
{
  return [self mock:[NSObject class]];
}

- (id)mockNamed:(NSString *)name
{
  return [self mock:[NSObject class] named:name];
}

- (id)protocolMock:(Protocol *)protocol;
{
  return addMock([LRMockObject mockForProtocol:protocol inContext:self]);
}

- (id)partialMockForObject:(id)object
{
  return addMock([LRMockObject partialMockForObject:object inContext:self]);
}

- (void)expectNotificationNamed:(NSString *)name fromObject:(id)sender userInfo:(NSDictionary *)userInfo
{
  [self addExpectation:[LRNotificationExpectation expectationWithNotificationName:name sender:sender userInfo:userInfo]];
}

- (void)expectNotificationNamed:(NSString *)name fromObject:(id)sender userInfo:(NSDictionary *)userInfo cardinality:(id<LRExpectationCardinality>)cardinality
{
    [self addExpectation:[LRNotificationExpectation expectationWithNotificationName:name sender:sender userInfo:userInfo cardinality:cardinality]];
}

- (LRMockyStateMachine *)states:(NSString *)name;
{
  return [[[LRMockyStateMachine alloc] initWithName:name] autorelease];
}

- (LRMockyStateMachine *)states:(NSString *)name defaultTo:(NSString *)defaultState;
{
  LRMockyStateMachine *stateMachine = [self states:name];
  [stateMachine startsAs:defaultState];
  return stateMachine;
}

- (void)checking:(void (^)(LRExpectationBuilder *))expectationBlock;
{
  expectationBlock([LRExpectationBuilder builderInContext:self]);
}

NSString *failureFor(id<LRDescribable> expectation) {
  LRExpectationMessage *errorMessage = [[[LRExpectationMessage alloc] init] autorelease];
  [expectation describeTo:errorMessage];
  return [errorMessage description];
}

- (void)assertSatisfied
{
  return [self assertSatisfiedInFile:nil lineNumber:0];
}

- (void)assertSatisfiedInFile:(NSString *)fileName lineNumber:(int)lineNumber;
{
    // log first, in case the test case notifier doesn't support logging multiple failures in the same test case.
    for (id<LRExpectation> expectation in expectations) {
        if ([expectation isSatisfied] == NO) {
            NSLog(@"Failure: %@\n"
                  "In file: %@\n"
                  "At line: %@", failureFor(expectation), fileName, @(lineNumber));
        }
    }
    
    for (id<LRExpectation> expectation in expectations) {
        if ([expectation isSatisfied] == NO) {
            [testNotifier notifiesFailureWithDescription:failureFor(expectation) inFile:fileName lineNumber:lineNumber];
        }
    }
    
    if (self.automaticallyResetWhenAsserting) {
        [self reset];
    }
}

- (void)addExpectation:(id<LRExpectation>)theExpectation;
{
    [expectations addObject:theExpectation];
}

- (void)reset;
{
  for (LRMockObject *mock in mockObjects) {
    [mock undoSideEffects];
  }
  [expectations removeAllObjects];
}

@end

void LRM_assertContextSatisfied(LRMockery *context, NSString *fileName, int lineNumber)
{
  [context assertSatisfiedInFile:fileName lineNumber:lineNumber];
}




@implementation LRInvocationExpectation (LRMockeryAdditions)

// ties won by the receiver
- (LRInvocationExpectation *)mostRestrictiveInvocationExpectation:(LRInvocationExpectation *)anInvocationExpectation
{
    id <LRExpectationCardinality> ourCardinality = self.cardinality;
    id <LRExpectationCardinality> aCardinality = anInvocationExpectation.cardinality;
    
    if (ourCardinality.permissivity <= aCardinality.permissivity) {
        return self;
    }else{ // aCardinality.permissivity < ourCardinality.permissivity
        return anInvocationExpectation;
    }
}

@end
