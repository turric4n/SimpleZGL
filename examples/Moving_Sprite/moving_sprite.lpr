program moving_sprite;

{	
 *  Copyright (c) 2018 Enrique Fuentes aka. Turrican
 *  Moving Sprite Example
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

  { TKen }

  TKen = class(TSZAnimatedSprite)
    public
      constructor Create(ImagePath: string; Spritebatch: TSZSpriteBath;
      X, Y, W, H: Integer; FrameH, FrameW: Integer; Name: string = '';
      LoadTextureNow: Boolean = False); override;
    private
      fismoving: Boolean;
      ftexture: zglPTexture;
      flastx: Single;
      flasty: Single;
      fspeed: Single;
      finitialspeed : Single;
      fmaxspeed: Single;
      frotationspeed: Single;
      fmissilepershoot: Integer;
      fdirection: Integer;
      //Normal JOY or Keyboard Callback
      procedure JoyInput(Sender: TObject; JoystickNum: Integer; var ReadValues: TSZJoystickStructure);
      //XBOX Joy Callback
      procedure XboxIn(Sender: TObject; ReadValues: TXboxInput);
      procedure Move(movx: Single; movy: Single);
      procedure OnMove;
  end;

  { TCoolBackground }

  TCoolBackground = class(TSZAnimatedBackground)
    public
      procedure Move(Direction : Integer; Speed : Single);
      constructor Create(ImagePath: string; Spritebatch: TSZSpriteBath; X, Y, W,
        H: Integer; FrameH, FrameW: Integer; Name: string='';
        LoadTextureNow: Boolean=False; unlimited: Boolean=True);
  end;

var
  DirApp  : UTF8String;
  DirHome : UTF8String;
  CurrentScene : TSZScene;
  Resolutions : zglPResolutionList;
  ScreenResW : Integer;
  ScreenResH : Integer;
  VirtualResW : Integer;
  VirtualResH : Integer;
  mainfont : zglpfont;
  kenplayer : TKen;
  mainspritebatch : TSZSpriteBath;
  BackGround : TCoolBackground;

function GetMaxRes(const values : array of integer) : Integer;
var
  lasthigh : Integer;
  x : Integer;
begin
  //Strange bug with my nvidia... need to fix... res is very high!
  lasthigh := 0;
  for x := 0 to High(values) do
  if values[x] < 6000 then
    if lasthigh <= values[x] then lasthigh := values[x];
  Result := lasthigh;
end;

{PROGRAM CALLBACKS}

procedure Input;
begin
  if Assigned(CurrentScene) then
  begin
    CurrentScene.Input;
    CurrentScene.ProcessTimer;
  end;
end;

procedure Init;
begin
  //Init screen and resolution (get the most optimal resolution)
  Resolutions := zglPResolutionList(zgl_Get(RESOLUTION_LIST));
  zgl_Enable( CORRECT_RESOLUTION );
  ScreenResW := GetMaxRes(Resolutions.Width);
  ScreenResH := GetMaxRes(Resolutions.Height);
  //Set virtual res and real res
  VirtualResH := 1080;
  VirtualResW := 1920;
  //Adjust screen settings
  if scr_SetOptions(ScreenResW, ScreenResH, REFRESH_MAXIMUM, False, True ) then
  begin
    scr_CorrectResolution(VirtualResW, VirtualResH);
  end;
  //Load Font
  MainFont := font_LoadFromFile(DirApp + 'fipps-20pt.zfi');
  //Create scene
  CurrentScene := TSZScene.Create(0 , 0, VirtualResH,  VirtualResW, mainfont, '', 'mainscene');

  //Very important if you want to use joystick or keyboard controls because if not init will crash
  CurrentScene.HandleKeyboard := True;
  CurrentScene.InitJoysticks;

  //Create SpriteBatch and add to scene
  MainSpritebatch := TSZSpriteBath.Create(CurrentScene.GetRect, 'mainsprbtch');
  CurrentScene.Add(MainSpritebatch);
  BackGround := TCoolBackground.Create('background.jpg',mainspritebatch,Round(mainspritebatch.Rectangle.X),Round(mainspritebatch.Rectangle.Y),VirtualResW * 2, VirtualResH,640,1600,'Background',true,true);
  //Create background and aad to spritebatch
  mainspritebatch.Add(BackGround);


  //Load Ken Sprite and assign to spritebatch  (Sprite-sheets need to be proportional need to implement real spritesheet!!!)
  kenplayer := TKen.Create('ken.png',MainSpriteBatch,0,Round(mainspritebatch.Rectangle.H / 2),512,512,110,103, 'Ken');

  CurrentScene.ShowFPS := True;
  CurrentScene.Start;
  MainSpritebatch.Start;
end;

procedure Draw;
begin
  if Assigned(CurrentScene) then CurrentScene.Draw;
  text_Draw(mainfont,0,0,IntToStr(Round(Background.GetCamera.X)));
  text_Draw(mainfont,0,50,IntToStr(Round(Background.GetRectangle2.X)));
  text_Draw(mainfont,0,100,IntToStr(Round(Background.GetRectangle2.X + Background.GetRectangle2.W) - VirtualResW));
end;

procedure Update( dt : Double );
begin
  if Assigned(CurrentScene) then CurrentScene.Update(dt);
end;

//Background movement

procedure TCoolBackground.Move(Direction: Integer; Speed : Single);
begin
  if Boolean(Direction) then Self.GetCamera.X := Self.GetCamera.X + (Speed / 2)
  else Self.GetCamera.X := Self.GetCamera.X - (Speed / 2);
  if Self.GetCamera.X <= 0 then Self.GetCamera.X := 0
  else if Self.GetCamera.X >= (Background.GetRectangle2.X + Background.GetRectangle2.W) - VirtualResW then Self.GetCamera.X := (Background.GetRectangle2.X + Background.GetRectangle2.W) - VirtualResW;
end;

constructor TCoolBackground.Create(ImagePath: string;
  Spritebatch: TSZSpriteBath; X, Y, W, H: Integer; FrameH, FrameW: Integer;
  Name: string; LoadTextureNow: Boolean; unlimited: Boolean);
begin
  inherited Create(ImagePath, Spritebatch, X, Y, W, H, FrameH, FrameW, Name,
    LoadTextureNow, unlimited);
  FlipSecondBackground:= True;
end;

{TKen}

constructor TKen.Create(ImagePath: string; Spritebatch: TSZSpriteBath; X, Y, W,
  H: Integer; FrameH, FrameW: Integer; Name: string; LoadTextureNow: Boolean);
begin
  inherited Create(ImagePath, Spritebatch, X, Y, W, H, FrameH, FrameW, Name,
    LoadTextureNow);
  _flip:=true;
  _angle:=0;
  fmaxspeed:=16;
  fInitialSpeed := 8;
  fspeed:=fInitialSpeed;
  fismoving:=True;
  flastx:= _rectangle.x;
  _frame:=1;
  if assigned(Spritebatch) then
  begin
    Spritebatch.add(Self);
    Self.AssignJoystick(CurrentScene.GetJoystickHandler.GetFreeXBOXJoystick);
    Self.AssignKeyboard(CurrentScene.GetKeyboardHandler.GetKeyboard);
    Self.OnJoyInput := Self.JoyInput;
    Self.OnXboxInput:=Self.OnXboxInput;
  end;
end;

//Ken's input

procedure TKen.JoyInput(Sender: TObject; JoystickNum: Integer; var ReadValues: TSZJoystickStructure);
begin
  if (readvalues.X > 0) or (readvalues.X < 0) or (readvalues.Y > 0) or (readvalues.Y < 0) then Move(readvalues.x, readvalues.y);
end;

procedure TKen.XboxIn(Sender: TObject; ReadValues: TXboxInput);
begin
  Move(ReadValues.Gamepad.sThumbLX, ReadValues.Gamepad.sThumbLY)
end;

//Ken's movement affects on background

procedure TKen.Move(movx: Single; movy: Single);
begin
  flastx:=_rectangle.X;
  flasty:=_rectangle.Y;
  if movx > 0 then
  begin
    if fdirection = 0 then fspeed := finitialspeed;
    fdirection := 1;
    fismoving := True;
  end
  else if movx < 0 then
  begin
    if fdirection = 1 then fspeed := finitialspeed;
    fdirection := 0;
    fismoving := true;
  end
  else Exit;
  if fspeed < fmaxspeed then fspeed:=fspeed + (abs(fspeed)) / 60;
  case fdirection of
    0:
    begin
      if (_rectangle.X > (VirtualResW div 2) - 256) or (Background.GetCamera.X <= 0)  then
      begin
        _rectangle.X:=_rectangle.X + (movx * fspeed);
        _rectangle.Y :=_rectangle.Y - (movy * fspeed);
      end
      else BackGround.Move(fdirection, fspeed);
    end;
    1:
    begin
      if (_rectangle.X < (VirtualResW div 2) - 256) or (Background.GetCamera.X >= (Background.GetRectangle2.X + Background.GetRectangle2.W) - VirtualResW)  then
      begin
        if not ((_rectangle.X + 256) > Background.GetRectangle2.X + Background.GetRectangle2.W) then
        begin
          _rectangle.X:=_rectangle.X + (movx * fspeed);
          _rectangle.Y :=_rectangle.Y - (movy *  fspeed);
        end;
      end
      else BackGround.Move(fdirection, fspeed);
    end
  end;
  onmove;
end;

//On ken's movement implement frame animation

procedure TKen.OnMove;
begin
  case fdirection of
    1:
    begin
      if not Flip then Flip:=true;
    end;
    0:
    begin
      if Flip then Flip:=false;
    end;
  end;
  if Frame < 0 then Frame:=0
  else if Frame < 6.2 then Frame:=Frame + (abs(fspeed)) / 60
  else Frame:=0;
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

  wnd_SetCaption( 'Moving sprite' );

  wnd_ShowCursor( TRUE );

  zgl_Disable( APP_USE_LOG );

  zgl_Init;
end.

