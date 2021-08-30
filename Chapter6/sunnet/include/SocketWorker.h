#pragma once
using namespace std;
#include <sys/epoll.h>
#include <memory>
#include "Conn.h"

class SocketWorker { 
private:
    //epoll描述符
    int epollFd;
public:
    void Init();        //初始化
    void operator()();  //线程函数
public:
    void AddEvent(int fd);
    void RemoveEvent(int fd);
    void ModifyEvent(int fd, bool epollOut);
private:
    void OnEvent(epoll_event ev);
    void OnAccept(shared_ptr<Conn> conn);
    void OnRW(shared_ptr<Conn> conn, bool r, bool w);
};