//
//  CONSTS.h
//  shxtEdu
//
//  Created by ccshxt on 16/4/24.
//  Copyright © 2016年 ccshxt. All rights reserved.
//

#ifndef CONSTS_h
#define CONSTS_h

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define URL_USER_LOGIN (@"http://42.96.168.190:82/control/sys/UserControlLoginAndroid.dhtml?username=%@&password=%@")
#define URL_STUDENT_GETALL (@"http://42.96.168.190:82/control/sys/StudentInfoQueryAndroid.dhtml?oper=getStudent&shxtyear=2015&classnumber=29")
#define URL_TEACHER_GETALL (@"http://42.96.168.190:82/control/sys/PlannerQueryAndroid.dhtml")
#define URL_DAILYS_BY_PAGE (@"http://42.96.168.190:82/control/sys/JournalQueryAndroid.dhtml?oper=list&pageNumber=%d&pageRecord=%@&uid=%@")

#endif /* CONSTS_h */
