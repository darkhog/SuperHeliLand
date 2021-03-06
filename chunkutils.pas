unit ChunkUtils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,allegro,boolUtils,Tilesets,Sprites;
type
  TChunkData = array of array of byte;

  { TChunk }

  TChunk = class
    public

      data:TChunkData;
      constructor Create(chunksize:Integer);
      destructor Destroy;override;
      procedure Draw(bitmap:AL_BITMAPptr;x,y:Integer; Tileset:TTileset; magentatransparent:boolean);
      procedure Draw(bitmap:AL_BITMAPptr;x,y:Integer; Tileset:TTileset; ScaleFactor:Integer; magentatransparent:boolean);
      function GetTerrainSprite(Tileset:TTileset):TSprite; //util functions so we can get collidable terrain
      function GetTrapSprite(Tileset:TTileset):TSprite;   //and spikes as sprites for easy collision checking.
      function GetChunkDataWithBlocks():TChunkData; //blocks are destroyable by the player, so we need a way to get them
                                                       //so we can destroy them in world (by displaying as TSprites).
  end;

procedure ChunkDataCircle(var ChunkData:TChunkData; x0,y0,radius,id:integer; filled:Boolean);
procedure ChunkDataRect(var ChunkData:TChunkData; x1,y1,x2,y2,id:Integer; filled:Boolean);
implementation

procedure ChunkDataCircle(var ChunkData: TChunkData; x0, y0, radius, id: integer; filled: Boolean);
var x,y,radiusError,height,ChunkDatasize:Integer;
begin
  //This function draws circle in ChunkData. It can be filled or not.
  ChunkDatasize:=Length(ChunkData);
  x := radius; y := 0;
  radiusError := 1-x;
  if not filled then begin
  while(x >= y) do
  begin
    //we need ifs so we won't get array out of bounds exception.
    if (Between(x + x0,-1,ChunkDatasize) and (Between(y + y0,-1,ChunkDatasize))) then ChunkData[x + x0][y + y0]:=id;
    if (Between(x + y0,-1,ChunkDatasize) and (Between(y + x0,-1,ChunkDatasize))) then ChunkData[y + x0][ x + y0]:=id;
    if (Between(-x + x0,-1,ChunkDatasize) and (Between(y + y0,-1,ChunkDatasize))) then ChunkData[-x + x0][ y + y0]:=id;
    if (Between(-y + x0,-1,ChunkDatasize) and (Between(x + y0,-1,ChunkDatasize))) then ChunkData[-y + x0][x + y0]:=id;
    if (Between(-x + x0,-1,ChunkDatasize) and (Between(-y + y0,-1,ChunkDatasize))) then ChunkData[-x + x0][-y + y0]:=id;
    if (Between(-y + x0,-1,ChunkDatasize) and (Between(-x + y0,-1,ChunkDatasize))) then ChunkData[-y + x0][-x + y0]:=id;
    if (Between(x + x0,-1,ChunkDatasize) and (Between(-y + y0,-1,ChunkDatasize))) then ChunkData[x + x0][ -y + y0]:=id;
    if (Between(y + x0,-1,ChunkDatasize) and (Between(-x + y0,-1,ChunkDatasize))) then ChunkData[y + x0][-x + y0]:=id;
    //Clipping ends here.
    //here begins code which I (Darkhog) don't really understands. I shamelessly copied it from site I forgot
    //name or url of.
    Inc(y);
        if(radiusError<0) then
                radiusError:=radiusError+2*y+1
        else
        begin
                Dec(x);
                radiusError:=radiusError+2*(y-x)+1;
        end;
  end;
  end
  else begin
    //filled circle rendering copied from other site (possibly gamedev-related Stack Exchange).
    //I guess author should be credited, but well... I don't know who he was and originally
    //it was pseudocode or C.
    for x:= -radius to radius-1 do
    begin
      height := Trunc(Sqrt(radius * radius - x * x));

      for y := -height to height-1 do begin
        //clipping so we won't get out of bounds of Chunk Data, a.k.a get segfault.
        if (Between(x + x0,-1,ChunkDatasize) and (Between(y + y0,-1,ChunkDatasize))) then ChunkData[x + x0][y + y0]:=id;
      end;
    end;
  end;

end;

procedure ChunkDataRect(var ChunkData: TChunkData; x1, y1, x2, y2, id: Integer;
  filled: Boolean);
