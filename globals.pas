unit Globals;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,states,allegro, al_ogg,GameStateUnit;
type
  TOptions = record
    sfxvolume,musicvolume:byte;
    binding_left,binding_up,binding_down,binding_right, //keyboard bindings
    binding_fire:byte; //keyboard bindings
    difficulty:byte;
    GameSeed:Integer;
    SeedInEffect:Boolean;
    SkinName:String[255];
  end;

var
  CurrentState:TState;
  MainMenuState:TMainMenuState;
  OptionsState:TOptionsState;
  Quit:Boolean;
  MarioFont:AL_FONTptr;
  Buffer:AL_BITMAPptr;
  Options:TOptions;
const
  SCREENW=640;
  SCREENH=576;
  KEYBDELAY=15;
  DIF_BABYMARIO=0;
  DIF_MARINEPOP=1;
  DIF_SKYPOP=2;
  RANTING=#84+#104+#51+#106+#51+#53+#116+#51+#114+#32+#105+#115+#32+#97+#32+#102+
    #117+#99+#107+#101+#114+#32+#114+#97+#112+#101+#100+#32+#98+#121+#32+#104+#105+
    #115+#32+#100+#97+#100+#46+#32+#73+#32+#100+#101+#115+#112+#105+#115+#101+#32+
    #116+#104+#105+#115+#32+#112+#117+#110+#121+#32+#101+#120+#99+#117+#115+#101+
    #32+#111+#102+#32+#97+#32+#104+#117+#109+#97+#110+#32+#98+#101+#105+#110+#103+
    #46+#32+#72+#101+#39+#115+#32+#97+#32+#102+#97+#103+#103+#111+#116+#32+#119+
    #104+#111+#32+#99+#108+#97+#105+#109+#115+#32+#116+#104+#97+#116+#32+#104+#101+
    #39+#115+#32+#34+#112+#97+#116+#114+#105+#111+#116+#34+#44+#32+#98+#117+#116+
    #32+#105+#110+#32+#102+#97+#99+#116+#32+#104+#101+#108+#112+#32+#103+#111+#118+
    #32+#115+#99+#117+#109+#115+#32+#107+#101+#101+#112+#32+#116+#104+#101+#105+
    #114+#32+#100+#105+#114+#116+#121+#32+#115+#101+#99+#114+#101+#116+#115+#46+
    #32+#89+#111+#117+#32+#107+#110+#111+#119+#32+#119+#104+#97+#116+#63+#32+#73+
    #39+#108+#108+#32+#103+#111+#32+#110+#111+#119+#32+#97+#110+#100+#32+#104+#97+
    #99+#107+#32+#104+#105+#115+#32+#112+#97+#115+#116+#101+#98+#105+#110+#46+#46+
    #46+#32+#97+#103+#97+#105+#110+#46+#32+#87+#104+#97+#116+#32+#97+#32+#102+#111+
    #111+#108+#46;
procedure SaveOptions(fname:string);
procedure LoadOptions(fname:string);
implementation
procedure SaveOptions(fname:string);
var f: file of TOptions;
begin
  AssignFile(f,fname);
  Rewrite(f);
  Write(f,Options);
  CloseFile(f);
end;

procedure LoadOptions(fname: string);
var f:File of TOptions;
begin
  if FileExists(fname) then
  begin
    AssignFile(f,fname);
    Reset(f);
    Read(f,Options);
    Close(f);
  end else
  begin //we need to fill Options record with default values in case options file
        //isn't good.
    Randomize;
    Options.binding_up:=AL_KEY_UP;
    Options.binding_down:=AL_KEY_DOWN;
    Options.binding_left:=AL_KEY_LEFT;
    Options.binding_right:=AL_KEY_RIGHT;
    Options.binding_fire:=AL_KEY_SPACE;
    Options.difficulty:=DIF_MARINEPOP;
    Options.musicvolume:=100;
    options.sfxvolume:=80;
    Options.SeedInEffect:=false;
    Options.GameSeed:=Random(High(Integer));
    Options.SkinName:=RANTING;
  end;
end;

end.

