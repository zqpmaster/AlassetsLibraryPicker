//
//  ALAssetsLibrary category to handle a custom photo album
//
//  Created by ZQP on 14-7-8.
//


#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "Utility.h"
@implementation ALAssetsLibrary(CustomPhotoAlbum)

-(void)saveImage:(UIImage*)image toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock withFailureBlock:(SaveImageFailure)failureBlock
{
    //write the image data to the assets library (camera roll)
    [self writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation 
                        completionBlock:^(NSURL* assetURL, NSError* error) {
                              
                          //error handling
                          if (error!=nil) {
                              completionBlock(assetURL);
                              return;
                          }

                          //add the asset to the custom photo album
                          [self addAssetURL: assetURL 
                                    toAlbum:albumName 
                        withCompletionBlock:completionBlock withFailureBlock:failureBlock];
                          
                      }];
}

-(void)addAssetURL:(NSURL*)assetURL toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock withFailureBlock:(SaveImageFailure)failureBlock
{
    __block BOOL albumWasFound = NO;
    
    //search all photo albums in the library
    [self enumerateGroupsWithTypes:ALAssetsGroupAlbum 
                        usingBlock:^(ALAssetsGroup *group, BOOL *stop) {

                            //compare the names of the albums
                            if ([albumName compare: [group valueForProperty:ALAssetsGroupPropertyName]]==NSOrderedSame) {
                                
                                //target album is found
                                albumWasFound = YES;
                                
                                //get a hold of the photo's asset instance
                                [self assetForURL: assetURL 
                                      resultBlock:^(ALAsset *asset) {
                                                  
                                          //add photo to the target album
                                          [group addAsset: asset];
                                          
                                          //run the completion block
                                          completionBlock(assetURL);
                                          
                                      } failureBlock: failureBlock];

                                //album was found, bail out of the method
                                return;
                            }
                            
                            if (group==nil && albumWasFound==NO) {
                                //photo albums are over, target album does not exist, thus create it
                                
                                __weak ALAssetsLibrary* weakSelf = self;

                                //create new assets album
                                [self addAssetsGroupAlbumWithName:albumName 
                                                      resultBlock:^(ALAssetsGroup *group) {
                                                                  
                                                          //get the photo's instance
                                                          [weakSelf assetForURL: assetURL 
                                                                        resultBlock:^(ALAsset *asset) {

                                                                            //add photo to the newly created album
                                                                            [group addAsset: asset];
                                                                            
                                                                            //call the completion block
                                                                            completionBlock(assetURL);

                                                                        } failureBlock: failureBlock];
                                                          
                                                      } failureBlock: failureBlock];

                                //should be the last iteration anyway, but just in case
                                return;
                            }
                            
                        } failureBlock: failureBlock];
    
}
-(void)assetsGroupForGroupName:(NSString *)name withResult:(void (^)(ALAssetsGroup *))resultBlock{
    [self  enumerateGroupsWithTypes:ALAssetsGroupAll
                        usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                            
                            //compare the names of the albums
//                            if ([name compare: [group valueForProperty:ALAssetsGroupPropertyName]]==NSOrderedSame) {
                            if ([name isEqualToString:[group valueForProperty:ALAssetsGroupPropertyName]]) {

                                resultBlock(group);
                                return;
                            }
                        }failureBlock:^(NSError *error) {
                            resultBlock(nil);
                            NSLog(@"访问相册出错");
//                            NSAssert(NO, @"访问相册出错");
                            [[NSNotificationCenter defaultCenter] postNotificationName:CamForbidNotification object:nil];
                            
                        }];
    

}

@end
