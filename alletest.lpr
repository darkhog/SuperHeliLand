program alletest;
{
 If I ever find out that my next game intended on sale won't end up on TPB on
 release day, I'll be seriously offended. Then I'll go, login into my TPB account
 and upload torrent of it myself and seed until it has at least 5 seeders except
 me. Oh, I'll also announce that on my twitter account @qvear. I don't care if
 my sales will drop because of it. I care about players.

 Yarr!
 - Dariusz "Darkhog" G. Jagielski
}
{$mode objfpc}{$H+}
{$apptype gui}
{$R allegro.res}
uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, allegro, sprites, PerlinNoiseUnit, WorldGen, boolUtils,
  Tilesets, ChunkUtils, Globals, states, GameObjects, GameStateUnit, Crt;
var lasted,chunklasted,x,y,chunkx:Integer;
    TicksInQueue:Integer;
    pause:boolean;

    WorldGenerator:TWorldGenerator;
    Tileset:TTileset;

    NeedRefresh:Boolean;

const pausedelay=10;



  procedure draw();
  begin
    {//clearing buffer
    al_clear_to_color(buffer,al_makeacol_depth(al_desktop_color_depth,255,255,255,255));
    //drawing text
    al_textout_centre_ex(buffer,MarioFont,'Press space to generate new chunk',320,25,al_makecol(0,0,0),-1);
    al_textout_centre_ex(buffer,MarioFont,'Press Q to quit',320,45,al_makecol(0,0,0),-1);


    //comment this line and uncomment next for a (nasty) surprise
    //al_masked_blit(perlin,buffer,0,0,300,200,100,100);
    al_masked_stretch_blit(perlin,buffer,0,0,18,18,0,0,18*2,18*2);
    //al_stretch_sprite(buffer,perlin,0,0,perlin^.w*2,perlin^.h*2);
    Chunk.Draw(buffer,0,16*4,Tileset,4,true);
    //showing counter animation


    //if pause, put indicator of it
    if pause then al_textout_centre_ex(buffer,al_font,'Pause',400,580,al_makeacol_depth(al_desktop_color_depth,255,0,0,255),al_makeacol_depth(al_desktop_color_depth,0,0,0,255));
    al_blit(buffer,al_screen,0,0,0,0,800,600); }

  end;
  {function generate_pixel(x,y:Integer):Integer;
  var ChunkDatasize:integer;
  begin
  ChunkDatasize:=Length(Chunk.Data);
  if ((Between(x,-1,ChunkDatasize)) and ((Between(y,-1,ChunkDatasize)))) then begin
    if Chunk.Data[x][y]=GROUNDID then result:= al_makecol(117,58,15)
    else if Chunk.Data[x][y]=INVINCIBLEBLOCKID then result:=al_makecol(134,197,16)
    else if Chunk.Data[x][y]=SPIKEID then result:=al_makecol(255,0,0)
    else if Chunk.Data[x][y]=BLOCKID then result:=al_makecol(0,0,255)
    else result:=al_makecol(255,0,255);
  end;

  end;  }

  procedure update_keyboard();
  begin
      Dec(lasted);
      dec(chunklasted);
      if (al_keyboard_needs_poll) then al_poll_keyboard;
      if (al_key[AL_KEY_Q]<>0) then quit:=true;
      if ((al_key[AL_KEY_P]<>0) and (lasted<=0)) then begin pause:=not pause; lasted:=pausedelay; end;
      if not pause then begin

        if ((al_key[AL_KEY_SPACE]<>0) and (chunklasted<=0)) then
        begin
          NeedRefresh:=true;
          chunklasted:=pausedelay;
        end;
      end;
  end;
  procedure quitfunc();CDECL;
  begin
    quit:=true;
  end;

  procedure update();CDECL;
  begin
    //frame update
    Inc(TicksInQueue);
    //update_keyboard;
  end;


{$R *.res}

