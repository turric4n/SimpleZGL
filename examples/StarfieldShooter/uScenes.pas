unit uScenes;

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

{$MODE Delphi}

interface

uses
  SimpleZGL,
  uObjects,
  {$IFDEF DCC}
  System.Math,
  {$ELSE}
  {$IFDEF ANDROID}
  zgl_textures,
  {$ELSE}
  zglHeader,
  {$ENDIF}
  Math,
  {$ENDIF}
  uGlobal;

type
  TSceneHelper = class
    public
      class function IntroScene : TSZScene;
  end;

implementation

{ TSceneHelper }

class function TSceneHelper.IntroScene: TSZScene;
var
  Event : TSZEvent;
begin
  //Create intro mainScene
  Result := TSZScene.Create(0,0,1080,1920,MainFont,'','IntroScene');
  Result.ShowTimer:=True;
  Result.ShowFPS:=True;
  Result.HandleKeyboard:=True;
  StarField := TStarfield.Create(Result.GetRect, 'Starfield', 128);
  Result.Add(StarField);
  StarField.Start;
end;


end.
