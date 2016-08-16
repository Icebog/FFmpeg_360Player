//
//  RTSPObj_c.m
//  FFmpegTester
//
//  Created by Icebog,Hsieh on 7/21/16.
//  Copyright © 2016 Icebog,Hsieh. All rights reserved.
//

#import "RTSPPlayer.h"

@implementation RTSPPlayer

@synthesize outputWidth, outputHeight;

-(void)setOutputWidth:(int)newValue{
    if (outputWidth != newValue) {
        outputWidth = newValue;
        [self setupScaler];
    }
}

-(void)setOutputHeight:(int)newValue{
    if (outputHeight != newValue) {
        outputHeight = newValue;
        [self setupScaler];
    }
}

- (int)sourceWidth{
    return pCodecCtx->width;
}

- (int)sourceHeight{
    return pCodecCtx->height;
}


-(UIImage *)currentImage{
    if (!pFrame->data[0]) return nil;
    [self convertFrameToRGB];
    return [self imageFromAVPicture:picture width:outputWidth height:outputHeight];
}


-(double)duration{
    return (double)pFormatCtx->duration / AV_TIME_BASE;
}

-(double)currentTime{
    AVRational timeBase = pFormatCtx->streams[videoStream]->time_base;
    return packet.pts * (double)timeBase.num / timeBase.den;
}

-(double)fps {
    return fps;
}

-(id)initWithVideoPath:(NSString *)moviePath usesTcp:(BOOL)usesTcp {
    if (!(self=[super init])) return nil;
    
    isReleaseResources = NO;
    
    AVCodec *pCodec;
    
    // Register all formats and codecs
    avcodec_register_all();
    av_register_all();
    avformat_network_init();
    
    AVDictionary *opts = 0;
    if (usesTcp){
        av_dict_set(&opts, "rtsp_transport", "tcp", 0);
    }
    
    if (avformat_open_input(&pFormatCtx, [moviePath UTF8String], NULL, &opts) !=0 ) {
        av_log(NULL, AV_LOG_ERROR, "Couldn't open file\n");
        goto initError;
    }
    
    // Retrieve stream information
    if (avformat_find_stream_info(pFormatCtx,NULL) < 0) {
        av_log(NULL, AV_LOG_ERROR, "Couldn't find stream information\n");
        goto initError;
    }
    
    // Find the first video stream
    videoStream=-1;
    audioStream=-1;
    
    for (int i=0; i<pFormatCtx->nb_streams; i++) {
        if (pFormatCtx->streams[i]->codec->codec_type==AVMEDIA_TYPE_VIDEO) {
            NSLog(@"found video stream");
            videoStream=i;
        }
        
        //        if (pFormatCtx->streams[i]->codec->codec_type==AVMEDIA_TYPE_AUDIO) {
        //            audioStream=i;
        //            NSLog(@"found audio stream");
        //        }
    }
    
    // Get a pointer to the codec context for the video stream
    stream = pFormatCtx->streams[videoStream];
    pCodecCtx = stream->codec;
    
    //Find stream fps
    if(stream->avg_frame_rate.den && stream->avg_frame_rate.num) {
        fps = av_q2d(stream->avg_frame_rate);
    } else {
        fps = 30;
    }
    
    // Find the decoder for the video stream
    pCodec = avcodec_find_decoder(pCodecCtx->codec_id);
    if (pCodec == NULL) {
        av_log(NULL, AV_LOG_ERROR, "Unsupported codec!\n");
        goto initError;
    }
    
    // Open codec
    if (avcodec_open2(pCodecCtx, pCodec, NULL) < 0) {
        av_log(NULL, AV_LOG_ERROR, "Cannot open video decoder\n");
        goto initError;
    }
    
    //    if (audioStream > -1 ) {
    //        NSLog(@"set up audiodecoder");
    //        [self setupAudioDecoder];
    //    }
    
    
    // Allocate video frame
    pFrame = av_frame_alloc();
    
    outputWidth = pCodecCtx->width;
    outputHeight = pCodecCtx->height;
    
    [self setupScaler];
    
    return self;
    
initError:
    return nil;
}

-(void)seekTime:(double)seconds{
    AVRational timeBase = pFormatCtx->streams[videoStream]->time_base;
    int64_t targetFrame = (int64_t)((double)timeBase.den / timeBase.num * seconds);
    avformat_seek_file(pFormatCtx, videoStream, targetFrame, targetFrame, targetFrame, AVSEEK_FLAG_FRAME);
    avcodec_flush_buffers(pCodecCtx);
}


