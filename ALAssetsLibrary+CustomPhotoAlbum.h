//
//  ALAssetsLibrary category to handle a custom photo album
//
//  Created by ZQP on 14-7-8.
//


#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef void(^SaveImageCompletion)(NSURL* url);
typedef void(^SaveImageFailure)(NSError* error);


@interface ALAssetsLibrary(CustomPhotoAlbum)

-(void)saveImage:(UIImage*)image toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock withFailureBlock:(SaveImageFailure)failureBlock;
-(void)addAssetURL:(NSURL*)assetURL toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock withFailureBlock:(SaveImageFailure)failureBlock;
-(void)assetsGroupForGroupName:(NSString *)name withResult: (void(^)(ALAssetsGroup *group))resultBlock;

@end