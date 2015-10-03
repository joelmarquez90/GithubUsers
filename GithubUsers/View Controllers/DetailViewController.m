//
//  DetailViewController.m
//  GithubUsers
//
//  Created by Joel Márquez on 10/2/15.
//  Copyright (c) 2015 Joel. All rights reserved.
//

#import "DetailViewController.h"
#import "UsersManager.h"

#import "UIImageView+WebCache.h"

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *profileURLLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersLabel;
@property (weak, nonatomic) IBOutlet UILabel *repositoriesLabel;

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setModel:(User *)model
{
    _model = model;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setup];
}

- (void)setup
{
    self.title = self.model.username;

    self.nameLabel.text = @"";
    self.emailLabel.text = @"";
    self.locationLabel.text = @"";
    self.profileURLLabel.text = @"";
    self.followersLabel.text = @"";
    self.repositoriesLabel.text = @"";
    self.avatarImageView.hidden = YES;
    
    __weak DetailViewController *weakSelf = self;
    [self.avatarImageView sd_setImageWithURL:self.model.avatarURL
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        weakSelf.avatarImageView.hidden = NO;
    }];
    
    [self loadUserInfo];
}

/*
 * Loads and populates user info from the server
 */
- (void)loadUserInfo
{
    [[[UsersManager sharedInstance] getUser:self.model.username] subscribeNext:^(User *user) {
        self.nameLabel.text = user.name;
        self.emailLabel.text = user.email;
        self.locationLabel.text = user.location;
        self.profileURLLabel.text = [user.profileURL absoluteString];
        self.followersLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Followers: %@", nil), user.followers];
        self.repositoriesLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Public Repositories: %@", nil), user.publicRepos];
    }];
}

@end