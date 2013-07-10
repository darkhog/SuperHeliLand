unit GameObjects;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Sprites,contnrs;
type
  TObjectMode = (omAnim,omSprite);
  TGameObject = class
    public
      Animations:TAnimatedSpriteList;
      Sprites:TSpriteList;
      CurrentAnim:integer;
      CurrentSprite:integer;
      ObjectMode:TObjectMode;
      x,y:Integer;
      procedure MoveTo(_x,_y:Integer);virtual;
      procedure MoveBy(_x,_y:Integer);virtual;
      procedure Update();virtual;
      procedure Draw;
      constructor Create
    private
  end;

implementation

end.

