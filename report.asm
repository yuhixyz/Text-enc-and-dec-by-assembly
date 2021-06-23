DATA SEGMENT

FILENAME_INPUT DB 'Please input filename: ', '$'  ; 请输入文件名的提示语句
CHOICE1 DB '1. Encrypt a string.', '$'  ; 1. 加密字符串
CHOICE2 DB '2. Decrypt a string.', '$'  ; 2. 解密字符串
CHOICE3 DB '3. Encrypt a file.', '$'  ; 3.加密文件
CHOICE4 DB '4. Decrypt a file.', '$'  ; 4. 解密文件
CHOICE5 DB '5. Show orininal file and decrypted file.', '$'  ; 5. 显示原始文件和解密文件
CHOICE6 DB '6. Exit', '$'  ; 退出
CHOICE_INPUT DB 'Your choice is: ', '$'
CHOICE_INPUT_ERROR DB 'Please input valid choice!', '$'
STR_INPUT DB 'Please input a string containing only numbers or letters: ', '$'
KEY_INPUT DB 'Please input a non-negetive number smaller than 10: ', '$'
AFTER_ENC DB 'String after encryption: ', '$'
AFTER_DEC DB 'String after decryption: ', '$'
PLAIN_TABLE DB 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789', '$'  ; 明文表
ENC_A_FILE_SUCCESS DB 'Encrypt file successfully!', '$'  ; 加密文件成功的提示语句
DEC_A_FILE_SUCCESS DB 'Decrypt file successfully!', '$'  ; 解密文件成功的提示语句
OPEN_FILE_ERROR_W DB 'Open file error by writing only!', '$'  ; 以只写的方式打开文件失败的提示语句
OPEN_FILE_ERROR_R DB 'Open file error by reading only!', '$'  ; 以只读的方式打开文件失败的提示语句
READ_FILE_ERROR DB 'Read file error!', '$'  ; 读文件失败的提示语句
WRITE_FILE_ERROR DB 'Write file error!', '$'  ; 写文件失败的提示语句
DISPLAY_ORI_FILE DB 'Orginal file: ', '$'  ; 显示原始文件的提示语句
DISPLAY_DEC_FILE DB 'Decrypted file: ', '$'  ; 显示解密文件的提示语句
ORI_FILE DB 15, ?, 14 DUP(?)  ; 原始文件名，注意打开文件时需要以0为结束符
ENC_FILE DB 15, ?, 14 DUP(?)  ; 加密文件名
DEC_FILE DB 15, ?, 14 DUP(?)  ; 解密文件名
ORI_INPUT_BUF DB 101, ?, 100 DUP(?)  ; 原文的输入缓冲区
ENC_OUTPUT_BUF DB 100 DUP(?)  ; 密文的输出缓冲区
ENC_INPUT_BUF DB 101, ?, 100 DUP(?)  ;  密文的输入缓冲区
DEC_OUTPUT_BUF DB 100 DUP(?)  ;  解密文的输出缓冲区
KEY DB 0  ; 密钥0~9
CIPHER_TABLE DB 62 DUP(?), '$'  ; 密文表
FILE_FLAG DB 0  ; 文件操作标记，1表示当前是对文件操作，0表示对字符串操作 
FILE_ID DB 2 DUP(?)  ; 文件号
FILE_SZ DB 5 DUP(?)  ; 文件大小
DEC_READ_BUF DB 100 DUP(?)  ; 解密文件读取内容缓冲区
ORI_READ_BUF DB 100 DUP(?)  ; 原始文件读取内容缓冲区

DATA ENDS


CODE SEGMENT
    ASSUME DS:DATA, CS:CODE
BEG:
    MOV AX, DATA
    MOV DS, AX
    ; 显示主菜单
    CALL SHOW_MAIN_MENU
    ; 1. 加密字符串 -> 输入字符串和key
    ; 2. 解密字符串 -> 输入字符串和key
    ; 3. 加密文件 -> 输入文件路径和key,输入加密后的文件路径
    ; 4. 解密文件 -> 输入文件路径和key,输入解密后的文件路径
    ; 5. 显示原始文件ORI_FILE和解密文件DEC_FILE的内容
    ; 6. Exit
    ; 1,2,3,4,5完成后会跳转回到主菜单

REPEAT_SOLVE_CHOICE:  ; 处理用户的选择
    CALL SOLVE_CHOICE
    JMP BEG


; 显示主菜单
SHOW_MAIN_MENU PROC
    ; 9号功能调用显示字符串
    ; 入口地址 DX=字符串首地址，且字符串以$结尾
    CALL PRINT_LINE
    MOV AH, 09H
    LEA DX, CHOICE1
    INT 21H
    CALL PRINT_LINE
    MOV AH, 09H
    LEA DX, CHOICE2
    INT 21H
    CALL PRINT_LINE
    MOV AH, 09H
    LEA DX, CHOICE3
    INT 21H
    CALL PRINT_LINE
    MOV AH, 09H
    LEA DX, CHOICE4
    INT 21H
    CALL PRINT_LINE
    MOV AH, 09H
    LEA DX, CHOICE5
    INT 21H
    CALL PRINT_LINE
    MOV AH, 09H
    LEA DX, CHOICE6
    INT 21H
    CALL PRINT_LINE
    RET
