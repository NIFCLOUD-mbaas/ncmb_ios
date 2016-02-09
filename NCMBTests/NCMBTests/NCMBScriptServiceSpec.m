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


SpecBegin(NCMBScriptService)

describe(@"NCMBScriptService", ^{
    
    //Dummy API key from mobile backend document
    NSString *applicationKey = @"6145f91061916580c742f806bab67649d10f45920246ff459404c46f00ff3e56";
    NSString *clientKey = @"1343d198b510a0315db1c03f3aa0e32418b7a743f8e4b47cbff670601345cf75";
    beforeAll(^{
        [NCMB setApplicationKey:applicationKey
                      clientKey:clientKey];
    });
    
    beforeEach(^{

    });
    
    it (@"should set default endpoint", ^{
        NCMBScriptService *service = [[NCMBScriptService alloc]init];
        expect(service.endpoint).to.equal(@"https://logic.mb.api.cloud.nifty.com");
    });
    
    it (@"should return specified endpoint and request url",^{
        NCMBScriptService *service = [[NCMBScriptService alloc] initWithEndpoint:@"http://localhost"];
        expect(service.endpoint).to.equal(@"http://localhost");
    });
    
    it (@"should create request with specified parameters", ^{
        
        NCMBScriptService *service = [[NCMBScriptService alloc] init];

        [service executeScript:@"testScript.js"
                        method:NCMBExecuteWithGetMethod
                       header:@{@"X-Custom-Header":@"customValue",
                                 @"Content-Type":@"text/plain"}
                         body:@{@"paramKey":@"paramValue"}
                         query:@{@"where":@{@"testKey":@"testValue"}}
                     withBlock:nil];
        
        NSString *expectStr = [NSString stringWithFormat:@"%@/%@/%@/%@?%@",
                               NCMBScriptServiceDefaultEndPoint,
                               NCMBScriptServiceApiVersion,
                               NCMBScriptServicePath,
                               @"testScript.js",
                               @"where=%7B%22testKey%22%3A%22testValue%22%7D"];
        expect(service.request.URL.absoluteString).to.equal(expectStr);
        
        NSDictionary *headers = [service.request allHTTPHeaderFields];
        expect([headers objectForKey:@"X-Custom-Header"]).to.equal(@"customValue");
        
        expect([headers objectForKey:@"Content-Type"]).toNot.equal(@"text/plain");
        expect([headers objectForKey:@"Content-Type"]).to.equal(@"application/json");
        
        expect(service.request.HTTPBody).to.beNil;
    });
    
    it (@"should create request with specified query string", ^{
        NCMBScriptService *service = [[NCMBScriptService alloc] init];
        
        [service executeScript:@"testScript.js"
                        method:NCMBExecuteWithGetMethod
                        header:nil
                          body:nil
                         query:@{@"number":@12345,
                                 @"string":@"test",
                                 @"array":@[@"typeA",@"typeB"],
                                 @"dictionary":@{@"key":@"value"},
                                 @"bool":@YES}
                     withBlock:nil];
        
        NSString *expectStr = [NSString stringWithFormat:@"%@/%@/%@/%@?%@",
                               NCMBScriptServiceDefaultEndPoint,
                               NCMBScriptServiceApiVersion,
                               NCMBScriptServicePath,
                               @"testScript.js",
                               @"array=%5B%22typeA%22%2C%22typeB%22%5D&bool=1&dictionary=%7B%22key%22%3A%22value%22%7D&number=12345&string=test"];
        expect(service.request.URL.absoluteString).to.equal(expectStr);
    });
    
    it(@"should run callback response of execute asynchronously script", ^{
        waitUntil(^(DoneCallback done) {
            
            __block NSData *resultData = nil;
            
            NCMBScriptExecuteCallback callbackBlock = ^(NSData *result, NSError *error){
                if (error) {
                    failure(@"This shnould not happen");
                } else {
                    resultData = result;
                }
                NSString *expectStr = @"hello";
                expect([[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding]).to.equal(expectStr);
                
                done();
            };
            
            NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:config
                                                                  delegate:nil
                                                             delegateQueue:[NSOperationQueue mainQueue]];
            
            id mockSession = OCMPartialMock(session);
            
            void (^invocation)(NSInvocation *) = ^(NSInvocation *invocation) {
                __unsafe_unretained void(^completionHandler)(NSData *data, NSURLResponse *res, NSError *error);
                [invocation getArgument:&completionHandler atIndex:3];
                
                
                NSURL *url = [NSURL URLWithString:@"http://sample.com"];
                NSDictionary *resDic = @{@"Content-Type":@"text/plane"};
                
                NSHTTPURLResponse *res = [[NSHTTPURLResponse alloc] initWithURL:url
                                                                     statusCode:200
                                                                    HTTPVersion:@"HTTP/1.1"
                                                                   headerFields:resDic];
                
                //invoke completion handler of NSURLSession
                completionHandler([@"hello" dataUsingEncoding:NSUTF8StringEncoding], (NSURLResponse *)res, nil);
            };
            
            OCMStub([[mockSession dataTaskWithRequest:OCMOCK_ANY
                                   completionHandler:OCMOCK_ANY] resume]).andDo(invocation);
            
            NCMBScriptService *service = [[NCMBScriptService alloc] init];
            
            service.session = mockSession;
            [service executeScript:@"testScript.js"
                            method:NCMBExecuteWithGetMethod
                            header:nil
                              body:nil
                             query:nil
                         withBlock:callbackBlock];
        });
        
    });
    
    it(@"should return error in callback", ^{
        waitUntil(^(DoneCallback done) {
            
            NCMBScriptExecuteCallback callbackBlock = ^(NSData *result, NSError *error){
                if (error) {
                    expect(error.code).to.equal(@404);
                    expect([error.userInfo objectForKey:NSLocalizedDescriptionKey]).to.equal(@"Not Found");
                } else {
                    failure(@"This shnould not happen");
                }
                
                done();
            };
            
            NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:config
                                                                  delegate:nil
                                                             delegateQueue:[NSOperationQueue mainQueue]];
            
            id mockSession = OCMPartialMock(session);
            
            void (^invocation)(NSInvocation *) = ^(NSInvocation *invocation) {
                __unsafe_unretained void(^completionHandler)(NSData *data, NSURLResponse *res, NSError *error);
                [invocation getArgument:&completionHandler atIndex:3];
                
                
                NSURL *url = [NSURL URLWithString:@"http://sample.com"];
                NSDictionary *resDic = @{@"Content-Type":@"application/json"};
                
                NSHTTPURLResponse *res = [[NSHTTPURLResponse alloc] initWithURL:url
                                                                     statusCode:404
                                                                    HTTPVersion:@"HTTP/1.1"
                                                                   headerFields:resDic];
                
                //invoke completion handler of NSURLSession
                NSDictionary *errorDic = @{@"error":@"Not Found", @"status":@400};
                completionHandler([NSJSONSerialization dataWithJSONObject:errorDic
                                                                  options:kNilOptions
                                                                    error:nil],
                                  (NSURLResponse *)res, nil);
            };
            
            OCMStub([[mockSession dataTaskWithRequest:OCMOCK_ANY
                                    completionHandler:OCMOCK_ANY] resume]).andDo(invocation);
            
            NCMBScriptService *service = [[NCMBScriptService alloc] init];
            
            service.session = mockSession;
            [service executeScript:@"testScript.js"
                            method:NCMBExecuteWithGetMethod
                            header:nil
                              body:nil
                             query:nil
                         withBlock:callbackBlock];
        });
    });
    
    it(@"should return result of execute script synchronously", ^{
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config
                                                              delegate:nil
                                                         delegateQueue:[NSOperationQueue mainQueue]];
        
        id mockSession = OCMPartialMock(session);
        
        void (^invocation)(NSInvocation *) = ^(NSInvocation *invocation) {
            __unsafe_unretained void(^completionHandler)(NSData *data, NSURLResponse *res, NSError *error);
            [invocation getArgument:&completionHandler atIndex:3];
            
            
            NSURL *url = [NSURL URLWithString:@"http://sample.com"];
            NSDictionary *resDic = @{@"Content-Type":@"text/plane"};
            
            NSHTTPURLResponse *res = [[NSHTTPURLResponse alloc] initWithURL:url
                                                                 statusCode:200
                                                                HTTPVersion:@"HTTP/1.1"
                                                               headerFields:resDic];
            
            //invoke completion handler of NSURLSession
            completionHandler([@"hello" dataUsingEncoding:NSUTF8StringEncoding], (NSURLResponse *)res, nil);
        };
        
        OCMStub([[mockSession dataTaskWithRequest:OCMOCK_ANY
                                completionHandler:OCMOCK_ANY] resume]).andDo(invocation);
        
        NCMBScriptService *service = [[NCMBScriptService alloc] init];
        
        service.session = mockSession;
        NSError *error = nil;
        NSData *result = [service executeScript:@"testScript.js"
                        method:NCMBExecuteWithGetMethod
                        header:nil
                          body:nil
                         query:nil
                         error:&error];
        
        expect(error).to.beNil;
        expect([[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding]).to.equal(@"hello");
    });
    
    it(@"should return error when execute invalid script synchronously", ^{
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config
                                                              delegate:nil
                                                         delegateQueue:[NSOperationQueue mainQueue]];
        
        id mockSession = OCMPartialMock(session);
        
        void (^invocation)(NSInvocation *) = ^(NSInvocation *invocation) {
            __unsafe_unretained void(^completionHandler)(NSData *data, NSURLResponse *res, NSError *error);
            [invocation getArgument:&completionHandler atIndex:3];
            
            
            NSURL *url = [NSURL URLWithString:@"http://sample.com"];
            NSDictionary *resDic = @{@"Content-Type":@"application/json"};
            
            NSHTTPURLResponse *res = [[NSHTTPURLResponse alloc] initWithURL:url
                                                                 statusCode:404
                                                                HTTPVersion:@"HTTP/1.1"
                                                               headerFields:resDic];
            
            //invoke completion handler of NSURLSession
            NSDictionary *errorDic = @{@"error":@"Not Found", @"status":@400};
            completionHandler([NSJSONSerialization dataWithJSONObject:errorDic
                                                              options:kNilOptions
                                                                error:nil],
                              (NSURLResponse *)res, nil);
        };
        
        OCMStub([[mockSession dataTaskWithRequest:OCMOCK_ANY
                                completionHandler:OCMOCK_ANY] resume]).andDo(invocation);
        
        NCMBScriptService *service = [[NCMBScriptService alloc] init];
        
        service.session = mockSession;
        NSError *error = nil;
        NSData *result = [service executeScript:@"testScript.js"
                                         method:NCMBExecuteWithGetMethod
                                         header:nil
                                           body:nil
                                          query:nil
                                          error:&error];
        expect(result).to.beNil;
        expect(error.code).to.equal(@404);
        expect([error.userInfo objectForKey:NSLocalizedDescriptionKey]).to.equal(@"Not Found");
    });
    
    afterEach(^{

    });
    
    afterAll(^{

    });
});

SpecEnd
