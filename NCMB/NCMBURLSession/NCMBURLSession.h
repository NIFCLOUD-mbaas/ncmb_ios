/*
 Copyright 2017-2019 FUJITSU CLOUD TECHNOLOGIES LIMITED All Rights Reserved.
 
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

#import <Foundation/Foundation.h>
#import "NCMBRequest.h"


@interface NCMBURLSession : NSURLSession<NSURLSessionTaskDelegate>

// コールバック
typedef void (^NCMBProgressBlock)(int percentDone);
typedef void (^NCMBResultBlock)(id response, NSError *error);

// プロパティ
@property (nonatomic)NCMBRequest *request;
@property (nonatomic)NSURLSessionConfiguration *config;
@property (nonatomic)NSURLSession *session;
@property (nonatomic)NSURLSessionDataTask *dataTask;
@property (nonatomic)NSURLSessionDataTask *uploadTask;
@property (nonatomic)NSURLSessionDownloadTask *downloadTask;
@property (nonatomic)NSMutableData *responseData;
@property (nonatomic,copy) void (^block)(id response, NSError *error);
@property (nonatomic,copy) void (^blockProgress)(int progress);

- (id)initWithRequestSync:(NCMBRequest*)request;

- (id)initWithRequestAsync:(NCMBRequest*)request;

- (id)initWithRequest:(NCMBRequest*)request cachePolicy:(NSURLRequestCachePolicy)cachePolicy;

- (id)initWithProgress:(NCMBRequest*)request  progress:(void (^)(int progress))progress;


- (void)dataAsyncConnectionWithBlock:(NCMBResultBlock)block;

- (void)fileUploadAsyncConnectionWithBlock:(NCMBResultBlock)block;

- (void)fileDownloadAsyncConnectionWithBlock:(NCMBResultBlock)block;

// ---------------------------------------------------------------------
//  NSURLSessionTaskDelegate(upload)
// ---------------------------------------------------------------------

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data;

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error;

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler;

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend;

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task needNewBodyStream:(void (^)(NSInputStream *bodyStream))completionHandler;

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler;



// ---------------------------------------------------------------------
//  NSURLSessionDownloadDelegate
// ---------------------------------------------------------------------

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes;

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite;

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location;
@end