SHOW_MAIN_MENU ENDP


; 跳转选择
SOLVE_CHOICE PROC
SOLVE_CHOICE_BEG:
    MOV AH, 09H
    LEA DX, CHOICE_INPUT
    INT 21H
    CALL PRINT_LINE
    ; 1号功能调用，读入一个字符
    ; 出口参数：AL=输入字符的ASCII码
    MOV AH, 01H
    INT 21H
    ; 根据AL的值跳转不同的函数
    ; AL=31H~36H
    ; 不在上述范围就提示重新输入
    CMP AL, 31H
    JC INVALID ; AL<31H就跳转到INVALID
    CMP AL, 36H
    JA INVALID; AL>36H就跳转到INVALID
VALID:  ; 输入合法
    SUB AL, 30H
    ; 根据AL=1～6跳转对应的处理函数
    CMP AL, 1
    JZ WORK1
    CMP AL, 2
    JZ WORK2
    CMP AL, 3
    JZ WORK3
    CMP AL, 4
    JZ WORK4
    CMP AL, 5
    JZ WORK5
    JMP WORK6
WORK1:
    CALL ENC_A_STR
    JMP SOLVE_CHOICE_END
WORK2:
    CALL DEC_A_STR
    JMP SOLVE_CHOICE_END
WORK3:
    CALL ENC_A_FILE
    JMP SOLVE_CHOICE_END
WORK4:
    CALL DEC_A_FILE
    JMP SOLVE_CHOICE_END
WORK5:
    CALL SHOW_ORI_AND_DEC_FILE
    JMP SOLVE_CHOICE_END
WORK6:  ; 退出
    MOV AH, 4CH
    INT 21H
    JMP SOLVE_CHOICE_END
INVALID:  ; 输入不合法
    CALL PRINT_LINE
    ; 输出错误提示信息，并要求重新输入
    MOV AH, 09H
    LEA DX, CHOICE_INPUT_ERROR
    INT 21H
    CALL PRINT_LINE
    JMP REPEAT_SOLVE_CHOICE
SOLVE_CHOICE_END:
    RET
SOLVE_CHOICE ENDP


; 加密一个字符串
ENC_A_STR PROC
    CMP FILE_FLAG, 1
    JZ NOT_INPUT_STR  ; FILE_FLAG=1直接跳转

    ; 1. 输入字符串
    ; 2. 加密字符串
    ; 3. 输出加密后的字符串
    ; 提示输入一个字符串
    CALL PRINT_LINE
    MOV AH, 09H
    LEA DX, STR_INPUT
    INT 21H
    CALL PRINT_LINE

    ; 输入一个字符串
    ; 存放在ORI_INPUT_BUF+2开始的单元
    ; 字符串长度存放在ORI_INPUT_BUF+1单元
    MOV AH, 0AH
    LEA DX, ORI_INPUT_BUF
    INT 21H

    ; 验证合法性（只含有数字和字母，暂时不写）

NOT_INPUT_STR:  ; 当FILE_FLAG=1时，ORI_INPUT_BUF+2由文件导入，不需要上面输入。
    ; 获取字符串长度存到AL中
    MOV AL, ORI_INPUT_BUF + 1
    MOV AH, 0
    MOV SI, AX  ; 将SI赋值为字符串长度
    MOV ORI_INPUT_BUF[SI + 2], '$'  ; 将字符串末尾的0DH替换成$
    ; 注意加密字符串是从0位置开始存放的，前面没有最大长度以及实际长度字段
    MOV ENC_OUTPUT_BUF[SI], '$'  ; 将字符串末尾的0DH替换成$

    ; 输出上述字符串验证（已正确输出）
    ; CALL PRINT_LINE
    ; MOV AH, 09H
    ; LEA DX, ORI_INPUT_BUF + 2
    ; INT 21H
    ; CALL PRINT_LINE

    CALL INPUT_A_KEY  ; 读入KEY

    ; 打印输入的数字验证（已经正确输出）
    ; CALL PRINT_LINE
    ; MOV AH, 02H
    ; MOV DL, KEY
    ; ADD DL, 30H
    ; INT 21H
    ; CALL PRINT_LINE

    ; 加密前字符串在ORI_INPUT_BUF
    ; 加密后字符串在ENC_OUTPUT_BUF
    ; 明文表abc...zABC...Z0123...9
    ; 密文表为明文表循环左移KEY位
    ; 下面开始加密操作
    ; 1. 枚举原字符串ORI_INPUT_BUF的每一个字符
    ; 2. 判断该字符AL的三种情况，用AH来存放明文表中的下标
    ; 2.1 AL='a'~'z', AH=AL-'a'
    ; 2.2 AL='A'~'Z', AH=AL-'A'+26
    ; 2.3 AL='0'~'9', AH=AL-'0'+52
    ; 3. AH+=KEY  ; AH更新为该位置的密文所对应的明文的下标
    ; 4. 根据AH的值，讨论三种情况，得到每一位对应的密码
    ; 4.1 AH=0~25, 密文=AH+'a'
    ; 4.2 AH=26~51, 密文=AH+'A'
    ; 4.3 AH=52~61, 密文=AH+'0'
    ; 5. 将上述每一位密文都填写到ENC_OUTPUT_BUF中
    ; 6. ENC_OUTPUT_BUF末尾加$（在上面已经做过了）
    ; 7. 9号功能调用输出ENC_OUTPUT_BUF
    
    ; 1. 枚举原字符串ORI_INPUT_BUF的每一个字符
    MOV CL, ORI_INPUT_BUF + 1  ; 获取字符串长度到CX中
    MOV CH, 0
    LEA DI, ORI_INPUT_BUF + 2  ; DI指向原字符串的开头
    LEA SI, ENC_OUTPUT_BUF  ; SI指向加密输出字符串的开头
