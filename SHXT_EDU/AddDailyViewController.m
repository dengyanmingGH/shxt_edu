//
//  AddDailyViewController.m
//  SHXT_EDU
//
//  Created by ccshxt on 16/5/5.
//  Copyright © 2016年 ccshxt. All rights reserved.
//

#import "AddDailyViewController.h"

@interface AddDailyViewController ()
@property (nonatomic,strong)  NSArray *classArray;
@property (strong, nonatomic) IBOutlet UIView *classNameView;
@property (strong, nonatomic) IBOutlet UIView *timeSelectView;
@property (strong, nonatomic) IBOutlet UITextField *className;
@property (strong, nonatomic) IBOutlet UITextField *beginTime;
@property (strong, nonatomic) IBOutlet UITextField *endTime;
@property (strong, nonatomic) UITextField *editingTf;
@property (strong, nonatomic) UIView *editingView;
@property (strong, nonatomic) UITapGestureRecognizer *singleTap;
@property (strong, nonatomic) IBOutlet UILabel *dailyLabel;
@property (strong, nonatomic) IBOutlet UIButton *cancelBtn;
@property (strong, nonatomic) IBOutlet UIButton *submitBtn;
@property (strong, nonatomic) IBOutlet UIPickerView *classNamePicker;
@property (strong, nonatomic) IBOutlet UIDatePicker *timeSelectDp;
@property (strong, nonatomic) IBOutlet UITextField *courseKPTf;


@property (strong, nonatomic) NSString *classYear;
@property (strong, nonatomic) NSString *classNum;
@property (strong, nonatomic) NSString *workDay;
@end

@implementation AddDailyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.classNameView.hidden = YES;
    //------------------------------------------------------------//
    [self getAllClass];
    //------------------------------------------------------------//
    //单击监听设置
    _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenEditingView)];
    //初始化日报label
    NSDate *current = [[NSDate alloc]init];
    //时间格式化
    NSDateFormatter *form = [[NSDateFormatter alloc] init]; // 定义时间格式
    [form setDateFormat:@"yyyy-MM-dd"];
    self.workDay = [form stringFromDate:current];
    self.dailyLabel.text = [NSString stringWithFormat:@"%@-%@", self.workDay,@"日报"];
    //按钮圆角设置
    self.cancelBtn.layer.cornerRadius = self.cancelBtn.frame.size.height/8.0;
    self.submitBtn.layer.cornerRadius = self.submitBtn.frame.size.height/8.0;
    
}

-(void)getAllClass{
    NSString *path = [self applicationDocumentDirectory];
    NSDictionary *dict = [[NSDictionary alloc]initWithContentsOfFile:path];
    NSString *urlStr = [[NSString alloc]initWithFormat:URL_TEACHER_GETALLCLASS,[dict objectForKey:@"userId"]];
    [CoreHttp getUrl:urlStr params:nil success:^(NSString *obj) {
        if(obj.length == 0){
            NSLog(@"AddDailyViewController - getAllClass : 没有查到数据");
        }else{
            NSData *data = [obj dataUsingEncoding:NSUTF8StringEncoding];
            self.classArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        }
    } errorBlock:^(CoreHttpErrorType errorType, NSString *errorMsg) {
        NSLog(@"get - error - %@",errorMsg);
    }];
}

-(void)hiddenEditingView{
    //隐藏被当前被编辑的picker视图
    self.editingView.hidden = YES;
    //设置textfield选择的时间
     if(![self.editingTf.restorationIdentifier  isEqual: @"classNameTf"]){
         //时间格式化
         NSDateFormatter *form = [[NSDateFormatter alloc] init]; // 定义时间格式
        [form setDateFormat:@"HH:mm:ss"];
        self.editingTf.text = [form stringFromDate:self.timeSelectDp.date];
     }
    [self.editingTf resignFirstResponder];
}

//选择器中拨轮的数量
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
//选择器中某个拨轮的行数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.classArray count];
}		
//为选择器中某个拨轮的行提供显示数据
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    NSDictionary *dict = [self.classArray objectAtIndex:row];
    self.classYear = [dict objectForKey:@"SHXTYEAR"];
    self.classNum = [dict objectForKey:@"CLASSNUMBER"];
    return [dict objectForKey:@"SHNAME"];
}
//选中选择器的某个拨轮中的某行时调用
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
     NSDictionary *dict = [self.classArray objectAtIndex:row];
    self.className.text = [dict objectForKey:@"SHNAME"];
}
- (IBAction)dailySubmit:(UIButton *)sender {
    NSString *path = [self applicationDocumentDirectory];
    NSString *userId = [[[NSDictionary alloc]initWithContentsOfFile:path] objectForKey:@"userId"];
    NSDictionary *dict = @{@"classname":self.classYear,@"classnumber":self.classNum,@"stage":@"0",@"classtimestart":self.beginTime.text,@"classtimeend":self.endTime.text,@"classcontent":self.courseKPTf.text,@"memo":self.courseKPTf.text,@"workday":self.workDay,@"uid":userId};
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    [CoreHttp postUrl:URL_TEACHER_DAILY_ADD params:@{@"oper":@"add",@"journal":jsonStr} success:^(NSString *obj) {
        if(obj.length == 0){
            NSLog(@"AddDailyViewController - dailySubmit : 数据提交失败");
        }else{
            //回主线程更新ui
            dispatch_async(dispatch_get_main_queue(), ^{
                //返回上一viewController
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        }
    } errorBlock:^(CoreHttpErrorType errorType, NSString *errorMsg) {
        NSLog(@"post - error - %@",errorMsg);
    }];


    
}
- (IBAction)dailyCancel:(id)sender {
    //返回上一viewController
    [self dismissViewControllerAnimated:YES completion:nil];
}
//textField被编辑时触发
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"textfield begin edit");
    if([textField.restorationIdentifier  isEqual: @"classNameTf"]){
        self.editingTf = self.className;
        self.editingView = self.classNameView;
    }else if([textField.restorationIdentifier  isEqual: @"beginTimeTf"]){
        self.editingTf = self.beginTime;
        self.editingView = self.timeSelectView;
    }else if([textField.restorationIdentifier  isEqual: @"endTimeTf"]){
        self.editingTf = self.endTime;
        self.editingView = self.timeSelectView;
    }else{
        self.editingTf = self.courseKPTf;
        return;
    }
    self.editingView.hidden = NO;
    self.editingView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.view addSubview:self.editingView];
    //设置被监听的视图
    [self.editingView addGestureRecognizer:_singleTap];
    [self.editingTf resignFirstResponder];
}

-(NSString *) applicationDocumentDirectory{
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [documentDirectory stringByAppendingString:@"/userInfo.plist"];
    return path;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.editingTf resignFirstResponder];
}
@end
