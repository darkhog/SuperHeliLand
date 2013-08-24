unit States;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,sprites,allegro,al_ogg,contnrs,GameObjects;

type

  { TState }

  TState = class
    public
      constructor Create;virtual;
      destructor Destroy;override;
      procedure Update;virtual;
      procedure BeforeDraw;virtual;
      procedure Draw;virtual;
      procedure Main;virtual;

    private

  end;

  { TOptionsState }

  TOptionsState = class(TState)
    public
      constructor Create;override;
      destructor Destroy;override;
      procedure Update;override;
      procedure BeforeDraw;override;
      procedure Draw;override;
      procedure Main;override;
    private
      BGSprite:TSprite;
      SelectionShroomSprite:TSprite;
      keybelapsed:integer;
      SFXSprite:TSprite;
      MUSSprite:TSprite;
      SaveSprite:TSprite;
      CancelSprite:TSprite;
      BindingsSprite:TSprite;
      GaugebackSprite:TSprite;
      SFXGaugeSprite:TSprite;
      MUSGaugeSprite:TSprite;
      MenuIndex:Integer;
      destroying:Boolean;
      music:AL_SAMPLEptr;
      firstupdate:boolean;
  end;
  { TMainMenuState }

  TMainMenuState = class(TState)
    public
      constructor Create;override;
      destructor Destroy;override;
      procedure Update;override;
      procedure BeforeDraw;override;
      procedure Draw;override;
      procedure Main;override;
    private
      keybelapsed:Integer;
      BGSprite:TSprite;
      SelectionShroomSprite:TSprite;

      StartItemSprite:TSprite;
      OptionItemSprite:TSprite;
      ExitItemSprite:TSprite;
      MenuIndex:Integer;
      destroying:boolean;

  end;

  { TDebugState }

  TDebugState = class(TState)
    public
      constructor Create;override;
      destructor Destroy;override;
      procedure Update;override;
      procedure BeforeDraw;override;
      procedure Draw;override;
      procedure Main;override;
    private
      keybelapsed:Integer;
      MarioGO: TGameObject;
      OtherMarioGO:TGameObject;
      DebugText:AL_BITMAPptr;
      DebugHUE:Integer;
  end;

  function keyreleased(idx:Integer):Boolean;
implementation
uses globals;
var
  last_al_key : AL_KEY_LIST;

{ TDebugState }

constructor TDebugState.Create;
var bmp,bmp2:AL_BITMAPptr;
    ASprite:TAnimatedSprite;
begin
  inherited Create;
  //loading MarioGO
  bmp:=al_load_pcx('mariosub.pcx',@al_default_palette);
  bmp2:=al_load_pcx('mariosub_mask.pcx',@al_default_palette);
  ASprite:=TAnimatedSprite.Create(bmp,bmp2,2,atLoop);
  Asprite.DelayBetweenFrames:=6;
  ASprite.magentatransparent:=true;
  ASprite.FrameWidth:=16;
  ASprite.ScaleFactor:=4;
  MarioGO:=TGameObject.Create(ASprite);
  Mariogo.x:=0;
  Mariogo.y:=0;
  MarioGO.CurrentAnim:=0;
  //loading OtherMarioGO
  bmp:=al_load_pcx('mariosub_rev.pcx',@al_default_palette);
  bmp2:=al_load_pcx('mariosub_rev_mask.pcx',@al_default_palette);
  ASprite:=TAnimatedSprite.Create(bmp,bmp2,2,atLoop);
  Asprite.DelayBetweenFrames:=6;
  ASprite.FrameWidth:=16;
  ASprite.magentatransparent:=true;
  ASprite.ScaleFactor:=4;
  OtherMarioGO:=TGameObject.Create(ASprite);
  OtherMarioGO.x:=6*8*4;
  OtherMarioGO.y:=6*8*4;
  OtherMarioGO.CurrentAnim:=0;
  //creating debug text bitmap
  DebugText:=al_create_bitmap(5*8,8); //we don't need to draw text, as we we'll
                                      //do that in draw, but we need to make this bitmap.
  DebugHUE:=0; //setting default hue. Debug will be rainbow-y.


end;

destructor TDebugState.Destroy;
begin
  al_destroy_bitmap(DebugText);
  MarioGO.Destroy;
  OtherMarioGO.Destroy;
  inherited Destroy;
end;