LABLE1:
    ; 取出当前枚举的字符
    MOV AL, DS:[DI]  ; AL表示原字符串的当前字符
    ; 讨论ch=AL的3种情况，将加密的结果写到AH中
TAG1:
    ; 1. AL='a'~'z'
    CMP AL, 'a'
    ; AL<'a'就跳到TAG2
    JB TAG2
    ; 否则一定满足AL为小写字母
    SUB AL, 'a'
    MOV AH, AL
    JMP TAG_END
TAG2:
    ; 2. AL='A'~'Z'
    CMP AL, 'A'
    ; al<'A'就跳到TAG3
    JB TAG3
    ; 否则一定满足AL为大写字母
    SUB AL, 'A'
    MOV AH, AL
    ADD AH, 26
    JMP TAG_END
TAG3:
    ; 3. AL='0'~'9'
    SUB AL, '0'
    MOV AH, AL
    ADD AH, 52
TAG_END:
    ; AH+=KEY得到明文表中的新下标
    ADD AH, KEY
    ; AH %= 62
    ; 如果AH>=62,AH-=62
    CMP AH, 62
    JB NOT_MOD  ; AH<62就不%62
    SUB AH, 62  
NOT_MOD:    
    ; 此时AH中得到了明文表中的新下标
    ; 讨论AH的3种情况
    ; 1 AH=0~25, 密文=AH+'a'
    ; 2 AH=26~51, 密文=AH+'A'
    ; 3 AH=52~61, 密文=AH+'0'
NEW_TAG1:
    CMP AH, 25
    ; AH>25就跳转NEW_TAG2
    JA NEW_TAG2
    ADD AH, 'a'
    MOV DS:[SI], AH  ; 将密文写到加密输出符号串的对应位置
    JMP CUR_END  ; 之前这里忘记JMP了
NEW_TAG2:
    CMP AH, 51
    ; AH>51就跳转NEW_TAG3
    JA NEW_TAG3
    SUB AH, 26
    ADD AH, 'A'
    MOV DS:[SI], AH 
    JMP CUR_END
NEW_TAG3:
    SUB AH, 52
    ADD AH, '0'
    MOV DS:[SI], AH
CUR_END:
    INC SI
    INC DI
    LOOP LABLE1
ENC_END:  ; 加密完成
    ; 若FILE_FLAG=1，则不将字符串内容输出到屏幕
    CMP FILE_FLAG, 1
    JZ END_RET
    ; 输出加密后的字符串ENC_OUTPUT_BUF
    CALL PRINT_LINE
    MOV AH, 09H
    LEA DX, AFTER_ENC
    INT 21H
    CALL PRINT_LINE
    MOV AH, 09H
    LEA DX, ENC_OUTPUT_BUF
    INT 21H
    CALL PRINT_LINE
END_RET:
    RET
ENC_A_STR ENDP


; 解密一个字符串
DEC_A_STR PROC
    CMP FILE_FLAG, 1
    JZ NOT_INPUT_STR2  ; FILE_FLAG=1直接跳转
    ; 1. 输入字符串
    ; 2. 解密字符串
    ; 3. 输出解密后的字符串

    ; 提示输入一个字符串
    CALL PRINT_LINE
    MOV AH, 09H
    LEA DX, STR_INPUT
    INT 21H
    CALL PRINT_LINE

    ; 输入一个字符串
    ; 存放在ENC_INPUT_BUF+2开始的单元
    ; 字符串长度存放在ENC_INPUT_BUF+1单元
    ; 解密字符串存放在DEC_OUTPUT_BUF开始的单元
    MOV AH, 0AH
    LEA DX, ENC_INPUT_BUF
    INT 21H

