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
#define URL_STUDENT_GETBYCLASS (@"http://42.96.168.190:82/control/sys/StudentInfoQueryAndroid.dhtml?oper=getStudent&shxtyear=%@&classnumber=%@")
#define URL_TEACHER_GETALL (@"http://42.96.168.190:82/control/sys/PlannerQueryAndroid.dhtml")
#define URL_DAILYS_BY_PAGE (@"http://42.96.168.190:82/control/sys/JournalQueryAndroid.dhtml?oper=list&pageNumber=%d&pageRecord=%@&uid=%@")
#define URL_TEACHER_GETALLCLASS (@"http://42.96.168.190:82/control/sys/StudentInfoQueryAndroid.dhtml?oper=getClass&ucid=%@")
#define URL_TEACHER_DAILY_ADD (@"http://42.96.168.190:82/control/sys/JournalManageAndroid.dhtml")
#define URL_TEACHER_DAILY_REMOVE (@"http://42.96.168.190:82/control/sys/JournalManageAndroid.dhtml?oper=del&id=%@")

#endif /* CONSTS_h */