var x,y,chunkdatasize:Integer;
begin
//This function draws rectangle in ChunkData. It can be filled or not.
//getting chunk's size:
  ChunkDatasize:=Length(ChunkData);
  //clamping x1/y1/x2/y2 so we won't get out of bounds of chunkdata:
    //min values:
  if x1<0 then x1:=0;
  if y1<0 then y1:=0;
  if x2<0 then x2:=0;
  if y2<0 then y2:=0;
    //max values:
  if x1>chunkdatasize-1 then x1:=chunkdatasize-1;
  if x2>chunkdatasize-1 then x2:=chunkdatasize-1;
  if y1>chunkdatasize-1 then y1:=chunkdatasize-1;
  if y2>chunkdatasize-1 then y2:=chunkdatasize-1;

  //Now that we know values are "safe" we can begin making rectangles.
  if not filled then
    begin
      //rectangle is not filled so we need a frame
      //first line
      for x:=x1 to x2 do
      begin
        ChunkData[x][y1]:=id;
      end;
      //second line
      for y:=y1 to y2 do
      begin
        ChunkData[x1][y]:=id;
      end;
      //third line
      for x:=x1 to x2 do
      begin
        ChunkData[x][y2]:=id;
      end;
      //fourth line
      for y:=y1 to y2 do
      begin
        ChunkData[x2][y]:=id;
      end;
      //Now we have nice frame!
    end else
    begin
      //rectangle is filled, so code is much simpler and consist of single pair of
      //nested for loops.
      for x:=x1 to x2 do
      begin
        for y:=y1 to y2 do
        begin
          ChunkData[x][y]:=id;
        end;
      end;
    end;
end;

{ TChunk }

constructor TChunk.Create(chunksize: Integer);
begin
  SetLength(data,chunksize,chunksize);
end;

destructor TChunk.Destroy;
begin

end;
//draw, GetTrapSprite or GetGroundSprite are most likely culprits of segfault I experience.
procedure TChunk.Draw(bitmap: AL_BITMAPptr; x, y: Integer; Tileset: TTileset; magentatransparent:boolean);
var TrapSprite,ChunkSprite:TSprite;
begin
  if bitmap=nil then exit; //failing when bitmap given is null to avoid crash.
                           //if chunk is not rendering, that's it.
  TrapSprite:=GetTrapSprite(Tileset);
  ChunkSprite := GetTerrainSprite(Tileset);
  TrapSprite.x:=x;
  TrapSprite.y:=y;
  ChunkSprite.x:=x;
  ChunkSprite.y:=y;
  ChunkSprite.magentatransparent:=magentatransparent;
  TrapSprite.magentatransparent:=magentatransparent;
  ChunkSprite.Draw(bitmap);
  TrapSprite.Draw(bitmap);
  trapsprite.destroy;
  chunksprite.Destroy();
end;

procedure TChunk.Draw(bitmap: AL_BITMAPptr; x, y: Integer; Tileset: TTileset;
  ScaleFactor: Integer; magentatransparent:boolean);
var TrapSprite,ChunkSprite:TSprite;
begin
  if bitmap=nil then exit; //failing when bitmap given is null to avoid crash.
                           //if chunk is not rendering, that's it.
  TrapSprite:=GetTrapSprite(Tileset);
  ChunkSprite := GetTerrainSprite(Tileset);
  TrapSprite.x:=x;
  TrapSprite.y:=y;
  ChunkSprite.x:=x;
  ChunkSprite.y:=y;
  TrapSprite.ScaleFactor:=ScaleFactor;
  ChunkSprite.ScaleFactor:=ScaleFactor;
  ChunkSprite.magentatransparent:=magentatransparent;
  TrapSprite.magentatransparent:=magentatransparent;
  ChunkSprite.Draw(bitmap);
  TrapSprite.Draw(bitmap);
  trapsprite.destroy;
  chunksprite.Destroy();
end;

function TChunk.GetTrapSprite(Tileset: TTileset
  ): TSprite;
