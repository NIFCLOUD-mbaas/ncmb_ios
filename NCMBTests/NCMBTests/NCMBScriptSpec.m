/*
 Copyright 2016 NIFTY Corporation All Rights Reserved.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "Specta.h"
#import <Expecta/Expecta.h>
#import <NCMB/NCMB.h>
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>


SpecBegin(NCMBScript)

describe(@"NCMBScript", ^{
    
    beforeAll(^{

    });
    
    beforeEach(^{

    });
    
    it(@"should create instance of NCMBScript with script name and request method", ^{
        NSString *scriptName = @"testScript.js";
        NCMBScript *script = [NCMBScript scriptWithName:scriptName method:NCMBExecuteWithGetMethod];
        expect(script.scriptName).to.equal(scriptName);
        expect(script.method).to.equal(NCMBExecuteWithGetMethod);
    });
    
    it(@"should raise NSInvalidArgumentException when script name is empty ", ^{
        XCTAssertThrows([NCMBScript scriptWithName:nil method:NCMBExecuteWithGetMethod], @"no raise exception");
        //expect().to.raise(NSInvalidArgumentException);
    });
    
    it(@"should raise NSInvalidArgumentException when request method is invalid", ^{
        XCTAssertThrows([NCMBScript scriptWithName:@"testScript.js" method:10], @"no raise exception");
        //expect([NCMBScript scriptWithName:@"testScript.js" method:10]).to.raise(NSInvalidArgumentException);
    });
    
    it(@"should run callback block after execute script asynchronously", ^{
        
        waitUntil(^(DoneCallback done) {
            
            NCMBScriptExecuteCallback block = ^(NSData *result, NSError *error){
                if (error) {
                    failure(@"This shnould not happen");
                }
                
                NSString *expectStr = @"hello";
                expect([[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding]).to.equal(expectStr);
                
                done();
            };
            
            NCMBScriptService *scriptService = [[NCMBScriptService alloc] init];
            id mockService = OCMPartialMock(scriptService);
            
            void (^invocation)(NSInvocation *) = ^(NSInvocation *invocation) {
                __unsafe_unretained void(^block)(NSData *data, NSError *error);
                [invocation getArgument:&block atIndex:7];
                
                //invoke callback block of NCMBScriptService
                block([@"hello" dataUsingEncoding:NSUTF8StringEncoding],nil);
            };
            
            OCMStub([mockService executeScript:OCMOCK_ANY
                                        method:NCMBExecuteWithGetMethod
                                        header:OCMOCK_ANY
                                          body:OCMOCK_ANY
                                         query:OCMOCK_ANY
                                     withBlock:block
                     ]).andDo(invocation);
            
            NCMBScript *script = [NCMBScript scriptWithName:@"testScript.js" method:NCMBExecuteWithGetMethod];
            script.service = mockService;
            [script execute:nil headers:nil queries:nil withBlock:block];
        });
    });
    
    it(@"should return NSData response when execute script synchronously", ^{
        
        NCMBScriptService *scriptService = [[NCMBScriptService alloc] init];
        id mockService = OCMPartialMock(scriptService);
        OCMStub([mockService executeScript:OCMOCK_ANY
                                    method:NCMBExecuteWithGetMethod
                                    header:OCMOCK_ANY
                                      body:OCMOCK_ANY
                                     query:OCMOCK_ANY
                                     error:[OCMArg anyObjectRef]])
        .andReturn([@"hello" dataUsingEncoding:NSUTF8StringEncoding]);
        
        NCMBScript *script = [NCMBScript scriptWithName:@"testScript.js" method:NCMBExecuteWithGetMethod];
        script.service = mockService;
        NSError *error = nil;
        NSData *result = [script execute:nil
                                 headers:nil
                                   queries:nil
                                   error:&error];
        
        expect([[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding]).to.equal(@"hello");
        
    });
    
    it(@"should return NSError response when execute invalid script synchronously", ^{
        
        void (^invocation)(NSInvocation *) = ^(NSInvocation *invocation) {
            NSError * __autoreleasing *error;
            [invocation getArgument:&error atIndex:7];
            
            //create error response
            *error = [NSError errorWithDomain:@"NCMBErrorDomain"
                                        code:404
                                    userInfo:@{NSLocalizedDescriptionKey:@"Not Found."}];
            
        };
        
        NCMBScriptService *scriptService = [[NCMBScriptService alloc] init];
        id mockService = OCMPartialMock(scriptService);
        
        OCMStub([mockService executeScript:OCMOCK_ANY
                                    method:NCMBExecuteWithGetMethod
                                    header:OCMOCK_ANY
                                      body:OCMOCK_ANY
                                     query:OCMOCK_ANY
                                     error:[OCMArg anyObjectRef]])
        .andDo(invocation).andReturn(nil);
        
        NCMBScript *script = [NCMBScript scriptWithName:@"notExistScript.js" method:NCMBExecuteWithGetMethod];
        script.service = mockService;
        NSError *error = nil;
        NSData *result = [script execute:nil
                                 headers:nil
                                   queries:nil
                                   error:&error];
        
        expect(result).to.beNil;
        expect(error).toNot.beNil;
        expect(error.code).to.equal(404);
        
    });
    
    afterEach(^{

    });
    
    afterAll(^{

    });
});

SpecEnd