NOT_INPUT_STR2:    
    ; 获取字符串长度存到AL中
    MOV AL, ENC_INPUT_BUF + 1
    MOV AH, 0
    MOV SI, AX  ; 将SI赋值为字符串长度
    MOV ENC_INPUT_BUF[SI + 2], '$'  ; 将字符串末尾的0DH替换成$
    ; 注意解密输出字符串是从0位置开始存放的，前面没有最大长度以及实际长度字段
    MOV DEC_OUTPUT_BUF[SI], '$'  ; 将字符串末尾的0DH替换成$

    CALL GENERATE_CIPHER_TABLE  ; 首先根据明文表生成密文表
    ; 枚举密文串的每一个字符，转化为密文写到对应位置
    
    ; 下面开始解密
    ; 1. 枚举输入的加密字符串ENC_INPUT_BUF+2
    ; 2. 当前字符存放到AL中，解密后存放到AH中
    ; 3. 把AH写到解密输出字符串DEC_OUTPUT_BUF的对应位置
    ; 4. 输入解密后的字符串
    MOV CL, ENC_INPUT_BUF + 1  ; 获取字符串长度到CX中
    MOV CH, 0
    LEA DI, ENC_INPUT_BUF + 2  ; DI指向加密输入字符串的开头
    LEA BX, DEC_OUTPUT_BUF  ; BX指向解密输出字符串的开头
DEC_LABEL:
    MOV AL, DS:[DI]  ; 每次循环取出需要解密的字符
    ; 在密文表中查找AL出现的下标
    LEA SI, CIPHER_TABLE  ; SI指向密文表的首地址
NOT_FIND_IDX:
    CMP DS:[SI], AL  ; 当前密文表中的字符是否和需要解密的字符相同
    JZ FIND_IDX  ; 找到了就跳出去
    INC SI
    JMP NOT_FIND_IDX
FIND_IDX:
    ; 此时SI指向密文表的某一个字符，恰好是需要解密的字符
    ; 求出SI相对于密文表首地址的偏移值
    SUB SI, OFFSET CIPHER_TABLE
    ; 在明文表中取出对应位置的字符存放到AH中
    LEA DX, PLAIN_TABLE  ; 获取明文表的首地址
    ; 取出密文表对应下标在明文表中的值
    ADD SI, DX
    MOV AH, DS:[SI]
    ; 将AH写到DEC_OUTPUT_BUF的对应位置
    MOV DS:[BX], AH
    INC DI
    INC BX
    LOOP DEC_LABEL
OUTPUT_DEC_OUTPUT_BUF:  ; 输出解密后的字符串
    CMP FILE_FLAG, 1  ; 如果为文件操作就不输出到屏幕上
    JZ DEC_END_RET
    CALL PRINT_LINE
    MOV AH, 09H
    LEA DX, AFTER_DEC
    INT 21H
    CALL PRINT_LINE
    MOV AH, 09H
    LEA DX, DEC_OUTPUT_BUF
    INT 21H    
    CALL PRINT_LINE
DEC_END_RET:
    RET
DEC_A_STR ENDP


; 加密一个文件
ENC_A_FILE PROC
    ; 读入文件名
    ; 将文件内容读入到ORI_INPUT_BUF+2
    ; 设置一个全局FILE_FLAG标记，用来表示ENC_A_STR子程序是否需要读入字符串
    ; 如果FILE_FLAG=1表示是文件加密，就不用读入需要加密的字符串
    ; 长度设在ORI_INPUT_BUF+1位置
    ; 这样就可以直接调用加密字符串的函数了
    ; 在加密字符串函数的输出阶段，输出字符串仍然存放在ENC_OUTPUT_BUF
    ; 但是要根据这个FILE_FLAG标记来选择是否输出到特定文件还是输出道屏幕上
    ; 还是直接输出到屏幕

    MOV FILE_FLAG, 1  ; 标记当前为文件操作
    ; 提示输入原文件名
    CALL PRINT_LINE
    MOV AH, 09H
    LEA DX, FILENAME_INPUT
    INT 21H
    CALL PRINT_LINE
    ; 输入原文件名，实际从ORI_FILE+2单元开始存
    MOV AH, 0AH
    LEA DX, ORI_FILE
    INT 21H
    ; 将ORI_FILE的结束符设为0
    MOV AL, ORI_FILE + 1  ; 取出长度
    MOV AH, 0
    MOV SI, AX  ; 长度赋给SI
    MOV ORI_FILE[SI + 2], 0  ; 文件名字符串结束符置为0
    ; 以只读的方式打开文件
    ; 3DH功能调用
    ; 入口参数
    ; DX=文件名字符串首地址
    ; AL=00只读
    ; 出口参数
    ; CF=0打开成功，AX=文件号
    ; CF=1打开失败，AX=错误代码
    MOV AH, 3DH
    MOV AL, 00H  ; 读
    LEA DX, ORI_FILE + 2
    INT 21H
    
    JNC OPEN_SUCCESS  ; 打开成功

    ; 这里写以只读打开文件失败的提示语句，并要求重新输入
    MOV AH, 09H
    LEA DX, OPEN_FILE_ERROR_R
    INT 21H
    JMP ENC_FILE_END
    
