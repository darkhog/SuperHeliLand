unit GameObjects;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Sprites,contnrs,allegro;
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
      function isColliding(GO:TGameObject):Boolean;
      function isColliding(Sprite:TSprite):Boolean;
      procedure Update();virtual;
      procedure Draw(Bitmap:AL_BITMAPptr);virtual;
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
  x:=_x;
  y:=_y;
end;

procedure TGameObject.MoveBy(_x, _y: Integer);
begin
  x:=x+_x;
  y:=x+_y;
end;

function TGameObject.isColliding(GO: TGameObject): Boolean;
begin
  Result:=false;
  case ObjectMode of
    omAnim:   begin
                if Animations.Items[CurrentAnim]<>nil then
                  if GO.ObjectMode=omAnim then
                  begin
                    Result:=((GO.Animations.Items[GO.CurrentAnim]<>nil) and (Animations.Items[CurrentAnim].IsColliding(GO.Animations.Items[GO.CurrentAnim])));
                  end else
                  begin
                    Result:=((GO.Sprites.Items[GO.CurrentSprite]<>nil) and (Animations.Items[CurrentAnim].IsColliding(GO.Sprites.Items[GO.CurrentSprite])));
                  end;
              end;
    omSprite: begin
                if Sprites.Items[CurrentSprite]<>nil then
                if GO.ObjectMode=omAnim then
                begin
                  Result:=((GO.Animations.Items[GO.CurrentAnim]<>nil) and (Sprites.Items[CurrentSprite].IsColliding(GO.Animations.Items[GO.CurrentAnim])));
                end else
                begin
                  Result:=((GO.Sprites.Items[GO.CurrentSprite]<>nil) and (Sprites.Items[CurrentSprite].IsColliding(GO.Sprites.Items[GO.CurrentSprite])));
                end;
              end;
  end;
end;

function TGameObject.isColliding(Sprite: TSprite): Boolean;
begin
  Result:=false;
  case ObjectMode of
    omAnim:   begin
                if Animations.Items[CurrentAnim]<>nil then
                  Result:=Animations.Items[CurrentAnim].IsColliding(Sprite);
                end;
    omSprite: begin
                if Sprites.Items[CurrentSprite]<>nil then
                  Result:=Sprites.Items[CurrentSprite].IsColliding(Sprite);
              end;
  end;
end;

procedure TGameObject.Update;
begin

end;

procedure TGameObject.Draw(Bitmap: AL_BITMAPptr);
begin
  case ObjectMode of
    omAnim:   begin
                if Animations.Items[CurrentAnim]<>nil then
                  Animations.Items[CurrentAnim].Draw(Bitmap);
              end;
    omSprite: begin
                if Sprites.Items[CurrentSprite]<>nil then
                  Sprites.Items[CurrentSprite].Draw(Bitmap);
              end;
  end;
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

