program lainz_circle;

{
 *  Copyright (c) 2017 Enrique Fuentes aka. Turrican
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

type

  { TUtils }

  TUtils = class
    public
      class function isCircle(const error : Double) : Boolean;
      class function getDistance(p1, p2 : TPoint) : Double;
      class function getCenter(p1, p2 : TPoint) : TPoint;

  end;

  { TSpecialSquare }

  TSpecialSquare = class(TSZSquare)
    private
      procedure MouseOver(ASender: TObject; X, Y : Single);
      procedure ResetOpacity(ASender : TObject);
    public
      procedure Draw; override;
  end;

  { TGrid }

  TGrid = class(TSZSpriteBath)
    public
      constructor Create(Rect: zglTRect; Name: string='');
    private
      procedure MouseGesture(ASender: TObject; Button : ShortInt; Move : zglTPoint2D);
      procedure MouseGestureOut(ASender: TObject; Button : ShortInt; Move : zglTPoint2D);
      procedure MouseOver(ASender: TObject; X, Y : Single);
      procedure DrawLines(Sender : TObject);
  end;

const
  MAXFPS = 60;
  MAX_STEPS = 100;
  SHADOW_STEP = 255 div MAX_STEPS;

var
  DirApp  : UTF8String;
  DirHome : UTF8String;
  CurrentScene : TSZScene;
  MainSpritebatch : TGrid;
  Resolutions : zglPResolutionList;
  ScreenResW : Integer;
  ScreenResH : Integer;
  mainfont : zglpfont;
  gridmouseclick : Boolean;
  steps : array[0..MAX_STEPS - 1] of TPoint;
  current_step : LongInt;
  cur: TPoint;
  circles: integer;

class function TUtils.isCircle(const error: Double): Boolean;
var
  weights: array of double;
  maxDistance, sumDistance, avgDistance, errorConstraint, distance, d: double;
  i, j: integer;
begin
  SetLength(weights, 0);
  maxDistance := 0;
  sumDistance := 0;
  avgDistance := 0;
  errorConstraint := 0;
  for i := 0 to MAX_STEPS - 1 do
  begin
    distance := 0;
    for j := 0 to MAX_STEPS - 1 do
    begin
      d := getDistance(steps[i], steps[j]);
      if (d > distance) then
        distance := d;
    end;
    if (distance > 0) then
    begin
      if (distance > maxDistance) then
        maxDistance := distance;
      sumDistance += distance;
      SetLength(weights, Length(weights) + 1);
      weights[Length(weights) - 1] := distance;
    end;
  end;
  if (Length(weights) > 0) then
    avgDistance := sumDistance / Length(weights)
  else
    exit(False);
  errorConstraint := error * avgDistance;
  for i := 0 to Length(weights) - 1 do
  begin
    if (abs(avgDistance - weights[i]) > errorConstraint) then
      exit(False);
  end;
  exit(True);
end;

class function TUtils.getDistance(p1, p2: TPoint): Double;
begin
  exit(sqrt((p2.x - p1.x) * (p2.x - p1.x) + (p2.y - p1.y) * (p2.y - p1.y)));
end;

class function TUtils.getCenter(p1, p2: TPoint): TPoint;
begin
  exit(Point((p2.x + p1.x) div 2, (p2.y + p1.y) div 2));
end;

{TSpecialSquare}

procedure TSpecialSquare.Draw;
begin
  inherited Draw;
end;

procedure TSpecialSquare.MouseOver(ASender: TObject; X, Y: Single);
begin
  if ASender is TSpecialSquare then
  begin
    if not gridmouseclick then
    begin
      Self.Filled := True;
      Self.FillColor := $FFFFFFF;
      Self.OnFadeOut := Self.ResetOpacity;
      TSpecialSquare(ASender).FadeOut(5);
    end;
  end;
end;

procedure TSpecialSquare.ResetOpacity(ASender: TObject);
begin
  if ASender is TSpecialSquare then
  begin
    TSpecialSquare(ASender).Filled := False;
    TSpecialSquare(ASender).FillColor := $1e1414;
    TSpecialSquare(ASender).Alpha := 255;
  end;
end;

{ TGrid }

constructor TGrid.Create(Rect: zglTRect; Name: string);
var
  row, col, num_row, num_col : Integer;
  y, x : Integer;
  square : TSpecialSquare;
begin
  inherited Create(Rect, Name);
  gridmouseclick := False;
  self.OnGesture := MouseGesture;
  self.OnGestureRelease := MouseGestureOut;
  self.OnMouseCollision := MouseOver;
  num_row := ScreenResH div 32;
  num_col := ScreenResW div 32;
  for row := 0 to num_row do
  begin
    for col := 0 to num_col do
    begin
      y := row * 32;
      x := col * 32;
      square := TSpecialSquare(Self.Add(TSpecialSquare.Create(Self, x, y, 32, 32, 'Square_' + IntToStr(col) + '_' + IntToStr(row))));
      square.FillColor := $1e1414;
      square.OnMouseCollision := square.MouseOver;
    end;
  end;
end;

procedure TGrid.MouseGesture(ASender: TObject; Button : ShortInt; Move : zglTPoint2D);
begin
  if Button = M_BLEFT then
  begin
    if not gridmouseclick then gridmouseclick := True
    else if gridmouseclick and TUtils.isCircle(0.3) then Inc(circles);
  end
end;

procedure TGrid.MouseGestureOut(ASender: TObject; Button: ShortInt;
  Move: zglTPoint2D);
begin
  if Button = M_BLEFT then gridmouseclick := False;
end;

procedure TGrid.MouseOver(ASender: TObject; X, Y: Single);
begin
  cur := Point(trunc(Round(x) div 32), trunc(Round(y) div 32));
end;

procedure TGrid.DrawLines(Sender: TObject);
var
  i, y, x, y2, x2 : Integer;
begin
  if gridmouseclick then
  begin
    for i := 0 to MAX_STEPS - 2 do
    begin
      y := steps[(current_step + i) mod MAX_STEPS].y * 32;
      x := steps[(current_step + i) mod MAX_STEPS].x * 32;
      begin
        y2 := steps[(current_step + i + 1) mod MAX_STEPS].y * 32;
        x2 := steps[(current_step + i + 1) mod MAX_STEPS].x * 32;
        pr2d_Line(x,y,x2,y2, $FFFFFF, SHADOW_STEP * i, PR2D_SMOOTH or PR2D_FILL);
      end;
    end;
  end;
end;

function GetMaxRes(const values : array of integer) : Integer;
var
  lasthigh : Integer;
  x : Integer;
begin
  lasthigh := 0;
  for x := 0 to High(values) do if lasthigh <= values[x] then lasthigh := values[x];
  Result := lasthigh;
end;

{PROGRAM CALLBACKS}

procedure Input;
begin
  if Assigned(CurrentScene) then
  begin
    CurrentScene.Input;
    CurrentScene.ProcessTimer;
    steps[current_step mod MAX_STEPS] := cur;
    Inc(current_step);
  end;
end;

procedure Init;
begin
  //Init screen and resolution (get the most optimal resolution)
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
  MainSpritebatch := TGrid.Create(CurrentScene.GetRect, 'mainsprbtch');
  MainSpritebatch.OnMouseClick := MainSpritebatch.OnMouseClick;
  MainSpritebatch.OnAfterDraw := MainSpritebatch.DrawLines;
  CurrentScene.Add(MainSpritebatch);
  CurrentScene.ShowFPS := True;
  CurrentScene.Start;
  MainSpritebatch.Start;
  circles := 0;
end;

procedure Draw;
begin
  if Assigned(CurrentScene) then CurrentScene.Draw;
  text_Draw(mainfont, 20,0, Inttostr(circles));
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

  wnd_SetCaption( 'Lainz''s Circle' );

  wnd_ShowCursor( TRUE );

  zgl_Disable( APP_USE_LOG );

  zgl_Init;
end.