OPEN_SUCCESS:  ; 打开文件成功，下面进行读文件
    LEA BX, FILE_ID
    MOV [BX], AX  ; 将打开的文件的文件号AX存放到FILE_ID中
    ; 3FH功能调用，读文件
    ; 入口参数：BX=文件号
    ; CX=读入字节数
    ; DX=准备存放所读取数据的缓冲区的首地址
    ; 出口参数：
    ; CF=0读取成功，AX=实际读取到的字节数
    ; CF=1读取失败，AX=错误代码
    ; 将文件内容读出后写到ORI_INPUT_BUF+2开始的单元，+1单元写上长度
    MOV AH, 3FH
    MOV BX, WORD PTR FILE_ID
    MOV CX, 100 ; 要读入整个文件，CX应该大于等于整个文件内容的字节数
    LEA DX, ORI_INPUT_BUF + 2
    INT 21H
    
    JNC READ_SUCCESS

    ; 这里写读文件失败的提示语句，并要求重新输入
    MOV AH, 09H
    LEA DX, READ_FILE_ERROR
    INT 21H
    JMP ENC_FILE_END

READ_SUCCESS:  ; 读取文件成功，出口参数AX=实际读取的字节数
    ; 将文件大小AX也要写入ORI_INPUT_BUF+1单元
    LEA BX, ORI_INPUT_BUF + 1
    MOV BYTE PTR [BX], AL ; 将文件的实际大小存到ORI_INPUT_BUF+1单元
    
    ; 关闭ORI_FILE
    MOV AH, 3EH
    MOV BX, WORD PTR FILE_ID
    INT 21H
    
    ; 调用加密字符串ORI_INPUT_BUF+2的子程序
    CALL ENC_A_STR

    ; 输入加密后的文件名
    ; 将ENC_OUTPUT_BUF内容写入该文件
    ; 提示输入加密文件名
    CALL PRINT_LINE
    MOV AH, 09H
    LEA DX, FILENAME_INPUT
    INT 21H
    CALL PRINT_LINE
    ; 输入加密文件名，实际从ENC_FILE+2单元开始存
    MOV AH, 0AH
    LEA DX, ENC_FILE
    INT 21H
    ; 将ENC_FILE的结束符设为0
    MOV AL, ENC_FILE + 1  ; 取出长度
    MOV AH, 0
    MOV SI, AX  ; 长度赋给SI
    MOV ENC_FILE[SI + 2], 0  ; 结束符置为0

    ; 创建文件
    ; 3CH功能调用
    MOV AH, 3CH
    MOV CX, 0  ; 普通文件
    LEA DX, ENC_FILE + 2
    INT 21H

    ; 以写的方式打开文件
    ; 3DH功能调用
    ; 入口参数
    ; DX=文件名字符串首地址
    ; AL=01只写
    ; 出口参数
    ; CF=0打开成功，AX=文件号
    ; CF=1打开失败，AX=错误代码
    MOV AH, 3DH
    MOV AL, 01H  ; 写
    LEA DX, ENC_FILE + 2
    INT 21H
    
    JNC WRITE_OPEN_SUCCESS  ; 打开文件成功
    
    ; 这里输出以写的方式打开文件失败的提示信息
    MOV AH, 09H
    LEA DX, OPEN_FILE_ERROR_W
    INT 21H
    JMP ENC_FILE_END

WRITE_OPEN_SUCCESS:  ; 以写的方式打开文件成功
    LEA BX, FILE_ID
    MOV [BX], AX  ; 将需要写的文件号存到FILE_ID中
    ; 下面进行写文件
    ; 40H功能调用
    ; 入口参数
    ; DX=缓冲区地址
    ; BX=文件号
    ; CX=需要写入的字节数
    MOV AH, 40H
    MOV BX, WORD PTR FILE_ID
    LEA DX, ENC_OUTPUT_BUF
    MOV CL, ORI_INPUT_BUF + 1  ; 写入字节数=读出字节数
    MOV CH, 0  ; 这里之前写出了bug，原因是MOV CX, WORD PTR  ORI_INPUT_BUF + 1
    ; 实际上长度字段只占用了1个字节，而注释里的写法，把字符串的第一个字符也赋值给CX了
    INT 21H

    JNC WRITE_SUCCESS  ; 写入文件成功

    ; 这里输出写文件失败的提示信息
    MOV AH, 09H
    LEA DX, WRITE_FILE_ERROR
    INT 21H
    JMP ENC_FILE_END

WRITE_SUCCESS:  ; 写入文件成功
    ; 输出成功的提示语句
    CALL PRINT_LINE
    MOV AH, 09H
    LEA DX, ENC_A_FILE_SUCCESS
    INT 21H
    CALL PRINT_LINE

