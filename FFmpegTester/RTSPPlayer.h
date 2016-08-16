//
//  RTSPObj_c.h
//  FFmpegTester
//
//  Created by Icebog,Hsieh on 7/21/16.
//  Copyright © 2016 Icebog,Hsieh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libavcodec/avcodec.h>
#import <libavformat/avformat.h>
#import <libswscale/swscale.h>
#import <UIKit/UIKit.h>

@interface RTSPPlayer : NSObject{
    AVFormatContext *pFormatCtx;
    AVCodecContext *pCodecCtx;
    AVFrame *pFrame;
    AVStream *stream;
    AVPacket packet;
    AVPicture picture;
    struct SwsContext *img_convert_ctx;
    int videoStream;
    int audioStream;
    int outputWidth;
    int outputHeight;
    int sourceWidth;
    int sourceHeight;
    UIImage *currentImage;
    double duration;
    double currentTime;
    double fps;
    BOOL isReleaseResources;
}


/* Output image size. Set to the source size by default. */
@property (nonatomic) int outputWidth, outputHeight;

/* Size of video frame */
@property (nonatomic, readonly) int sourceWidth, sourceHeight;

/* Last decoded picture as UIImage */
@property (nonatomic, readonly, nullable) UIImage *currentImage;

/* Length of video in seconds */
@property (nonatomic, readonly) double duration;

/* Current time of video in seconds */
@property (nonatomic, readonly) double currentTime;

@property (nonatomic, readonly) double fps;

-(id _Nonnull)initWithVideoPath:(NSString * _Nonnull)moviePath usesTcp:(BOOL)usesTcp;

/* Read the next frame from the video stream. Returns false if no frame read (video over). */
-(BOOL)stepFrame;

/* Seek to closest keyframe near specified time */
-(void)seekTime:(double)seconds;

-(void)releaseResources;

-(void)baseAddressFromCGImage:(CGImageRef _Nonnull)image completion:(void (^ _Nullable)(CGSize size, void* _Nonnull frameData))completion;



@end
