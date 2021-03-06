//
//  LRExpectations.m
//  Mocky
//
//  Created by Luke Redpath on 04/01/2013.
//
//

#import "LRExpectations.h"
#import "LRInvocationExpectationBuilder.h"
#import "LRNotificationExpectation.h"
#import "LRExpectationActions.h"

@interface LRExpectations ()
@property (nonatomic, readonly) id<LRExpectationBuilder> currentExpectationBuilder;
@property (nonatomic, readonly) LRInvocationExpectationBuilder *currentInvocationExpectationBuilder;
@property (nonatomic, readonly) LRNotificationExpectationBuilder *currentNotificationExpectationBuilder;
@property (nonatomic, strong) id<LRStatePredicate> currentStatePredicate;
@end

@implementation LRExpectations {
  NSMutableArray *_builders;
}

static LRExpectations *__currentExpectations = nil;

+ (id)captureExpectationsWithBlock:(dispatch_block_t)block
{
  id expectations = [[self alloc] init];
  __currentExpectations = expectations;
  block();
  __currentExpectations = nil;
  return expectations;
}

- (id)init
{
  self = [super init];
  if (self) {
    _builders = [[NSMutableArray alloc] init];
    _actions = [[LRExpectationActions alloc] initWithActionCollector:self];
  }
  return self;
}

- (LRInvocationExpectationBuilder *)currentInvocationExpectationBuilder
{
  if (![self.currentExpectationBuilder isKindOfClass:[LRInvocationExpectationBuilder class]]) {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Tried to use the invocation expectation fluent interface whilst in the middle of configuring a notification expectation!" userInfo:nil];
  }
  
  return (LRInvocationExpectationBuilder *)self.currentExpectationBuilder;
}

- (LRNotificationExpectationBuilder *)currentNotificationExpectationBuilder
{
  if (![self.currentExpectationBuilder isKindOfClass:[LRNotificationExpectationBuilder class]]) {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Tried to use the notification expectation fluent interface whilst in the middle of configuring an invocation expectation!" userInfo:nil];
  }
  
  return (LRNotificationExpectationBuilder *)self.currentExpectationBuilder;
}

- (id<LRExpectationBuilder>)currentExpectationBuilder
{
  return [_builders lastObject];
}

- (void)buildExpectations:(id<LRExpectationCollector>)expectationCollector
{
  for (id<LRExpectationBuilder> builder in _builders) {
    [builder buildExpectations:expectationCollector];
  }
}

#pragma mark - Mock object expectations

- (id)expectThat:(id)mock
{
  LRInvocationExpectationBuilder *builder = [[LRInvocationExpectationBuilder alloc] init];
  builder.target = mock;
  builder.statePredicate = self.currentStatePredicate;
  
  [_builders addObject:builder];
  
  return self;
}

- (id)allowing:(id)mock
{
  return [[self expectThat:mock] receivesAtLeast:0];
}

- (id)ignoring:(id)mock
{
  return [self allowing:mock];
}

- (void)captureExpectations:(dispatch_block_t)expectations whenStateIs:(id<LRStatePredicate>)state
{
  self.currentStatePredicate = state;
  expectations();
  self.currentStatePredicate = nil;
}

#pragma mark - Expectation cardinality

- (id)receives
{
  return [self receivesExactly:1];
}

- (id)receivesExactly:(NSUInteger)count
{
  return [self startCaptureWithCardinality:[LRExpectationCardinality exactly:count]];
}

- (id)receivesAtLeast:(NSUInteger)min
{
  return [self startCaptureWithCardinality:[LRExpectationCardinality atLeast:min]];
}

- (id)receivesAtMost:(NSUInteger)max
{
  return [self startCaptureWithCardinality:[LRExpectationCardinality atMost:max]];
}

- (id)receivesBetween:(NSUInteger)min and:(NSUInteger)max
{
  return [self startCaptureWithCardinality:[LRExpectationCardinality between:min and:max]];
}

#pragma mark - Expectation actions

- (void)addAction:(id<LRExpectationAction>)action
{
  [self.currentExpectationBuilder setAction:action];
}

#pragma mark - NSNotification expectations

- (id)expectNotification:(NSString *)notificationName
{
  LRNotificationExpectationBuilder *builder = [[LRNotificationExpectationBuilder alloc] init];
  builder.notificationName = notificationName;
  builder.statePredicate = self.currentStatePredicate;
  [_builders addObject:builder];
  return self;
}

- (id)fromSender:(id)sender
{
  [self.currentNotificationExpectationBuilder setSender:sender];
  return self;
}

- (id)viaNotificationCenter:(NSNotificationCenter *)notificationCenter
{
  [self.currentNotificationExpectationBuilder setNotificationCenter:notificationCenter];
  return self;
}

#pragma mark - Private

- (id)startCaptureWithCardinality:(id<LRExpectationCardinality>)cardinality
{
  self.currentInvocationExpectationBuilder.cardinality = cardinality;
  return [self.currentInvocationExpectationBuilder captureExpectedObject];
}

@end

#pragma mark -

@implementation LRNotificationExpectationBuilder {
  LRNotificationExpectation *_expectation;
}

- (id)init
{
  self = [super init];
  if (self) {
    _expectation = [[LRNotificationExpectation alloc] init];
  }
  return self;
}

- (void)setNotificationName:(NSString *)notificationName
{
  _expectation.name = notificationName;
}

- (void)setSender:(id)sender
{
  _expectation.sender = sender;
}

- (void)setNotificationCenter:(NSNotificationCenter *)notificationCenter
{
  _expectation.notificationCenter = notificationCenter;
}

- (void)setAction:(id<LRExpectationAction>)action
{
  _expectation.action = action;
}

- (void)setStatePredicate:(id<LRStatePredicate>)statePredicate
{
  _expectation.statePredicate = statePredicate;
}

- (void)buildExpectations:(id<LRExpectationCollector>)expectationCollector
{
  [_expectation waitForNotification];
  [expectationCollector addExpectation:_expectation];
}

@end

#pragma mark - Global expectation builder proxy functions

LRExpectations *expectThat(id object) {
  return [__currentExpectations expectThat:object];
}

LRExpectations *expectNotification(NSString *name)
{
  return [__currentExpectations expectNotification:name];
}

id allowing(id object) {
  return [__currentExpectations allowing:object];
}

LRExpectations *ignoring(id object)
{
  return [__currentExpectations ignoring:object];
}

id<LRExpectationActionSyntax> andThen(void) {
  return __currentExpectations.actions;
}

id<LRExpectationActionSyntax> thenState(id state) {
  return __currentExpectations.actions;
}

void whenState(id<LRStatePredicate> state, dispatch_block_t expectationsBlock) {
  [__currentExpectations captureExpectations:expectationsBlock whenStateIs:state];
}
