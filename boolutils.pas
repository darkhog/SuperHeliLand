unit boolUtils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;
  //following functions checks if value is between specific range, so we can avoid
  //complicated and potentially faulty if statements.
  function Between(num,min,max:Integer):Boolean;
  function Between(num,min,max:Double):Boolean;
  function Between(num,min,max:Single):Boolean;
  function Between(num,min,max:Real):Boolean;
implementation
  function Between(num,min,max:Integer):Boolean;
  begin
    Result:=(num<max) and (num>min);
  end;
  function Between(num,min,max:Double):Boolean;
  begin
    Result:=(num<max) and (num>min);
  end;
  function Between(num,min,max:Single):Boolean;
  begin
    Result:=(num<max) and (num>min);
  end;
  function Between(num,min,max:Real):Boolean;
  begin
    Result:=(num<max) and (num>min);
  end;
end.

