Program gmodeinfo;

{$mode objfpc}{$H+}
{$APPTYPE CONSOLE}

Uses
   {$IFDEF Unix}
      CThreads, ptcCrt, ptcMouse, ptcGraph, SysUtils;
   {$ENDIF}

   {$IFDEF DOS}
     Crt, Mouse, Graph, SysUtils;
   {$ENDIF}

   {$IFDEF Windows}
     ptcCrt, ptcMouse, ptcGraph, SysUtils;
   {$ENDIF}


Var
    ModeInfo: PModeInfo; // � �㤥� �������� ���ଠ�� � �����०����
    Rez: String;

Begin
    clrscr;
    ModeInfo:=QueryAdapterInfo;
    If ModeInfo=NIL Then
        WriteLn('�� 㤠���� ������� ���ଠ�� � �����������...')
    Else
    Begin
        WriteLn('� �ࠩ��� ', '� ०��� ', '����襭�� ', '���⮢ ');
        WriteLn('------------------------------------------------------------');
        While ModeInfo^.Next<>NIL Do
        Begin
            Write(ModeInfo^.DriverNumber:10);
            Write(ModeInfo^.ModeNumber:9);
            // Write(' "'+ModeInfo^.ModeName+'"':22);
            Rez:=IntToStr(ModeInfo^.MaxX+1)+'x'+IntToStr(ModeInfo^.MaxY+1);
            Write(Rez:11);
            WriteLn(ModeInfo^.MaxColor:7);
            ModeInfo:=ModeInfo^.Next;
        End;
        ReadLn;
    End;
End.
