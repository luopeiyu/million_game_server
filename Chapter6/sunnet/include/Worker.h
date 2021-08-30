#pragma once
#include <thread> 
#include "Sunnet.h"
#include "Service.h"
class Sunnet;

using namespace std;

class Worker { 
public:
    int id;             //编号
    int eachNum;        //每次处理多少条消息
    void operator()();  //线程函数
private:
    //辅助函数
    void CheckAndPutGlobal(shared_ptr<Service> srv);
};