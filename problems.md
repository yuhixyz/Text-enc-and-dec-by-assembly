## 这里记录遇到的各种较大的问题和疑惑（自己看）

1. PTR慎用

```assembly
MOV CL, ENC_INPUT_BUF + 1  ; 获取字符串长度到CX中
MOV CH, 0
; 上面的写法并不等价于
MOV CX, WORD PTR ENC_INPUT_BUF + 1

第一种写法是正确的，取出存放在ENC_INPUT_BUF + 1单元的值，表示字符串的实际长度（只占一个字节），然后存放到CX中。
第二种写法将ENC_INPUT_BUF+1, +2单元内容赋值给了CX，而+2单元已经是字符串的第一个字符了。

```

2. 在debug打印信息时，有可能因为修改了AH的值，导致之前某一个功能调用中出口参数有AX，AX被改变，而后面再使用AX已经不是正确的值了。

3. 在文件读写时，如果程序仍然在运行，是看不到写入文件的结果的，因为此时写入的东西还在缓冲区，只有程序运行结束，才会吧内容写入文件。（暂时不知道这句话的正确性，也有可能是由于代码中没有关闭文件导致，之后有空再测试）