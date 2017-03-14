//
//  QRViewController.m
//  QRWeiXinDemo
//
//  Created by Paul on 13/03/2017.
//  Copyright © 2017 Paul. All rights reserved.
//

#import "QRViewController.h"
#import "QRSourceHelper.h"
#import <AVFoundation/AVFoundation.h>
#import "QRView.h"
#import "HistoryListTableViewController.h"
#import "QRModel.h"
#import "DBManager.h"

@interface QRViewController ()<AVCaptureMetadataOutputObjectsDelegate,QRViewDelegate>

@property (strong, nonatomic) AVCaptureDevice * device;
@property (strong, nonatomic) AVCaptureDeviceInput * input;
@property (strong, nonatomic) AVCaptureMetadataOutput * output;
@property (strong, nonatomic) AVCaptureSession * session;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer * preview;
@property (strong, nonatomic) QRView *qrRectView;
@property (strong, nonatomic) UIButton *lightBtn;

@end

@implementation QRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [[DBManager sharedManager] createDatabaseWithName:HistoryListDB];
    [[DBManager sharedManager] addTableToDatabase:HistoryListDB withTBName:HistoryListTab model:[QRModel class]];
    [self checkAuthor];
}

-(void)checkAuthor
{
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authStatus)
    {
        case AVAuthorizationStatusNotDetermined:
        {
            [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted)
             {
                 [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                     dispatch_async(dispatch_get_main_queue(), ^{
                         
                         if(granted)
                         {
                             [self startScan];
                         }
                         else
                         {
                             NSString *tips = NSLocalizedString(@"AlertCameraMessage", @"提示语");
                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AlertCameraPrompt", @"提示标题") message:tips delegate:nil cancelButtonTitle:NSLocalizedString(@"AlertCameraSureBtnTitle", @"确定按钮") otherButtonTitles:nil];
                             [alert show];
                             [self.navigationController popViewControllerAnimated:YES];
                         }
                         
                     });
                 }];
             }];
            break;
        }
            
        case AVAuthorizationStatusRestricted:
        {
            [self.navigationController popViewControllerAnimated:YES];
            NSString *tips = NSLocalizedString(@"AlertCameraMessage", @"提示语");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AlertCameraPrompt", @"提示标题") message:tips delegate:nil cancelButtonTitle:NSLocalizedString(@"AlertCameraSureBtnTitle", @"确定按钮") otherButtonTitles:nil];
            [alert show];
            if(self.navigationController)
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            break;
        }
            
        case AVAuthorizationStatusDenied:
        {
            [self.navigationController popViewControllerAnimated:YES];
            NSString *tips = NSLocalizedString(@"AlertCameraMessageWithPath", @"权限打开路径提示");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AlertCameraPrompt", @"提示标题") message:tips delegate:nil cancelButtonTitle:NSLocalizedString(@"AlertCameraSureBtnTitle", @"确定") otherButtonTitles:nil];
            [alert show];
            if(self.navigationController)
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            break;
        }
            
        case AVAuthorizationStatusAuthorized:
        {
            [self startScan];
            break;
        }
    }
}