-(void)setupScaler{
    
    // Release old picture and scaler
    avpicture_free(&picture);
    sws_freeContext(img_convert_ctx);
    
    // Allocate RGB picture
    avpicture_alloc(&picture, PIX_FMT_RGB24, outputWidth, outputHeight);
    
    // Setup scaler
    static int sws_flags =  SWS_FAST_BILINEAR;
    img_convert_ctx = sws_getContext(pCodecCtx->width,
                                     pCodecCtx->height,
                                     pCodecCtx->pix_fmt,
                                     outputWidth,
                                     outputHeight,
                                     PIX_FMT_RGB24,
                                     sws_flags, NULL, NULL, NULL);
    
}

-(BOOL)stepFrame{
    // AVPacket packet;
    int frameFinished=0;
    
    while (!frameFinished && av_read_frame(pFormatCtx, &packet) >=0 ) {
        // Is this a packet from the video stream?
        if(packet.stream_index==videoStream) {
            // Decode video frame
            avcodec_decode_video2(pCodecCtx, pFrame, &frameFinished, &packet);
        }
    }
    
    if (frameFinished == 0 && isReleaseResources == NO) {
        [self releaseResources];
    }
    
    return frameFinished != 0;
}

-(void)convertFrameToRGB{
    sws_scale(img_convert_ctx,
              pFrame->data,
              pFrame->linesize,
              0,
              pCodecCtx->height,
              picture.data,
              picture.linesize);
}

-(UIImage *)imageFromAVPicture:(AVPicture)pict width:(int)width height:(int)height{
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, pict.data[0], pict.linesize[0]*height,kCFAllocatorNull);
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef cgImage = CGImageCreate(width,
                                       height,
                                       8,
                                       24,
                                       pict.linesize[0],
                                       colorSpace,
                                       bitmapInfo,
                                       provider,
                                       NULL,
                                       NO,
                                       kCGRenderingIntentDefault);
    CGColorSpaceRelease(colorSpace);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    
    CGImageRelease(cgImage);
    CGDataProviderRelease(provider);
    CFRelease(data);
    
    return image;
}

-(void)baseAddressFromCGImage:(CGImageRef)image completion:(void (^ __nullable)(CGSize size, void* frameData))completion{
    
    CGSize frameSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    
    CVPixelBufferRef pixelBuffer;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, frameSize.width,
                                          frameSize.height,  kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                                          &pixelBuffer);
    if (status == kCVReturnSuccess) {
        CVPixelBufferLockBaseAddress(pixelBuffer,kCVPixelBufferLock_ReadOnly);
        
        void *data = CVPixelBufferGetBaseAddress(pixelBuffer);
                
        if (completion != nil){
            completion(frameSize,data);
        }
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer,kCVPixelBufferLock_ReadOnly);
    }
    
    
    
}


//-(void*)baseAddressFromCGImage:(CGImageRef)image{
//    CGSize frameSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
//    
//    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
//                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
//                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
//                             nil];
//    
//    CVPixelBufferRef pixelBuffer;
//    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, frameSize.width,
//                                          frameSize.height,  kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
//                                          &pixelBuffer);
//    if (status != kCVReturnSuccess) {
//        return NULL;
//    }
//    
//    CVPixelBufferLockBaseAddress(pixelBuffer,kCVPixelBufferLock_ReadOnly);
//    void *data = CVPixelBufferGetBaseAddress(pixelBuffer);
//    
//    //    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
//    //    CGContextRef context = CGBitmapContextCreate(data, frameSize.width, frameSize.height,
//    //                                                 8, CVPixelBufferGetBytesPerRow(pixelBuffer), rgbColorSpace,
//    //                                                 (CGBitmapInfo) kCGImageAlphaNoneSkipLast);
//    //    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
//    //                                           CGImageGetHeight(image)), image);
//    //
//    //    CGColorSpaceRelease(rgbColorSpace);
//    //    CGContextRelease(context);
//    
//    CVPixelBufferUnlockBaseAddress(pixelBuffer,kCVPixelBufferLock_ReadOnly);
//    
//    return data;
//}

#pragma mark - releaseResources
-(void)releaseResources {
    // Free scaler
    sws_freeContext(img_convert_ctx);
    
    // Free RGB picture
    avpicture_free(&picture);
    
    // Free the packet that was allocated by av_read_frame
    //    av_free_packet(&packet);
    
    // Free the YUV frame
    av_free(pFrame);
    
    // Close the codec
    if (pCodecCtx) avcodec_close(pCodecCtx);
    
    // Close the video file
    if (pFormatCtx) avformat_close_input(&pFormatCtx);
    
}

@end
