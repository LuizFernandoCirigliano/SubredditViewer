//
//  RedditDownloader.h
//  SubredditViewer
//
//  Created by Luiz Fernando 2 on 4/28/16.
//  Copyright © 2016 CiriglianoApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RedditImage.h"

@interface RedditDownloader : NSObject

-(id _Nonnull) initWithSubreddit:(NSString * _Nonnull)subreddit;

-(void) getNextPicturesWithCompletion:(void (^ _Nonnull)(NSArray * _Nullable , NSError * _Nullable))completion;

@end
