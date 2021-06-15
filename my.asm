DATA SEGMENT
ORI_FILE DB 'fils\ori_file.txt', 0  ; 原始文件
ENC_FILE DB 'files\enc_file.txt', 0  ; 加密文件
DEC_FILE DB 'files\dec_file.txt', 0  ; 解密文件
CHOICE1 db '1. Encrypt a string.', '$'  ; 1. 加密字符串
CHOICE2 db '2. Decrypt a string.', '$'  ; 2. 解密字符串
CHOICE3 db '3. Encrypt a file.', '$'  ; 3.加密文件
CHOICE4 db '4. Decrypt a file.', '$'  ; 4. 解密文件
CHOICE5 db '5. Show orininal file and decrypted file.', '$'  ; 5. 显示原始文件和解密文件
CHOICE6 db '6. Exit', '$'  ; 退出
CHOICE_INPUT db 'Your choice is: ', '$'
CHOICE_INPUT_ERROR db 'Please input valid choice!', '$'

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
    ; 3. 
    ;


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