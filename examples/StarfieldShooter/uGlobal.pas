unit uGlobal;

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
    System.Contnrs,
    zglheader;
  {$ELSE}
    {$IFDEF ANDROID}
    zgl_font,
    zgl_textures,
    zgl_screen,
    {$ELSE}
    zglheader,
    {$ENDIF}
    Contnrs;
  {$ENDIF}

const
  DEBUG = False;
  {$IFDEF ANDROID}
  DIRRES : UTF8String = 'assets/';
  {$ELSE}
  DIRRES : UTF8String = '.\assets\';
  {$ENDIF}

var
  CurrentScene : TSZScene;
  MainScene : TSZScene;
  MainFont : zglPFont;
  Resolutions : zglPResolutionList;
  ExtraFont : zglPfont;
  StarTexture : zglPTexture;
  ScreenResW : Integer;
  ScreenResH : Integer;
  StarField : TSZSpriteBath;

implementation


end.
