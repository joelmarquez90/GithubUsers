//
//  API.m
//  GithubUsers
//
//  Created by Joel Márquez on 10/2/15.
//  Copyright (c) 2015 Joel. All rights reserved.
//

#import "API.h"

#import <AFNetworking/AFNetworking.h>

/*
 * Reactive API Manager
 */
@interface API()

@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;

@end

@implementation API

#pragma mark - Singleton

+ (instancetype)sharedAPI
{
    static API *sharedAPI = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAPI = [API new];
    });
    return sharedAPI;
}

#pragma mark - Init & Setup

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    NSURLSessionConfiguration *sessionConfiguration =
    [NSURLSessionConfiguration defaultSessionConfiguration];
    
    sessionConfiguration.allowsCellularAccess = YES;
    sessionConfiguration.discretionary = YES;
    
    NSURL *apiURL = [NSURL URLWithString:@"https://api.github.com"];
    self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:apiURL sessionConfiguration:sessionConfiguration];
    
    // Serializers
    
    self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:NSJSONWritingPrettyPrinted];
    
    self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
}

#pragma mark - Requests

- (RACSignal*)GET:(NSString *)endpoint
            query:(NSDictionary *)query
{
    NSParameterAssert(endpoint);
    NSParameterAssert([endpoint characterAtIndex:0] == '/');
    
    if (query && [query count]) {
        endpoint = [endpoint stringByAppendingString:[self queryStringFromDictionary:query]];
    }
    
    @weakify(self)
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        @strongify(self)
        
        NSURLSessionDataTask *task =
        [self.sessionManager GET:endpoint
                      parameters:nil
                         success:^(NSURLSessionDataTask *task, id responseObject) {
                             
                             NSHTTPURLResponse *response = (NSHTTPURLResponse *)[task response];
                             if ([self isSuccessStatusCode:[response statusCode]]) {
                                 [subscriber sendNext:responseObject];
                                 [subscriber sendCompleted];
                             }
                             else {
                                 [subscriber sendError:[NSError errorWithDomain:@"" code:[response statusCode] userInfo:@{}]];
                             }
                         } failure:^(NSURLSessionDataTask *task, NSError *error) {
                             [subscriber sendError:error];
                         }
         ];
        
        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
        
    }];
}

#pragma mark - Utilities

- (BOOL)isSuccessStatusCode:(NSInteger)statusCode
{
    return (statusCode >= 200 && statusCode < 300);
}

- (NSString*)queryStringFromDictionary:(NSDictionary*)dictionary
{
    __block NSString *queryString = @"?";
    
    __block NSInteger entriesCount = [dictionary count];
    __block NSInteger count = 0;
    
    @weakify(self)
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(NSString* key, id obj, BOOL *stop) {
        
        @strongify(self);
        
        count++;
        
        NSString *encodedObj = [obj isKindOfClass:NSString.class] ? [self urlEncode:obj] : obj;
        NSString *arg = [NSString stringWithFormat:@"%@=%@%@",
                         key,
                         encodedObj,
                         (count == entriesCount?@"":@"&")];
        
        queryString = [queryString stringByAppendingString:arg];
        
    }];
    
    return queryString;
}

- (NSString *)urlEncode:(NSString *)str
{
    return  CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                      NULL,
                                                                      (CFStringRef)str,
                                                                      NULL,
                                                                      (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                      kCFStringEncodingUTF8));
}

@end