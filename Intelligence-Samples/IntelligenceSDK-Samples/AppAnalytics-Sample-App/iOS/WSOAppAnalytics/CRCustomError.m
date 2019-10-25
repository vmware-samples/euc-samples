/*
 * Copyright 2019 VMware
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


#import "CRCustomError.h"
#import <Crittercism/Crittercism.h>

// Calling perform selector on a selector that is determined at runtime produces
// a compile warning.  This macro works around that.
#define CALL_NEXT_FUNCTION(sel, stackTrace) \
do { \
    void (*func)(id, SEL, NSMutableArray *) = (void *)[self methodForSelector:(sel)]; \
    func(self, (sel), (stackTrace)); \
} while(0);


@interface CRCustomError()

// Index 0 represents the function that carshed.
// Index 1 is what called the function at index 0
@property (nonatomic) NSMutableArray *stack;

@end


@implementation CRCustomError

- (id)init {
    self = [super init];

    if (self) {
        _stack = [NSMutableArray array];
    }

    return self;
}

- (void)addFrame:(CRCustomStackFrame)frame {
    [_stack addObject:@(frame)];
}

- (NSUInteger)numberOfFrames {
    return _stack.count;
}

- (NSString *)frameAtIndex:(NSUInteger)index {
    CRCustomStackFrame frame = [_stack[index] unsignedIntegerValue];
    SEL sel = [self selectorFromStackFrame:frame];
    return NSStringFromSelector(sel);
}

- (void)clear {
    [_stack removeAllObjects];
}

- (SEL)selectorFromStackFrame:(CRCustomStackFrame)frame {
    switch (frame) {
        case crFunctionA:
            return @selector(funcA:);
        case crFunctionB:
            return @selector(funcB:);
        case crFunctionC:
            return @selector(funcC:);
        case crFunctionD:
            return @selector(funcD:);
        default:
            NSAssert(NO, @"Unrecognized function: %lu", (unsigned long)frame);
    }

    return nil;
}

- (CRCustomStackFrame)popFrameFromStackTrace:(NSMutableArray *)stackTrace {
    CRCustomStackFrame frame = [[stackTrace lastObject] unsignedIntegerValue];
    [stackTrace removeLastObject];
    return frame;
}

- (void)crash {
    [self doError];
}

- (void)raiseException {
    @try {
        [self doError];
    } @catch (NSException *exception) {
        [Crittercism logHandledException:exception];
    }
}

- (void)doError {
    if(_stack.count == 0) {
        [NSException raise:@"custom stack trace" format:@"%@", _stack];
    }

    NSMutableArray *stackTrace = [NSMutableArray arrayWithArray:_stack];
    CRCustomStackFrame frame = [self popFrameFromStackTrace:stackTrace];
    SEL sel = [self selectorFromStackFrame:frame];
    CALL_NEXT_FUNCTION(sel, stackTrace);
}

- (void)funcA:(NSMutableArray *)stackTrace {
    if(stackTrace.count == 0) {
        [NSException raise:@"custom stack trace" format:@"%@", _stack];
    }

    CRCustomStackFrame frame = [self popFrameFromStackTrace:stackTrace];
    SEL sel = [self selectorFromStackFrame:frame];
    CALL_NEXT_FUNCTION(sel, stackTrace);
}


- (void)funcB:(NSMutableArray *)stackTrace {
    if(stackTrace.count == 0) {
        [NSException raise:@"custom stack trace" format:@"%@", _stack];
    }

    CRCustomStackFrame frame = [self popFrameFromStackTrace:stackTrace];
    SEL sel = [self selectorFromStackFrame:frame];
    CALL_NEXT_FUNCTION(sel, stackTrace);
}

- (void)funcC:(NSMutableArray *)stackTrace {
    if(stackTrace.count == 0) {
        [NSException raise:@"custom stack trace" format:@"%@", _stack];
    }

    CRCustomStackFrame frame = [self popFrameFromStackTrace:stackTrace];
    SEL sel = [self selectorFromStackFrame:frame];
    CALL_NEXT_FUNCTION(sel, stackTrace);
}

- (void)funcD:(NSMutableArray *)stackTrace {
    if(stackTrace.count == 0) {
        [NSException raise:@"custom stack trace" format:@"%@", _stack];
    }

    CRCustomStackFrame frame = [self popFrameFromStackTrace:stackTrace];
    SEL sel = [self selectorFromStackFrame:frame];
    CALL_NEXT_FUNCTION(sel, stackTrace);
}

@end
