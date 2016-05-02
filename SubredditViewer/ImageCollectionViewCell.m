//
//  ImageCollectionViewCell.m
//  SubredditViewer
//
//  Created by Luiz Fernando 2 on 4/28/16.
//  Copyright © 2016 CiriglianoApps. All rights reserved.
//

#import "ImageCollectionViewCell.h"
#import <Masonry/Masonry.h>

@implementation ImageCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.imageView =  [[UIImageView alloc] initWithFrame:self.contentView.frame];
    
    [self addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    self.backgroundColor = [UIColor greenColor];
}

@end
