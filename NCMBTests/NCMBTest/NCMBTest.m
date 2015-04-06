//
//  NCMBTest.m
//  NCMBTest
//
//  Created by SCI01433 on 2015/04/06.
//  Copyright (c) 2015年 NIFTY Corporation. All rights reserved.
//

#import <Specta/Specta.h> // #import "Specta.h" if you're using libSpecta.a

SharedExamplesBegin(MySharedExamples)
// Global shared examples are shared across all spec files.

sharedExamplesFor(@"foo", ^(NSDictionary *data) {
    __block id bar = nil;
    beforeEach(^{
        bar = data[@"bar"];
    });
    it(@"should not be nil", ^{
        //XCTAssertNotNil(bar);
        XCTAssertNil(bar);
    });
});

SharedExamplesEnd

SpecBegin(Thing)

describe(@"Thing", ^{
    sharedExamplesFor(@"another shared behavior", ^(NSDictionary *data) {
        // Locally defined shared examples can override global shared examples within its scope.
    });
    
    beforeAll(^{
        // This is run once and only once before all of the examples
        // in this group and before any beforeEach blocks.
    });
    
    beforeEach(^{
        // This is run before each example.
    });
    
    it(@"should do stuff", ^{
        // This is an example block. Place your assertions here.
    });
    
    it(@"should do some stuff asynchronously", ^{
        waitUntil(^(DoneCallback done) {
            // Async example blocks need to invoke done() callback.
            done();
        });
    });
    
    itShouldBehaveLike(@"a shared behavior", @{@"key" : @"obj"});
    
    itShouldBehaveLike(@"another shared behavior", ^{
        // Use a block that returns a dictionary if you need the context to be evaluated lazily,
        // e.g. to use an object prepared in a beforeEach block.
        return @{@"key" : @"obj"};
    });
    
    describe(@"Nested examples", ^{
        it(@"should do even more stuff", ^{
            // ...
        });
    });
    
    pending(@"pending example");
    
    pending(@"another pending example", ^{
        // ...
    });
    
    afterEach(^{
        // This is run after each example.
    });
    
    afterAll(^{
        // This is run once and only once after all of the examples
        // in this group and after any afterEach blocks.
    });
});

SpecEnd