-(void)startScan
{
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    // 条码类型 AVMetadataObjectTypeQRCode
    _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
    // Preview
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:_session];
    _preview.videoGravity =AVLayerVideoGravityResize;
    _preview.frame =self.view.layer.bounds;
    [self.view.layer insertSublayer:_preview atIndex:0];
    [_session startRunning];

    CGRect screenRect = [UIScreen mainScreen].bounds;
    self.qrRectView = [[QRView alloc] initWithFrame:screenRect];
    self.qrRectView.transparentArea = CGSizeMake(150, 150);
    self.qrRectView.backgroundColor = [UIColor clearColor];
    self.qrRectView.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    self.qrRectView.delegate = self;
    [self.view addSubview:self.qrRectView];
    
    self.lightBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.qrRectView.frame.size.width - 60, 80, 40, 40)];
    [self.lightBtn setBackgroundImage:[UIImage imageNamed:@"green_light"] forState:UIControlStateNormal];
    [self.lightBtn addTarget:self action:@selector(lightClick:) forControlEvents:UIControlEventTouchUpInside];
    self.lightBtn.tag = 1003;
    [self.view addSubview:self.lightBtn];
    
    UIButton *recordListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    recordListBtn.frame = CGRectMake(0, 0, 80, 40);
    [recordListBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [recordListBtn setTitle:NSLocalizedString(@"ScanRecord", @"扫码记录") forState:UIControlStateNormal];
    [recordListBtn.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [recordListBtn addTarget:self action:@selector(historyListBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:recordListBtn];

    //修正扫描区域
    CGFloat screenHeight = self.view.frame.size.height;
    CGFloat screenWidth = self.view.frame.size.width;
    CGRect cropRect = CGRectMake((screenWidth - self.qrRectView.transparentArea.width) / 2,
                                 (screenHeight - self.qrRectView.transparentArea.height) / 2,
                                 self.qrRectView.transparentArea.width,
                                 self.qrRectView.transparentArea.height);

    [_output setRectOfInterest:CGRectMake(cropRect.origin.y / screenHeight,
                                          cropRect.origin.x / screenWidth,
                                          cropRect.size.height / screenHeight,
                                          cropRect.size.width / screenWidth)];
}

-(void)historyListBtnClick:(UIButton *)sender
{
    HistoryListTableViewController *historyList = [[HistoryListTableViewController alloc] init];
    [self.navigationController pushViewController:historyList animated:YES];
}

-(void)lightClick:(UIButton *)sender
{
    if(sender.tag == 1003)
    {
        [sender setBackgroundImage:[UIImage imageNamed:@"red_light"] forState:UIControlStateNormal];
        [self turnOnLed];
        sender.tag = 1004;
    }
    else
    {
        [sender setBackgroundImage:[UIImage imageNamed:@"green_light"] forState:UIControlStateNormal];
        [self turnOffLed];
        sender.tag = 1003;
    }
}

-(void)turnOffLed {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch])
    {
        [device lockForConfiguration:nil];
        [device setTorchMode: AVCaptureTorchModeOff];
        [device unlockForConfiguration];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AlertLightPrompt", @"提示标题") message:NSLocalizedString(@"AlertLightMessage", @"提示语") delegate:self cancelButtonTitle:NSLocalizedString(@"AlertLightSureBtnTitle", @"确定按钮") otherButtonTitles:nil];
        [alert show];
    }
}

-(void)turnOnLed {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch])
    {
        [device lockForConfiguration:nil];
        [device setTorchMode: AVCaptureTorchModeOn];
        [device unlockForConfiguration];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"AlertLightPrompt", @"提示标题") message:NSLocalizedString(@"AlertLightMessage", @"提示语") delegate:self cancelButtonTitle:NSLocalizedString(@"AlertLightSureBtnTitle", @"确定按钮") otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark QRViewDelegate
-(void)scanTypeConfig:(QRItem *)item
{
    CGRect screenRect = [UIScreen mainScreen].bounds;
    if (item.type == QRItemTypeQRCode)
    {
        [self.qrRectView removeFromSuperview];
        self.qrRectView = [[QRView alloc] initWithFrame:screenRect];
        self.qrRectView.transparentArea = CGSizeMake(150, 150);
        self.qrRectView.backgroundColor = [UIColor clearColor];
        self.qrRectView.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
        self.qrRectView.delegate = self;
        [self.view addSubview:self.qrRectView];
        _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
    }
    else if (item.type == QRItemTypeOther)
    {
        [self.qrRectView removeFromSuperview];
        self.qrRectView = [[QRView alloc] initWithFrame:screenRect];
        self.qrRectView.transparentArea = CGSizeMake(300, 60);
        self.qrRectView.backgroundColor = [UIColor clearColor];
        self.qrRectView.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
        self.qrRectView.delegate = self;
        [self.view addSubview:self.qrRectView];
        _output.metadataObjectTypes = @[AVMetadataObjectTypeEAN13Code,
                                        AVMetadataObjectTypeEAN8Code,
                                        AVMetadataObjectTypeCode128Code,
                                        AVMetadataObjectTypeQRCode];
    }
    [self.view bringSubviewToFront:self.lightBtn];
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    NSString *stringValue;
    if ([metadataObjects count] >0)
    {
        //stop scan
        [_session stopRunning];
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(finishScanWithContent:)])
    {
        QRModel *model = [[QRModel alloc] initWithDic:@{@"title":[self getCurrentDateString], @"detail":stringValue, @"remark":@"0"}];
        NSArray *arr = [[DBManager sharedManager] fetchAllDataFromDataBaseName:HistoryListDB tableName:HistoryListTab model:[QRModel new]];
        if(arr && arr.count > 0)
        {
            for (QRModel *objModel in arr)
            {
                if([objModel.detail isEqual:model.detail])
                {
                    [[DBManager sharedManager] deleteDataFromDatabase:HistoryListDB tableName:HistoryListTab model:objModel];
                    break;
                }
            }
            [[DBManager sharedManager] insertDataToDatabase:HistoryListDB tableName:HistoryListTab model:model];
        }
        else
        {
            [[DBManager sharedManager] insertDataToDatabase:HistoryListDB tableName:HistoryListTab model:model];
        }
        [self.delegate finishScanWithContent:stringValue];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSString *)getCurrentDateString
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"YYYY/MM/dd/hh:mm:ss"];
    return [formatter stringFromDate:date];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