procedure TDebugState.Update;
var oldx,oldy:Integer;
begin
 { lastup:=false;
  lastdown:=false;
  lastleft:=false;
  lastright:=false;}
  oldx:=MarioGO.x;
  oldy:=MarioGO.y;
  Inc(DebugHUE);
  MarioGO.Update;
  OtherMarioGO.Update;
  if DebugHUE>=360 then DebugHUE:=0;

  //movement
  if al_key[Options.binding_up]<>0 then begin
    MarioGO.y:=MarioGO.y-4;
    if MarioGO.isColliding(OtherMarioGO) then MarioGO.y:=oldy;
  end;
  if al_key[Options.binding_down]<>0 then begin
    MarioGO.y:=MarioGO.y+4;
    if MarioGO.isColliding(OtherMarioGO) then MarioGO.y:=oldy;
  end;
  if al_key[Options.binding_left]<>0 then begin
    MarioGO.x:=MarioGO.x-4;
    if MarioGO.isColliding(OtherMarioGO) then MarioGO.x:=oldx;
  end;
  if al_key[Options.binding_right]<>0 then begin
    MarioGO.x:=MarioGO.x+4;
    if MarioGO.isColliding(OtherMarioGO) then MarioGO.x:=oldx;
  end;

  //reacting to collisions;

  {if ((MarioGO.isColliding(OtherMarioGO)) and (lastdown)) then MarioGO.y:=MarioGO.y-8;
  if ((MarioGO.isColliding(OtherMarioGO)) and (lastleft)) then MarioGO.x:=MarioGO.x+8;
  if ((MarioGO.isColliding(OtherMarioGO)) and (lastright)) then MarioGO.x:=MarioGO.x-8;}

  //if ESC was pressed, return to main menu
  if al_key[AL_KEY_ESC]<>0 then CurrentState:=MainMenuState;
  inherited Update;
end;

procedure TDebugState.BeforeDraw;
var r,g,b:Integer;
begin
  inherited BeforeDraw;
  al_clear_to_color(DebugText,al_makecol(255,0,255));
  al_hsv_to_rgb(DebugHUE,1,1,r,g,b);
  al_textout_ex(DebugText,MarioFont,'DEBUG',0,0,al_makecol(r,g,b),-1);
end;

procedure TDebugState.Draw;
begin
  inherited Draw;
  al_clear_to_color(Buffer,al_makecol(255,255,255));
  if MarioGO.isColliding(OtherMarioGO) then al_rectfill(Buffer,6*8*4,0,7*8*4,8*4,al_makecol(0,0,255));
  if MarioGO.y>OtherMarioGO.y then begin
    OtherMarioGO.Draw(Buffer);
    MarioGO.Draw(buffer);
  end else begin
    MarioGO.Draw(buffer);
    OtherMarioGO.Draw(Buffer);  //simple y-sorting.
  end;
  al_masked_stretch_blit(DebugText,Buffer,0,0,DebugText^.w,DebugText^.h,0,0,DebugText^.w*4,DebugText^.h*4);
  al_blit(Buffer,al_screen,0,0,0,0,SCREENW,SCREENH);
end;

procedure TDebugState.Main;
begin
  inherited Main;
end;

{ TGameState }



{ TOptionsState }

