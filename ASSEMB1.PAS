program assembler_test1;
{
 программа в которой демонстрируется ввод-вывод текста
 на консоль MS DOS без применения стандартных паскалевких
 writeln, readln, вместо этого применен 
 ВВОД-ВЫВОД НА АССЕМБЛЕРЕ ЧЕРЕЗ ПРЕРЫВАНИЯ MS DOS.
}


uses  crt
      ,graph
      ,u_assmb1
      {$IFDEF DPMI}
      ,winapi
      {$ENDIF}
      ;

procedure check_mode;
begin
  {$IFDEF DPMI}
   clrscr;
   writeln('PROGRAM STOPPED! Only for real mode!');
   halt(1);
  {$ENDIF}
end;

type
  DOS_input_buffer = record
    buff_size : byte;
    buffer  : string[255];
  end;

var
  message: string[255];
  input_buff : DOS_input_buffer;
  message2 : string[255];

function LongMul( X,Y: integer ) : LongInt; assembler;
asm
   mov  ax, X
   imul Y
end;


begin
   check_mode;

   message := 'Welcome To Pascal Inline Assembler And Dos' + #13#10 +
              'Please Input Your Name: $';
   asm  { печатем на консоль из строки через
          прерывание 21 }
      mov ax, offset message+1
      mov dx, ax
      mov ax, 0
      mov ah, 09h
      int 21h
      { вывести #13#10, то есть переход на новую строку  }
      mov dl, 10
      mov ax, 0
      mov ah, 02h
      int 21h
      mov dl, 13
      mov ax, 0
      mov ah, 02h
      int 21h
   end;

   input_buff.buff_size := 255;

   asm { вводим из консоли строку через прерывание 21h }
      mov ax, offset input_buff
      mov dx, ax
      mov ax, 0
      mov ah, 0Ah
      int 21h
      { вывести #13#10, то есть переход на новую строку  }
      mov dl, 10
      mov ax, 0
      mov ah, 02h
      int 21h
      mov dl, 13
      mov ax, 0
      mov ah, 02h
      int 21h
   end;

   asm
     { подготовим строку в буфере для печати через функцию 09h
      прерывания 21h   }
      mov ax, offset input_buff { получим адрес буфера  }
      add ax, 1 { в адресе нас интересует 2-й байт,
                  прирастим адрес на единицу  }
      mov bx, ax  { сохраним адрес в bx }
      mov ax, [bx] { получим по адресу из bx данные буфера,
                    нужен второй байт  }
      add al, 1  { добавим единицу в младший полурегистр  }
      mov [bx],ax { положим прирашенные на единицу
                   данные обратно в память, теперь строка
                   паскаля увеличена на один символ  }
      mov cx, 0
      mov ah, 0
      mov cx, ax  { в cx новая длинна паскалевой строки  }
      mov ax, bx
      add ax, cx { сложили bx (адрес начала паскалевой строки) и
                   cx - новую длинну строки  }
      mov bx, ax { переложим этот адрес в bx  }
      mov ax, '$'
      mov [bx], al
    end;

    message2:='Hello, mister $';


    { распечатем строку из буфера функцией 09h прерывания 21h  }
    asm
      { вводим из консоли строку через прерывание 21h }
      lea ax, message2
      add ax, 1
      mov dx, ax
      mov ax, 0
      mov ah, 09h
      int 21h
      { вводим из консоли строку через прерывание 21h }
      lea ax, input_buff
      add ax, 2
      mov dx, ax
      mov ax, 0
      mov ah, 09h
      int 21h
      { выводим перевод строки ещё одним вариантом }
      jmp @continuation { обход строки данных  }
      { строка данных, доступаня через адрес метки  }
      @codesegment_string: db '    STRING FROM CODE SEGMENT','$'
      @continuation:  nop { метка обхода строки данных  }
      push ds { сохраним регистр ds  }
      push cs { поместим регистр cs в стек  }
      pop ds { ds = cs  }
      mov dx, OFFSET @codesegment_string { DS:DX  адрес строки  }
      mov ax, 0
      mov ah, 09h { 09h - код функции вывода  }
      int 21h  { вызываем прерывание DOS  }
      pop ds  { восстанавливаем DS  }
    end;

    asm
     call test1
    end;

   writeln('LongMul: ', 2000*2000 , ' ---',  LongMul( 2000, 2000 )  );

   readln;

end.