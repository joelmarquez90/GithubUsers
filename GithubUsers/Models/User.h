//
//  Owner.h
//  GithubUsers
//
//  Created by Joel Márquez on 10/2/15.
//  Copyright (c) 2015 Joel. All rights reserved.
//

@interface User : MTLModel <MTLJSONSerializing>

@property (copy, nonatomic, readonly) NSNumber *ID;
@property (copy, nonatomic, readonly) NSNumber *publicRepos;
@property (copy, nonatomic, readonly) NSNumber *followers;
@property (copy, nonatomic, readonly) NSString *username;
@property (copy, nonatomic, readonly) NSString *name;
@property (copy, nonatomic, readonly) NSString *location;
@property (copy, nonatomic, readonly) NSString *email;
@property (copy, nonatomic, readonly) NSURL *avatarURL;
@property (copy, nonatomic, readonly) NSURL *profileURL;

@end