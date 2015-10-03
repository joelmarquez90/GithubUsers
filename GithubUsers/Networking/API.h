//
//  API.h
//  GithubUsers
//
//  Created by Joel Márquez on 10/2/15.
//  Copyright (c) 2015 Joel. All rights reserved.
//

@interface API : NSObject

+ (instancetype)sharedAPI;

- (RACSignal *)GET:(NSString *)endpoint query:(NSDictionary *)query;

@end