program starfieldshooter;

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
  sysutils,
  SimpleZGL,
  zglHeader,
  uGlobal,
  uScenes;

type
  TIntArray = array of Integer;

const
  MAXFPS = 60;
var
  DirApp  : UTF8String;
  DirHome : UTF8String;
  last_update : Double;
  last_draw : Double;
  min_wait_ticks : Double = 1000 div MAXFPS;
  next_gameticke : Double = 0;
  sleep_time : Double = 0;
  audio   : Integer;

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
    scr_CorrectResolution(1920,1080);
  end
  else halt;
  //Create mainfont
  MainFont := font_LoadFromFile(DIRRES + 'font.zfi');
  CurrentScene := uScenes.TSceneHelper.IntroScene;
  CurrentScene.Start;
end;

procedure Draw;
begin
  if Assigned(CurrentScene) then CurrentScene.Draw;
  text_Draw(MainFont, 0, 50, Inttostr(ScreenResW) + 'X' + Inttostr(ScreenResH));
end;

procedure Update( dt : Double );
begin
  while timer_GetTicks < (last_update + min_wait_ticks) do u_Sleep(1);
  last_update:=timer_GetTicks;
  if Assigned(CurrentScene) then CurrentScene.Update(dt);
end;

procedure Quit;
begin

end;

Begin
  //Start ZenGL
  if not zglLoad( libZenGL ) Then exit;

  DirApp  := utf8_Copy( PAnsiChar( zgl_Get( DIRECTORY_APPLICATION ) ) );
  DirHome := utf8_Copy( PAnsiChar( zgl_Get( DIRECTORY_HOME ) ) );

  zgl_Reg( SYS_LOAD, @Init );

  zgl_Reg( SYS_DRAW, @Draw );

  zgl_Reg( SYS_UPDATE, @Update );

  timer_Add(@Input, 16, false, nil);

  zgl_Reg( SYS_EXIT, @Quit );

  wnd_SetCaption( 'Turrican''s StarField' );

  wnd_ShowCursor( TRUE );

  zgl_Disable( APP_USE_LOG );

  zgl_Init;
End.
