# Test in localhost 

## requirement

- node.js
- express
- body-parser

## create local server

- create directory for local server project
- create app.js

```
var express = require('express');
var bodyParser = require('body-parser');

var app = express();

app.use(bodyParser.json());

var moduleForGetMethod = require('./testScript_GET.js');
var moduleForPostMethod = require('./testScript_POST.js');
var moduleForPutMethod = require('./testScript_PUT.js');
var moduleForDeleteMethod = require('./testScript_DELETE.js');

var apiVersion = "/2015-09-01";
var servicePath = "/script";

app.get(apiVersion + servicePath + '/testScript_GET.js', moduleForGetMethod);
app.post(apiVersion + servicePath + '/testScript_POST.js', moduleForPostMethod);
app.put(apiVersion + servicePath + '/testScript_PUT.js', moduleForPutMethod);
app.delete(apiVersion + servicePath + '/testScript_DELETE.js', moduleForDeleteMethod);

app.listen(3000, function () {
    console.log('app listening on port 3000');
});
```

- copy test script(test_XXX.js) to directory of local server
- execute `node app.js`

## access to local server from ScriptSample

- set endpoint to local server in AppDelegate.m

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [NCMB setApplicationKey:@"YOUR_APP_KEY"
                  clientKey:@"YOUR_CLIENT_KEY"];
    
    NCMBScript *script = [NCMBScript scriptWithName:@"testScript_GET.js"
                                             method:NCMBSCRIPT_GET
                                           endpoint:@"http://localhost:3000"]; //endpoint of local server

    [script execute:@{@"name":@"Test"}
            headers:nil
            queries:@{@"objectId":@"testId"}
          withBlock:^(NSData *data, NSError *error) {
              if (error) {
                  NSLog(@"error:%@", error.description);
              } else {
                  NSLog(@"data:%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
              }
          }];
    
    return YES;
}
```
