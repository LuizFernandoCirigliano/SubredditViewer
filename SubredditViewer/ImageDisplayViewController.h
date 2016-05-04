//
//  ImageDisplayViewController.h
//  SubredditViewer
//
//  Created by Luiz Fernando 2 on 5/2/16.
//  Copyright © 2016 CiriglianoApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RedditImage.h"

@interface ImageDisplayViewController : UIViewController

@property (strong, nonatomic) NSString *sourceURLString;
@property (strong, nonatomic) UIImage *tempImg;
@property (strong, nonatomic) RedditImage *redditImage;

@end
