#include "Service.h"
#include "Sunnet.h"
#include <iostream>
#include <unistd.h>
#include <string.h>

//构造函数
Service::Service() {
    //初始化锁
    pthread_spin_init(&queueLock, PTHREAD_PROCESS_PRIVATE);//看看参数有什么区别，Skynet怎么用的
    pthread_spin_init(&inGlobalLock, PTHREAD_PROCESS_PRIVATE);
}

//析构函数
Service::~Service(){
    pthread_spin_destroy(&queueLock);
    pthread_spin_destroy(&inGlobalLock);
}

//插入消息
void Service::PushMsg(shared_ptr<BaseMsg> msg) {
    pthread_spin_lock(&queueLock);
    {
        msgQueue.push(msg);
    }
    pthread_spin_unlock(&queueLock);
}

//取出消息
shared_ptr<BaseMsg> Service::PopMsg() {
    shared_ptr<BaseMsg> msg = NULL;
    //取一条消息
    pthread_spin_lock(&queueLock);
    {
        if (!msgQueue.empty()) { 
            msg =  msgQueue.front();
            msgQueue.pop();
        }
    }
    pthread_spin_unlock(&queueLock);
    return msg;
}

//处理一条消息，返回值代表是否处理
bool Service::ProcessMsg() {
    shared_ptr<BaseMsg> msg = PopMsg();
    if(msg) {
        OnMsg(msg);
        return true;
    }
    else {
        return false;
    }
} 

//处理N条消息，返回值代表是否处理
void Service::ProcessMsgs(int max) {
    for(int i=0; i<max; i++){
        bool succ = ProcessMsg();
        if(!succ){
            break;
        }
    }
}

//创建服务后触发
void Service::OnInit() {
    cout << "[" << id <<"] OnInit"  << endl;
    //开启监听
    Sunnet::inst->Sunnet::Listen(8002, id);
} 

//收到客户端数据
void Service::OnSocketData(int fd, const char* buff, int len) {
    cout << "OnSocketData" << fd << " buff: " << buff << endl;
    /* echo
    char wirteBuff[3] = {'l','p','y'};
    write(fd, &wirteBuff, 3);
    */
    /* 练习题新增行
    usleep(15000000); //15秒
    char wirteBuff2[3] = {'n','e','t'};
    int r = write(fd, &wirteBuff2, 3);
    cout << "write2 r:" << r <<  " " << strerror(errno) <<  endl;
    */
    /*PIPE实验新增行
    usleep(1000000); //1秒
    char wirteBuff3[2] = {'n','o'};
    r = write(fd, &wirteBuff3,2);
    cout << "write3 r:" << r <<  " " << strerror(errno) <<  endl;
    */
   /*发送大量数据实验
   char* wirteBuff = new char[4200000];
   wirteBuff[4200000-1] = 'e';
   int r = write(fd, wirteBuff, 4200000); 
   cout << "write r:" << r <<  " " << strerror(errno) <<  endl;
   */
   //用ConnWriter发送大量数据
   char* wirteBuff = new char[4200000];
   wirteBuff[4200000-1] = 'e';
   auto w = writers[fd];
   w->EntireWrite(shared_ptr<char>(wirteBuff), 4200000);
   w->LingerClose();
}

//套接字可写
void Service::OnSocketWritable(int fd) {
    cout << "OnSocketWritable " << fd << endl;
    auto w = writers[fd];
    w->OnWriteable();
}

//关闭连接前
void Service::OnSocketClose(int fd) {
    writers.erase(fd);
    cout << "OnSocketClose " << fd << endl;
}

//收到其他服务发来的消息
void Service::OnServiceMsg(shared_ptr<ServiceMsg> msg) {
    cout << "OnServiceMsg " << endl;
}

//新连接
void Service::OnAcceptMsg(shared_ptr<SocketAcceptMsg> msg) {
    cout << "OnAcceptMsg " << msg->clientFd << endl;
    auto w = make_shared<ConnWriter>();
    w->fd = msg->clientFd;
    writers.emplace(msg->clientFd, w);
}

//套接字可读可写
void Service::OnRWMsg(shared_ptr<SocketRWMsg> msg) {
    int fd = msg->fd;
    //可读
    if(msg->isRead) {
        const int BUFFSIZE = 512;
        char buff[BUFFSIZE];
        int len = 0;
        do {
            len = read(fd, &buff, BUFFSIZE);
            if(len > 0){
                OnSocketData(fd, buff, len);
            }
        }while(len == BUFFSIZE);

        if(len <= 0 && errno != EAGAIN) {
            if(Sunnet::inst->GetConn(fd)) {
                OnSocketClose(fd);
                Sunnet::inst->CloseConn(fd);
            }
        }
    }
    //可写（注意没有else）
    if(msg->isWrite) {
        if(Sunnet::inst->GetConn(fd)){
            OnSocketWritable(fd);
        }
    }
}



//收到消息时触发
void Service::OnMsg(shared_ptr<BaseMsg> msg) {
    //SERVICE
    if(msg->type == BaseMsg::TYPE::SERVICE) {
        auto m = dynamic_pointer_cast<ServiceMsg>(msg);
        OnServiceMsg(m);
    }
    //SOCKET_ACCEPT
    else if(msg->type == BaseMsg::TYPE::SOCKET_ACCEPT) {
        auto m = dynamic_pointer_cast<SocketAcceptMsg>(msg);
        OnAcceptMsg(m);
    }
    //SOCKET_RW
    else if(msg->type == BaseMsg::TYPE::SOCKET_RW) {
        auto m = dynamic_pointer_cast<SocketRWMsg>(msg);
        OnRWMsg(m);
    }
}


//退出服务时触发
void Service::OnExit() {
    cout << "[" << id <<"] OnExit"  << endl;
}

void Service::SetInGlobal(bool isIn) {
    pthread_spin_lock(&inGlobalLock);
    {
        inGlobal = isIn;
    }
    pthread_spin_unlock(&inGlobalLock);
}