/*
 Copyright 2014 NIFTY Corporation All Rights Reserved.
 
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

#import "NCMBTwitterUtils.h"

#import "NCMBOAToken.h"
#import "NCMBOAConsumer.h"
#import "NCMBOAServiceTicket.h"
#import "NCMBOADataFetcher.h"
#import "NCMBURLConnection.h"
#import "NCMBTwitterLoginView.h"

#define AUTHORIZE_URL @"https://api.twitter.com/oauth/authorize"
#define REQUEST_TOKEN_URL @"https://api.twitter.com/oauth/request_token"
#define TOKEN_FORMAT_URL @"https://api.twitter.com/oauth/authorize?oauth_token=%@"

#define SIGNATURE_METHOD @"HMAC-SHA1"
#define OAUTH_VERSION @"1.0"

@interface NCMB_Twitter()<UIWebViewDelegate, UIActionSheetDelegate>
@property(nonatomic,strong) NCMBOAToken* requestToken;
@property(nonatomic,strong) NSMutableData* responseData;
@property (nonatomic,copy) void (^succeedBlock)();
@property (nonatomic,copy) void (^failedBlock)(NSError* error);
@property (nonatomic,copy) void (^cancelBlock)();
@property (nonatomic,strong) NCMBTwitterLoginView* webView;
@property (nonatomic) BOOL isLocked;

- (NCMB_Twitter*) initWithKey:(NSString*) key withSecret:(NSString*) secret;

@end

@implementation NCMB_Twitter
static NCMB_Twitter* _self = nil;

enum{
    ActivityIndicatorBackgroundTag = 10000,
    ActivityIndicatorTag = 10001,
};

#pragma mark - class method

+(NCMB_Twitter*)sharedInstace{
    if(!_self) _self = [NCMB_Twitter new];
    return _self;
}

#pragma mark - siganture

- (NSString *)encodedURLParameterString:(NSString*)str{
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)str,
                                                                           NULL,
                                                                           CFSTR(":/=,!$&'()*+;[]@#?"),
                                                                           kCFStringEncodingUTF8));
	return result;
}


// NSDictionaryをソートした文字列へ変換
-(NSString*)concatenateQuery:(NSDictionary*)parameters {
    if(!parameters||[parameters count]==0) return nil;
    NSMutableString *query = [NSMutableString string];
    NSArray *sortedKeys = [[parameters allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for(NSString *key in sortedKeys)
        [query appendFormat:@"&%@=%@",key,parameters[key]];
    return [query substringFromIndex:1];
}

// key=value形式のNSStringを辞書へ変換
-(NSDictionary*)splitQuery:(NSString*)query {
    if(!query||[query length]==0) return nil;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    for(NSString *parameter in [query componentsSeparatedByString:@"&"]) {
        NSRange range = [parameter rangeOfString:@"="];
        
        NSString *value,*key;
        if(range.location!=NSNotFound){
            value = [parameter substringFromIndex:range.location+range.length];
            key = [parameter substringToIndex:range.location];
        }else{
            value = [parameter substringFromIndex:range.length];
            key = [NSString new];
        }
        
        parameters[key] = value;
    }
    return parameters;
}

-(void)requestUserDataWithAuthToken:(NSString*)authToken authTokenSecret:(NSString*)authTokenSecret handler:(void(^)(NSDictionary* userData,NSError* error))handler{
    NSURL* url = [NSURL URLWithString:@"https://api.twitter.com/1.1/account/verify_credentials.json"];
    self.authToken = authToken;
    self.authTokenSecret = authTokenSecret;
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [self signRequest:request];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *errorblock) {
            NSDictionary* userData = nil;
            if(!errorblock){
                userData = [NSJSONSerialization JSONObjectWithData:responseData
                                                          options:NSJSONReadingAllowFragments
                                                            error:&errorblock];
            }
            handler(userData,errorblock);
    }];
}

-(void)checkTwitterId:(NSString *)twitterId
           screenName:(NSString *)screenName
            authToken:(NSString*)authToken
      authTokenSecret:(NSString*)authTokenSecret
              handler:(void(^)(BOOL isCallated, NSError* error))handler{
    [self requestUserDataWithAuthToken:authToken authTokenSecret:authTokenSecret handler:^(NSDictionary *userData, NSError *error) {
        if(!error){
            if([[userData objectForKey:@"id_str"] isEqualToString:twitterId]&&[[userData objectForKey:@"screen_name"] isEqualToString:screenName]){
                handler(YES,nil);
            }else{
                NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithCapacity:0];
                [userInfo setObject:@"Unauthorized" forKey:NSLocalizedDescriptionKey];
                NSError* idError = [NSError errorWithDomain:ERRORDOMAIN code:401 userInfo:userInfo];
                handler(NO,idError);
            }
        }else{
            handler(NO,error);
        }
    }];
}

- (void)signRequest:(NSMutableURLRequest *)request{
    NCMBOAConsumer *consumer = [[NCMBOAConsumer alloc] initWithKey:_consumerKey
                                                             secret:_consumerSecret];
    NCMBOAToken* token = [[NCMBOAToken alloc] initWithKey:self.authToken secret:self.authTokenSecret];
    NCMBOAMutableURLRequest *oAMutableRequest = [[NCMBOAMutableURLRequest alloc] initWithURL:[request URL]
                                                                                     consumer:consumer
                                                                                        token:token
                                                                                        realm:nil
                                                                            signatureProvider:nil];
    [oAMutableRequest setHTTPMethod:[request HTTPMethod]];
    [oAMutableRequest setHTTPBody:[request HTTPBody]];
    [oAMutableRequest prepare];
    [request setAllHTTPHeaderFields:[oAMutableRequest allHTTPHeaderFields]];
}

#pragma mark - authorize

- (void)authorizeWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure cancel:(void (^)(void))cancel{
    if ([self oAuthLock]) {
        self.succeedBlock = success;
        self.failedBlock = failure;
        self.cancelBlock = cancel;
    
        [self requestOAuthToken];
    } else {
        cancel();
    }
}

- (void)requestOAuthToken{
    NSURL *url = [NSURL URLWithString:REQUEST_TOKEN_URL];
    NCMBOAConsumer *consumer = [[NCMBOAConsumer alloc] initWithKey:_consumerKey
                                                     secret:_consumerSecret];
    NCMBOAMutableURLRequest *request = [[NCMBOAMutableURLRequest alloc] initWithURL:url
                                                                             consumer:consumer
                                                                                token:nil
                                                                                realm:nil
                                                                    signatureProvider:nil];
    NCMBOADataFetcher *fetcher = [[NCMBOADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(requestTokenTicket:didFinishWithData:)
                  didFailSelector:@selector(requestTokenTicket:didFailWithError:)];
}

#pragma mark - web view

-(void)startWebViewLoading{
    [self.webView startWebViewLoading];
}

-(void)endWebViewLoading{
    [self.webView endWebViewLoading];
}

-(void)disappearWebView{
    [self.webView closeWebView];
    self.webView = nil;
}

-(void)appearWebView{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    self.webView = [[NCMBTwitterLoginView alloc] init];
    [self.webView appearWebView:orientation];
    //デリゲートをセットする
    self.webView.webView.delegate = self;
    [self.webView.closeButton addTarget:self action:@selector(closeWebView:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - process lock
- (BOOL)oAuthLock {
    BOOL success = NO;
    @synchronized(self) {
        if (!self.isLocked) {
            self.isLocked = YES;
            success = YES;
        }
    }
    return success;
}

- (void)oAuthUnlock {
    self.isLocked = NO;
}

#pragma mark - handle call back blocks

-(void)oAuthCanceled{
    [self disappearWebView];
    [self oAuthUnlock];

    if(_cancelBlock)
        self.cancelBlock();
}

-(void)oAuthFailedWithError:(NSError*)error{
    [self disappearWebView];
    [self oAuthUnlock];

    if(_failedBlock)
        self.failedBlock(error);
}

-(void)oAuthAccessTokenReceived:(NCMBOAToken*)token{
    
    self.userId = token.attributes[@"user_id"];
    self.screenName = token.attributes[@"screen_name"];
    self.authToken = token.key;
    self.authTokenSecret = token.secret;

    [self disappearWebView];
    [self oAuthUnlock];
    
    if(_succeedBlock)
        self.succeedBlock();

}

#pragma mark - web view delegate

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:actionSheet.title]];
            break;
            
        default:
            break;
    }
}

- (void) closeWebView:(id)sender {
    [self oAuthCanceled];
}

- (BOOL) webView:(UIWebView*) webView
shouldStartLoadWithRequest:(NSURLRequest*) request
  navigationType:(UIWebViewNavigationType) navigationType
{
    // WebView内でリンクをクリックした際に、認証と無関係な遷移を捕捉してSafariで開く処理
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSRange range = [[request.URL absoluteString] rangeOfString:@"https://api.twitter.com/"];
        if (range.location == NSNotFound) {
            UIWindow* window = [UIApplication sharedApplication].windows[0];
                
            UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
            actionSheet.delegate = self;
            actionSheet.title = [[request URL] absoluteString];
            [actionSheet addButtonWithTitle:@"Safariで開く"];
            [actionSheet addButtonWithTitle:@"キャンセル"];
            actionSheet.cancelButtonIndex = 1;
                
            [actionSheet showInView:window];

            return NO;
        }
    }
    
    [self startWebViewLoading];
    
    if ( [[request.URL absoluteString] isEqualToString:AUTHORIZE_URL] ){
        NSString* body = [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding];
        
        BOOL cancel = NO;
        NSArray *pairs = [body componentsSeparatedByString:@"&"];
        for (NSString *pair in pairs) {
            NSArray *elements = [pair componentsSeparatedByString:@"="];
            if ([[elements objectAtIndex:0] isEqualToString:@"cancel"])
                cancel = YES;
        }

        if(cancel){
            [self oAuthCanceled];
            return NO;
        }

    }
    
    //iOS9かつ、一度Twitter認証で失敗して、/login/errorにアクセスしようとしている場合をエラーとする
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0 &&
        [[request.URL absoluteString] containsString:@"https://api.twitter.com/login/error"]) {
        return NO;
    }
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithCapacity:0];
    NSArray *pairs = [[[request URL] query] componentsSeparatedByString:@"&"];
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        params[[elements objectAtIndex:0]] = [elements objectAtIndex:1];
    }
    
    if([[params allKeys] containsObject:@"oauth_verifier"]){
        NSString* oauth_verifier = params[@"oauth_verifier"];
        [self requestOAuthAccessTokenWithVerifier:oauth_verifier];
        return NO;
    }
    
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    if ([error code] != NSURLErrorCancelled){
        [self.webView webviewDidFailLoad];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.webView endWebViewLoading];
}

#pragma mark - 

-(void)oAuthTokenReceived:(NCMBOAToken*)token{
    NSString* path = [NSString stringWithFormat:TOKEN_FORMAT_URL, token.key];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:path] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5];
    
    [self appearWebView];
    [_webView loadRequest:request];
}

- (void) requestOAuthAccessToken:(NSURLRequest*) request;
{
    [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void) connection:(NSURLConnection*) connection didReceiveResponse:(NSURLResponse*) response
{
    self.responseData = [[NSMutableData alloc] init];
}

- (void) connection:(NSURLConnection*) connection didReceiveData:(NSData*) data
{
    [_responseData appendData:data];
}

#pragma mark - ticket response

- (void) requestTokenTicket:(NCMBOAServiceTicket*) ticket didFinishWithData:(NSData*) data
{
    if ( ticket.didSucceed ){
        NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        self.requestToken = [[NCMBOAToken alloc] initWithHTTPResponseBody:responseBody];
        [self oAuthTokenReceived:_requestToken];
    } else {
        NSInteger statusCode = [(NSHTTPURLResponse *)ticket.response statusCode];
        NSError* error = [NSError errorWithDomain:@"request tickets is invalid." code:statusCode userInfo:nil];
        [self oAuthFailedWithError:error];
    }
}

- (void) requestTokenTicket:(NCMBOAServiceTicket*) ticket didFailWithError:(NSError*) error
{
    [self oAuthFailedWithError:error];
}

#pragma mark - accessToken response

- (void) requestAccessTokenTicket:(NCMBOAServiceTicket*) ticket didFinishWithData:(NSData*) data
{
    if ( ticket.didSucceed ){
        NSString *responseBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NCMBOAToken* accessToken = [[NCMBOAToken alloc] initWithHTTPResponseBody:responseBody];
        
        NSMutableDictionary* attrs = [NSMutableDictionary dictionaryWithCapacity:0];
        NSArray *pairs = [responseBody componentsSeparatedByString:@"&"];
        NSArray *keys = @[@"screen_name",@"user_id"];
        for (NSString *pair in pairs) {
            NSArray *elements = [pair componentsSeparatedByString:@"="];
            for (NSString *key in keys){
                if ([[elements objectAtIndex:0] isEqualToString:key]) {
                    attrs[key] = [elements objectAtIndex:1];
                }
            }
        }
        [accessToken setAttributes:attrs];
        [self oAuthAccessTokenReceived:accessToken];
    }else{
        NSInteger statusCode = [(NSHTTPURLResponse *)ticket.response statusCode];
        NSError* error = [NSError errorWithDomain:@"access token request is invalid." code:statusCode userInfo:nil];
        [self oAuthFailedWithError:error];
    }
}

- (void)requestAccessTokenTicket:(NCMBOAServiceTicket*) ticket didFailWithError:(NSError*) error
{
    [self oAuthFailedWithError:error];
}

-(void)requestOAuthAccessTokenWithVerifier:(NSString*) verifier
{
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/oauth/access_token"];
    NCMBOAConsumer *consumer = [[NCMBOAConsumer alloc] initWithKey:_consumerKey
                                                    secret:_consumerSecret];
    self.requestToken = [[NCMBOAToken alloc] initWithKey:[_requestToken key] secret:[_requestToken secret]];
    _requestToken.verifier = verifier;
	
    NCMBOAMutableURLRequest *request = [[NCMBOAMutableURLRequest alloc] initWithURL:url consumer:consumer token:_requestToken realm:nil signatureProvider:nil];
    [request setHTTPMethod:@"POST"];
	    
    NCMBOADataFetcher *fetcher = [[NCMBOADataFetcher alloc] init];
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(requestAccessTokenTicket:didFinishWithData:)
                  didFailSelector:@selector(requestAccessTokenTicket:didFailWithError:)];
    
}

#pragma mark - initial

- (NCMB_Twitter*) initWithKey:(NSString*) key withSecret:(NSString*) secret
{
    self.consumerKey = key;
    self.consumerSecret = secret;
	return self;
}

-(id)init{
    if(self = [super init]){
        
    }
    return self;
}

@end
