//
//  RedditDownloader.m
//  SubredditViewer
//
//  Created by Luiz Fernando 2 on 4/28/16.
//  Copyright © 2016 CiriglianoApps. All rights reserved.
//

#import "RedditDownloader.h"

@interface RedditDownloader ()

@property (strong, nonatomic) NSString *subreddit;
@property (strong, nonatomic) NSString *after;
@property (nonatomic) NSInteger count;

@end


@implementation RedditDownloader

-(id) initWithSubreddit:(NSString *)subreddit {
    self = [super init];
    if (self) {
        self.subreddit = subreddit;
        self.count = 0;
    }
    return self;
}

-(NSArray *) getPhotoArrayFromJSON:(NSDictionary *)redditJSON {
    self.after = [redditJSON valueForKeyPath:@"data.after"];
    NSArray *posts = [redditJSON valueForKeyPath:@"data.children"];
    self.count += posts.count;
    NSMutableArray *photos = [NSMutableArray array];
    
    for (NSDictionary *post in posts) {
        RedditImage *img = [[RedditImage alloc] initWithDictionary:post];
        if (img) [photos addObject:img];
    }
    
    return photos;
}

-(void) getNextPicturesWithCompletion:(void (^)(NSArray * , NSError *))completion {
    NSString *string = [NSString stringWithFormat:@"https://reddit.com/r/%@.json", self.subreddit];
    if (self.after) {
        string = [string stringByAppendingString:[NSString stringWithFormat:@"?count=%ld&after=%@", self.count, self.after]];
    }
    
    NSURL *url = [NSURL URLWithString:string];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
            completion(nil , error);
        } else {
            NSError *jsonError = nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            
            if (jsonError) {
                NSLog(@"%@", [jsonError localizedDescription]);
                completion(nil, jsonError);
            } else {
                NSArray *photos = [self getPhotoArrayFromJSON:json];
                completion(photos, nil);
            }
        }
    }];
    [task resume];
}

@end
