program colorfading;

{	
 *  Copyright (c) 2018 Enrique Fuentes aka. Turrican
 *  Based on Lainz BGRA Canvas example and ported to SimpleZGL. Thanks for awesome BGRA Example! 
 *  
 *  This software is provided 'as-is', without any express or
 *  implied warranty. In no event will the authors be held
 *  liable for any damages arising from the use of this software.
 *
 *  Permission is granted to anyone to use this software for any purpose,
 *  including commercial applications, and to alter it and redistribute
 *  it freely, subject to the following restrictions:
 *
 *  1. The origin of this software must not be misrepresented;
 *     you must not claim that you wrote the original software.
 *     If you use this software in a product, an acknowledgment
 *     in the product documentation would be appreciated but
 *     is not required.
 *
 *  2. Altered source versions must be plainly marked as such,
 *     and must not be misrepresented as being the original software.
 *
 *  3. This notice may not be removed or altered from any
 *     source distribution.
}



uses
  SimpleZGL,
  Classes,
  sysutils,
  zglHeader,
  Math;

const
  MAXFPS = 60;
  MAXROWS = 10;
  MAXCOLS = 2;
  COLORTABLE : array[0..MAXCOLS,0..MAXROWS] of Integer = (
    ($FF0000, $44C0CB, $C71585, $CC8040, $453545, $003545, $453445, $453400, $324255, $909090, $AA8888),
    ($00FF00, $3CFFCA, $FF7705, $FF4050, $555555, $543955, $AABBCC, $FAFFCC, $873433, $734283, $BB8341),
    ($0000FF, $C0CBFF, $1585C7, $88CBAA, $938429, $000333, $213123, $FEE333, $EEE222, $ACF233, $CAFFFF)
  );

  RED = $FF0000; //RGB
  GREEN = $00FF00; //RGB
  BLUE = $0000FF; //RGB


var
  DirApp  : UTF8String;
  DirHome : UTF8String;
  CurrentScene : TSZScene;
  MainSpritebatch : TSZSpriteBath;
  Resolutions : zglPResolutionList;
  ScreenResW : Integer;
  ScreenResH : Integer;
  mainfont : zglpfont;
  NowColor : LongInt;
  BaseColor : LongInt;
  NextColor : LongInt;
  CurrentRow : Integer;
  CurrentCol : Integer;
  SpriteRectangle : TSZSquare;
  iteration : Integer;

function GetMaxRes(const values : array of integer) : Integer;
var
  lasthigh : Integer;
  x : Integer;
begin
  lasthigh := 0;
  for x := 0 to High(values) do if lasthigh <= values[x] then lasthigh := values[x];
  Result := lasthigh;
end;

function ColorToRGB(Color : LongInt) : TRGB;
begin
  Result.r := (Color shr 16) and $FF;
  Result.g := (Color shr 8) and $FF;
  Result.b := Color and $FF;
end;

function RGBToColor(Color : TRGB) : LongInt;
begin
  Result := Color.B + Color.G shl 8 + Color.R shl 16;
end;

function IsTheSameColor(ColorA, ColorB : LongInt) : Boolean;
var
 a, b : TRGB;
begin
  a := ColorToRGB(ColorA);
  b := ColorToRGB(ColorB);
  Result := (a.r = b.r) and (a.g = b.g) and (a.b = b.b);
end;

function FadeCurrentColorToNextFrame(CurrentColor, TargetColor : LongInt) : LongInt;
var
  Curr : TRGB;
  Tgt  : TRGB;
begin
  Curr := ColorToRGB(CurrentColor);
  Tgt := ColorToRGB(TargetColor);
  if Curr.r > Tgt.r then Dec(Curr.r)
  else if Curr.r < Tgt.r then Inc(Curr.r);
  if Curr.g > Tgt.g then Dec(Curr.g)
  else if Curr.g < Tgt.g then Inc(Curr.g);
  if Curr.b > Tgt.b then Dec(Curr.b)
  else if Curr.b < Tgt.b then Inc(Curr.b);
  Result := RGBToColor(Curr);