ENC_FILE_END:  ; 加密文件完成
    ; 关闭文件
    MOV AH, 3EH
    MOV BX, WORD PTR FILE_ID
    INT 21H
    ; 恢复标记
    MOV FILE_FLAG, 0  
    RET
ENC_A_FILE ENDP


; 解密一个文件
DEC_A_FILE PROC
    ; 读入文件名
    ; 将文件内容读入到ENC_INPUT_BUF+2
    ; 设置一个全局FILE_FLAG标记，用来表示DEC_A_STR子程序是否需要读入字符串
    ; 如果FILE_FLAG=1表示是文件解密，就不用读入需要解密的字符串
    ; 长度设在ENC_INPUT_BUF+1位置
    ; 这样就可以直接调用解密字符串的函数了
    ; 在解密字符串函数的输出阶段，输出字符串仍然存放在DEC_OUTPUT_BUF
    ; 但是要根据这个FILE_FLAG标记来选择是否输出到特定文件还是输出道屏幕上

    MOV FILE_FLAG, 1  ; 标记当前为文件操作
    ; 提示输入需要解密的文件名
    CALL PRINT_LINE
    MOV AH, 09H
    LEA DX, FILENAME_INPUT
    INT 21H
    CALL PRINT_LINE
    ; 输入需要解密的文件的文件名（即当前为加密文件），实际从ENC_FILE+2单元开始存
    MOV AH, 0AH
    LEA DX, ENC_FILE
    INT 21H
    ; 将ENC_FILE的结束符设为0
    MOV AL, ENC_FILE + 1  ; 取出长度
    MOV AH, 0
    MOV SI, AX  ; 长度赋给SI
    MOV ENC_FILE[SI + 2], 0  ; 文件名字符串结束符置为0
    ; 以只读的方式打开文件
    ; 3DH功能调用
    ; 入口参数
    ; DX=文件名字符串首地址
    ; AL=00只读
    ; 出口参数
    ; CF=0打开成功，AX=文件号
    ; CF=1打开失败，AX=错误代码
    MOV AH, 3DH
    MOV AL, 00H  ; 读
    LEA DX, ENC_FILE + 2
    INT 21H
    
    JNC OPEN_SUCCESS2  ; 打开成功

    ; 这里写以只读打开文件失败的提示语句，并要求重新输入
    MOV AH, 09H
    LEA DX, OPEN_FILE_ERROR_R
    INT 21H
    JMP DEC_FILE_END
    
OPEN_SUCCESS2:  ; 打开文件成功，下面进行读文件
    LEA BX, FILE_ID
    MOV [BX], AX  ; 将打开的文件的文件号AX存放到FILE_ID中
    ; 3FH功能调用，读文件
    ; 入口参数：BX=文件号
    ; CX=读入字节数
    ; DX=准备存放所读取数据的缓冲区的首地址
    ; 出口参数：
    ; CF=0读取成功，AX=实际读取到的字节数
    ; CF=1读取失败，AX=错误代码
    ; 将文件内容读出后写到ENC_INPUT_BUF+2开始的单元，+1单元写上长度
    MOV AH, 3FH
    MOV BX, WORD PTR FILE_ID
    MOV CX, 100 ; 要读入整个文件，CX应该大于等于整个文件内容的字节数
    LEA DX, ENC_INPUT_BUF + 2
    INT 21H
    
    JNC READ_SUCCESS2

    ; 这里写读文件失败的提示语句，并要求重新输入
    MOV AH, 09H
    LEA DX, READ_FILE_ERROR
    INT 21H
    JMP DEC_FILE_END

READ_SUCCESS2:  ; 读取文件成功，出口参数AX=实际读取的字节数
    ; 将文件大小AX也要写入ENC_INPUT_BUF+1单元
    LEA BX, ENC_INPUT_BUF + 1
    MOV BYTE PTR [BX], AL ; 将文件的实际大小存到ENC_INPUT_BUF+1单元

    ; 关闭ENC_FILE
    MOV AH, 3EH
    MOV BX, WORD PTR FILE_ID
    INT 21H

    ; 调用解密字符串ENC_INPUT_BUF+2的子程序
    CALL DEC_A_STR

    ; 输入解密后后的文件名
    ; 将ENC_OUTPUT_BUF内容写入该文件
    ; 提示输入加密文件名
    CALL PRINT_LINE
    MOV AH, 09H
    LEA DX, FILENAME_INPUT
    INT 21H
    CALL PRINT_LINE
    ; 输入解密后的文件名，实际从DEC_FILE+2单元开始存
    MOV AH, 0AH
    LEA DX, DEC_FILE
    INT 21H
    ; 将DEC_FILE的结束符设为0
    MOV AL, DEC_FILE + 1  ; 取出长度
    MOV AH, 0
    MOV SI, AX  ; 长度赋给SI
    MOV DEC_FILE[SI + 2], 0  ; 结束符置为0

    ; 创建文件
    ; 3CH功能调用
    MOV AH, 3CH
    MOV CX, 0  ; 普通文件
    LEA DX, DEC_FILE + 2
    INT 21H

    ; 以写的方式打开文件
    ; 3DH功能调用
    ; 入口参数
    ; DX=文件名字符串首地址
    ; AL=01H只写
    ; 出口参数
    ; CF=0打开成功，AX=文件号
    ; CF=1打开失败，AX=错误代码
    MOV AH, 3DH
    MOV AL, 01H  ; 写
    LEA DX, DEC_FILE + 2
    INT 21H
    
    JNC WRITE_OPEN_SUCCESS2  ; 打开文件成功
    
    ; 这里输出以写的方式打开文件失败的提示信息
    MOV AH, 09H
    LEA DX, OPEN_FILE_ERROR_W
    INT 21H
    JMP DEC_FILE_END

