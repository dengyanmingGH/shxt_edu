//
//  ViewController.m
//  SHXT_EDU
//
//  Created by ccshxt on 16/4/24.
//  Copyright © 2016年 ccshxt. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UITextField *unameTf;
@property (strong, nonatomic) IBOutlet UITextField *upwdTf;
/* 当前选中的textField */
@property (nonatomic,retain) UITextField *textField;
@property (strong, nonatomic) IBOutlet UIButton *loginBtn;
@property (strong, nonatomic) NSMutableData *datas;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.unameTf.delegate = self;
    self.upwdTf.delegate = self;
    //按钮圆角设置
    self.loginBtn.layer.cornerRadius = self.loginBtn.frame.size.height/8.0;
}
- (IBAction)loginClick:(id)sender {
    NSLog(@"login btn click");
    NSString *uname = self.unameTf.text;
    NSString *upwd = self.upwdTf.text;
    NSString *urlStr = [[NSString alloc]initWithFormat:URL_USER_LOGIN,uname,upwd];
    //NSString *urlStr = [[NSString alloc]initWithFormat:URL_USER_LOGIN,@"dym",@"123123"];
    [CoreHttp getUrl:urlStr params:nil success:^(NSString *obj) {
        if(obj.length == 0){
            [self showLoginErr];
        }else{
            [self gotoMainTabViewController];
            [self setUserInfo:obj];
        }
    } errorBlock:^(CoreHttpErrorType errorType, NSString *errorMsg) {
        NSLog(@"get - error - %@",errorMsg);
    }];

}
//显示登录错误信息
-(void) showLoginErr{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"帐号密码有误，请重新输入！" preferredStyle:UIAlertControllerStyleAlert];
    //在代码块中可以填写具体这个按钮执行的操作
    UIAlertAction *defaultAction=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *actoin){}];
    [alert addAction:defaultAction]; //代码块前的括号是代码块返回的数据类型
    //回主线程更新ui
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController: alert animated:YES completion:nil];
    });
}
//用模态跳转到主界面
-(void) gotoMainTabViewController{
    //回主线程更新ui
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        id tabViewController = [storyboard instantiateViewControllerWithIdentifier:@"rootTab"];
        [self presentViewController:tabViewController animated:YES completion:^{}];
    });
}
-(BOOL) isUserInfoFileExist{
    NSFileManager * fm = [NSFileManager defaultManager];
    NSString *path = [self applicationDocumentDirectory];
    BOOL isExist = [fm fileExistsAtPath:path];
    return isExist;
}
-(void) setUserInfo:(NSString *)userId{
    NSString *path = [self applicationDocumentDirectory];
    NSDictionary *dictData ;
    if([self isUserInfoFileExist]){
        dictData = [[NSDictionary alloc]initWithContentsOfFile:path];
        [dictData setValue:userId forKey:@"userId"];
    }else{
        dictData = @{@"userId":userId};
    }
    [dictData writeToFile:path atomically:YES];
    
}
-(NSString *) applicationDocumentDirectory{
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [documentDirectory stringByAppendingString:@"userInfo.plist"];
    return path;
}

//textField被编辑时触发
-(void)textFieldDidBeginEditing:(UITextField *)textField{
     NSLog(@"textfield begin edit");
    self.textField = textField;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.textField resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
