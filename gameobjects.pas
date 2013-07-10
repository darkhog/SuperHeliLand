unit GameObjects;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Sprites,contnrs;
type
  TObjectMode = (omAnim,omSprite);

  { TGameObject }

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
      procedure Draw;virtual;
      constructor Create(mode:TObjectMode);
      constructor Create(DefaultAnimation:TAnimatedSprite);
      constructor Create(DefaultSprite:TSprite);
      destructor Destroy; override;
    private
  end;

implementation

{ TGameObject }

procedure TGameObject.MoveTo(_x, _y: Integer);
begin

end;

procedure TGameObject.MoveBy(_x, _y: Integer);
begin

end;

procedure TGameObject.Update;
begin

end;

procedure TGameObject.Draw;
begin

end;

constructor TGameObject.Create(mode: TObjectMode);
begin
  inherited Create;
  ObjectMode:=mode;
  if mode=omAnim then Animations:=TAnimatedSpriteList.create;
  if mode=omSprite then Sprites:=TSpriteList.create;
end;

constructor TGameObject.Create(DefaultAnimation: TAnimatedSprite);
begin
  Create(omAnim);
  Animations.Add(DefaultAnimation);
end;

constructor TGameObject.Create(DefaultSprite: TSprite);
begin
  Create(omSprite);
  Sprites.Add(DefaultSprite);
end;

destructor TGameObject.Destroy;
begin
  inherited Destroy;
  Animations.Free;
  Sprites.Free;
end;

end.

