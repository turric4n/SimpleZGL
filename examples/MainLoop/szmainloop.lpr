program szmainloop;

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
  zglHeader;

const
  MAXFPS = 60;

var
  DirApp  : UTF8String;
  DirHome : UTF8String;
  CurrentScene : TSZScene;
  Resolutions : zglPResolutionList;
  ScreenResW : Integer;
  ScreenResH : Integer;
  mainfont : zglpfont;

function GetMaxRes(const values : array of integer) : Integer;
var
  lasthigh : Integer;
  x : Integer;
begin
  lasthigh := 0;
  for x := 0 to High(values) do
  begin
    if lasthigh <= values[x] then lasthigh := values[x];
  end;
  Result := lasthigh;
end;

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
  if scr_SetOptions(ScreenResW, ScreenResH, REFRESH_MAXIMUM, True, True ) then
  begin
    scr_CorrectResolution(ScreenResW,ScreenResH);
  end;
  MainFont := font_LoadFromFile(DirApp + 'font.zfi');
  CurrentScene := TSZScene.Create(0 , 0, ScreenResH, ScreenResW, mainfont, '', 'mainscene');
  CurrentScene.ShowFPS := true;
  CurrentScene.Start;
end;

procedure Draw;
begin
  if Assigned(CurrentScene) then CurrentScene.Draw;
end;

procedure Update( dt : Double );
begin
  if Assigned(CurrentScene) then CurrentScene.Update(dt);
end;

procedure Quit;
begin
  halt;
end;

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
  //Register exit callback
  zgl_Reg( SYS_EXIT, @Quit );

  wnd_SetCaption( 'MainLoop' );

  wnd_ShowCursor( TRUE );

  zgl_Disable( APP_USE_LOG );

  zgl_Init;
end.