var chunksize,x,y:integer; tempsprite:TSprite;
begin
  chunksize:=length(data);
  Result:=TSprite.Create(al_create_bitmap(chunksize*Tileset.TileSize,chunksize*Tileset.TileSize),al_create_bitmap(chunksize*Tileset.TileSize,chunksize*Tileset.TileSize));
  al_clear_to_color(Result.SpriteBitmap,al_makecol(255,0,255));
  al_clear_to_color(Result.MaskBitmap,al_makecol(255,0,255));
  for x:=0 to chunksize-1 do
  begin
    for y:=0 to chunksize-1 do
    begin
      if data[x][y]=SPIKEID then
        begin
          tempsprite:=Tileset.GetTileSprite(SPIKEID);
          tempsprite.x:=x*Tileset.TileSize;
          tempsprite.y:=y*Tileset.TileSize;
          tempsprite.Draw(Result.SpriteBitmap);
          tempsprite.DrawMask(Result.MaskBitmap);
          tempsprite.Destroy;
        end;
    end;
  end;
end;

function TChunk.GetTerrainSprite(Tileset: TTileset
  ): TSprite;
var chunksize,x,y:integer; tempsprite:TSprite;
begin
  chunksize:=length(data);
  Result:=TSprite.Create(al_create_bitmap(chunksize*Tileset.TileSize,chunksize*Tileset.TileSize),al_create_bitmap(chunksize*Tileset.TileSize,chunksize*Tileset.TileSize));
  al_clear_to_color(Result.SpriteBitmap,al_makecol(255,0,255));
  al_clear_to_color(Result.MaskBitmap,al_makecol(255,0,255));
  for x:=0 to chunksize-1 do
  begin
    for y:=0 to chunksize-1 do
    begin
      if data[x][y]=AIRID then continue;
      if data[x][y]=BLOCKID then continue;
      if data[x][y]=SPIKEID then continue;
      if data[x][y]=GROUNDID then
        begin
          if y mod 2<>0 then
            begin
              if x mod 2<>0 then
                begin
                  tempsprite:=Tileset.GetTileSprite(0);

                  tempsprite.x:=x*Tileset.TileSize;
                  tempsprite.y:=y*Tileset.TileSize;
                  tempsprite.Draw(Result.SpriteBitmap);
                  tempsprite.DrawMask(Result.MaskBitmap);
                  tempsprite.Destroy;
                end else
                begin
                  tempsprite:=Tileset.GetTileSprite(4);
                  tempsprite.x:=x*Tileset.TileSize;
                  tempsprite.y:=y*Tileset.TileSize;
                  tempsprite.Draw(Result.SpriteBitmap);
                  tempsprite.DrawMask(Result.MaskBitmap);
                  tempsprite.Destroy;
                end
            end else
            begin
              if x mod 2=0 then
                begin
                  tempsprite:=Tileset.GetTileSprite(0); //if you don't know what those means, check out tileset.pcx.
                  tempsprite.x:=x*Tileset.TileSize;
                  tempsprite.y:=y*Tileset.TileSize;
                  tempsprite.Draw(Result.SpriteBitmap);
                  tempsprite.DrawMask(Result.MaskBitmap);
                  tempsprite.Destroy;
                end else
                begin
                  tempsprite:=Tileset.GetTileSprite(4);
                  tempsprite.x:=x*Tileset.TileSize;
                  tempsprite.y:=y*Tileset.TileSize;
                  tempsprite.Draw(Result.SpriteBitmap);
                  tempsprite.DrawMask(Result.MaskBitmap);
                  tempsprite.Destroy;
                end
            end
        end;
        if data[x][y]=INVINCIBLEBLOCKID then
          begin
            tempsprite:=Tileset.GetTileSprite(INVINCIBLEBLOCKID);
            tempsprite.x:=x*Tileset.TileSize;
            tempsprite.y:=y*Tileset.TileSize;
            tempsprite.Draw(Result.SpriteBitmap);
            tempsprite.DrawMask(Result.MaskBitmap);
            tempsprite.Destroy;
          end;
    end;
  end;
end;

function TChunk.GetChunkDataWithBlocks(): TChunkData;
var cd:TChunkData;
    chunksize,x,y:Integer;
begin
  chunksize:=Length(data);
  SetLength(cd,chunksize,chunksize);
  for x:=0 to chunksize-1 do
  begin
    for y:=0 to chunksize-1 do
    begin
      if data[x][y]=BLOCKID then cd[x][y]:=BLOCKID else cd[x][y]:=AIRID;
    end;
  end;
  Result:=cd;
end;

end.