constructor TOptionsState.Create;
var bmp:AL_BITMAPptr;
begin
  inherited Create;
  //loading music
  music:=LoadOGGVorbis('music/underground.ogg');
  //loading background
  bmp:=al_load_pcx('optionbg.pcx',@al_default_palette);
  BGSprite:=TSprite.Create(bmp,bmp);
  BGSprite.ScaleFactor:=4;
  BGSprite.UpdateMask; //need to be called.
  //loading selection mushroom
  bmp:=al_load_pcx('mushroom.pcx',@al_default_palette);
  SelectionShroomSprite:=TSprite.Create(bmp,bmp);
  SelectionShroomSprite.ScaleFactor:=4;
  SelectionShroomSprite.UpdateMask; //need to be called.
  SelectionShroomSprite.x:=16*4;
  SelectionShroomSprite.y:=32*4;
  SelectionShroomSprite.magentatransparent:=true;
  //loading gaugeback
  bmp:=al_load_pcx('gaugeback.pcx',@al_default_palette);
  GaugebackSprite:=TSprite.Create(bmp,bmp);
  GaugebackSprite.ScaleFactor:=4;
  GaugebackSprite.UpdateMask; //need to be called.
  GaugebackSprite.magentatransparent:=true;
  //loading sfx gauge
  bmp:=al_load_pcx('actualgauge.pcx',@al_default_palette);
  SFXGaugeSprite:=TSprite.Create(bmp,bmp);
  SFXGaugeSprite.ScaleFactor:=4;
  SFXGaugeSprite.x:=56*4;
  SFXGaugeSprite.y:=32*4;
  SFXGaugeSprite.UpdateMask; //need to be called.
  SFXGaugeSprite.magentatransparent:=true;
  //loading mus gauge
  bmp:=al_load_pcx('actualgauge.pcx',@al_default_palette);
  MUSGaugeSprite:=TSprite.Create(bmp,bmp);
  MUSGaugeSprite.ScaleFactor:=4;
  MUSGaugeSprite.x:=56*4;
  MUSGaugeSprite.y:=40*4;
  MUSGaugeSprite.UpdateMask; //need to be called.
  MUSGaugeSprite.magentatransparent:=true;
  //creating BINDINGS text
  bmp:=al_create_bitmap(8*8,8);
  al_clear_to_color(bmp,al_makecol(255,0,255)); //need to be used so text would be transparent.
  al_textout_ex(bmp,MarioFont,'Bindings',0,0,al_makecol(0,0,0),-1);
  BindingsSprite:=TSprite.Create(bmp,bmp);
  BindingsSprite.ScaleFactor:=4;
  BindingsSprite.x:=24*4;
  BindingsSprite.y:=48*4;
  BindingsSprite.magentatransparent:=true;
  //creating SFX text
  bmp:=al_create_bitmap(3*8,8);
  al_clear_to_color(bmp,al_makecol(255,0,255)); //need to be used so text would be transparent.
  al_textout_ex(bmp,MarioFont,'Sfx',0,0,al_makecol(0,0,0),-1);
  SFXSprite:=TSprite.Create(bmp,bmp);
  SFXSprite.ScaleFactor:=4;
  SFXSprite.x:=24*4;
  SFXSprite.y:=32*4;
  SFXSprite.magentatransparent:=true;
  //creating MUS text
  bmp:=al_create_bitmap(3*8,8);
  al_clear_to_color(bmp,al_makecol(255,0,255)); //need to be used so text would be transparent.
  al_textout_ex(bmp,MarioFont,'Mus',0,0,al_makecol(0,0,0),-1);
  MUSSprite:=TSprite.Create(bmp,bmp);
  MUSSprite.ScaleFactor:=4;
  MUSSprite.x:=24*4;
  MUSSprite.y:=40*4;
  MUSSprite.magentatransparent:=true;
  //creating CANCEL text
  bmp:=al_create_bitmap(6*8,8);
  al_clear_to_color(bmp,al_makecol(255,0,255)); //need to be used so text would be transparent.
  al_textout_ex(bmp,MarioFont,'Cancel',0,0,al_makecol(0,0,0),-1);
  CancelSprite:=TSprite.Create(bmp,bmp);
  CancelSprite.ScaleFactor:=4;
  CancelSprite.x:=24*4;
  CancelSprite.y:=72*4;
  CancelSprite.magentatransparent:=true;
  //creating SAVE text
  bmp:=al_create_bitmap(4*8,8);
  al_clear_to_color(bmp,al_makecol(255,0,255)); //need to be used so text would be transparent.
  al_textout_ex(bmp,MarioFont,'Save',0,0,al_makecol(0,0,0),-1);
  SaveSprite:=TSprite.Create(bmp,bmp);
  SaveSprite.ScaleFactor:=4;
  SaveSprite.x:=24*4;
  SaveSprite.y:=64*4;
  SaveSprite.magentatransparent:=true;
  keybelapsed:=0;
  //setting menu index
  MenuIndex:=0;
  // we don't destroy anything yet
  destroying:=false;
  //we need to set this so music will start playing
  firstupdate:=true;
end;

destructor TOptionsState.Destroy;
begin
  //we need to set that to avoid potential segfaults related to drawing or updating
  destroying:=true;

  //removing save option sprite
  if SaveSprite<>nil then SaveSprite.Destroy;
  //removing Cancel option sprite
  if CancelSprite<>nil then CancelSprite.Destroy;
  //removing bindings option sprite
  if BindingsSprite<>nil then BindingsSprite.Destroy;
  //removing SFX Gauge sprite
  if SFXGaugeSprite<>nil then SFXGaugeSprite.Destroy;
  //removing MUS Gauge sprite
  if MUSGaugeSprite<>nil then MUSGaugeSprite.Destroy;
  //removing MUS text sprite
  if MUSSprite<>nil then MUSSprite.Destroy;
  //removing SFX text sprite
  if SFXSprite<>nil then SFXSprite.Destroy;
  //removing gauge back sprite
  if GaugebackSprite<>nil then GaugebackSprite.Destroy;
  //removing selection shroom
  if SelectionShroomSprite<>nil then SelectionShroomSprite.Destroy;
  //removing background
  if BGSprite<>nil then BGSprite.Destroy;
  //stopping & destroying music
  al_stop_sample(music);
  al_destroy_sample(music);
  inherited Destroy;
