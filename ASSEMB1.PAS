program assembler_test1;
{
 �ணࠬ�� � ���ன ������������� ����-�뢮� ⥪��
 �� ���᮫� MS DOS ��� �ਬ������ �⠭������ ��᪠������
 writeln, readln, ����� �⮣� �ਬ���� 
 ����-����� �� ���������� ����� ���������� MS DOS.
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
   asm  { ���⥬ �� ���᮫� �� ��ப� �१
          ���뢠��� 21 }
      mov ax, offset message+1
      mov dx, ax
      mov ax, 0
      mov ah, 09h
      int 21h
      { �뢥�� #13#10, � ���� ���室 �� ����� ��ப�  }
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

   asm { ������ �� ���᮫� ��ப� �१ ���뢠��� 21h }
      mov ax, offset input_buff
      mov dx, ax
      mov ax, 0
      mov ah, 0Ah
      int 21h
      { �뢥�� #13#10, � ���� ���室 �� ����� ��ப�  }
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
     { �����⮢�� ��ப� � ���� ��� ���� �१ �㭪�� 09h
      ���뢠��� 21h   }
      mov ax, offset input_buff { ����稬 ���� ����  }
      add ax, 1 { � ���� ��� ������� 2-� ����,
                  ����⨬ ���� �� �������  }
      mov bx, ax  { ��࠭�� ���� � bx }
      mov ax, [bx] { ����稬 �� ����� �� bx ����� ����,
                    �㦥� ��ன ����  }
      add al, 1  { ������� ������� � ����訩 ����ॣ����  }
      mov [bx],ax { ������� ���襭�� �� �������
                   ����� ���⭮ � ������, ⥯��� ��ப�
                   ��᪠�� 㢥��祭� �� ���� ᨬ���  }
      mov cx, 0
      mov ah, 0
      mov cx, ax  { � cx ����� ������ ��᪠����� ��ப�  }
      mov ax, bx
      add ax, cx { ᫮���� bx (���� ��砫� ��᪠����� ��ப�) �
                   cx - ����� ������ ��ப�  }
      mov bx, ax { ��५���� ��� ���� � bx  }
      mov ax, '$'
      mov [bx], al
    end;

    message2:='Hello, mister $';


    { �ᯥ�⥬ ��ப� �� ���� �㭪樥� 09h ���뢠��� 21h  }
    asm
      { ������ �� ���᮫� ��ப� �१ ���뢠��� 21h }
      lea ax, message2
      add ax, 1
      mov dx, ax
      mov ax, 0
      mov ah, 09h
      int 21h
      { ������ �� ���᮫� ��ப� �१ ���뢠��� 21h }
      lea ax, input_buff
      add ax, 2
      mov dx, ax
      mov ax, 0
      mov ah, 09h
      int 21h
      { �뢮��� ��ॢ�� ��ப� ��� ����� ��ਠ�⮬ }
      jmp @continuation { ��室 ��ப� ������  }
      { ��ப� ������, ����㯠�� �१ ���� ��⪨  }
      @codesegment_string: db '    STRING FROM CODE SEGMENT','$'
      @continuation:  nop { ��⪠ ��室� ��ப� ������  }
      push ds { ��࠭�� ॣ���� ds  }
      push cs { �����⨬ ॣ���� cs � �⥪  }
      pop ds { ds = cs  }
      mov dx, OFFSET @codesegment_string { DS:DX  ���� ��ப�  }
      mov ax, 0
      mov ah, 09h { 09h - ��� �㭪樨 �뢮��  }
      int 21h  { ��뢠�� ���뢠��� DOS  }
      pop ds  { ����⠭�������� DS  }
    end;

    asm
     call test1
    end;

   writeln('LongMul: ', 2000*2000 , ' ---',  LongMul( 2000, 2000 )  );

   readln;

end.