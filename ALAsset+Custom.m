//
//  ALAsset+Custom.m
//
//  Created by ZQP on 14-7-8.
//


#import "ALAsset+Custom.h"

@implementation ALAsset (Custom)


-(UIImage *)originalImage{
    
    ALAssetRepresentation* rep = [self defaultRepresentation];
                   
    
    Byte* buf = malloc((long)[rep size]);
   
    NSError* err = nil;
    
    NSUInteger bytes = [rep getBytes:buf fromOffset:0LL
                              length:(int)[rep size] error:&err];
    if (err||bytes == 0) {
        NSLog(@"eror bytes");
            return nil;
        }
    NSData *photoData = [[NSData alloc] initWithBytes:buf length:(long)rep.size];
    UIImage *Image=[[UIImage alloc]initWithData:photoData];
    return Image;
    free(buf);

}
-(void)deleteAsset{
    [self setImageData:nil metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
        
    }];

}
-(void)saveModifiedImage:(UIImage*)image{
    [self writeModifiedImageDataToSavedPhotosAlbum:UIImageJPEGRepresentation(image, 1) metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
        
    }];
}
@end