unit masked_collision;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, allegro,Sprites;
function collide(Sprite1:TSprite; Sprite2:TSprite):Boolean;
implementation

function max(a,b:Integer):integer;
begin
    if a>b then result:=a else result:=b;
end;
function min(a,b:Integer):integer;
begin
    if a<b then result:=a else result:=b;
end;

function collide( Sprite1: TSprite; Sprite2: TSprite):boolean;
var  xmax1,xmax2,ymax1,ymax2,xmin,xmax,ymin,ymax,x,y,x1,x2,y1,y2,color1,color2,mask1,mask2:Integer;
begin
	  xmax1 := Sprite1.x + sprite1.ActualMaskBitmap^.w;
          ymax1 := Sprite1.y + sprite1.ActualMaskBitmap^.h;
	  xmax2 := Sprite2.x + sprite2.ActualMaskBitmap^.w;
          ymax2 := Sprite2.y + sprite2.ActualMaskBitmap^.h;
	  xmin := max(Sprite1.x, Sprite2.x);
	  ymin := max(Sprite1.y, Sprite2.y);
	  xmax := min(xmax1, xmax2);
	  ymax := min(ymax1, ymax2);
	  if ((xmax <= xmin) or (ymax <= ymin)) then begin Result:=false; exit; end;
	  mask1 := al_bitmap_mask_color(sprite1.ActualMaskBitmap);
	  mask2 := al_bitmap_mask_color(sprite2.ActualMaskBitmap);
	  for y := ymin to ymax-1 do begin
	    for x := xmin to xmax-1 do begin
	      x1 := x - Sprite1.x; y1 := y - Sprite1.y;
	      x2 := x - Sprite2.x; y2 := y - Sprite2.y;
	      color1 := al_getpixel(sprite1.ActualMaskBitmap, x1, y1);
	      color2 := al_getpixel(sprite2.ActualMaskBitmap, x2, y2);
	      if (((color1<>mask1) and (color2 <> mask2)) {or ((al_geta(color1)<128)) and ((al_geta(color2)<128))}) then begin Result:=true; exit; end;
	    end;
	  end;
	  Result:=false
end;



end.