WRITE_OPEN_SUCCESS2:  ; 以写的方式打开文件成功
    LEA BX, FILE_ID
    MOV [BX], AX  ; 将需要写的文件号存到FILE_ID中
    ; 下面进行写文件
    ; 40H功能调用
    ; 入口参数
    ; DX=缓冲区地址
    ; BX=文件号
    ; CX=需要写入的字节数
    MOV AH, 40H
    MOV BX, WORD PTR FILE_ID
    LEA DX, DEC_OUTPUT_BUF
    MOV CL, ENC_INPUT_BUF + 1  ; 写入字节数=读出字节数
    MOV CH, 0  ; 这里之前写出了bug，原因是MOV CX, WORD PTR  ORI_INPUT_BUF + 1
    ; 实际上长度字段只占用了1个字节，而注释里的写法，把字符串的第一个字符也赋值给CX了
    INT 21H

    JNC WRITE_SUCCESS2  ; 写入文件成功

    ; 这里输出写文件失败的提示信息
    MOV AH, 09H
    LEA DX, WRITE_FILE_ERROR
    INT 21H
    JMP DEC_FILE_END

WRITE_SUCCESS2:  ; 写入文件成功
    ; 输出成功的提示语句
    CALL PRINT_LINE
    MOV AH, 09H
    LEA DX, DEC_A_FILE_SUCCESS
    INT 21H
    CALL PRINT_LINE

DEC_FILE_END:  ; 解密文件完成
    ; 关闭文件
    MOV AH, 3EH
    MOV BX, WORD PTR FILE_ID
    INT 21H
    ; 恢复标记
    MOV FILE_FLAG, 0  
    RET
DEC_A_FILE ENDP


; 显示原文件和解密的文件
SHOW_ORI_AND_DEC_FILE PROC
    ; 根据之前用户输入的ORI_FILE、DEC_FILE
    ; 打开文件并输出内容
    
    ; 打开ORI_FILE
    MOV AH, 3DH
    MOV AL, 00H  ; 读
    LEA DX, ORI_FILE + 2
    INT 21H

    LEA BX, FILE_ID
    MOV [BX], AX  ; 将打开的文件的文件号AX存放到FILE_ID中
    
    ; 将ORI_FILE文件内容读出后写到ORI_READ_BUF
    MOV AH, 3FH
    MOV BX, WORD PTR FILE_ID
    MOV CX, 100 ; 要读入整个文件，CX应该大于等于整个文件内容的字节数
    LEA DX, ORI_READ_BUF + 2
    INT 21H

    ; 读入文件成功，将长度写到ORI_READ_BUF+1单元
    LEA BX, ORI_READ_BUF + 1
    MOV BYTE PTR [BX], AL

    ; 显示输出提示语句
    CALL PRINT_LINE
    MOV AH, 09H
    LEA DX, DISPLAY_ORI_FILE
    INT 21H
    CALL PRINT_LINE

    ; 在ORI_READ_BUF末尾添加$，再用9号功能打印
    MOV AL, ORI_READ_BUF + 1
    MOV AH, 0
    MOV SI, AX ; 内容长度
    MOV ORI_READ_BUF[SI], '$'
    MOV AH, 09H
    LEA DX, ORI_READ_BUF + 2
    INT 21H
    CALL PRINT_LINE

    ; 关闭ORI_FILE
    MOV AH, 3EH
    MOV BX, WORD PTR FILE_ID
    INT 21H

    ; --------------------------

    ; 打开DEC_FILE
    MOV AH, 3DH
    MOV AL, 00H  ; 读
    LEA DX, DEC_FILE + 2
    INT 21H

    LEA BX, FILE_ID
    MOV [BX], AX  ; 将打开的文件的文件号AX存放到FILE_ID中
    
    ; 将DEC_FILE文件内容读出后写到DEC_READ_BUF
    MOV AH, 3FH
    MOV BX, WORD PTR FILE_ID
    MOV CX, 100 ; 要读入整个文件，CX应该大于等于整个文件内容的字节数
    LEA DX, DEC_READ_BUF + 2
    INT 21H

    ; 读入文件成功，将长度写到ORI_READ_BUF+1单元
    LEA BX, DEC_READ_BUF + 1
    MOV BYTE PTR [BX], AL

    ; 显示输出提示语句
    MOV AH, 09H
    LEA DX, DISPLAY_DEC_FILE
    INT 21H
    CALL PRINT_LINE

    ; 在DEC_READ_BUF末尾添加$，再用9号功能打印
    MOV AL, DEC_READ_BUF + 1
    MOV AH, 0
    MOV SI, AX ; 内容长度
    MOV DEC_READ_BUF[SI], '$'
    MOV AH, 09H
    LEA DX, DEC_READ_BUF + 2
    INT 21H

    ; 关闭DEC_FILE
    MOV AH, 3EH
    MOV BX, WORD PTR FILE_ID
    INT 21H

    CALL PRINT_LINE
    RET
