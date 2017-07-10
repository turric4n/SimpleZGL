unit uObjects;

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
  {$IFDEF ANDROID}
  zgl_screen,
  zgl_window,
  zgl_timers,
  zgl_touch,
  zgl_render_2d,
  zgl_fx,
  zgl_log,
  zgl_textures,
  zgl_textures_png,
  zgl_sprite_2d,
  zgl_memory,
  zgl_primitives_2d,
  zgl_font,
  zgl_text,
  zgl_math_2d,
  zgl_utils,
  zgl_lib_ogg,
  zgl_types,
  zgl_camera_2d,
  zgl_collision_2d,
  {$ELSE}
  zglheader,
  {$ENDIF}
  SimpleZGL;

type
  TFrameAnimation = class(TSZAnimation)
    public
      procedure ProcessAnimation; override;
  end;

  TStar = class (TSZAnimatedSprite)
    private
      acceleration : Extended;
      accelerationhit : Extended;
      hit : Extended;
      firstx : Extended;
      firsty : Extended;
      procedure Collision(ASender: TObject);
      procedure Click(ASender: TObject; Button : ShortInt; X, Y : Single);
    public
      constructor Create(_texture: zglPTexture; Spritebatch: TSZSpriteBath; X: Integer; Y: Integer; W: Integer; H: Integer; FrameH: Integer; FrameW: Integer; Name: string = '');
      procedure Process; override;
      procedure ProcessAnimation;
      procedure Reset;
  end;

  { TShoot }

  TShoot = class(TSZAnimatedSprite)
    private
      acceleration : Extended;
      accelerationhit : Extended;
      hit : Extended;
      firstx : Extended;
      firsty : Extended;
    public
      constructor Create(_texture: zglPTexture; Spritebatch: TSZSpriteBath; X: Integer; Y: Integer; W: Integer; H: Integer; FrameH: Integer; FrameW: Integer; Name: string = '');
      procedure Process; override;
      procedure ProcessAnimation;
      procedure Reset;
  end;

  { TStarfield }

  TStarfield = class(TSZSpriteBath)
    private
      fmainstar : TStar;
      hiddenshoot : TShoot;
      procedure Shoot(ASender: TObject; Button: ShortInt; X, Y: Single);
    public
      constructor Create(Rect: zglTRect; const Name : string = ''; const StarCount : Integer = 1);
  end;



implementation

{ TFrameAnimation }

procedure TFrameAnimation.ProcessAnimation;
begin
  if Assigned(OnProcess) then OnProcess(Self);
end;

{ TStar }

procedure TStar.Click(ASender: TObject; Button: ShortInt; X, Y: Single);
begin
  //accelerationhit := 32;
end;

procedure TStar.Collision(ASender: TObject);
begin
  if not (ASender is TStar) then
  begin
    if ASender is TShoot then
    begin
      if TShoot(ASender).Rect.H < Self.Rect.H then
      begin
        Self.FadeAmount := 5;
        Self.FadeOut;
        TShoot(ASender).FadeOut;
      end;
    end;
  end;
end;

constructor TStar.Create(_texture: zglPTexture; Spritebatch: TSZSpriteBath; X, Y, W, H, FrameH, FrameW: Integer; Name: string);
begin
  inherited Create(_texture, Spritebatch, X, Y, W, H, FrameH, FrameW, Name);
  OnCollision := Collision;
  OnMouseClick := Click;
  firstx := x;
  firsty := y;
  acceleration := W * 0.15;
  Rotate;
end;

procedure TStar.Reset;
begin
  self.Rect.X := firstx;
  Self.Rect.Y := firsty;
end;

procedure TStar.Process;
begin
  ProcessOpacity;
  ProcessAnimation;
end;

procedure TStar.ProcessAnimation;
begin
  inherited;
  if accelerationhit > 0 then
  accelerationhit := accelerationhit - 0.4;
  Self.Rect.X := (Self.Rect.X - acceleration) + accelerationhit;
  if Self.Rect.X < Self._spritebatch.Rectangle.X - Self.Rect.W then
  begin
    Self.Rect.X :=  Round(Self._spritebatch.Rectangle.W + 256);
    Self.Rect.Y := Random(Round(Self._spritebatch.Rectangle.H + 10));
  end;
end;

{ TStarField }

constructor TStarfield.Create(Rect: zglTRect; const Name: string;
  const StarCount: Integer);
var
  x : Integer;
  newstar : TStar;
  w : Integer;
  h : Integer;
begin
  Randomize;
  inherited Create(Rect, Name);
  fmainstar := TStar(TSZAnimatedSprite.Create('assets/' + 'star.png', Self, 0, 0, 128, 128, 256, 256, 'MainStar', True));
  for x := 0 to StarCount + 1 do
  begin
    w := Random(128);
    h := w;
    newstar := TStar.Create(fmainstar.texture, self, Round(Self.Rectangle.W + 256), Random(Round(Self.Rectangle.H)), w, h, 256, 256);
    Self.Add(newstar);
    newstar.isCollideable := True;
    newstar.Alpha := 255;
  end;
  Self.Collideable := True;
  hiddenshoot := TShoot.Create('assets/' + 'magic_ball.png', Self, 0, 0, 512, 512, 128, 128, 'Shoot', True);
  Self.OnMouseClick := Shoot;
end;

procedure TStarfield.Shoot(ASender: TObject; Button: ShortInt; X, Y: Single);
var
  shoot : TShoot;
begin
  Shoot := TShoot.Create(hiddenshoot.texture, Self, Round(x) - 32, Round(y) - 32, 512, 512, 128, 128, 'Shoot');
  Self.Add(Shoot);
  Shoot.Visible := True;
  Shoot.Alpha := 255;
end;

{ TShoot }

constructor TShoot.Create(_texture: zglPTexture; Spritebatch: TSZSpriteBath; X, Y, W, H, FrameH, FrameW: Integer; Name: string);
begin
  inherited;
  firstx := x;
  firsty := y;
  acceleration := W * 0.15;
  Rotate;
  _iscollideable := True;
end;

procedure TShoot.Process;
begin
  ProcessOpacity;
  ProcessAnimation;
end;

procedure TShoot.ProcessAnimation;
begin
  inherited;
  Self.Rect.H := Self.Rect.H - 8;
  Self.Rect.W := Self.Rect.W - 8;
  if Self.Rect.H <= 0 then
  begin
    _iscollideable := False;
    Self.Delete;
  end;
end;

procedure TShoot.Reset;
begin

end;

end.