end;

procedure TOptionsState.Update;
const LastMenuIndex=4;
begin
  Inc(keybelapsed);
  if not destroying then
  begin
    if firstupdate then
    begin
      firstupdate:=false;
      al_play_sample(music,round((options.musicvolume/100)*255),127,1000,1); //allegro handles music volume in 0..255 range rather than in percentage, so
                                                                             //we need to calculate that.
    end;
    if ((al_key[Options.binding_up]<>0) and (keybelapsed>=KEYBDELAY)) then begin Dec(MenuIndex); keybelapsed:=0; end;
    if ((al_key[Options.binding_down]<>0) and (keybelapsed>=KEYBDELAY)) then begin Inc(MenuIndex); keybelapsed:=0; end;
    if MenuIndex>LastMenuIndex then MenuIndex:=0;
    if MenuIndex<0 then MenuIndex:=LastMenuIndex;
    case MenuIndex of
      0 : begin SelectionShroomSprite.y:=32*4; end; //sfx
      1 : begin SelectionShroomSprite.y:=40*4; end;//mus
      2 : begin SelectionShroomSprite.y:=48*4; end;//bindings
      3 : begin SelectionShroomSprite.y:=64*4; end;//save
      4 : begin SelectionShroomSprite.y:=72*4; end;//cancel
    end;
    if ((al_key[AL_KEY_ENTER]<>0) or (al_key[AL_KEY_ENTER_PAD]<>0) or (al_key[Options.binding_fire]<>0)) and (keybelapsed>=KEYBDELAY) then
    begin
      keybelapsed:=0;
      case MenuIndex of
      2 : begin end;//bindings
      //this may flop, we'll see.
      3 : begin SaveOptions('game.opt'); al_stop_sample(music); firstupdate:=true; CurrentState:=MainMenuState; exit; end;//save
      4 : begin LoadOptions('game.opt'); al_stop_sample(music); firstupdate:=true; CurrentState:=MainMenuState; exit; end;//cancel
      end;
    end;
    if ((al_key[Options.binding_left]<>0) and (keybelapsed>=KEYBDELAY)) then
    begin
      keybelapsed:=0;
      case MenuIndex of
      0 : begin
            if Options.sfxvolume>0 then Options.sfxvolume:=Options.sfxvolume -10;
            if Options.sfxvolume>100 then Options.sfxvolume:=0; //aditional check in case we accidentally go outta range;
          end;
      1 : begin
            if Options.musicvolume>0 then Options.musicvolume:=Options.musicvolume -10;
            if Options.musicvolume>100 then Options.musicvolume:=0; //aditional check in case we accidentally go outta range;
          end;
      end;

    end;
    if ((al_key[Options.binding_right]<>0) and (keybelapsed>=KEYBDELAY)) then
    begin
      keybelapsed:=0;
      case MenuIndex of
      0 : begin
            if Options.sfxvolume<100 then Options.sfxvolume:=Options.sfxvolume +10;
            if Options.sfxvolume>100 then Options.sfxvolume:=100; //aditional check in case we accidentally go outta range;
          end;
      1 : begin
            if Options.musicvolume<100 then Options.musicvolume:=Options.musicvolume +10;
            if Options.musicvolume>100 then Options.musicvolume:=100; //aditional check in case we accidentally go outta range;
          end;
      end;

    end;
    SFXGaugeSprite.x:=(56+((Options.sfxvolume div 10)*8))*4; //setting on-screen position of gauge for sfx volume
    MUSGaugeSprite.x:=(56+((Options.musicvolume div 10)*8))*4; //setting on-screen position of gauge for music volume
  end;
  inherited Update;
end;

procedure TOptionsState.BeforeDraw;
begin
  al_adjust_sample(music,round((options.musicvolume/100)*255),127,1000,1); //allegro keeps music volume in 0..255 range rather than as 0..100 percentage
                                                                           //so we need to calculate that.
  inherited BeforeDraw;
