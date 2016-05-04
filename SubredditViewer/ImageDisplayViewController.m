//
//  ImageDisplayViewController.m
//  SubredditViewer
//
//  Created by Luiz Fernando 2 on 5/2/16.
//  Copyright © 2016 CiriglianoApps. All rights reserved.
//

#import "ImageDisplayViewController.h"
#import <Masonry/Masonry.h>
#import "RMPZoomTransitionAnimator.h"

@interface ImageDisplayViewController () <UINavigationControllerDelegate, RMPZoomTransitionAnimating, RMPZoomTransitionDelegate>

@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation ImageDisplayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    
    [self.view addSubview:self.imageView];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.hidden = YES;
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:self.sourceURLString];
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = [UIImage imageWithData:imageData];
        });
    });

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) createExpandedImageView {
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
    [self.view addSubview:blurView];
    
    [blurView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - <RMPZoomTransitionAnimating>

- (UIImageView *)transitionSourceImageView
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.imageView.image];
    imageView.contentMode = self.imageView.contentMode;
    imageView.clipsToBounds = YES;
    imageView.userInteractionEnabled = NO;
    imageView.frame = self.imageView.frame;
    return imageView;
}

- (UIColor *)transitionSourceBackgroundColor
{
    return  [UIColor blackColor];
}

- (CGRect)transitionDestinationImageViewFrame
{
    CGSize frameSize = self.view.frame.size;
    CGSize imgSize = self.redditImage.size;
    CGFloat scale = MIN(frameSize.width/imgSize.width, frameSize.height/imgSize.height);
    CGFloat width = imgSize.width * scale;
    CGFloat height = imgSize.height * scale;
    
    CGFloat y = self.view.center.y - height/2;
    CGFloat x = self.view.center.x - width/2;
    CGRect frame = CGRectMake(x, y, width, height);
    return frame;
}

-(void)zoomTransitionAnimator:(RMPZoomTransitionAnimator *)animator didCompleteTransition:(BOOL)didComplete animatingSourceImageView:(UIImageView *)imageView {
    self.imageView.hidden = NO;
}

@end
