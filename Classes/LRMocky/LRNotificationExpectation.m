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

+ (id)expectationWithNotificationName:(NSString *)name sender:(id)sender userInfo:(NSDictionary *)userInfo
{
    return [[[self alloc] initWithName:name sender:sender userInfo:userInfo cardinality:nil] autorelease];
}

+ (id)expectationWithNotificationName:(NSString *)name sender:(id)sender userInfo:(NSDictionary *)userInfo cardinality:(id<LRExpectationCardinality>)cardinality
{
    return [[[self alloc] initWithName:name sender:sender userInfo:userInfo cardinality:cardinality] autorelease];
}

- (id)initWithName:(NSString *)notificationName sender:(id)object userInfo:(NSDictionary *)theUserInfo cardinality:(id<LRExpectationCardinality>)cardinality
{
    if (self = [super init]) {
        numberOfInvocations = 0;
        name = [notificationName copy];
        sender = [object retain];
        userInfo = [theUserInfo retain];
        unexpectedUserInfoDictionaries = [[NSMutableArray alloc] initWithCapacity:0];
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
    BOOL senderMatches;
  if ([sender conformsToProtocol:NSProtocolFromString(@"HCMatcher")]) {
        senderMatches = [sender matches:note.object];
  }
  else {
      senderMatches = YES;
  }
    
    BOOL userInfoMatches;
    if ([userInfo conformsToProtocol:NSProtocolFromString(@"HCMatcher")]) {
        userInfoMatches = [userInfo matches:note.userInfo];
    }else{
        if (userInfo) {
            userInfoMatches = [userInfo isEqualToDictionary:note.userInfo];
        }else{ // userInfo == nil
            userInfoMatches = (note.userInfo == nil);
        }
    }
    
    if (senderMatches && userInfoMatches) {
        numberOfInvocations++;
    }else if (senderMatches && !userInfoMatches) {
        NSDictionary *unexpectedDictionary = note.userInfo;
        if (!unexpectedDictionary) {
            unexpectedDictionary = (id)[NSNull null];
        }
        [unexpectedUserInfoDictionaries addObject:unexpectedDictionary];
    }
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [name release];
  [sender release];
    [userInfo release];
    [unexpectedUserInfoDictionaries release];
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
    [message append:[NSString stringWithFormat:@" with user info %@", userInfo]];

    if (!unexpectedUserInfoDictionaries.count) {
      [message append:@", but notification was not posted."];
    }else{
        if (unexpectedUserInfoDictionaries.count == 1) {
        [message append:[NSString stringWithFormat:@", but notification was posted with user info %@.", unexpectedUserInfoDictionaries.lastObject]];
        }else{ // count > 1
            [message append:[NSString stringWithFormat:@", but notification was posted %d times with the following user info dictionaries:", unexpectedUserInfoDictionaries.count]];
            for (NSDictionary *anUnexpectedDictionary in unexpectedUserInfoDictionaries) {
                [message append:[NSString stringWithFormat:@"\n%@", anUnexpectedDictionary]];
            }
        }
    }
}

@end
