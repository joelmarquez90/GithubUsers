//
//  Owner.m
//  GithubUsers
//
//  Created by Joel Márquez on 10/2/15.
//  Copyright (c) 2015 Joel. All rights reserved.
//

#import "User.h"

@implementation User

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
                 @"ID" : @"id",
                 @"publicRepos" : @"public_repos",
                 @"followers" : @"followers",
                 @"username" : @"login",
                 @"name" : @"name",
                 @"location" : @"location",
                 @"email" : @"email",
                 @"avatarURL" : @"avatar_url",
                 @"profileURL" : @"url"
             };
}

+ (NSValueTransformer *)avatarURLJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)profileURLJSONTransformer
{
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end