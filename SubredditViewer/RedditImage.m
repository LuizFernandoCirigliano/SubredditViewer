//
//  RedditImage.m
//  SubredditViewer
//
//  Created by Luiz Fernando 2 on 4/28/16.
//  Copyright © 2016 CiriglianoApps. All rights reserved.
//

#import "RedditImage.h"

@implementation RedditImage
-(id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        NSArray *postImages = [dict valueForKeyPath:@"data.preview.images"];
        if (postImages) {
            NSDictionary *photoDict = postImages[0];
            if (photoDict) {
                NSDictionary *sourceDict = photoDict[@"source"];
                
                CGFloat width = [sourceDict[@"width"] floatValue];
                CGFloat height = [sourceDict[@"height"] floatValue];

                NSString *sourceURL = sourceDict[@"url"];
                
                if (!width || !height || !sourceURL) return nil;
                self.size = CGSizeMake(width, height);
                self.sourceURLString = sourceURL;
                self.thumbnailURLString = [dict valueForKeyPath:@"data.thumbnail"];
            } else {
                return nil;
            }
        } else {
            return nil;
        }

    }
    return self;
}
@end
