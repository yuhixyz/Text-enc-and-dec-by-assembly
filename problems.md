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

3. 写入文件时，如果写入文件后没有关闭文件，无法查看到最新的写入结果，需要添加关闭文件的操作

```assembly
; 关闭文件
MOV AH, 3EH
MOV BX, WORD PTR FILE_ID  ; 文件号
INT 21H
``
4. 和第1点类似，都是因为想修改一个字节却修改了一个字的长度

```assembly
; 本意是想要3FH功能调用出口参数AX=实际读取的字节数，存放到长度字段
; 于是写成了下面这两行
LEA BX, ORI_INPUT_BUF + 1
MOV [BX], AX

; 注意！上面的做法，影响到了ORI_INPUT_BUF + 2单元，这个单元开始是存放字符串的，而这个单元却被AX的16位中的8位覆盖了，故出错。

; 应该如下写法
LEA BX, ORI_INPUT_BUF + 1
MOV BYTE PTR [BX], AL
```