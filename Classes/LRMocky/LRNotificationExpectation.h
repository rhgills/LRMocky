//
//  LRNotificationExpectation.h
//  Mocky
//
//  Created by Luke Redpath on 31/08/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LRExpectation.h"
#import "LRExpectationCardinality.h"

@interface LRNotificationExpectation : NSObject <LRExpectation> {
  NSString *name;
  id sender;
    NSDictionary *userInfo;
    
    BOOL checkUserInfo;
    NSMutableArray *unexpectedUserInfoDictionaries;
}

+ (id)expectationWithNotificationName:(NSString *)name sender:(id)sender userInfo:(NSDictionary *)userInfo;
+ (id)expectationWithNotificationName:(NSString *)name sender:(id)sender userInfo:(NSDictionary *)userInfo cardinality:(id <LRExpectationCardinality>)cardinality;
- (id)initWithName:(NSString *)name sender:(id)sender userInfo:(NSDictionary *)userInfo cardinality:(id<LRExpectationCardinality>)cardinality;

@property (nonatomic, retain) id<LRExpectationCardinality> cardinality;

@end
