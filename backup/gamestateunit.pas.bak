unit GameStateUnit;

{$mode objfpc}{$H+}
{
Since game's main code will be fairly long, especially update and draw methods
I've come to conclusion it needs its own unit. -Darkhog.
}
interface

uses
  Classes, SysUtils,states,sprites,allegro,al_ogg;
type
  TGameState = class(TState)
    public
      constructor Create;override;
      destructor Destroy;override;
      procedure Update;override;
      procedure BeforeDraw;override;
      procedure Draw;override;
      procedure Main;override;
    private
  end;

implementation
  constructor TGameState.Create;
var bmp:AL_BITMAPptr;
begin
  inherited Create;
end;

destructor TGameState.Destroy;
begin
  inherited Destroy;
end;

procedure TGameState.Update;
begin
  inherited Update;
end;

procedure TGameState.BeforeDraw;
begin
  inherited BeforeDraw;
end;

procedure TGameState.Draw;
begin
  inherited Draw;
end;

procedure TGameState.Main;
begin
  inherited Main;
end;
end.