begin
  Randomize;
  //initializing Allegro
  if al_init then
  begin
      //setting up window

      al_set_color_depth(al_desktop_color_depth);
      al_set_gfx_mode(AL_GFX_AUTODETECT_WINDOWED,SCREENW,SCREENH,SCREENW,SCREENH);
      al_set_window_title('Super Heli Land');
      al_set_close_button_callback(@quitfunc);
      //installing keyboard
      al_textout_ex(al_screen,al_font,'Installing keyboard... ',0,0,al_makeacol_depth(al_desktop_color_depth,128,128,128,255),al_makeacol_depth(al_desktop_color_depth,0,0,0,255));
      al_install_keyboard;
      al_textout_ex(al_screen,al_font,'OK',600,0,al_makeacol_depth(al_desktop_color_depth,0,255,0,255),al_makeacol_depth(al_desktop_color_depth,0,0,0,255));

      //installing timers
      al_textout_ex(al_screen,al_font,'Installing timers... ',0,20,al_makeacol_depth(al_desktop_color_depth,128,128,128,255),al_makeacol_depth(al_desktop_color_depth,0,0,0,255));
      al_install_timer;
      al_textout_ex(al_screen,al_font,'OK',600,20,al_makeacol_depth(al_desktop_color_depth,0,255,0,255),al_makeacol_depth(al_desktop_color_depth,0,0,0,255));

      //installing update timer
      al_textout_ex(al_screen,al_font,'Initializing update routine... ',0,40,al_makeacol_depth(al_desktop_color_depth,128,128,128,255),al_makeacol_depth(al_desktop_color_depth,0,0,0,255));
      al_install_int_ex(@Update,AL_BPS_TO_TIMER(60));
      al_textout_ex(al_screen,al_font,'OK',600,40,al_makeacol_depth(al_desktop_color_depth,0,255,0,255),al_makeacol_depth(al_desktop_color_depth,0,0,0,255));

      //making buffer so screen won't blink
      {al_textout_ex(al_screen,al_font,'Tworzenie bufora ramki... ',0,60,al_makeacol_depth(al_desktop_color_depth,128,128,128,255),al_makeacol_depth(al_desktop_color_depth,0,0,0,255));
      buffer:=al_create_bitmap_ex(al_desktop_color_depth,640,576);
      al_textout_ex(al_screen,al_font,'OK',600,60,al_makeacol_depth(al_desktop_color_depth,0,255,0,255),al_makeacol_depth(al_desktop_color_depth,0,0,0,255));}

      //loading tileset
      {al_textout_ex(al_screen,al_font,'Ladowanie Tilesetu... ',0,80,al_makeacol_depth(al_desktop_color_depth,128,128,128,255),al_makeacol_depth(al_desktop_color_depth,0,0,0,255));
      Tileset:=TTileset.Create();
      Tileset.TilesetSprite:=TSprite.Create(al_load_pcx('tileset.pcx',@al_default_palette),al_load_pcx('tileset_mask.pcx',@al_default_palette));
      Tileset.TilesetCols:=5;
      Tileset.TilesetRows:=1;
      Tileset.TileSize:=8;
      al_textout_ex(al_screen,al_font,'OK',600,80,al_makeacol_depth(al_desktop_color_depth,0,255,0,255),al_makeacol_depth(al_desktop_color_depth,0,0,0,255));}

      //let's make some noise.
      {al_textout_ex(al_screen,al_font,'Tworzenie perlina... ',0,100,al_makeacol_depth(al_desktop_color_depth,128,128,128,255),al_makeacol_depth(al_desktop_color_depth,0,0,0,255));
      perlin:=al_create_bitmap_ex(al_desktop_color_depth,18,18);
      Randomize;
      WorldGenerator:= TWorldGenerator.Create(Random(High(Integer)));
      chunkx:=0;
      Chunk:=TChunk.Create(18);
      Chunk.Data:=WorldGenerator.GenerateChunkData(chunkx,0,18);
      Inc(chunkx);

      for x:=0 to 18-1 do begin
        for y:=0 to 18-1 do begin

          al_putpixel(perlin,x,y,generate_pixel(x,y));
        end;

      end;}

      //loading settings
      al_textout_ex(al_screen,al_font,'Installing sound... ',0,60,al_makeacol_depth(al_desktop_color_depth,128,128,128,255),al_makeacol_depth(al_desktop_color_depth,0,0,0,255));
      al_install_sound(AL_DIGI_AUTODETECT,AL_MIDI_AUTODETECT);
      al_textout_ex(al_screen,al_font,'OK',600,60,al_makeacol_depth(al_desktop_color_depth,0,255,0,255),al_makeacol_depth(al_desktop_color_depth,0,0,0,255));
      al_textout_ex(al_screen,al_font,'Loading settings... ',0,80,al_makeacol_depth(al_desktop_color_depth,128,128,128,255),al_makeacol_depth(al_desktop_color_depth,0,0,0,255));
      LoadOptions('game.opt');
      al_textout_ex(al_screen,al_font,'OK',600,80,al_makeacol_depth(al_desktop_color_depth,0,255,0,255),al_makeacol_depth(al_desktop_color_depth,0,0,0,255));
      al_textout_ex(al_screen,al_font,'Loading font... ',0,100,al_makeacol_depth(al_desktop_color_depth,128,128,128,255),al_makeacol_depth(al_desktop_color_depth,0,0,0,255));
      MarioFont:=al_load_font('marioland.pcx',nil,nil);
      al_textout_ex(al_screen,al_font,'OK',600,100,al_makeacol_depth(al_desktop_color_depth,0,255,0,255),al_makeacol_depth(al_desktop_color_depth,0,0,0,255));
      //loading marioland font


      al_textout_ex(al_screen,al_font,'Creating states... ',0,120,al_makeacol_depth(al_desktop_color_depth,128,128,128,255),al_makeacol_depth(al_desktop_color_depth,0,0,0,255));
      MainMenuState:=TMainMenuState.Create;
      DebugState:=TDebugState.Create;
      OptionsState:=TOptionsState.Create;
      CurrentState:=MainMenuState;
      al_textout_ex(al_screen,al_font,'OK',600,120,al_makeacol_depth(al_desktop_color_depth,0,255,0,255),al_makeacol_depth(al_desktop_color_depth,0,0,0,255));

      al_textout_ex(al_screen,al_font,'Starting main loop... ',0,140,al_makeacol_depth(al_desktop_color_depth,128,128,128,255),al_makeacol_depth(al_desktop_color_depth,0,0,0,255));

      Buffer:=al_create_bitmap(SCREENW,SCREENH);
      //main loop
      repeat
        while TicksInQueue>0 do
        begin
          if ((CurrentState<>nil) and (not quit)) then CurrentState.Update;
          Dec(TicksInQueue);
        end;
        if not quit then CurrentState.BeforeDraw;
        if not quit then CurrentState.Draw;
        if not quit then CurrentState.Main;


      until quit;
      SaveOptions('game.opt');
      al_destroy_font(MarioFont);
      CurrentState:=nil;
      MainMenuState.Free;
      OptionsState.Free;
      Debugstate.Free;
      al_destroy_bitmap(buffer);
  end;
end.

