//
//  SHKTencentWeixin.m
//  ShareKit
//
//  Created by icyleaf on 12-11-2.
//  Copyright 2012 icyleaf.com. All rights reserved.
//

//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//

#import "SHKTencentWeixin.h"
#import "SHKConfiguration.h"

@interface SHKTencentWeixin ()

@end

static NSString *const kSHKTencentWeixinUserInfo = @"kSHKTencentWeixinUserInfo";

@implementation SHKTencentWeixin


+ (SHKTencentWeixin *)sharedWeixin
{
    static SHKTencentWeixin *weixin = nil;
    @synchronized([SHKTencentWeixin class]) {
        if ( ! weixin)
        {
            weixin = [[SHKTencentWeixin alloc] init];
        }
    }
    
    return weixin;
}

+ (void)registerApp
{
    [WXApi registerApp:SHKCONFIG(tencentWeixinAppId)];
}

+ (BOOL)handleOpenURL:(NSURL*)url
{
    return [WXApi handleOpenURL:url delegate:[[[SHKTencentWeixin alloc] init] autorelease]];
}


#pragma mark -
#pragma mark Configuration : Service Defination

+ (NSString *)sharerTitle
{
	return @"微信";
}

+ (BOOL)canShareURL
{
	return ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]);
}

+ (BOOL)canShareText
{
    if ([WXApi isWXAppInstalled]) {
        NSLog(@"isWXAppInstalled");
    }
    
    if ([WXApi isWXAppSupportApi]) {
         NSLog(@"isWXAppSupportApi");
    }
    
	return ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]);
}

+ (BOOL)canShareImage
{
    return ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]);
}


#pragma mark -
#pragma mark Configuration : Dynamic Enable

- (BOOL)shouldAutoShare
{
	return NO;
}

#pragma mark -
#pragma mark Authorization

+ (void)logout
{
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:kSHKTencentWeixinUserInfo];
	[super logout];
}

- (BOOL)isAuthorized
{
    return YES;
}

#pragma mark -
#pragma mark UI Implementation

- (void)show
{
    if (item.shareType == SHKShareTypeURL)
	{
		[item setCustomValue:[NSString stringWithFormat:@"%@: %@", item.title, [item.URL absoluteString]] forKey:@"status"];
	}
	
	else if (item.shareType == SHKShareTypeImage)
	{
		[item setCustomValue:item.title forKey:@"status"];
	}
	
	else if (item.shareType == SHKShareTypeText)
	{
		[item setCustomValue:item.text forKey:@"status"];
	}
    
    [self showTencentWeixinForm];
}

- (void)showTencentWeixinForm
{
    SHKFormControllerLargeTextField *rootView = [[SHKFormControllerLargeTextField alloc] initWithNibName:nil bundle:nil delegate:self];
    
	rootView.text = [item customValueForKey:@"status"];
	rootView.maxTextLength = 140;
	rootView.image = item.image;
	rootView.imageTextLength = 25;
	
	self.navigationBar.tintColor = SHKCONFIG_WITH_ARGUMENT(barTintForView:,self);
	
	[self pushViewController:rootView animated:NO];
	[rootView release];
	
	[[SHK currentHelper] showViewController:self];
}

- (void)sendForm:(SHKFormControllerLargeTextField *)form
{
    item.text = form.textView.text;
	[self tryToSend];
}


#pragma mark -
#pragma mark Share API Methods

- (BOOL)validateItem
{
	if (self.item.shareType == SHKShareTypeUserInfo) {
		return YES;
	}
	
	NSString *status = [item customValueForKey:@"status"];
	return status != nil;
}

- (BOOL)validateItemAfterUserEdit
{
	BOOL result = NO;
	
	BOOL isValid = [self validateItem];
	NSString *status = [item customValueForKey:@"status"];
	
	if (isValid && status.length <= 140) {
		result = YES;
	}
	
	return result;
}

- (BOOL)send
{
	if ( ! [self validateItemAfterUserEdit])
		return NO;
	
    switch (item.shareType) {
            
        case SHKShareTypeURL:
        case SHKShareTypeText:
            [self sendStatus];
            break;
    
        case SHKShareTypeImage:
            [self sendImage];
            break;
		default:
			break;
	}
	
	// Notify delegate
	[self sendDidStart];	
	
	return YES;
}

- (void)sendStatus
{
    SendMessageToWXReq *req = [[[SendMessageToWXReq alloc] init] autorelease];
    req.bText = YES;
    req.text = [item customValueForKey:@"status"];
    
    [WXApi sendReq:req];
}

- (void)sendImage
{
    CGFloat compression = 0.9f;
	NSData *imageData = UIImageJPEGRepresentation([item image], compression);
	
	// TODO
	// Note from Nate to creator of sendImage method - This seems like it could be a source of sluggishness.
	// For example, if the image is large (say 3000px x 3000px for example), it would be better to resize the image
	// to an appropriate size (max of img.ly) and then start trying to compress.
	
	while ([imageData length] > 32000 && compression > 0.1) {
		// NSLog(@"Image size too big, compression more: current data size: %d bytes",[imageData length]);
		compression -= 0.1;
		imageData = UIImageJPEGRepresentation([item image], compression);
	}
    
    WXMediaMessage *message = [WXMediaMessage message];
    [message setThumbImage:item.image];
    [message setTitle:[item customValueForKey:@"status"]];
    
    // Real size image
    WXEmoticonObject *ext = [WXEmoticonObject object];
    ext.emoticonData = UIImagePNGRepresentation(item.image);
    
    message.mediaObject = ext;
    
    SendMessageToWXReq *req = [[[SendMessageToWXReq alloc] init] autorelease];
    req.bText = NO;
    req.message = message;
    
    [WXApi sendReq:req];
}


#pragma mark - Weixin delegate methods

- (void)onResp:(BaseResp *)resp
{
    if (resp.errCode == 0) {
        // success
        [self sendDidFinish];
    }
    
    else {
        // fail
        [self sendDidFailWithError:[SHK error:resp.errStr]];
    }
}
@end

