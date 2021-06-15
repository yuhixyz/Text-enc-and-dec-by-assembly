; 预期用两种简单加密组合
; 1. 凯撒加密
; 2. 置换加密

DATA SEGMENT
ORI_FILE DB 'fils\ori_file.txt', 0  ; 原始文件
ENC_FILE DB 'files\enc_file.txt', 0  ; 加密文件
DEC_FILE DB 'files\dec_file.txt', 0  ; 解密文件
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
ORI_INPUT_BUF DB 101, ?, 100 DUP(?)  ; 原文的输入缓冲区
ENC_OUTPUT_BUF DB 100 DUP(?)  ; 密文的输出缓冲区
ENC_INPUT_BUF DB 101, ?, 100 DUP(?)  ;  密文的输入缓冲区
DEC_OUTPUT_BUF DB 100 DUP(?)  ;  解密文的输出缓冲区
KEY DB 0  ; 密钥0~9
AFTER_ENC DB 'String after encryption: ', '$'
 

DATA ENDS


CODE SEGMENT
    ASSUME DS:DATA, CS:CODE
BEG:
    MOV AX, DATA
    MOV DS, AX
    ; 显示主菜单
    CALL SHOW_MAIN_MENU
    
    ; call SHOW_MAIN_MENU
    ; 1. 加密字符串 -> 输入字符串和key
    ; 2. 解密字符串 -> 输入字符串和key
    ; 3. 加密文件 -> 输入文件路径和key,输入加密后的文件路径
    ; 4. 解密文件 -> 输入文件路径和key,输入解密后的文件路径
    ; 5. 显示原始文件ORI_FILE和解密文件DEC_FILE的内容
    ; 6. Exit
    ; 1,2,3,4,5完成后会跳转回到主菜单

CALL_SOLVE_CHOICE:  ; 处理用户的选择
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
    JMP CALL_SOLVE_CHOICE
SOLVE_CHOICE_END:
    RET
SOLVE_CHOICE ENDP


; 加密一个字符串
ENC_A_STR PROC
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

    ; 验证合法性（只含有数字和字母，暂时不写）

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
    RET
ENC_A_STR ENDP


; 解密一个字符串
DEC_A_STR PROC


    RET
DEC_A_STR ENDP


; 加密一个文件
ENC_A_FILE PROC



    RET
ENC_A_FILE ENDP


; 解密一个文件
DEC_A_FILE PROC


    RET
DEC_A_FILE ENDP


; 显示原文件和解密的文件
SHOW_ORI_AND_DEC_FILE PROC


    RET
SHOW_ORI_AND_DEC_FILE ENDP


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