end;

procedure TOptionsState.Draw;
var i:integer;
begin
  if not destroying then
  begin
    //drawing background
    BGSprite.Draw(buffer);
    //putting gauge background
    for i:=0 to 10 do
    begin
      GaugebackSprite.Put(Buffer,(56+(i*8))*4,SFXSprite.y);
      GaugebackSprite.Put(Buffer,(56+(i*8))*4,MUSSprite.y);
    end;
    //putting actual gauges
    SFXGaugeSprite.Draw(Buffer);
    MUSGaugeSprite.Draw(Buffer);
    //drawing labels and menu items
    SFXSprite.Draw(Buffer);
    MUSSprite.Draw(Buffer);
    SaveSprite.Draw(Buffer);
    CancelSprite.Draw(Buffer);
    BindingsSprite.Draw(Buffer);
    //drawing selection shroom:
    SelectionShroomSprite.Draw(buffer);
  //background image
  //SelectionShroomx: 16
  //sfx: 24,32
  //mus: 24,40
  //bindings: 24,48
  //save: 24,64
  //cancel: 24,72
  //gaugestartx: 56
    al_blit(buffer,al_screen,0,0,0,0,SCREENW,SCREENH); //blitting (double buffering), so we won't have "blinking screen".
  end;
  inherited Draw;
end;

procedure TOptionsState.Main;
begin
  inherited Main;
end;


{ TMainMenuState }

constructor TMainMenuState.Create;
var bmp:AL_BITMAPptr;
begin
  inherited;
  //creating title image
  bmp:=al_load_pcx('title.pcx',@al_default_palette);
  BGSprite:=TSprite.Create(bmp,bmp);
  BGSprite.ScaleFactor:=4;
  BGSprite.UpdateMask; //need to be called.
  //loading selection mushroom
  bmp:=al_load_pcx('mushroom.pcx',@al_default_palette);
  SelectionShroomSprite:=TSprite.Create(bmp,bmp);
  SelectionShroomSprite.ScaleFactor:=4;
  SelectionShroomSprite.UpdateMask; //need to be called.
  SelectionShroomSprite.x:=32*4;
  SelectionShroomSprite.y:=96*4;
  SelectionShroomSprite.magentatransparent:=true;
  //creating Start option sprite
  bmp:=al_create_bitmap(5*8,8);
  al_clear_to_color(bmp,al_makecol(255,0,255));
  al_textout_ex(bmp,MarioFont,'Start',0,0,al_makecol(0,0,0),-1); //need to be used so text would be transparent.
  StartItemSprite:=TSprite.Create(bmp,bmp);
  StartItemSprite.ScaleFactor:=4;
  StartItemSprite.x:=40*4;
  StartItemSprite.y:=96*4;
  StartItemSprite.magentatransparent:=true;
  //creating "Option" option sprite
  bmp:=al_create_bitmap(6*8,8);
  al_clear_to_color(bmp,al_makecol(255,0,255));
  al_textout_ex(bmp,MarioFont,'Option',0,0,al_makecol(0,0,0),-1); //need to be used so text would be transparent.
  OptionItemSprite:=TSprite.Create(bmp,bmp);
  OptionItemSprite.ScaleFactor:=4;
  OptionItemSprite.x:=40*4;
  OptionItemSprite.y:=104*4;
  OptionItemSprite.magentatransparent:=true;
  //creating Exit option sprite
  bmp:=al_create_bitmap(4*8,8);
  al_clear_to_color(bmp,al_makecol(255,0,255));
  al_textout_ex(bmp,MarioFont,'Exit',0,0,al_makecol(0,0,0),-1); //need to be used so text would be transparent.
  ExitItemSprite:=TSprite.Create(bmp,bmp);
  ExitItemSprite.ScaleFactor:=4;
  ExitItemSprite.x:=40*4;
  ExitItemSprite.y:=112*4;
  ExitItemSprite.magentatransparent:=true;
  //setting menu index to 0
  MenuIndex:=0;
  //telling we aren't destroying state just yet
  destroying:=false;
  //initializing keyboard delay, so it won't go too fast:
  keybelapsed:=0;
end;

