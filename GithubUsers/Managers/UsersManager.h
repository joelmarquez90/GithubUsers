//
//  RepositoriesManager.h
//  GithubUsers
//
//  Created by Joel Márquez on 10/2/15.
//  Copyright (c) 2015 Joel. All rights reserved.
//

@interface UsersManager : NSObject

+ (instancetype)sharedInstance;

- (RACSignal *)getUsers;
- (RACSignal *)getUser:(NSString *)username;

@end