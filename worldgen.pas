unit WorldGen;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, allegro, PerlinNoiseUnit,boolUtils,ChunkUtils,Tilesets;

type


{ TWorldGenerator }

TWorldGenerator = class
  public
    constructor Create(seed: Integer);
    destructor Destroy();override;
    function GenerateChunkData(ChunkDataX,ChunkDataY, ChunkDatasize:Integer):TChunkData;


  private
    PerlinGenerator: TPerlinNoise;
    cx,cy,lastcarvey:Integer;
    procedure _genStepTerrain(var ChunkData:TChunkData);
    procedure _genStepGround(var ChunkData:TChunkData);
    procedure _genStepCarve(var ChunkData:TChunkData);
    procedure _genStepTraps(var ChunkData:TChunkData);
    procedure _genStepBlocks(var ChunkData:TChunkData);


end;


implementation


const
  Octaves=4;
  Persistance=6.5;
  Frequency=2;
  TrapChance=18; //there is 14 percent of chance that spike will spawn on ground or block.

{ TWorldGenerator }

constructor TWorldGenerator.Create(seed: Integer);
begin
  inherited Create;
  PerlinGenerator:= TPerlinNoise.Create(seed);
  lastcarvey:=0;
end;

destructor TWorldGenerator.Destroy;
begin
  inherited;
  PerlinGenerator.Destroy;
end;

function TWorldGenerator.GenerateChunkData(ChunkDataX, ChunkDataY, ChunkDatasize: Integer
  ): TChunkData;
var

  ChunkData:TChunkData;
begin

    cx:=ChunkDatax;
    cy:=ChunkDatay;

    //setting dimensions of ChunkData
    SetLength(ChunkData,ChunkDatasize,ChunkDatasize);

    _genStepTerrain(ChunkData);
    _genStepCarve(ChunkData);
    _genStepBlocks(ChunkData);
    _genStepGround(ChunkData);
    _genStepTraps(ChunkData);
    result:=ChunkData;
    ChunkData:=nil;
end;

procedure TWorldGenerator._genStepTerrain(var ChunkData: TChunkData);
var  i,perlinresult:Byte;
     x,y,temp,ChunkDatasize:Integer;
     neighbors:array[0..7]of byte;
begin
  //getting length of ChunkData
  ChunkDatasize:=Length(ChunkData);
  //generation
    for x:=0 to ChunkDatasize-1 do
    begin
      for y:=0 to ChunkDatasize-1 do
      begin
        //getting perlin for specified point
        perlinresult:=Trunc(PerlinGenerator.PerlinNoise2d((cx*ChunkDatasize)+x,(cy*ChunkDatasize)+y,Persistance,Frequency,Octaves)*255);
        //smoothing it so it won't look awful
        neighbors[0]:=Trunc(PerlinGenerator.PerlinNoise2d(((cx*ChunkDatasize)+x)-1,(cy*ChunkDatasize)+y,Persistance,Frequency,Octaves)*255);
        neighbors[1]:=Trunc(PerlinGenerator.PerlinNoise2d(((cx*ChunkDatasize)+x)+1,(cy*ChunkDatasize)+y,Persistance,Frequency,Octaves)*255);
        neighbors[2]:=Trunc(PerlinGenerator.PerlinNoise2d((cx*ChunkDatasize)+x,((cy*ChunkDatasize)+y)-1,Persistance,Frequency,Octaves)*255);
        neighbors[3]:=Trunc(PerlinGenerator.PerlinNoise2d((cx*ChunkDatasize)+x,((cy*ChunkDatasize)+y)+1,Persistance,Frequency,Octaves)*255);
        neighbors[4]:=Trunc(PerlinGenerator.PerlinNoise2d(((cx*ChunkDatasize)+x)-1,((cy*ChunkDatasize)+y)-1,Persistance,Frequency,Octaves)*255);
        neighbors[5]:=Trunc(PerlinGenerator.PerlinNoise2d(((cx*ChunkDatasize)+x)+1,((cy*ChunkDatasize)+y)-1,Persistance,Frequency,Octaves)*255);
        neighbors[6]:=Trunc(PerlinGenerator.PerlinNoise2d(((cx*ChunkDatasize)+x)+1,((cy*ChunkDatasize)+y)+1,Persistance,Frequency,Octaves)*255);
        neighbors[7]:=Trunc(PerlinGenerator.PerlinNoise2d(((cx*ChunkDatasize)+x)-1,((cy*ChunkDatasize)+y)+1,Persistance,Frequency,Octaves)*255);
        temp:= perlinresult div 2;
        for i:=0 to 7 do begin
          temp:= temp + (neighbors[i] div 12);
        end;
        if temp>255 then temp:=255;
        perlinresult:=temp;
        //standard ground
        if Between(perlinresult,90,256) then ChunkData[x][y]:=GROUNDID
        else ChunkData[x][y]:= AIRID;
      end;
    end;

