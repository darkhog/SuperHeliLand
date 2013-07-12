unit GameObjects;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Sprites,contnrs,allegro;
type
  TObjectMode = (omAnim,omSprite);

  { TGameObject }

  TGameObject = class
    private
      _CurrentAnim:integer; //actual value of current animation
      procedure SetAnim(Value:Integer); //sets value of animation and if it isn't nil reset it
    public
      Animations:TAnimatedSpriteList;                               //list of animations
      Sprites:TSpriteList;                                          //List of sprites
      CurrentSprite:integer;                                        //We keep current sprite number separately
                                                                    //as to not interfere if we want to switch
                                                                    //GO from animation to static sprite
      ObjectMode:TObjectMode;                                       //Is this GO animated or is it just static
                                                                    //object such as box? We don't need to
                                                                    //animate static objects as it will make
                                                                    //game needlessly slower.
      x,y:Integer;                                                  //x/y positions of GO
      property CurrentAnim:integer read _CurrentAnim write SetAnim; //property for current animation
      procedure MoveTo(_x,_y:Integer);virtual;                      //moves object to specific position
      procedure MoveBy(_x,_y:Integer);virtual;                      //moves object by specified amount of pixels
      function isColliding(GO:TGameObject):Boolean;                 //collision check with another GO
      function isColliding(Sprite:TSprite):Boolean;                 //collision check with a Sprite.
                                                                    //We don't need version with
                                                                    //TAnimatedSprite as it is
                                                                    //descendant of TSprite and
                                                                    //checks exactly same way.
      procedure Update();virtual;                                   //Update function of TGameObject
      procedure Draw(Bitmap:AL_BITMAPptr);virtual;                  //Rendering function of TGameObject
      constructor Create(mode:TObjectMode);                         //constructor 1
      constructor Create(DefaultAnimation:TAnimatedSprite);         //constructor with default animation
      constructor Create(DefaultSprite:TSprite);                    //constructor with default sprite
      destructor Destroy; override;                                 //destructor
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
  Result:=false; //setting result just in case
  case ObjectMode of
    omAnim:   begin
                if Animations.Items[CurrentAnim]<>nil then //safety check so we won't get segfault
                  if GO.ObjectMode=omAnim then //checking if object mode of other game object is animation
                  begin
                    //setting result, checking other's GO "nilness" of animation
                    Result:=((GO.Animations.Items[GO.CurrentAnim]<>nil) and (Animations.Items[CurrentAnim].IsColliding(GO.Animations.Items[GO.CurrentAnim])));
                  end else //if it's not omAnim, then it must be in sprite mode
                  begin
                    //setting result, checking other's GO "nilness" of sprite
                    Result:=((GO.Sprites.Items[GO.CurrentSprite]<>nil) and (Animations.Items[CurrentAnim].IsColliding(GO.Sprites.Items[GO.CurrentSprite])));
                  end;
              end;
    omSprite: begin
                if Sprites.Items[CurrentSprite]<>nil then //safety check so we won't get segfault
                if GO.ObjectMode=omAnim then //checking if object mode of other game object is animation
                begin
                  //setting result, checking other's GO "nilness" of animation
                  Result:=((GO.Animations.Items[GO.CurrentAnim]<>nil) and (Sprites.Items[CurrentSprite].IsColliding(GO.Animations.Items[GO.CurrentAnim])));
                end else //if it's not omAnim, then it must be in sprite mode
                begin
                  //setting result, checking other's GO "nilness" of sprite
                  Result:=((GO.Sprites.Items[GO.CurrentSprite]<>nil) and (Sprites.Items[CurrentSprite].IsColliding(GO.Sprites.Items[GO.CurrentSprite])));
                end;
              end;
  end;
end;

function TGameObject.isColliding(Sprite: TSprite): Boolean;
begin
  Result:=false; //setting result, just in case
  case ObjectMode of
    omAnim:   begin
                if Animations.Items[CurrentAnim]<>nil then //safety check so we won't get segfault
                  //setting result
                  Result:=Animations.Items[CurrentAnim].IsColliding(Sprite);
                end;
    omSprite: begin
                if Sprites.Items[CurrentSprite]<>nil then //safety check so we won't get segfault
                  //setting result
                  Result:=Sprites.Items[CurrentSprite].IsColliding(Sprite);
              end;
  end;
end;

procedure TGameObject.Update;
begin
  case ObjectMode of //we update differently depending of whether it is animation
                     //or sprite, so there you go.
    omAnim:   begin
                if Animations.Items[CurrentAnim]<>nil then //safety check so we won't get segfault
                  begin
                    //updating animation
                    Animations.Items[CurrentAnim].Update;
                    //locking animated sprite's position to game object's
                    Animations.Items[CurrentAnim].x:=x;
                    Animations.Items[CurrentAnim].y:=y;
                  end;
              end;
    omSprite: begin
                if Sprites.Items[CurrentSprite]<>nil then //safety check so we won't get segfault
                  begin
                    //locking sprite's position to game object's
                    Sprites.Items[CurrentSprite].x:=x;
                    Sprites.Items[CurrentSprite].y:=y;
                  end;
              end;
  end;
end;

procedure TGameObject.Draw(Bitmap: AL_BITMAPptr);
begin
  case ObjectMode of
    omAnim:   begin
                if Animations.Items[CurrentAnim]<>nil then //safety check so we won't get segfault
                  begin
                    //when working with animations, we need to test if it needs updating of actual frame and then
                    //render it before we actually draw it to bitmap.
                    if Animations.Items[CurrentAnim].NeedUpdate then Animations.Items[CurrentAnim].UpdateFrame;
                    Animations.Items[CurrentAnim].Draw(Bitmap);
                  end;
              end;
    omSprite: begin
                if Sprites.Items[CurrentSprite]<>nil then //safety check so we won't get segfault
                  //drawing sprite to requested bitmap (usually buffer one)
                  Sprites.Items[CurrentSprite].Draw(Bitmap);
              end;
  end;
end;

constructor TGameObject.Create(mode: TObjectMode);
begin
  inherited Create;
  ObjectMode:=mode;
  //we don't need both lists if we are going to use only one type which is
  //usually the case. If we need both, it is possible to create them
  //after contruction (both will be freed when destroying class if applicable).
  //todo: replace ifs with case of.
  if mode=omAnim then Animations:=TAnimatedSpriteList.create;
  if mode=omSprite then Sprites:=TSpriteList.create;
end;

constructor TGameObject.Create(DefaultAnimation: TAnimatedSprite);
begin
  Create(omAnim); //executing standard constructor with omAnim object mode
  Animations.Add(DefaultAnimation); //adding animation to the list
end;

constructor TGameObject.Create(DefaultSprite: TSprite);
begin
  Create(omSprite); //executing standard constructor with omSprite object mode
  Sprites.Add(DefaultSprite); //adding sprite to the list
end;

destructor TGameObject.Destroy;
begin
  inherited Destroy;
  Animations.Free; //free checks if it is nil, so it'll destroy them only if necessary.
  Sprites.Free;
end;

procedure TGameObject.SetAnim(Value: Integer);
begin
  _CurrentAnim:=Value; //setting actual animation value
  if Animations.Items[_CurrentAnim]<>nil then Animations.Items[_CurrentAnim].Reset; //resetting animation if it wasn't nil so it'll play from start.
end;

end.

