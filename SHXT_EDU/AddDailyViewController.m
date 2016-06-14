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
@end

@implementation AddDailyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.classNameView.hidden = YES;
    //------------------------------------------------------------//
    //获取 plist 文件路径
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"classes" ofType:@"plist"];
    //从dailys.plist获取全部数据
    self.classArray = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    //------------------------------------------------------------//
    //单击监听设置
    _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenEditingView)];
    //初始化日报label
    NSDate *current = [[NSDate alloc]init];
    //时间格式化
    NSDateFormatter *form = [[NSDateFormatter alloc] init]; // 定义时间格式
    [form setDateFormat:@"yyyy.MM.dd"];
    self.dailyLabel.text = [NSString stringWithFormat:@"%@-%@", [form stringFromDate:current],@"日报"];
    //按钮圆角设置
    self.cancelBtn.layer.cornerRadius = self.cancelBtn.frame.size.height/8.0;
    self.submitBtn.layer.cornerRadius = self.submitBtn.frame.size.height/8.0;
    //Picker圆角设置
    self.classNamePicker.layer.cornerRadius = self.classNamePicker.frame.size.height/8.0;
    
    //TODO datepicker未生效！！！
    self.timeSelectDp.layer.cornerRadius = self.timeSelectDp.frame.size.height/8.0;
    self.timeSelectDp.layer.masksToBounds = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)hiddenEditingView{
    //隐藏被当前被编辑的picker视图
    self.editingView.hidden = YES;
    //设置textfield选择的时间
     if(![self.editingTf.restorationIdentifier  isEqual: @"classNameTf"]){
         //时间格式化
         NSDateFormatter *form = [[NSDateFormatter alloc] init]; // 定义时间格式
        [form setDateFormat:@"HH:mm"];
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
    return [self.classArray objectAtIndex:row];
}
//选中选择器的某个拨轮中的某行时调用
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSLog(@"pickerView didSelectRow - %@",pickerView);
    self.className.text = [self.classArray objectAtIndex:row];
}
- (IBAction)dailySubmit:(UIButton *)sender {
    //返回上一viewController
    [self dismissViewControllerAnimated:YES completion:nil];
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
    }else{
        self.editingTf = self.endTime;
        self.editingView = self.timeSelectView;
    }
    self.editingView.hidden = NO;
    self.editingView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [self.view addSubview:self.editingView];
    //设置被监听的视图
    [self.editingView addGestureRecognizer:_singleTap];
    [self.editingTf resignFirstResponder];
}
//-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    NSLog(@"touch begin");
//}
@end