SHOW_ORI_AND_DEC_FILE ENDP


; 生成密文表
GENERATE_CIPHER_TABLE PROC
    CALL INPUT_A_KEY  ; 读入KEY

    ; 下面由明文表生成密文表
    MOV CX, 62
    LEA DI, PLAIN_TABLE   ; DI指向明文表的首地址
    LEA SI, CIPHER_TABLE  ; SI指向密文表的首地址
LABLE2:
    ; 取出当前枚举的字符
    MOV AL, DS:[DI]  ; AL表示原字符串的当前字符
    ; 讨论ch=AL的3种情况
G_TAG1:
    ; 1. AL='a'~'z'
    CMP AL, 'a'
    ; AL<'a'就跳到TAG2
    JB G_TAG2
    ; 否则一定满足AL为小写字母
    SUB AL, 'a'
    MOV AH, AL
    JMP G_TAG_END
G_TAG2:
    ; 2. AL='A'~'Z'
    CMP AL, 'A'
    ; al<'A'就跳到TAG3
    JB G_TAG3
    ; 否则一定满足AL为大写字母
    SUB AL, 'A'
    MOV AH, AL
    ADD AH, 26
    JMP G_TAG_END
G_TAG3:
    ; 3. AL='0'~'9'
    SUB AL, '0'
    MOV AH, AL
    ADD AH, 52
G_TAG_END:
    ; AH+=KEY得到明文表中的新下标
    ADD AH, KEY
    ; AH %= 62
    ; 如果AH>=62,AH-=62
    CMP AH, 62
    JB G_NOT_MOD  ; AH<62就不%62
    SUB AH, 62  
G_NOT_MOD:    
    ; 此时AH中得到了明文表中的新下标
    ; 讨论AH的3种情况
    ; 1 AH=0~25, 密文=AH+'a'
    ; 2 AH=26~51, 密文=AH+'A'
    ; 3 AH=52~61, 密文=AH+'0'
G_NEW_TAG1:
    CMP AH, 25
    ; AH>25就跳转NEW_TAG2
    JA G_NEW_TAG2
    ADD AH, 'a'
    MOV DS:[SI], AH  ; 将密文写到加密输出符号串的对应位置
    JMP G_CUR_END  ; 之前这里忘记JMP了
G_NEW_TAG2:
    CMP AH, 51
    ; AH>51就跳转NEW_TAG3
    JA G_NEW_TAG3
    SUB AH, 26
    ADD AH, 'A'
    MOV DS:[SI], AH 
    JMP G_CUR_END
G_NEW_TAG3:
    SUB AH, 52
    ADD AH, '0'
    MOV DS:[SI], AH
G_CUR_END:
    INC SI
    INC DI
    LOOP LABLE2
; OUTPUT_CIPHER_TABLE:  ; 输出密文表验证（已验证正确）
;     CALL PRINT_LINE
;     MOV AH, 09H
;     LEA DX, CIPHER_TABLE
;     INT 21H
;     CALL PRINT_LINE
    RET
GENERATE_CIPHER_TABLE ENDP


; 输入KEY
INPUT_A_KEY PROC
    ; 提示输入小于10的非负整数
    CALL PRINT_LINE
    MOV AH, 09H
    LEA DX, KEY_INPUT
    INT 21H
    CALL PRINT_LINE

    ; 接收用户输入一个小于10的非负整数（合法性暂时不验证）
    ; 1号功能调用，从键盘键入一个字符，出口参数AL=按键ASCII码
    MOV AH, 01H
    INT 21H
    SUB AL, 30H
    MOV KEY, AL  ; 将key存放到KEY
    RET
INPUT_A_KEY ENDP


; 打印换行
PRINT_LINE PROC
    ; 2号功能调用，打印字符
    ; 入口参数 DL=字符的ASCII码
    MOV AH, 02H
    MOV DL, 0DH  ; 回车符
    INT 21H
    MOV AH, 02H
    MOV DL, 0AH  ; 换行符
    INT 21H
    RET
PRINT_LINE ENDP

CODE ENDS
END BEG