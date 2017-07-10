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
         

unit SimpleXinput;

interface
   {$DEFINE USE_XINPUT}
   {$IFDEF USE_XINPUT}
   uses
   XInput,
  {$IFDEF FPC}
    Windows;
  {$ELSE}
    Winapi.Windows;
  {$ENDIF}


type
  TXBoxControllerEventsDisconnected = procedure(Sender: TObject) of object;
  TXBoxControllerEventsConnected = procedure(Sender: TObject) of object;
  TXboxInputState = XINPUT_STATE;
  TXBoxController = class(TObject)
    private
      _controllerState: XINPUT_STATE;
      _controllerNum: Integer;
      _controllerDetected: Boolean;
      _connected: Boolean;
    public
      OnDisconnected: TXBoxControllerEventsDisconnected;
      OnConnected: TXBoxControllerEventsConnected;
      property IsConnected: boolean read _connected;
      constructor Create(playerNumber: Integer);
      function GetState: XINPUT_STATE;
      procedure Vibrate(Left,Right: Integer);
      const
        INPUT_DEADZONE = 7864;
  end;

{$endif}

implementation

{$IFDEF USE_XINPUT}

constructor TXBoxController.Create(playerNumber: Integer);
begin
  _controllerNum:=playerNumber;
end;

function TXBoxController.GetState: XINPUT_STATE;
begin
  ZeroMemory(@_controllerState, SizeOf(XINPUT_STATE));
  if XInputGetState(_controllerNum, _controllerState) = ERROR_SUCCESS then
  begin
    if not _connected then
    if Assigned(OnConnected) then (OnConnected(Self));
    _controllerDetected:=True;
    _connected:=True;
    Result:=_controllerState;
  end
  else
  begin
    if _controllerDetected then
    begin
      if Assigned(OnDisconnected) then (OnDisconnected(Self));
      _connected:=False;
      _controllerDetected:=False;
    end;
  end;
end;

procedure TXBoxController.Vibrate(Left: Integer; Right: Integer);
var
  Vibration: XINPUT_VIBRATION;
begin
  ZeroMemory(@Vibration, sizeof(XINPUT_VIBRATION));
  Vibration.wLeftMotorSpeed:= Left;
  Vibration.wRightMotorSpeed:=Right;
  XInputSetState(_controllerNum, Vibration);
end;

{$ENDIF}

end.
