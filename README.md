# million_game_server
the book of million online game server development  
《百万在线：大型游戏服务端开发》  
![百万在线](https://github.com/luopeiyu/million_game_server/blob/master/web/zcover.jpg)   
 

京东连接  [https://item.jd.com/12931061.html](https://item.jd.com/12931061.html)  

更多介绍请见WIKI  
[首页](https://github.com/luopeiyu/million_game_server/wiki)  
[1、这本书讲什么](https://github.com/luopeiyu/million_game_server/wiki/%E8%BF%99%E6%9C%AC%E4%B9%A6%E8%AE%B2%E4%BB%80%E4%B9%88)  
[2、服务端成长路线](https://github.com/luopeiyu/million_game_server/wiki/%E6%9C%8D%E5%8A%A1%E7%AB%AF%E6%88%90%E9%95%BF%E8%B7%AF%E7%BA%BF)  
[3、案例：球球大作战](https://github.com/luopeiyu/million_game_server/wiki/%E6%A1%88%E4%BE%8B%EF%BC%9A%E7%90%83%E7%90%83%E5%A4%A7%E4%BD%9C%E6%88%98)  
[4、案例：C++版Skynet](https://github.com/luopeiyu/million_game_server/wiki/%E6%A1%88%E4%BE%8B%EF%BC%9ACpp%E7%89%88Skynet)  
[5、作者是谁](https://github.com/luopeiyu/million_game_server/wiki/%E4%BD%9C%E8%80%85%E6%98%AF%E8%B0%81)  
[6、勘误](https://github.com/luopeiyu/million_game_server/wiki/%E5%8B%98%E8%AF%AF)  
[7、一些宣传图](https://github.com/luopeiyu/million_game_server/wiki/%E4%B8%80%E4%BA%9B%E5%AE%A3%E4%BC%A0%E5%9B%BE)  
 
 
## 做个大作战游戏 
书籍第三章将用一个完整游戏案例——球球大作战，介绍分布式游戏服务端的实现。  
Skynet的使用方法、服务端拓扑结构设计、如何编写服务端逻辑、如何实现跨服逻辑、如何对网络数据编码解码、如何设计游戏数据库、如何正确关闭服务器、怎样做断线重连   
![球球大作战战斗界面](https://github.com/luopeiyu/million_game_server/blob/master/web/qqdzz2.jpg) 

 
  
 
## 亲手用C++仿写Skynet 
书中第五部分会以C++仿写Skynet为主线，一方面说明Skynet的调度原理，另一方面介绍C++开发服务端的方法。  
用cmake构建工程、操作系统如何调度进程、栈堆的区别、如何创建线程、智能指针创建C++对象、对象的内存分布、读写锁自旋锁互斥锁的区别、哈希表的使用和性能、锁的临界区控制、如何使用条件变量、半小时学会Epoll、C++嵌入Lua   
![程序的内存示意图](https://github.com/luopeiyu/million_game_server/blob/master/web/sunnet1.jpg)  
  



## 同步算法 热更新 防外挂 
状态同步、帧同步、卡顿的原因？ 书中第八章探索同步问题  
服务端怎么做热更新？热更新技术的来龙去脉？书中第九章探索热更新问题   
服务端怎么做防外挂？防外挂的常见技巧？书中第十章探索外挂问题   