end;

{PROGRAM CALLBACKS}

procedure Input;
begin
  if Assigned(CurrentScene) then
  begin
    CurrentScene.Input;
    CurrentScene.ProcessTimer;
  end;
  if IsTheSameColor(NowColor,COLORTABLE[CurrentCol, CurrentRow]) then
  begin
    if CurrentRow = MAXROWS then
    begin
      if CurrentCol = MAXCOLS then currentcol := 0
      else Inc(CurrentCol);
      CurrentRow := 0;
      Inc(Iteration);
    end
    else Inc(CurrentRow);
  end;
  NowColor := FadeCurrentColorToNextFrame(NowColor, COLORTABLE[CurrentCol, CurrentRow]);
  SpriteRectangle.FillColor := NowColor;
end;

procedure Init;
var
  a : TRGB;
  b : LongWord;
begin
  //Init screen and resolution (get the most optimal resolution)
  Iteration := 0;
  Resolutions := zglPResolutionList(zgl_Get(RESOLUTION_LIST));
  zgl_Enable( CORRECT_RESOLUTION );
  ScreenResW := GetMaxRes(Resolutions.Width);
  ScreenResH := GetMaxRes(Resolutions.Height);
  if scr_SetOptions(ScreenResW, ScreenResH, REFRESH_MAXIMUM, False, True ) then
  begin
    scr_CorrectResolution(ScreenResW,ScreenResH);
  end;
  MainFont := font_LoadFromFile(DirApp + 'font.zfi');
  CurrentScene := TSZScene.Create(0 , 0, ScreenResH, ScreenResW, mainfont, '', 'mainscene');
  MainSpritebatch := TSZSpriteBath.Create(CurrentScene.GetRect, 'mainsprbtch');
  SpriteRectangle := TSZSquare.Create(MainSpritebatch,Round(MainSpritebatch.Rectangle.X),Round(MainSpritebatch.Rectangle.Y),Round(MainSpritebatch.Rectangle.W),Round(MainSpritebatch.Rectangle.H), 'Test');
  //FirstColor
  CurrentCol := 0;
  CurrentRow := 0;
  NowColor := COLORTABLE[CurrentCol,CurrentRow];
  NextColor := COLORTABLE[CurrentCol,CurrentRow + 1];
  a := ColorToRGB(NextColor);
  BaseColor := NowColor;
  SpriteRectangle.FillColor := NowColor;
  SpriteRectangle.Filled := True;
  MainSpritebatch.Add(SpriteRectangle);
  CurrentScene.Add(MainSpritebatch);
  CurrentScene.ShowFPS := True;
  CurrentScene.Start;
  MainSpritebatch.Start;
end;

procedure Draw;
begin
  if Assigned(CurrentScene) then CurrentScene.Draw;
end;

procedure Update( dt : Double );
begin
  if Assigned(CurrentScene) then CurrentScene.Update(dt);
end;

{MAIN}

begin
  //Init ZenGL
  if not zglLoad( libZenGL ) Then exit;
  //Define APP Directories
  DirApp  := utf8_Copy( PAnsiChar( zgl_Get( DIRECTORY_APPLICATION ) ) );
  DirHome := utf8_Copy( PAnsiChar( zgl_Get( DIRECTORY_HOME ) ) );
  //Register CALLBACKS from ZenGL backend
  zgl_Reg( SYS_LOAD, @Init );

  zgl_Reg( SYS_DRAW, @Draw );

  zgl_Reg( SYS_UPDATE, @Update );
  //Register input timer
  timer_Add(@Input, 16, false, nil);

  wnd_SetCaption( 'Color Fading' );

  wnd_ShowCursor( TRUE );

  zgl_Disable( APP_USE_LOG );

  zgl_Init;
end.

