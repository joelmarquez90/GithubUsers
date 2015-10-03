//
//  RepositoriesManager.m
//  GithubUsers
//
//  Created by Joel Márquez on 10/2/15.
//  Copyright (c) 2015 Joel. All rights reserved.
//

#import "UsersManager.h"
#import "User.h"
#import "API.h"

/*
 * This class fetches the public Github API to get paginated user lists, and user details
 */
@interface UsersManager()

@property (nonatomic, strong) NSNumber *lastUserID;

@end

@implementation UsersManager

#pragma mark - Singleton

+ (instancetype)sharedInstance
{
    static UsersManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [UsersManager new];
    });
    
    return sharedInstance;
}

#pragma mark - User services

/*
 * This method fetches the user list. lastUserID is used to store the last id of the user list,
 * in order to request the next pagination users. Once the response comes from the server as an array,
 * we transform that array of dictionaries into an array of Users with Mantle and then send the users
 */
- (RACSignal *)getUsers
{
    @weakify(self)
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        @strongify(self)
        
        NSDictionary *query = self.lastUserID ? @{ @"since" : self.lastUserID } : nil;
        [[[API sharedAPI] GET:@"/users" query:query] subscribeNext:^(NSArray *response) {
            
            NSError *error = nil;
            NSArray *users = [MTLJSONAdapter modelsOfClass:User.class fromJSONArray:response error:&error];
            // We keep the reference to the last user id from the response in order to do the pagination
            self.lastUserID = ((User *)[users lastObject]).ID;
            
            if (!error) {
                [subscriber sendNext:users];
                [subscriber sendCompleted];
            }
            else {
                [subscriber sendError:error];
            }
            
        } error:^(NSError *error) {
            [subscriber sendError:error];
        }];
        
        return nil;
    }];
}

/*
 * This method fetchs user profile and transforms the response into the User class with Mantle and then
 * send the transformed user
 */
- (RACSignal *)getUser:(NSString *)username
{    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSString *getURL = [NSString stringWithFormat:@"/users/%@", username];
        [[[API sharedAPI] GET:getURL query:nil] subscribeNext:^(NSDictionary *response) {
            
            NSError *error = nil;
            User *user = [MTLJSONAdapter modelOfClass:User.class fromJSONDictionary:response error:&error];
            
            if (!error) {
                [subscriber sendNext:user];
                [subscriber sendCompleted];
            }
            else {
                [subscriber sendError:error];
            }
            
        } error:^(NSError *error) {
            [subscriber sendError:error];
        }];
        
        return nil;
    }];
}

@end