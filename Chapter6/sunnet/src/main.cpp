#include "Sunnet.h"
#include <iostream>
#include <unistd.h>

int testConn() {
    Sunnet::inst->AddConn(1, 1, Conn::TYPE::LISTEN);
    Sunnet::inst->AddConn(2, 1, Conn::TYPE::CLIENT);
    Sunnet::inst->RemoveConn(2);
    cout << Sunnet::inst->GetConn(1).get() << endl;
    cout << Sunnet::inst->GetConn(2).get() << endl;
}

int testSocketCtrl() {
    int fd = Sunnet::inst->Listen(8001, 1);
    usleep(30*1000000);
    Sunnet::inst->CloseConn(fd);
}


int TestEcho() {
    auto t = make_shared<string>("gateway");
    uint32_t gateway = Sunnet::inst->NewService(t);
}

int main() {
    new Sunnet();
    Sunnet::inst->Start();
    TestEcho();
    Sunnet::inst->Wait();
    return 0;
}