destructor TMainMenuState.Destroy;
begin

  //we need to set that to avoid potential segfaults related to drawing
  destroying:=true;
  //removing buffer
  //removing exit option sprite
  if ExitItemSprite<>nil then ExitItemSprite.Destroy;
  //removing "option" option sprite
  if OptionItemSprite<>nil then OptionItemSprite.Destroy;
  //removing start option sprite
  if StartItemSprite<>nil then StartItemSprite.Destroy;
  //removing selection mushroom
  if SelectionShroomSprite<>nil then SelectionShroomSprite.Destroy;
  //removing title card
  if BGSprite<>nil then BGSprite.Destroy;
  inherited Destroy;
end;

procedure TMainMenuState.Update;
const LastMenuIndex=2;
begin
  inherited;
  Inc(keybelapsed);
  if not destroying then
  begin //making sure we won't get any accidental segfaults
    //handling Debug State, to activate: right ctrl+left shift+D.
    if ((al_key[AL_KEY_RCONTROL]<>0) and (al_key[AL_KEY_LSHIFT]<>0) and (al_key[AL_KEY_D]<>0) and (keybelapsed>=KEYBDELAY))  then
      begin
        keybelapsed:=0;
        CurrentState:=DebugState;
      end;

    //handling keyboard
    if ((al_key[Options.binding_up]<>0) and (keybelapsed>=KEYBDELAY)) then begin Dec(MenuIndex); keybelapsed:=0; end;
    if ((al_key[Options.binding_down]<>0) and (keybelapsed>=KEYBDELAY)) then begin Inc(MenuIndex); keybelapsed:=0; end;
    if MenuIndex>LastMenuIndex then MenuIndex:=0;
    if MenuIndex<0 then MenuIndex:=LastMenuIndex;
    case MenuIndex of
      0 : begin SelectionShroomSprite.y:=96*4; end; //start
      1 : begin SelectionShroomSprite.y:=104*4; end;//option
      2 : begin SelectionShroomSprite.y:=112*4; end;//exit
    end;
    if ((al_key[AL_KEY_ENTER]<>0) or (al_key[AL_KEY_ENTER_PAD]<>0) or (al_key[Options.binding_fire]<>0)) and (keybelapsed>=KEYBDELAY) then
    begin
      keybelapsed:=0;
      case MenuIndex of
      0 : begin  end; //start
      1 : begin CurrentState:=OptionsState; end;//option
      2 : begin quit:=true; end;//exit
    end;
    end;
  end;
end;

procedure TMainMenuState.BeforeDraw;
begin
  inherited;
end;

procedure TMainMenuState.Draw;
begin
  inherited;
  if ((not destroying)and (not quit)) then
  begin
    //we embed it that way, just to avoid potential segfaults.
    if BGSprite<>nil then BGSprite.Draw(Buffer);
    if StartItemSprite<>nil then StartItemSprite.Draw(Buffer);
    if OptionItemSprite<>nil then OptionItemSprite.Draw(Buffer);
    if ExitItemSprite<>nil then ExitItemSprite.Draw(Buffer);
    if SelectionShroomSprite<>nil then SelectionShroomSprite.Draw(Buffer);
    al_blit(buffer,al_screen,0,0,0,0,SCREENW,SCREENH);
  end;
end;

procedure TMainMenuState.Main;
begin
  inherited;
end;
//obsolete, unused and not working
//TODO: Remove it sometime.
function keyreleased(idx: Integer): Boolean;

begin
  Result := ((al_key[idx]=0) and (last_al_key[idx]<>0));
  last_al_key:=al_key;
end;

{ TState }

constructor TState.Create;
begin
  inherited;
  //Here state is initialized. Every state needs to keep their own buffer for
  //double/triple buffering. All resource loading should be done here.
end;

destructor TState.Destroy;
begin
  inherited;
  //You should dispose of any resources made in Create if you don't want to cause
  //memory leak
end;

procedure TState.Update;
begin
  //Update is called every frame (60 times per second).
  //It is designed to update objects (collision check, movement)
  //You shouldn't, however, do any write to variables (change values)
  //that aren't primitives (writing to integers, strings, etc. is fine)
  //or you'll get memory leak
end;

procedure TState.BeforeDraw;
begin
  //Like Main, this is called in main loop and usage is similar.
  //It is, however called before drawing.
end;

procedure TState.Draw;
begin
  //Drawing is done here. It is called in main loop (as fast as it can).
end;

procedure TState.Main;
begin
  //This method is also called in main loop. It is designed to do things
  //that aren't drawing and needs to be called in main loop, for example
  //rebuilding map, updating frame of TAnimatedSprite, etc.
end;

end.

