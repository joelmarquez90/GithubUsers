//
//  SubtitleTableViewCell.m
//  GithubUsers
//
//  Created by Joel Márquez on 10/3/15.
//  Copyright (c) 2015 Joel. All rights reserved.
//

#import "SubtitleTableViewCell.h"

#import "UIImageView+WebCache.h"

@implementation SubtitleTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    return [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
}

- (void)setModel:(User *)model
{
    _model = model;
    
    self.textLabel.text = model.username;
    self.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Id: %@", nil), model.ID];
    [self.imageView sd_setImageWithURL:model.avatarURL];
}

- (void)prepareForReuse
{
    self.imageView.image = nil;
    self.textLabel.text = nil;
    self.detailTextLabel.text = nil;
}

@end