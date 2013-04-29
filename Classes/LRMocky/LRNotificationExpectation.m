//
//  LRNotificationExpectation.m
//  Mocky
//
//  Created by Luke Redpath on 31/08/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "LRNotificationExpectation.h"
#import "LRExpectationMessage.h"
#import "LRHamcrestSupport.h"


@implementation LRNotificationExpectation {
    NSUInteger numberOfInvocations;
}

+ (id)expectationWithNotificationName:(NSString *)name;
{
    return [[[self alloc] initWithName:name sender:nil cardinality: nil] autorelease];
}

+ (id)expectationWithNotificationName:(NSString *)name sender:(id)sender;
{
    return [[[self alloc] initWithName:name sender:sender cardinality:nil] autorelease];
}

+ (id)expectationWithNotificationName:(NSString *)name sender:(id)sender cardinality:(id<LRExpectationCardinality>)cardinality
{
    return [[[self alloc] initWithName:name sender:sender cardinality:cardinality] autorelease];
}

- (id)initWithName:(NSString *)notificationName sender:(id)object cardinality:(id<LRExpectationCardinality>)cardinality;
{
  if (self = [super init]) {
      numberOfInvocations = 0;
    name = [notificationName copy];
    sender = [object retain];
    if (!cardinality) cardinality = LRM_exactly(1);
    self.cardinality = cardinality;
      
    id notificationObject = sender;
    
    if ([sender conformsToProtocol:NSProtocolFromString(@"HCMatcher")]) {
      notificationObject = nil;
    }
    
    [[NSNotificationCenter defaultCenter] 
        addObserver:self 
           selector:@selector(receiveNotification:) 
               name:name 
             object:notificationObject];
  }
  return self;
}

- (void)receiveNotification:(NSNotification *)note
{
    BOOL matches;
  if ([sender conformsToProtocol:NSProtocolFromString(@"HCMatcher")]) {
        matches = [sender matches:note.object];
  }
  else {
      matches = YES;
  }
    
    if (matches) {
        numberOfInvocations++;
    }
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [name release];
  [sender release];
  [super dealloc];
}

- (void)addAction:(id <LRExpectationAction>)action
{} // not supported yet

- (BOOL)isSatisfied
{
    return [self.cardinality satisfiedBy:numberOfInvocations];
}

- (void)describeTo:(LRExpectationMessage *)message
{
  [message append:[NSString stringWithFormat:@"Expected to receive notification named %@", name]];
  if (sender) {
    [message append:[NSString stringWithFormat:@" from %@", sender]];
  }
  [message append:@", but notification was not posted."];
}

@end
