//
//  ViewController.m
//  SubredditViewer
//
//  Created by Luiz Fernando 2 on 4/28/16.
//  Copyright © 2016 CiriglianoApps. All rights reserved.
//

#import "ViewController.h"
#import "RedditDownloader.h"
#import "ImageCollectionViewCell.h"
#import "ImageDisplayViewController.h"
#import "RMPZoomTransitionAnimator.h"
#import <Masonry/Masonry.h>

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, RMPZoomTransitionAnimating, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property CGFloat maxWidth;

@property (atomic) BOOL fetching;

@property (strong, nonnull) RedditDownloader *rd;
@property (strong, nonatomic) NSString *subName;
@property (strong, nonatomic) NSMutableArray *redditImages;


@end

@implementation ViewController

-(void)setSubName:(NSString *)subName {
    _subName = subName;
    self.rd = [[RedditDownloader alloc] initWithSubreddit:_subName];
    self.redditImages = [[NSMutableArray alloc] init];
    [self.collectionView reloadData];
    [self getMorePhotos];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(80, 80);
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.sectionInset = UIEdgeInsetsMake(20, 0, 20, 0);
    self.collectionView.collectionViewLayout = flowLayout;
    
    self.subName = @"roomporn";
    
    [self enableSearchButton];
    
    self.navigationController.delegate = self;
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.maxWidth = self.collectionView.frame.size.width;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Search Methods
-(void) enableSearchButton {
    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(menuItemSelected)];
    self.navigationItem.leftBarButtonItem = menuItem;
}

-(void) menuItemSelected {
    UIBarButtonItem *rightMenuItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(didConfirmSearch)];
    self.navigationItem.rightBarButtonItem = rightMenuItem;
    
    UIBarButtonItem *leftMenuItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(clearSearch)];
    self.navigationItem.leftBarButtonItem = leftMenuItem;
    
    UITextField *textField = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width, 21.0)];
    textField.placeholder = @"Enter a subreddit to ImgIT";
    self.navigationItem.titleView = textField;
    
    [textField becomeFirstResponder];
}

-(void) clearSearch {
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.titleView = nil;
    
    [self enableSearchButton];
}

-(void) didConfirmSearch {
    NSString *sub = ((UITextField *)self.navigationItem.titleView).text;
    if (sub.length > 0) {
        self.subName = sub;
    }
    [self clearSearch];
}

- (void) getMorePhotos {
    if (self.fetching) return;
    self.fetching = YES;
    [self.rd getNextPicturesWithCompletion:^(NSArray * _Nullable newPhotos, NSError * _Nullable error) {
        self.fetching = NO;
        if (!error) {
            NSInteger previousLen = self.redditImages.count;
            NSInteger newLen = newPhotos.count;
            
            NSMutableArray *indexes = [NSMutableArray array];
            
            for (NSInteger i = previousLen; i < previousLen + newLen; i++)
            {
                [indexes addObject:[NSIndexPath indexPathForItem:i inSection:0]];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView performBatchUpdates:^{
                    [self.redditImages addObjectsFromArray:newPhotos];
                    [self.collectionView insertItemsAtIndexPaths:indexes];
                } completion:nil];
            });
        }
    }];
}


#pragma mark - UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.redditImages.count;
}

//-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    CGSize origSize = [self.photos[indexPath.row] size];
//    
//    CGFloat width = origSize.width > self.maxWidth ? self.maxWidth - 0.1 : origSize.width;
//    CGFloat height = width * origSize.height/origSize.width;
//    
//    return CGSizeMake(width, height);
//}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"photoCell" forIndexPath:indexPath];
    RedditImage *img = self.redditImages[indexPath.row];
    
    cell.imageView.image = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *url = [NSURL URLWithString:img.thumbnailURLString];
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.imageView.image = [UIImage imageWithData:imageData];
        });
    });
    return cell;
}

#pragma mark - UICollectionView Delegate

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row > self.redditImages.count - 5) {
        [self getMorePhotos];
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageDisplayViewController *vc = [[ImageDisplayViewController alloc] init];
    UIImage *tempImg = ((ImageCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath]).imageView.image;
    vc.tempImg = tempImg;
    vc.sourceURLString = [self.redditImages[indexPath.row] sourceURLString];
    vc.redditImage = self.redditImages[indexPath.row];
    
    [self showViewController:vc sender:nil];
}
#pragma mark - View Delegate

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    self.maxWidth = size.width;
    [self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - Transition Protocol

- (UIImageView *)transitionSourceImageView
{
    NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
    ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:selectedIndexPath];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:cell.imageView.image];
    imageView.contentMode = cell.imageView.contentMode;
    imageView.clipsToBounds = YES;
    imageView.userInteractionEnabled = NO;
    imageView.frame = [cell.imageView convertRect:cell.imageView.frame toView:self.collectionView.superview];
    return imageView;
}

- (UIColor *)transitionSourceBackgroundColor
{
    return [UIColor blackColor];
}

- (CGRect)transitionDestinationImageViewFrame
{
    NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
    ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:selectedIndexPath];
    CGRect cellFrameInSuperview = [cell.imageView convertRect:cell.imageView.frame toView:self.collectionView.superview];
    return cellFrameInSuperview;
}


- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
    // minimum implementation for example
    RMPZoomTransitionAnimator *animator = [[RMPZoomTransitionAnimator alloc] init];
    animator.goingForward = (operation == UINavigationControllerOperationPush);
    animator.sourceTransition = (id<RMPZoomTransitionAnimating>)fromVC;
    animator.destinationTransition = (id<RMPZoomTransitionAnimating>)toVC;
    return animator;
}

@end
