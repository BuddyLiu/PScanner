//
//  ViewController.m
//  ScanDemo
//
//  Created by Paul on 27/02/2017.
//  Copyright © 2017 Paul. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "QRViewController.h"

@interface ViewController ()<QRViewControllerDelegate>

@property (nonatomic, strong) UIButton *scanBtn;
@property (nonatomic, strong) UILabel *scanContentLabel;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    CFShow((__bridge CFTypeRef)(infoDictionary));
    // app名称
    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    self.navigationItem.title = app_Name;
    self.scanContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 80 + 64, [UIScreen mainScreen].bounds.size.width - 20, 120)];
    self.scanContentLabel.numberOfLines = 0;
    [self.scanContentLabel setAdjustsFontSizeToFitWidth:YES];
    self.scanContentLabel.textColor = [UIColor blackColor];
    self.scanContentLabel.text = @"点击下方按钮";
    self.scanContentLabel.textColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
    self.scanContentLabel.textAlignment = NSTextAlignmentCenter;
    self.scanContentLabel.clipsToBounds = YES;
    self.scanContentLabel.layer.cornerRadius = 5;
    self.scanContentLabel.layer.borderWidth = 1.5;
    self.scanContentLabel.layer.borderColor = [[UIColor greenColor] colorWithAlphaComponent:0.3].CGColor;
    self.scanContentLabel.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:self.scanContentLabel];
    
    self.scanBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/4.0, self.view.frame.size.height/2.0, self.view.frame.size.width/2.0, self.view.frame.size.width/2.0)];
    self.scanBtn.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.3];
    self.scanBtn.clipsToBounds = YES;
    self.scanBtn.layer.cornerRadius = self.view.frame.size.width/4.0;
    self.scanBtn.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    self.scanBtn.layer.borderWidth = 1.5;
    [self.scanBtn setTitle:@"开始扫描" forState:UIControlStateNormal];
    [self.scanBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.scanBtn addTarget:self action:@selector(scanBtnClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.scanBtn];

}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder)to:nil from:nil forEvent:nil];
}

-(void)scanBtnClickAction:(UIButton *)sender
{
    QRViewController *qRvc = [[QRViewController alloc] init];
    qRvc.delegate = self;
    [self.navigationController pushViewController:qRvc animated:YES];
}

-(void)finishScanWithContent:(NSString *)scanContent
{
    if(scanContent && self.scanContentLabel)
    {
        [self.scanContentLabel setText:scanContent];
        self.scanContentLabel.textColor = [UIColor blackColor];
        if(([self.scanContentLabel.text rangeOfString:@"http://"].length > 0)
           || ([self.scanContentLabel.text rangeOfString:@"https://"].length > 0))
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"扫码内容已复制！\n是否确定打开该链接！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消",nil];
            alert.tag = 8790;
            [alert show];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"扫码内容已复制！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消",nil];
            alert.tag = 8791;
            [alert show];
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"未检测到二维码！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        alert.tag = 8791;
        [alert show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 8790)
    {
        if(buttonIndex == 0)
        {
            if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:self.scanContentLabel.text]])
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.scanContentLabel.text]];
            }
        }
        else
        {
            //nothing to do
        }
    }
    else
    {
        self.scanContentLabel.text = @"点击下方按钮";
        self.scanContentLabel.textColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