end;

procedure TWorldGenerator._genStepGround(var ChunkData: TChunkData);
var ChunkDatasize,x,y:Integer;

begin
  ChunkDatasize:=Length(ChunkData);
  for x:=0 to ChunkDatasize-1 do begin
    for y:=1 to ChunkDatasize-2 do begin
      //we start at Y=1 and end one index before end of ChunkData as we need to test block before that for being
      //air and if there is something under.
      if ((ChunkData[x][y]=AIRID) and (ChunkData[x][y-1]=AIRID) and (ChunkData[x][y+1]=GROUNDID))
         then ChunkData[x][y]:=INVINCIBLEBLOCKID;
    end;
  end;

end;

procedure TWorldGenerator._genStepCarve(var ChunkData: TChunkData);
var x,ChunkDatasize:Integer;
begin
 // writeln;
  //writeln('-------NEW ChunkData---------');
  {
  This function uses what I call Worm Algorithm, Dunno if it was made previously
  by someone else (probably was) and how it is proffessionally called. I made it
  on my own.
  Reason for name of it is that it carves cave in a way worm would do it. This
  ensures continous play area without some impenetrable walls that would stop
  player.
  }
  ChunkDatasize:=Length(ChunkData);
  if lastcarvey=0 then lastcarvey:=ChunkDatasize div 2;
  for x:=0 to ChunkDatasize do begin
    ChunkDataCircle(ChunkData,x,lastcarvey,3,AIRID,true);
    if lastcarvey > ChunkDatasize div 2 then lastcarvey:=lastcarvey-Random(4) else
    if lastcarvey < (ChunkDatasize div 2) then lastcarvey:=lastcarvey+Random(2) else
    lastcarvey:=lastcarvey-Random(6)+6;
    if lastcarvey>ChunkDatasize then lastcarvey :=ChunkDatasize-5;
    //write(lastcarvey,'|');
  end;
end;

procedure TWorldGenerator._genStepTraps(var ChunkData: TChunkData);
var ChunkDatasize,x,y:Integer;

begin
  ChunkDatasize:=Length(ChunkData);
  for x:=0 to ChunkDatasize-1 do begin
    for y:=1 to ChunkDatasize-2 do begin
      //we start at Y=1 and end one index before end of ChunkData as we need to test block before that for being
      //air and if there is something under.
      if ((ChunkData[x][y]=AIRID) and (ChunkData[x][y-1]=AIRID) and ((ChunkData[x][y+1]=GROUNDID) or
         (ChunkData[x][y+1]=INVINCIBLEBLOCKID)) and (Random(101)<TrapChance)) then ChunkData[x][y]:=SPIKEID;
         //randomizing above is done so whole ground won't be in traps.
    end;
  end;


end;

procedure TWorldGenerator._genStepBlocks(var ChunkData: TChunkData);
var x1,y1,x2,y2,i,chunkdatasize:Integer;
begin
  ChunkDatasize:=Length(ChunkData);
  for i:=1 to 3 do //3 blocks per chunk is reasonable amount
  begin
    x1:=0;
    y1:=0;
    x2:=0;
    y2:=0;
    //we need to get x1,y1 and x2,y2 in some empty area of map
    while chunkdata[x1][y1]<>AIRID do
      begin
        x1:=random(chunkdatasize);
        y1:=random(chunkdatasize);
      end;
    while chunkdata[x2][y2]<>AIRID do
      begin
        x2:=random(chunkdatasize);
        y2:=random(chunkdatasize);
      end;
    if abs(x1-x2)>3 then x2:=x1+3; //block of blocks can't be wider than 3 blocks. It can however be as high as it can.
    ChunkDataRect(ChunkData,x1,y1,x2,y2,BLOCKID, true); //making rectangle in chunk.
  end;
end;

end.

