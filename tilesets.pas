unit Tilesets;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,allegro,sprites;

type

  { TTileset }

  TTileset = class
    public
      TileSize,TilesetCols,TilesetRows:Integer;
      TilesetSprite:TSprite;
      constructor Create();
      constructor Create(Sprite:TSprite);
      destructor  Destroy();override;

      function GetTileSprite(TileID:Integer):TSprite;
    private

end;
const
  GROUNDID=0;
  INVINCIBLEBLOCKID=1;
  BLOCKID=2;
  SPIKEID=3;
  AIRID=255;
implementation

{ TTileset }

constructor TTileset.Create;
begin
inherited;
end;

constructor TTileset.Create(Sprite: TSprite);
begin
  inherited Create;
  TilesetSprite:=Sprite;
end;

destructor TTileset.Destroy;
begin
inherited;
if TilesetSprite<>nil then TilesetSprite.Destroy(); //taking care of tileset sprite.
end;

function TTileset.GetTileSprite(TileID: Integer): TSprite;
var x,y:Integer;
begin
  if TileID>TilesetRows*TilesetCols then begin
    //we can't get tileID bigger than last tile in tileset, so we failing there.
    Result:=TSprite.Create(al_create_bitmap(TileSize,TileSize),al_create_bitmap(TileSize,TileSize));
    al_clear_to_color(Result.SpriteBitmap,al_makecol(255,0,255));
    al_clear_to_color(Result.MaskBitmap,al_makecol(255,0,255));
    al_textout_ex(Result.SpriteBitmap,al_font,'?',0,0,al_makecol(0,0,0),al_makecol(255,0,255));

    exit;
  end;
  Result:=TSprite.Create(al_create_bitmap(TileSize,TileSize),al_create_bitmap(TileSize,TileSize));
  //getting x/y in TILES of tile with selected ID (thanks imcold from Pascal Game
  //Development forums for code!)
  x:= TileID mod TilesetCols;
  y:= TileID div TilesetCols;
  //and now changing it into values in pixels to cut tile into sprite properly
  x:= x*TileSize;
  y:= y*TileSize;

  //now the fun part - cutting tileset's sprite
  al_blit(TilesetSprite.SpriteBitmap,Result.SpriteBitmap,x,y,0,0,TileSize,TileSize); //sprite
  al_blit(TilesetSprite.MaskBitmap,Result.MaskBitmap,x,y,0,0,TileSize,TileSize); //collision mask
end;

end.

