{---------------------------------}
{-------= Simple ZGL =------------}
{---------------------------------}
{                                 }
{ version:  0.1.2                 }
{ date:     2017.07.10            }
{ license:  zlib                  }
{                                 }
{                                 }
{--------- developed by: ---------}
{                                 }
{  Enrique Fuentes aka Turrican   }
{                                 }
{ e-mail: turrican@hotmail.com    }
{ telegram: @turrican             }
{                                 }
{                                 }
{                                 }
{---------------------------------}

{ Simple Multimedia framework for ZenGL}

unit SimpleZGL;

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


interface

uses
{$IFDEF ANDROID}
  {$DEFINE LINUX}
  zgl_application,
  zgl_main,
  zgl_file,
  zgl_screen,
  zgl_window,
  zgl_timers,
  zgl_touch,
  zgl_render_2d,
  zgl_tiles_2d,
  zgl_fx,
  zgl_log,
  zgl_textures,
  zgl_textures_png,
  zgl_textures_jpg,
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
  zgl_mouse,
  zgl_render,
  zgl_joystick,
  zgl_keyboard,
{$ELSE}
  {$IFNDEF LINUX}
  {$DEFINE USE_XINPUT}
  {$ENDIF}
  zglheader,
{$ENDIF}
{$IFDEF FPC}   {Lazarus and Free Pascal}
  contnrs,
{$M+}
{$ENDIF}
{$IFDEF DCC}   {Delphi XE and newer versions}
{$DEFINE DELPHI}
  System.Generics.Collections,
{$ENDIF}
{$IFDEF USE_XINPUT}
  SimpleXinput,
  XInput,
{$ENDIF}
  SysUtils,
  math,
  {$IFDEF UNIX}
  //cthreads, cmem,
  //MTProcs,
  {$ELSE}
  {$IFDEF FPC}
     syncobjs,
  {$ELSE}
     System.SyncObjs,
  {$ENDIF}

  {$ENDIF}
  classes;

type
  TMoveTypes = (Left = $00, Right, Up, Down, None);
  TDirection = (dirUp = 1, dirDown, dirLeft, dirRight);
  TSZEventBeforeDraw = procedure(ASender: TObject) of object;
  TSZEventAfterDraw = procedure(ASender: TObject) of object;
  TSZEventAnimationOnFinished = procedure(ASender: TObject) of object;
  TSZEventAnimationOnProcess = procedure(ASender: TObject) of object;
  TSZEventOnMouseWheel = procedure(ASender: TObject; Direction: TDirection; X, Y : Single)
    of object;
  TSZEventOnLoadError = procedure(ASender: TObject; AException: Exception)
    of object;
  TSZEventMouseCollision = procedure(ASender: TObject; X, Y : Single) of object;
  TSZEventCollision = procedure(ASender: TObject) of object;
  TSZEventOnMouseClick = procedure(ASender: TObject; Button : ShortInt; X, Y : Single) of object;
  TSZEventOnFadeOut = procedure(ASender: TObject) of object;
  TSZEventOnMouseOut = procedure(ASender: TObject) of object;
  TSZEventOnFadeIn = procedure(ASender: TObject) of object;
  TSZEventOnTextureLoaded = procedure(ASender: TObject) of object;
  TSZEventOnMoveAnimation = procedure(ASender: TObject) of object;
  TSZEventOnGesture = procedure(ASender: TObject; Button : ShortInt; Move : zglTPoint2D) of object;
  TSZEventOnJoyDisconnected = procedure(ASender: TObject) of object;
  TSZEventOnJoyConnected = procedure(ASender: TObject) of object;
  TSZEventOnJoyInput = procedure(ASender: TObject) of object;
  TSZEventOnMove = procedure(ASender: TObject) of object;
  TSZEventListBoxOnItemSelected = procedure(ASender: TObject; Item: Integer)
    of object;
  TSZEventListBoxOnItemClicked = procedure(ASender: TObject) of object;
  TSZEventOnErrorLoadTexture = procedure(ASender: TObject) of object;
  TSZEventFinished = procedure(ASender: TObject) of object;
  TSZEventOnProcess = procedure(ASender: TObject) of object;
  TSZEventOnStart = procedure(ASender: TObject) of object;
{$IFDEF USE_XINPUT}
  {$IFNDEF LINUX}
  TXboxInput = TXboxInputState;
  {$ENDIF}
{$ENDIF}
{$IFNDEF ANDROID}
  PByteArray = zglheader.PByteArray;
{$ELSE}
  PByteArray = zgl_types.PByteArray;
{$ENDIF}
  TRectangle = zglTRect;

  TSZSprite = class;

  TSZScene = class;

  TSZSpriteBath = class;

  TMouseLastCoords = record
    LastMouseXLeftButton,
    LastMouseXRightButton,
    LastMouseYLeftButton,
    LastMouseYRightButton : Single;
  end;

  TSZSpriteCollisionThread = class(TThread)
  private
    fspritebatch: TSZSpriteBath;
  public
    visiblealready: Boolean;
    constructor Create(Spritebatch: TSZSpriteBath);
    destructor Destroy;
    procedure Execute; override;
  end;

  TSZEvent = class(TObject)
  private
    _AssignedObject: TObject;
    _ObjectClass: TClass;
    _Name: string;
    _Enabled: Boolean;
    _FireAt: Integer;
    _ElapsedTime: Integer;
    _CurrentTime: Integer;
    _EndAt: Integer;
    _Infinite: Boolean;
    _finished: Boolean;
    _running: Boolean;
    _onfinished: TSZEventFinished;
    _onprocess: TSZEventOnProcess;
    _onstart: TSZEventOnStart;
  public
    constructor Create;
    property Running: Boolean read _running write _running;
    property ElapsedTime: Integer read _ElapsedTime write _ElapsedTime;
    property OnFinished: TSZEventFinished read _onfinished write _onfinished;
    property OnProcess: TSZEventOnProcess read _onprocess write _onprocess;
    property OnStart: TSZEventOnStart read _onstart write _onstart;
    property Finished: Boolean read _finished write _finished;
    property Infinite: Boolean read _Infinite write _Infinite;
    property CurrentTime: Integer read _CurrentTime write _CurrentTime;
    property AssignedObject: TObject read _AssignedObject write _AssignedObject;
    property FireAt: Integer read _FireAt write _FireAt;
    property Name: string read _Name write _Name;
    property EndAt: Integer read _EndAt write _EndAt;
  end;

  TSZAnimation = class(TObject)
  private
    _name : string;
    _loop: Boolean;
    _ElapsedTime: Extended;
    _internaltime: Integer;
    _time: Extended;
    _finished: Boolean;
    _onfinished: TSZEventAnimationOnFinished;
    _onprocess: TSZEventAnimationOnProcess;
  public
    property AnimationTime: Extended read _time write _time;
    property ElapsedTime: Extended read _ElapsedTime;
    property Loop: Boolean read _loop write _loop;
    property Finished: Boolean read _finished;
    property Name : string read _name write _name;
    property OnProcess: TSZEventAnimationOnProcess read _onprocess
      write _onprocess;
    property OnFinished: TSZEventAnimationOnFinished read _onfinished
      write _onfinished;
    procedure ProcessAnimation; virtual; abstract;
    procedure Restart; virtual; abstract;
  end;

{$IFDEF DCC}
  TSZEventList = TObjectList<TSZEvent>;
  TSZAnimationList = TObjectList<TAnimation>;
{$ENDIF}
{$IFDEF FPC}
  TSZEventList = TObjectList;
  TSZAnimationList = TObjectList;
{$ENDIF}

  TSZCustomAnimation = class(TSZAnimation)
  public
    procedure ProcessAnimation; override;
    procedure Restart; override;
  end;

  TSZBlinkAnimation = class(TSZAnimation)
  private
    _fadein: Boolean;
    _fadeout: Boolean;
    _alpha: Integer;
    _speed: Single;
  public
    property Alpha: Integer read _alpha;
    procedure ProcessAnimation; override;
    procedure Restart; override;
    constructor Create(Speed: Single; Loop: Boolean = True; Name : string = '');
  end;

  TSZMoveAnimation = class(TSZAnimation)
  private
    _firstxvalue: Extended;
    _firstyvalue: Extended;
    _relativex : Extended;
    _relativey : Extended;
    _degree : Extended;
    _animx: Extended;
    _animy: Extended;
    _x: Extended;
    _y: Extended;
    _acelerationx: Extended;
    _acelerationy: Extended;
    _average : Boolean;
    _averagesum : Extended;
    _aceleration : Extended;
  public
    constructor Create(CurrentX: Extended; CurrentY: Extended; X: Extended;
      Y: Extended; Time: Extended; Loop: Boolean = False; Average : Boolean = True; Name : string = '');
    procedure ProcessAnimation; override;
    property AnimX: Extended read _animx write _animx;
    property AnimY: Extended read _animy write _animy;
    property AccelerationX: Extended read _acelerationx;
    property AccelerationY: Extended read _acelerationy;
    procedure Reprogram(CurrentX : Extended; CurrentY : Extended; X : Extended; Y : Extended; Time : Integer; Loop : Boolean = False);
    procedure Restart; override;
  end;

  TSZDiagonalAnimation = class(TSZAnimation)
    private
      _firstxvalue : Extended; //C
      _firstyvalue : Extended; //B
      _x : Extended; //D
      _y : Extended; //A
      //Calculate diagonal sqrt(Power((_firstxvalue + _x), 2) + Power(_firstyvalue + _y), 2));
  end;

  TSZCameraAnimation = class(TSZMoveAnimation)
  private
    _camera: zglPCamera2D;
  public
    constructor Create(Camera: zglPCamera2D; X: Extended; Y: Extended;
      Time: Integer; Loop: Boolean = False; Name : string = '');
    procedure ProcessAnimation; override;
    procedure Restart; override;
  end;

  TJoyButton = record
    Pressed: Boolean;
  end;

  PSZJoystickStructure = ^TSZJoystickStructure;

  TSZJoystickStructure = record
    X: Extended;
    Y: Extended;
    buttons: array of TJoyButton;
    Info: zglPJoyInfo;
  end;

  TSZJoystickEventsNoJoy = procedure(Sender: TObject) of object;
  TSZJoystickEventOnInit = procedure(Sender: TObject;
    var ReadValues: TSZJoystickStructure) of object;
  TSZJoystickEventsOnRead = procedure(Sender: TObject) of object;
  TSZJoystickEventsOnValue = procedure(Sender: TObject; JoystickNum: Integer;
    var ReadValues: TSZJoystickStructure) of object;
{$IFDEF USE_XINPUT}
  {$IFNDEF LINUX}
  TSZJoystickEventsXBoxOnValue = procedure(Sender: TObject;
    ReadValues: TXboxInput) of object;
  {$ENDIF}
{$ENDIF}

  TSZJoystick = class(TObject)
  private
{$IFDEF USE_XINPUT}
    {$IFNDEF LINUX}
    XboxController: TXBoxController;
    State: TXboxInputState;
    _OnXBOXValue: TSZJoystickEventsXBoxOnValue;
    {$ENDIF}
{$ENDIF}
    _notified: Boolean;
    _isXboxPad: Boolean;
    _JoyInfo: TSZJoystickStructure;
    _inuse: Boolean;
    _OnValue: TSZJoystickEventsOnValue;
    _AssignedObject: TObject;
    _OnDisconnected: TSZEventOnJoyDisconnected;
    _OnConnected: TSZEventOnJoyConnected;
  public
    constructor Create;
    property AssignedObject: TObject read _AssignedObject write _AssignedObject;
    property Notified: Boolean read _notified;
    property JoyInfo: TSZJoystickStructure read _JoyInfo write _JoyInfo;
    property InUse: Boolean read _inuse write _inuse;
    property IsXBOXPad: Boolean read _isXboxPad;
    property OnValue: TSZJoystickEventsOnValue read _OnValue write _OnValue;
{$IFDEF USE_XINPUT}
    {$IFNDEF LINUX}
    property OnXBOXValue: TSZJoystickEventsXBoxOnValue read _OnXBOXValue
      write _OnXBOXValue;
    {$ENDIF}
{$ENDIF}
    property OnConnected: TSZEventOnJoyConnected read _OnConnected
      write _OnConnected;
    property OnDisconnected: TSZEventOnJoyDisconnected read _OnDisconnected
      write _OnDisconnected;
  end;

  TSZKeyboard = class(TSZJoystick)
  end;

{$IFDEF FPC}
  TSZJoystickList = TObjectList;
{$ELSE}
  TSZJoystickList = TObjectList<TJoystick>;
{$ENDIF}

  TSZJoystickHandler = class(TObject)
  private
    _JoystickCount: Integer;
    _OnRead: TSZJoystickEventsOnRead;
    _OnValue: TSZJoystickEventsOnValue;
    _OnNoJoy: TSZJoystickEventsNoJoy;
    _OnInit: TSZJoystickEventOnInit;
    _Joysticks: TSZJoystickList;
{$IFDEF USE_XINPUT}
    {$IFNDEF LINUX}
    XboxControllersConnected: Integer;
    XboxControllers: array [0 .. 3] of TXBoxController;
    procedure InitXinput;
    procedure OnXboxControllerConnected(Sender: TObject);
    procedure OnXboxControllerDisconnected(Sender: TObject);
    procedure GetXboxControllers;
    function _GetFreeXBOXJoystick: TSZJoystick;
    {$ENDIF}
{$ENDIF}
    function _GetFreeJoystick: TSZJoystick;
  public
    property JoystickCount: Integer read _JoystickCount;
    property OnRead: TSZJoystickEventsOnRead read _OnRead write _OnRead;
    property OnValue: TSZJoystickEventsOnValue read _OnValue write _OnValue;
    property OnNoJoy: TSZJoystickEventsNoJoy read _OnNoJoy write _OnNoJoy;
    property OnInitJoy: TSZJoystickEventOnInit read _OnInit write _OnInit;
    property GetFreeJoystick: TSZJoystick read _GetFreeJoystick;
{$IFDEF USE_XINPUT}
   {$IFNDEF LINUX}
    property GetFreeXBOXJoystick: TSZJoystick read _GetFreeXBOXJoystick;
    {$ENDIF}
{$ENDIF}
    property GetJoysticks: TSZJoystickList read _Joysticks;
    procedure Reset;
    procedure Poll;
    procedure Init;
    constructor Create;
  end;

  TSZKeyboardHandler = class(TObject)
  private
    _OnRead: TSZJoystickEventsOnRead;
    _OnValue: TSZJoystickEventsOnValue;
    _OnInit: TSZJoystickEventOnInit;
    _Keyboard: TSZKeyboard;
  public
    property GetKeyboard: TSZKeyboard read _Keyboard;
    property OnRead: TSZJoystickEventsOnRead read _OnRead write _OnRead;
    property OnValue: TSZJoystickEventsOnValue read _OnValue write _OnValue;
    property OnInitJoy: TSZJoystickEventOnInit read _OnInit write _OnInit;
    procedure Reset;
    procedure Poll;
    procedure Init;
    constructor Create;
  end;

  TSZSprite = class(TObject)
  private
{$IFNDEF FPC}
    procedure _settexturedata(Value: PByteArray);
    function _gettexturedata: PByteArray;
{$ELSE}
    procedure _settexturedata(Value: PByteArray);
    function _gettexturedata: PByteArray;
{$ENDIF}
  protected
    _camera_rect : zglTRect;
    _spritebatch : TSZSpriteBath;
    _textureframeh: Integer;
    _textureframew: Integer;
    _frames: Integer;
    _frame: Single;
    _time: Integer;
    _ElapsedTime: Integer;
    _rectangle: zglPRect;
    _fade_amount: Integer;
    _events: TSZEventList;
    texture: zglPTexture;
    _Keyboard: TSZKeyboard;
    _joystick: TSZJoystick;
    _joycontrol: Boolean;
    _noneedtexture : Boolean;
    _Name: string;
    _camera_mouse_X, _camera_mouse_Y : Single;
    _texture_string_stream: string;
    _camera: zglPCamera2D;
    _mouseOn: Boolean;
    _textureFilename: string;
    _textureloaded: Boolean;
    _alpha: Integer;
    _rotate: Boolean;
    _busy: Boolean;
    _blinking: Boolean;
    _iscollideable: Boolean;
    _angle: Single;
    _id: string;
    _fadein: Boolean;
    _fadeout: Boolean;
    _active: Boolean;
    _flip: Boolean;
    _Num: Integer;
    _notTexture: Boolean;
    _Selected: Boolean;
    _visible: Boolean;
    _textureowner : Boolean;
    _delete : Boolean;
    _fonjoyinput: TSZJoystickEventsOnValue;
{$IFDEF USE_XINPUT}
    {$IFNDEF LINUX}
    _fonxboxinput: TSZJoystickEventsXBoxOnValue;
    {$ENDIF}
{$ENDIF}
    function GetGesture(var LastCoordX, LastCoordY : Single) : zglTPoint2D;
    function _isvisible(CameraRect: zglTRect): Boolean;
    procedure Loadtexture; virtual; abstract;
    procedure ProcessAnimation; virtual; abstract;
    procedure ProcessOpacity;
    procedure CollideWith(Sprite: TSZSprite);
    procedure CollideWithRectangle(Rectangle: zglPRect);
    procedure AssignInput(onValues: TSZJoystickEventsOnValue);
{$IFDEF USE_XINPUT}
    {$IFNDEF LINUX}
    procedure AssignInputXbox(onValues: TSZJoystickEventsXBoxOnValue);
    {$ENDIF}
{$ENDIF}
    function MouseCollide: Boolean;
  public
    OnErrorLoadingTexture: TSZEventOnErrorLoadTexture;
    OnGesture: TSZEventOnGesture;
    OnCollision: TSZEventCollision;
    OnMove: TSZEventOnMove;
    OnMouseCollision: TSZEventMouseCollision;
    OnMouseClick: TSZEventOnMouseClick;
    OnMoveAnimation: TSZEventOnMoveAnimation;
    OnLoadError: TSZEventOnLoadError;
    OnFadeIn: TSZEventOnFadeIn;
    OnFadeOut: TSZEventOnFadeOut;
    OnMouseOut: TSZEventOnMouseOut;
    OnMouseWheel: TSZEventOnMouseWheel;
    OnTextureLoaded: TSZEventOnTextureLoaded;
    OnBeforeDraw: TSZEventBeforeDraw;
    OnAfterDraw: TSZEventAfterDraw;
    property Events: TSZEventList read _events write _events;
    property GetTexture: zglPTexture read texture;
    property OnJoyInput: TSZJoystickEventsOnValue read _fonjoyinput
      write AssignInput;
{$IFDEF USE_XINPUT}
    {$IFNDEF LINUX}
    property OnXboxInput: TSZJoystickEventsXBoxOnValue read _fonxboxinput
      write AssignInputXbox;
    {$ENDIF}
{$ENDIF}
{$IFDEF DCC}
    property TextureData: PByteArray read _gettexturedata write _settexturedata;
{$ELSE}
    property TextureData: PByteArray read _gettexturedata write _settexturedata;
{$ENDIF}
    property TextureOwner : Boolean read _textureowner write _textureowner;
    property Alpha : Integer read _alpha write _alpha;
    property Frame: Single read _frame write _frame;
    property Name: string read _Name write _Name;
    property Num: Integer read _Num write _Num;
    property FadeAmount: Integer read _fade_amount write _fade_amount;
    property isCollideable: Boolean read _iscollideable write _iscollideable;
    property GetElapsedTime: Integer read _ElapsedTime;
    property Selected: Boolean read _Selected write _Selected;
    property Active: Boolean read _active write _active;
    property GetCamera: zglPCamera2D read _camera;
    property GetJoystick: TSZJoystick read _joystick;
    property Rect: zglPRect read _rectangle write _rectangle;
    property Visible: Boolean read _visible write _visible;
    property Flip: Boolean read _flip write _flip;
    constructor Create(ImagePath: string; Name: string = ''); overload; virtual;
    constructor Create(_texture: zglPTexture; Name: string = '');
      overload; virtual;
    procedure SetCoordinates(X, Y : Single);
    procedure AddEvent(Event: TSZEvent);
    procedure ProcessEvents;
    procedure Delete;
    procedure ChangeTexture(texture: zglPTexture); overload; virtual;
    procedure ChangeTexture(ImagePath: string); overload; virtual;
    procedure ProcessTimer;
    procedure JoyControl;
    procedure NoJoyControl;
    procedure Rotate;
    procedure StopRotate;
    procedure UnBlink;
    procedure Blink;
    procedure MouseClick;
    procedure MouseEvents;
    procedure ResizeTextureFrame(Height, Width: Integer);
    procedure Draw; virtual; abstract;
    procedure FadeOut; overload;
    procedure FadeOut(Amount: Integer); overload;
    procedure FadeIn; overload;
    procedure FadeIn(Amount: Integer); overload;
    procedure Input; virtual; abstract;
    procedure Process; virtual; abstract;
    procedure AssignJoystick(Joystick: TSZJoystick);
    procedure AssignKeyboard(Keyboard: TSZKeyboard);
    procedure UnassignKeyboard;
    procedure UnassignJoystick;
  published
    procedure TextureResize(H, W: Integer);
  end;

{$IFDEF FPC}
  TSpriteList = TObjectList;
{$ENDIF}
  TSZSpriteBath = class(TObject)
  protected
    _time: Integer;
    _camera: zglTCamera2D;
    _myupdatethread: TSZSpriteCollisionThread;
{$IFDEF DCC}
    spritelist: TObjectList<TSZSprite>;
{$ENDIF}
{$IFDEF FPC}
    spritelist: TObjectList;
{$ENDIF}
    _ElapsedTime: Integer;
    _joycontrol: Boolean;
    _fadeout: Boolean;
    _fadein: Boolean;
    _ismoving: Boolean;
    _moveanimation: TSZMoveAnimation;
    _resx: Integer;
    _resy: Integer;
    _camera_mouse_X: Single;
    _camera_mouse_Y: Single;
    _Name: string;
    _running: Boolean;
    _rectangle: zglTRect;
    _dt: Double;
    _collideable : Boolean;
    _events: TSZEventList;
    procedure _processAnimation;
    function _GetCamera: zglPCamera2D;
    function MouseCollide: Boolean;
    function GetGesture(var LastCoordX, LastCoordY : Single) : zglTPoint2D;
    // procedure OnSpriteAdd(ASender: TObject; const Item: TSZSprite; Action: TCollectionNotification);
  public
    OnBeforeDraw: TSZEventBeforeDraw;
    OnGesture: TSZEventOnGesture;
    OnMouseWheel: TSZEventOnMouseWheel;
    OnMouseCollision: TSZEventMouseCollision;
    OnMouseClick: TSZEventOnMouseClick;
    OnFadeOut: TSZEventOnFadeOut;
    OnFadeIn: TSZEventOnFadeIn;
    OnAfterDraw: TSZEventAfterDraw;
    OnMoveAnimation: TSZEventOnMoveAnimation;
    OnStart : TSZEventOnStart;
    ShowBorders: Boolean;
    property Collideable : Boolean read _collideable write _collideable;
    property Events: TSZEventList read _events write _events;
    property GetElapsedTime: Integer read _ElapsedTime;
    property GetCameraMouseX: Single read _camera_mouse_X;
    property GetCameraMouseY: Single read _camera_mouse_Y;
    property Rectangle: zglTRect read _rectangle write _rectangle;
    property GetCamera: zglPCamera2D read _GetCamera;
    property GetResX: Integer read _resx;
    property GetResY: Integer read _resy;
    property Name: string read _Name write _Name;
    {$IFDEF DCC}
        property Sprites : TObjectList<TSZSprite> read spritelist write spritelist;
    {$ENDIF}
    {$IFDEF FPC}
        property Sprites : TObjectList read spritelist write spritelist;
    {$ENDIF}
    constructor Create(Rect: zglTRect; Name: string = '');
    destructor Destroy; override;
    function Getsprite(Name: string): TSZSprite;
    function GetLastSprite: TSZSprite;
    procedure AddEvent(Event: TSZEvent);
    procedure ProcessEvents;
    procedure ProcessTimer;
    procedure JoyControl;
    procedure NoJoyControl;
    procedure FadeOut;
    procedure FadeIn;
    procedure SetRes(Width, Height: Integer);
    function Add(Sprite: TSZSprite): TSZSprite;
    procedure Move(Animation: TSZMoveAnimation);
    procedure Clean;
    procedure Draw;
    procedure Update(dt: Double);
    procedure Input;
    procedure Start;
    procedure Resume;
    procedure Stop;
  end;

{$IFDEF FPC}
  TSpriteBatchList = TObjectList;
{$ENDIF}

  TSZScene = class(TObject)
  protected
    _showfps: Boolean;
    _font: zglPFont;
    _time: Integer;
    _elapsedtimeMS: Extended;
    _camera: zglTCamera2D;
    _Name: string;
    _visible: Boolean;
    _ElapsedTime: Integer;
    _h: Integer;
    _w: Integer;
    _y: Integer;
    _x: Integer;
    _textureloaded: Boolean;
    _alpha: Integer;
    _backgroundtexturename: string;
    _handleKeyboard: Boolean;
    _keyboardHandler: TSZKeyboardHandler;
    _joystickHandler: TSZJoystickHandler;
    _hasjoysticks: Boolean;
    _hasbackground: Boolean;
    _scrolling: Boolean;
    _scrollingUp: Boolean;
    _scrollingDown: Boolean;
    _loop: Boolean;
    _showtimer: Boolean;
    _background: zglPTexture;
    _events: TSZEventList;
{$IFDEF DCC}
    _spritebatchList: TObjectList<TSZSpriteBath>;
{$ENDIF}
{$IFDEF FPC}
    _spritebatchList: TSpriteBatchList;
{$ENDIF}
    function _GetCamera: zglPRect;
    function Getcoords: zglTRect;
    procedure ProcessEvents;
  public
    constructor Create(X, Y: Integer; H, W: Integer; font: zglPFont;
      BackgroundImage: string = ''; Name: string = '');
    function Add(Spritebatch: TSZSpriteBath): TSZSpriteBath;
    function GetSpriteBatch(Name: string): TSZSpriteBath;
    property Events: TSZEventList read _events write _events;
    property ShowTimer: Boolean read _showtimer write _showtimer;
    property ShowFPS: Boolean read _showfps write _showfps;
    property GetElapsedTimeMS: Extended read _elapsedtimeMS;
    property GetElapsedTime: Integer read _ElapsedTime;
    property GetRect: zglTRect read Getcoords;
    property GetCamera: zglPRect read _GetCamera;
    property GetJoystickHandler: TSZJoystickHandler read _joystickHandler
      write _joystickHandler;
    property GetKeyboardHandler: TSZKeyboardHandler read _keyboardHandler
      write _keyboardHandler;
    property HandleKeyboard: Boolean read _handleKeyboard write _handleKeyboard;
    function AddEvent(Event: TSZEvent): TSZEvent;
    procedure ResetTimer;
    procedure ProcessTimer;
    procedure Clean(Spritebatch: TSZSpriteBath); overload;
    procedure Loadtexture;
    procedure InitJoysticks;
    procedure Clean; overload;
    procedure Draw;
    procedure Update(dt: Double);
    procedure Input;
    procedure Start;
    procedure Resume;
    procedure Stop;
  end;

  TSZTile = class(TSZSprite)
  protected
    _textures: array of zglPTexture;
    _Tileid: string;
    _TextRec: zglTRect;
    _tilename: string;
    _spritebatch: TSZSpriteBath;
    _font: zglPFont;
    _LogoTexture: zglPTexture;
    function _readytodraw: Boolean;
    function _isinthescreen: Boolean;
    procedure ProcessAnimation; override;
  public
    // procedure AddTexture;
    // procedure ChangeTexture(idx : Integer);
    procedure Draw; override;
    destructor Destroy; override;
    property Name: string read _tilename write _tilename;
    property IsInTheScreen: Boolean read _isinthescreen;
    property ReadyToDraw: Boolean read _readytodraw;
    property GetTexture: zglPTexture read texture;
    constructor Create(texture: zglPTexture; font: zglPFont;
      Spritebatch: TSZSpriteBath; X, Y, W, H: Integer; Name: string = '';
      LoadTextureNow: Boolean = False); overload;
    constructor Create(ImagePath: string; font: zglPFont;
      Spritebatch: TSZSpriteBath; X, Y, W, H: Integer; Name: string = '';
      LoadTextureNow: Boolean = False); overload;
    constructor Create(ImagePath: string; Spritebatch: TSZSpriteBath;
      Rectangle: zglTRect; Name: string = '';
      LoadTextureNow: Boolean = False); overload;
    procedure Input; override;
    procedure Process; override;
    procedure Loadtexture; override;
  end;

  TSZText = class(TSZSprite)
  type
  private
    _scale: Single;
    _width: Extended;
    _height: Integer;
    _scrolling: Boolean;
    texture: zglPFont;
    _text: string;
    _spritebatch: TSZSpriteBath;
    _lines: Integer;
    _lines_w: Integer;
    _lines_h: Integer;
    procedure _setText(text: string);
    procedure ProcessAnimation; override;
  public
    property Scale: Single read _scale write _scale;
    property text: string read _text write _setText;
    constructor Create(fontPath: string; Spritebatch: TSZSpriteBath;
      X, Y: Integer; Name: string = ''); overload; virtual;
    constructor Create(font: zglPFont; Spritebatch: TSZSpriteBath;
      X, Y: Integer; Name: string = ''); overload; virtual;
    procedure Process; override;
    procedure Draw; override;
    procedure Input; override;
    procedure Loadtexture; override;
    procedure Scroll;
  end;

  TSZAnimated = class(TSZSprite)
  protected
    _spritebatch: TSZSpriteBath;
    _isinthescreen: Boolean;
    _Animations: TSZAnimationList;
    procedure ProcessAnimation;
  public
    constructor Create(ImagePath: string; Spritebatch: TSZSpriteBath;
      X, Y, W, H: Integer; FrameH, FrameW: Integer; Name: string = '';
      LoadTextureNow: Boolean = False); overload; virtual;
    constructor Create(_texture: zglPTexture; Spritebatch: TSZSpriteBath;
      X, Y, W, H: Integer; FrameH, FrameW: Integer; Name: string = ''); overload; virtual;
    destructor Destroy; override;
    procedure Loadtexture; override;
    property IsInTheScreen: Boolean read _isinthescreen;
    procedure DeleteAnimations;
    procedure RemoveAnimation(Animation: TSZAnimation);
    procedure AssignAnimation(Animation: TSZAnimation);
    function GeTSZAnimation(Name : string) : TSZAnimation;
    function GeTSZAnimations : TSZAnimationList;
  end;

  TSZAnimatedSprite = class(TSZAnimated)
  protected
    procedure Input; override;
    procedure Process; override;
    procedure Draw; override;
  end;

  TSZAnimatedBackground = class(TSZAnimated)
  private
    _spritebatch: TSZSpriteBath;
    _rectangle2: zglTRect;
    _unlimited: Boolean;
    _cameraback: zglPCamera2D;
  public
    constructor Create(ImagePath: string; Spritebatch: TSZSpriteBath;
    X, Y, W, H: Integer; FrameH, FrameW: Integer;
    Name: string = ''; LoadTextureNow: Boolean = False; unlimited: Boolean = True);
     property GetCamera: zglPCamera2D read _cameraback;
    procedure Draw; override;
    procedure Input; override;
    procedure Process; override;
  end;

  TSZSimpleColorBackground = class(TSZAnimated)
  private
    _spritebatch : TSZSpriteBath;
    _rectangle2 : zglTRect;
    _unlimited : Boolean;
    _cameraback : zglPCamera2D;
    _color : Integer;
  public
    constructor Create(Color : Cardinal; Spritebatch: TSZSpriteBath; X, Y, W, H: Integer; Name: string = ''; unlimited: Boolean = True);
     property GetCamera: zglPCamera2D read _cameraback;
    procedure Draw; override;
    procedure Input; override;
    procedure Process; override;
  end;

  TSZTextBox = class(TSZAnimatedSprite)
  type
  private
    _scroll_input_sensibility: Integer;
    _current_input_count: Integer;
    _scrollerindex: Integer;
    _scale: Integer;
    _width: Integer;
    _height: Integer;
    _scrolling: Boolean;
    texture: zglPFont;
    _alpha: Integer;
    _text: string;
    _numlines: Integer;
    _textheight: Integer;
    _spritebatch: TSZSpriteBath;
    _textboxcam: zglTCamera2D;
    _scroller_height: Single;
    _stringlist: TStringList;
    _lineheight: Single;
    _currentline: Integer;
    _visiblelines: Integer;
    _scroller_pos: Single;
    _selectedblinks: Boolean;
    _blinkspeed: Single;
    _itemcount: Integer;
    _firstitemalpha: Integer;
    _backtile : TSZTile;
    FOnItemClicked: TSZEventListBoxOnItemClicked;
    FOnItemSelected: TSZEventListBoxOnItemSelected;
    BlinkAnimation: TSZBlinkAnimation;
    procedure BlinkAnimationProc(Sender: TObject);
    procedure _setText(text: string);
    function _GetCamera: zglPCamera2D;
    procedure _OnScroll(ASender: TObject; aDirection: TDirection; X, Y : Single);
    procedure SetOnItemClicked(const Value: TSZEventListBoxOnItemClicked);
    procedure SetOnItemSelected(const Value: TSZEventListBoxOnItemSelected);
  public
    property OnItemSelected: TSZEventListBoxOnItemSelected read FOnItemSelected
      write SetOnItemSelected;
    property OnItemClicked: TSZEventListBoxOnItemClicked read FOnItemClicked
      write SetOnItemClicked;
    property Scroll_Input_Sensibility: Integer read _scroll_input_sensibility
      write _scroll_input_sensibility;
    property ItemCount: Integer read _numlines write _numlines;
    property TextHeight: Integer read _textheight;
    property ScrollIndex: Integer read _scrollerindex;
    property ScrollPos: Single read _scroller_pos;
    property BlinkSpeed: Single read _blinkspeed write _blinkspeed;
    property SelectedBlinks: Boolean read _selectedblinks write _selectedblinks;
    property AddLine: string write _setText;
    property GetLines : TStringList read _stringlist;
    property GetCamera: zglPCamera2D read _GetCamera;
    property GetBackGround : TSZTile read _backtile;
    constructor Create(fontPath: string; Spritebatch: TSZSpriteBath;
      X, Y, W, H: Integer; Name: string = ''; imgbackground : string = ''); overload;
    constructor Create(font: zglPFont; Spritebatch: TSZSpriteBath;
      X, Y, W, H: Integer; Name: string = ''; imgbackground : string = ''); overload;
    procedure Process; override;
    procedure Draw; override;
    procedure Input; override;
    procedure Loadtexture; override;
    procedure Scroll(Direction: TDirection);
  end;

  TSZSpriteFontChar = record
    ch: Char;
    X: Integer;
    Y: Integer;
    W: Integer;
    H: Integer;
  end;

  TSZAlphabet = set of 'A' .. 'z';

  TSZSpriteFontFile = record
    CharCount: Integer;
    Chars: TSZAlphabet;
  end;

  TSZSpriteFont = class(TSZAnimatedSprite)
  private
    fspritefont: TSZSpriteFontFile;
    procedure LoadFont(Path: string);
  public
    constructor Create(fontPath: string; texturePath: string;
      Spritebatch: TSZSpriteBath; Name: string = ''); overload;
    constructor Create(fontPath: string; texture: zglPTexture;
      Spritebatch: TSZSpriteBath; Name: string = ''); overload;
    procedure Process; override;
    procedure Draw; override;
    procedure Input; override;
    procedure Loadtexture; override;
  end;

  TSZPrimitive = class(TSZAnimatedSprite)
    private
      _bordercolor : Cardinal;
      _color : Cardinal;
      _filled: Boolean;
      procedure _fillcolor(Color : Cardinal);
    public
      property FillColor : Cardinal read _color write _fillcolor;
      property Filled : Boolean read _filled write _filled;
      constructor Create(Spritebatch : TSZSpriteBath; Name : string); overload;
      constructor Create(Spritebatch: TSZSpriteBath; X, Y, W, H: Integer; Name: string = ''); overload;
      destructor Destroy; override;
      procedure Process; override;
      procedure Input; override;
  end;

  TSZTextureType = (NoColision = 0, Solido, Lenta, Rapida, Mortal);

  TCoords = record
    x: Extended;
    y: Extended;
  end;

  TSZMap = class(TSZAnimatedSprite)
    private
      map: zglTTiles2D;
      mapTexture: zglTTiles2D;
      sprites: zglTTiles2D;
      TileW: Integer;
      TileH: Integer;
      bitmapCount: Integer;
      texTiles: zglPTexture;
      texBitmap: zglTMemory;
      ConfigOK: Boolean;
      HeroCoords: TCoords;
      MonstersCoords: array of TCoords;
      Coins: array of TCoords;
      TipoTextura: array of TSZTextureType;
      procedure LoadFromFile(const Path : UTF8String);
      procedure SaveToFile(const Path : UTF8String);
    public
      constructor Create(Spritebatch : TSZSpriteBath; MapPath : UTF8String);
      procedure Draw; override;
      //procedure Update; override;
  end;

  TSZSquare = class(TSZPrimitive)
    protected
      procedure Draw; override;
  end;

  TSZLIne = class(TSZPrimitive)
    protected
      procedure Draw; override;
  end;

  TBmChar = record
    w,h : byte;
    relx,rely : shortint;
    shift : shortint;
    d : pointer;
  end;

  TRGB = record
    r,g,b : byte;
  end;  {TRGB}

  {$IFNDEF FPC}

  TBMFFont = class(TObject)
    private
      infostring : AnsiString;
      lineheight,zoom : byte;
      charcount : ShortInt;
      sizeover,sizeunder,addspace,sizeinner : shortint;
      x,y : integer;
      usedcolors,highestcolor : byte;
      rgb : array[Byte] of TRGB;
      tablo : array[AnsiChar] of TBmChar;
    public
      function rgbvalue(i:byte):longint;
      function LoadBMF(path : UTF8String) : Boolean;
      function GenerateTexture : zglPTexture;
  end;
  {$ENDIF}

const
  BMFHEADER = #$E1#$E6#$D5#$1A;

var
  MouseLastCoords : TMouseLastCoords;

implementation

constructor TSZSpriteCollisionThread.Create(Spritebatch: TSZSpriteBath);
begin
  FreeOnTerminate := True;
  inherited Create(True);
  fspritebatch := Spritebatch;
end;

procedure TSZSpriteCollisionThread.Execute;
var
  Sprite: TSZSprite;
  sprite2: TSZSprite;
begin
  while not Terminated do
  begin
    if Assigned(fspritebatch) and Assigned(fspritebatch.spritelist) then
    begin
      for Sprite in fspritebatch.spritelist do
      begin
        if Assigned(Sprite) and Sprite.Visible and Sprite._iscollideable then
        begin
          for sprite2 in fspritebatch.spritelist do
          begin
            if (Assigned(sprite2)) and (sprite2.isCollideable) and (sprite2 <> Sprite) then
            begin
              Sprite.CollideWith(sprite2);
            end;
          end;
        end;
      end;
    end;
    Sleep(16);
  end;
end;

destructor TSZSpriteCollisionThread.Destroy;
begin
  inherited Destroy;
  fspritebatch := nil;
end;

constructor TSZMoveAnimation.Create(CurrentX: Extended; CurrentY: Extended;
  X: Extended; Y: Extended; Time: Extended; Loop: Boolean = False; Average : Boolean = True; Name : string = '');
begin
  _name := Name;
  _loop := Loop;
  _firstxvalue := CurrentX;
  _firstyvalue := CurrentY;
  _x := X;
  _y := Y;
  _time := Time;
  _ElapsedTime := 0;
  _internaltime := 0;
  _animx := _firstxvalue;
  _animy := _firstyvalue;
  _average := False;
  _acelerationx := (_x - _firstxvalue) / Time;
  _acelerationx := ((_acelerationx * 16) / 1000);
  _acelerationy := (_y - _firstyvalue) / Time;
  _acelerationy := ((_acelerationy * 16) / 1000);
//  if _average then
//  begin
//    _averagesum := (_acelerationx + _acelerationy) / 2;
//  end;
end;

procedure TSZMoveAnimation.ProcessAnimation;
begin
  Inc(_internaltime);
  _ElapsedTime := (_internaltime * 16) / 1000;
  if _ElapsedTime >= _time then
  begin
    if not _loop then
    begin
      _finished := True;
      if Assigned(OnFinished) then
        OnFinished(Self);
    end
    else
    begin
      _animx := _firstxvalue;
      _animy := _firstyvalue;
      _ElapsedTime := 0;
      _internaltime := 0;
      if Assigned(OnFinished) then
        OnFinished(Self);
    end;
  end
  else
  begin
    if _animx <> _x then
    begin
      if _average then
      begin
        if _x < _animx then _animx := _animx + _averagesum
        else if _x > _animx then _animx := _animx - _averagesum
      end
      else
      begin
        if _x < _animx then _animx := _animx + _acelerationx
        else if _x > _animx then _animx := _animx + _acelerationx
      end;
    end;
    if _animy <> _y then
    begin
      if _average then
      begin
        if _y < _animy then _animy := _animy + _averagesum
        else if _y > _animy then _animy := _animy + _averagesum
      end
      else
      begin
        if _y < _animy then _animy := _animy + _acelerationy
        else if _y > _animy then _animy := _animy + _acelerationy
      end;
    end;
    if Assigned(_onprocess) then
      _onprocess(Self);
  end;
end;

procedure TSZMoveAnimation.Reprogram(CurrentX, CurrentY, X, Y: Extended; Time: Integer; Loop: Boolean);
begin
  _loop := Loop;
  _firstxvalue := CurrentX;
  _firstyvalue := CurrentY;
  _x := X;
  _y := Y;
  _time := Time;
  _ElapsedTime := 0;
  _internaltime := 0;
  _animx := _firstxvalue;
  _animy := _firstyvalue;
  _acelerationx := (_x - _firstxvalue) / Time;
  _acelerationx := ((_acelerationx * 16) / 1000);
  _acelerationy := (_y - _firstxvalue) / Time;
  _acelerationy := ((_acelerationy * 16) / 1000);
end;

procedure TSZMoveAnimation.Restart;
begin
  _animx := _firstxvalue;
  _animy := _firstyvalue;
  _ElapsedTime := 0;
  _internaltime := 0;
  _finished := false;
end;

constructor TSZCameraAnimation.Create(Camera: zglPCamera2D; X: Extended; Y: Extended;
  Time: Integer; Loop: Boolean = False; Name : string = '');
begin
  inherited Create(Camera.X, Camera.Y, X, Y, Time, Loop, True, Name);
  OnProcess := nil;
  _camera := Camera;
end;

procedure TSZCameraAnimation.ProcessAnimation;
begin
  Inc(_internaltime);
  _ElapsedTime := (_internaltime * 16) / 1000;
  if _ElapsedTime >= _time then
  begin
    if not _loop then
    begin
      _finished := True;
      if Assigned(OnFinished) then
        OnFinished(Self);
    end
    else
    begin
      _animx := _firstxvalue;
      _animy := _firstyvalue;
      _ElapsedTime := 0;
      _internaltime := 0;
    end;
  end
  else
  begin
    if _animx <> _x then
    begin
      _animx := _animx + _acelerationx;
      _camera.X := _animx;
    end;
    if _animy <> _y then
    begin
      _animy := _animy + _acelerationy;
      _camera.Y := _animy;
    end;
    if Assigned(_onprocess) then
      _onprocess(Self);
  end;
end;

procedure TSZCameraAnimation.Restart;
begin
  _animx := _firstxvalue;
  _animy := _firstyvalue;
  _ElapsedTime := 0;
  _internaltime := 0;
  _finished := false;
end;

constructor TSZJoystick.Create;
begin
  _inuse := False;
end;

constructor TSZKeyboardHandler.Create;
begin
  Init;
end;

procedure TSZKeyboardHandler.Reset;
begin
  Init;
end;

procedure TSZKeyboardHandler.Init;
var
  X: Integer;
  keybinfo: zglPJoyInfo;
begin
  if Assigned(_Keyboard) then
    _Keyboard.Free
  else
    _Keyboard := TSZKeyboard.Create;
  begin
    new(keybinfo);
    keybinfo.Name := 'Keyboard';
    keybinfo.Count.Axes := 1;
    keybinfo.Count.buttons := 8;
    _Keyboard._JoyInfo.Info := keybinfo;
    SetLength(_Keyboard._JoyInfo.buttons,
      _Keyboard._JoyInfo.Info.Count.buttons);
    if Assigned(_OnInit) then
      _OnInit(Self, _Keyboard._JoyInfo);
  end;
end;

procedure TSZKeyboardHandler.Poll;
var
  i, X: Integer;
begin
  if key_Press(K_DOWN) then
    _Keyboard._JoyInfo.Y := 1
  else if key_Press(K_UP) then
    _Keyboard._JoyInfo.Y := -1
  else
    _Keyboard._JoyInfo.Y := 0;
  if key_Press(K_LEFT) then
    _Keyboard._JoyInfo.X := -1
  else if key_Press(K_RIGHT) then
    _Keyboard._JoyInfo.X := 1
  else
    _Keyboard._JoyInfo.X := 0;
  _Keyboard._JoyInfo.buttons[0].Pressed := key_Press(K_Z);
  _Keyboard._JoyInfo.buttons[1].Pressed := key_Press(K_X);
  _Keyboard._JoyInfo.buttons[2].Pressed := key_Press(K_C);
  _Keyboard._JoyInfo.buttons[4].Pressed := key_Press(K_ENTER);
  _Keyboard._JoyInfo.buttons[5].Pressed := key_Press(K_SPACE);
  _Keyboard._JoyInfo.buttons[6].Pressed := key_Press(K_ESCAPE);
  _Keyboard._JoyInfo.buttons[7].Pressed := key_Press(K_SHIFT);
  if Assigned(_Keyboard.OnValue) then
    _Keyboard.OnValue(_Keyboard.AssignedObject, i, _Keyboard._JoyInfo);
  key_ClearState;
end;

constructor TSZJoystickHandler.Create;
begin
  _JoystickCount := joy_Init;
  Init;
end;

procedure TSZJoystickHandler.Reset;
begin
  _JoystickCount := joy_Init;
  Init;
end;

procedure TSZJoystickHandler.Init;
var
  X: Integer;
begin
  if Assigned(_Joysticks) then
    _Joysticks.Free
  else
    _Joysticks := TSZJoystickList.Create(True);
  if _JoystickCount < 1 then
  begin
    if Assigned(_OnNoJoy) then
      _OnNoJoy(Self);
  end
  else
  begin
    for X := 0 to JoystickCount - 1 do
    begin
      _Joysticks.Add(TSZJoystick.Create);
{$IFDEF DCC}
      _Joysticks.Last._JoyInfo.Info := joy_GetInfo(X);
      SetLength(_Joysticks.Last._JoyInfo.buttons,
        _Joysticks.Last._JoyInfo.Info.Count.buttons);
      if Assigned(_OnInit) then
        _OnInit(Self, _Joysticks.Last._JoyInfo);
{$ELSE}
      TSZJoystick(_Joysticks.Last)._JoyInfo.Info := joy_GetInfo(X);
      SetLength(TSZJoystick(_Joysticks.Last)._JoyInfo.buttons,
        TSZJoystick(_Joysticks.Last)._JoyInfo.Info.Count.buttons);
      if Assigned(_OnInit) then
        _OnInit(Self, TSZJoystick(_Joysticks.Last)._JoyInfo);
{$ENDIF}
    end;
  end;
{$IFDEF USE_XINPUT}
  {$IFNDEF LINUX}
  InitXinput;
  {$ENDIF}
{$ENDIF}
end;

{$IFDEF USE_XINPUT}
{$IFNDEF LINUX}
procedure TSZJoystickHandler.InitXinput;
var
  joy: TSZJoystick;
  X: Integer;
begin
  for joy in _Joysticks do
  begin
    if joy._isXboxPad then
    begin
      if Assigned(joy.XboxController) then
        joy.XboxController.Free;
      joy.Free;
    end;
  end;
  for X := 0 to 3 do
  begin
    _Joysticks.Add(TSZJoystick.Create);
    TSZJoystick(_Joysticks.Last)._isXboxPad := True;
    TSZJoystick(_Joysticks.Last).InUse := False;
    TSZJoystick(_Joysticks.Last).XboxController := TXBoxController.Create(X);
    TSZJoystick(_Joysticks.Last).XboxController.OnConnected := OnXboxControllerConnected;
    TSZJoystick(_Joysticks.Last).XboxController.OnDisconnected :=
      OnXboxControllerDisconnected;
    TSZJoystick(_Joysticks.Last).XboxController.GetState;
  end;
end;

procedure TSZJoystickHandler.OnXboxControllerConnected(Sender: TObject);
var
  joy: TSZJoystick;
begin
  for joy in _Joysticks do
  begin
    if Assigned(joy.XboxController) then
      if TXBoxController(Sender) = joy.XboxController then
        if Assigned(joy.OnConnected) then
          joy.OnConnected(joy);
  end;
end;

procedure TSZJoystickHandler.OnXboxControllerDisconnected(Sender: TObject);
var
  joy: TSZJoystick;
begin
  for joy in _Joysticks do
  begin
    if Assigned(joy.XboxController) then
      if TXBoxController(Sender) = joy.XboxController then
      begin
        if Assigned(joy.OnDisconnected) then
          joy.OnDisconnected(joy);
        _Joysticks.Remove(joy);
      end;
  end;
end;

procedure TSZJoystickHandler.GetXboxControllers;
var
  joy: TSZJoystick;
  State: TXboxInputState;
begin
  for joy in _Joysticks do
  begin
    if joy._isXboxPad then
    begin
      State := joy.XboxController.GetState;
      if joy.XboxController.IsConnected then
      begin
        if ((State.Gamepad.sThumbLX < TXBoxController.INPUT_DEADZONE) and
          (State.Gamepad.sThumbLX > (-TXBoxController.INPUT_DEADZONE))) then
          State.Gamepad.sThumbLX := 0;
        if ((State.Gamepad.sThumbLY < TXBoxController.INPUT_DEADZONE) and
          (State.Gamepad.sThumbLY > (-TXBoxController.INPUT_DEADZONE))) then
          State.Gamepad.sThumbLY := 0;
        if Assigned(joy.OnXBOXValue) then
          joy.OnXBOXValue(joy._AssignedObject, State);
      end;
    end;
  end;
end;

function TSZJoystickHandler._GetFreeXBOXJoystick;
var
  joy: TSZJoystick;
begin
  Result := nil;
  for joy in _Joysticks do
  begin
    if not joy._inuse and joy._isXboxPad then
    begin
      Result := joy;
      Exit;
    end;
  end;
end;
     {$ENDIF}
{$ENDIF}

procedure TSZJoystickHandler.Poll;
var
  i, X: Integer;
begin
  for i := 0 to _JoystickCount - 1 do
  begin
{$IFDEF DCC}
    _Joysticks[i]._JoyInfo.X := joy_AxisPos(i, JOY_AXIS_X);
    _Joysticks[i]._JoyInfo.Y := joy_AxisPos(i, JOY_AXIS_Y);
    for X := 0 to High(_Joysticks[i]._JoyInfo.buttons) do
    begin
      _Joysticks[i]._JoyInfo.buttons[X].Pressed := joy_Down(i, X);
    end;
    if Assigned(_Joysticks[i].OnValue) then
      _Joysticks[i].OnValue(_Joysticks[i].AssignedObject, i,
        _Joysticks[i]._JoyInfo);
{$ELSE}
    TSZJoystick(_Joysticks[i])._JoyInfo.X := joy_AxisPos(i, JOY_AXIS_X);
    TSZJoystick(_Joysticks[i])._JoyInfo.Y := joy_AxisPos(i, JOY_AXIS_Y);
    for X := 0 to High(TSZJoystick(_Joysticks[i])._JoyInfo.buttons) do
    begin
      TSZJoystick(_Joysticks[i])._JoyInfo.buttons[X].Pressed := joy_Down(i, X);
    end;
    if Assigned(TSZJoystick(_Joysticks[i]).OnValue) then
      TSZJoystick(_Joysticks[i]).OnValue(TSZJoystick(_Joysticks[i]).AssignedObject,
        i, TSZJoystick(_Joysticks[i])._JoyInfo);
{$ENDIF}
  end;
  joy_ClearState;
{$IFDEF USE_XINPUT}
{$IFNDEF LINUX}
  GetXboxControllers;
{$ENDIF}
{$ENDIF}
end;

function TSZJoystickHandler._GetFreeJoystick;
var
  joy: TSZJoystick;
begin
  Result := nil;
  for joy in _Joysticks do
  begin
    if not joy._inuse then
    begin
      Result := joy;
      Exit;
    end;
  end;
end;

constructor TSZSprite.Create(ImagePath: string; Name: string = '');
begin
  _camera_mouse_X := 0;
  _camera_mouse_Y := 0;
  Events := TSZEventList.Create(True);
  _time := 0;
  _fade_amount := 5;
  _angle := 0;
  _Name := Name;
  _active := True;
  _textureloaded := False;
  _textureFilename := ImagePath;
  new(_rectangle);
end;

constructor TSZSprite.Create(_texture: zglPTexture; Name: string = '');
begin
  _textureowner := False;
  _camera_mouse_X := 0;
  _camera_mouse_Y := 0;
  Events := TSZEventList.Create(True);
  _time := 0;
  _fade_amount := 5;
  _angle := 0;
  _Name := Name;
  if Assigned(_texture) then
  begin
    texture := _texture;
    _textureloaded := True;
  end;
  new(_rectangle);
end;

procedure TSZSprite.Delete;
begin
  _delete := True;
end;

{$IFDEF DCC}

function TSZSprite._gettexturedata: PByteArray;
{$ELSE}

function TSZSprite._gettexturedata: PByteArray;
{$ENDIF}
begin
  tex_GetData(Self.texture, Result);
end;

function TSZSprite._isvisible(CameraRect: zglTRect): Boolean;
begin
  Result := col2d_RectInRect(_rectangle^, CameraRect);
end;

{$IFDEF DCC}

procedure TSZSprite._settexturedata(Value: zglheader.PByteArray);
{$ELSE}

procedure TSZSprite._settexturedata(Value: PByteArray);
{$ENDIF}
begin
  //tex_SetData(texture, Value, 0, 0, Rect.W, Rect.H);

end;
procedure TSZSprite.ResizeTextureFrame(Height: Integer; Width: Integer);
begin
  if texture <> nil then
    tex_SetFrameSize(texture, Width, Height);
end;

procedure TSZSprite.Blink;
begin
  _blinking := True;
  _fadeout := True;
end;

procedure TSZSprite.JoyControl;
begin
  _joycontrol := True;
end;

procedure TSZSprite.NoJoyControl;
begin
  _joycontrol := False;
end;

procedure TSZSprite.AssignJoystick(Joystick: TSZJoystick);
begin
  if Assigned(Joystick) then
  begin
{$IFDEF USE_XINPUT}
{$IFNDEF LINUX}
    if Joystick._isXboxPad then
    begin
      _joystick := Joystick;
      _joystick._inuse := True;
      _joystick._OnXBOXValue := Self.OnXboxInput;
    end
    else
{$ENDIF}
{$ENDIF}
    begin
      _joystick := Joystick;
      _joystick._inuse := True;
      _joystick.OnValue := Self.OnJoyInput;
    end;
  end;
  _joystick.AssignedObject := Self;
end;

procedure TSZSprite.AddEvent(Event: TSZEvent);
begin
  Event.AssignedObject := Self;
  Event._ObjectClass := Self.ClassType;
  Events.Add(Event);
end;

procedure TSZSprite.AssignInput(onValues: TSZJoystickEventsOnValue);
begin
  _fonjoyinput := onValues;
  if Assigned(_joystick) then
    _joystick.OnValue := onValues;
  if Assigned(_Keyboard) then
    _Keyboard.OnValue := onValues;
end;

{$IFDEF USE_XINPUT}

procedure TSZSprite.AssignInputXbox(onValues: TSZJoystickEventsXBoxOnValue);
begin
  _fonxboxinput := onValues;
  if Assigned(_joystick) and _joystick.IsXBOXPad then
    _joystick.OnXBOXValue := onValues;
end;
{$ENDIF}

procedure TSZSprite.AssignKeyboard(Keyboard: TSZKeyboard);
begin
  if Assigned(Keyboard) then
  begin
    _Keyboard := Keyboard;
    _Keyboard._inuse := True;
    _Keyboard._OnValue := Self.OnJoyInput;
    _Keyboard.AssignedObject := Self;
  end;
end;

procedure TSZSprite.UnassignKeyboard;
begin
  if Assigned(_Keyboard) then
  begin
    _Keyboard._inuse := False;
    _Keyboard.AssignedObject := nil;
    _Keyboard.OnValue := nil;
    _Keyboard := nil;
  end;
end;

procedure TSZSprite.UnassignJoystick;
begin
  if Assigned(_joystick) then
  begin
    _joystick._inuse := False;
    _joystick.AssignedObject := nil;
{$IFDEF USE_XINPUT}
    _joystick._OnXBOXValue := nil;
{$ENDIF}
    _joystick.OnValue := nil;
    _joystick := nil;
  end;
end;

procedure TSZSprite.UnBlink;
begin
  _fadeout := False;
  _fadein := False;
  _blinking := False;
  _alpha := 255;
end;

procedure TSZSprite.Rotate;
begin
  _rotate := True;
end;

procedure TSZSprite.SetCoordinates(X, Y: Single);
begin
  _rectangle.X := x;
end;

procedure TSZSprite.StopRotate;
begin
  _rotate := False;
end;

procedure TSZAnimated.RemoveAnimation(Animation: TSZAnimation);
begin
  if Assigned(_Animations) then
    _Animations.Remove(Animation);
end;

function TSZTile._isinthescreen: Boolean;
var
  X: Boolean;
  Y: Boolean;
  temprect: zglTRect;
  cliprect: zglTRect;
begin
  temprect.X := _spritebatch.GetCamera.X + _rectangle.W;
  temprect.Y := _spritebatch.GetCamera.Y + _rectangle.H;
  temprect.W := _spritebatch.Rectangle.W;
  temprect.H := _spritebatch.Rectangle.H;
  col2d_Rect(_rectangle^, temprect);
  // cliprect:=col2d_ClipRect(_rectangle^, temprect);
  // scissor_Begin( Round( _rectangle.X ), Round( _rectangle.Y ), Round( _rectangle.W ), Round( _rectangle.H ) );
  // scissor_End;
  Result := True;
  // x:=(_rectangle.X + _rectangle.W <= (_spritebatch.rectangle.W + _spritebatch.GetCamera.X)) and (_rectangle.X >= (_spritebatch.rectangle.X + _spritebatch.GetCamera.X));
  // y:=(_rectangle.Y + _rectangle.H <= (_spritebatch.rectangle.H + _spritebatch.GetCamera.Y)) and (_rectangle.Y >= (_spritebatch.rectangle.Y + _spritebatch.GetCamera.Y));
  // y:=(_rectangle.Y <= (_spritebatch.rectangle.H + _spritebatch.GetCamera.Y)) and (_rectangle.Y >= (_spritebatch.rectangle.Y + _spritebatch.GetCamera.Y));
  // Result:=x and y;
end;

procedure TSZSprite.ProcessEvents;
var
  Event: TSZEvent;
begin
  for Event in Events do
  begin
    if (Self._time >= Event.FireAt) and not(Event.Running) then
    begin
      Event.Running := True;
      Event.CurrentTime := Self._time;
      if Assigned(Event.OnStart) then
        Event.OnStart(Event);
      Break;
    end;
    if (Event.Running and (Self._time < Event._EndAt)) or
      (Event.Running and Event.Infinite) then
    begin
      Event.CurrentTime := Self._time;
      if Assigned(Event.OnProcess) then
        Event.OnProcess(Event);
    end;
    if (Self._time >= Event.EndAt) and Event.Infinite then
    begin
      Event.CurrentTime := Self._time;
      if Assigned(Event.OnFinished) then
        Event.OnFinished(Event);
      Event.Free;
    end;
  end;
end;

procedure TSZSprite.ProcessOpacity;
begin
  if _fadein and not _fadeout then
  begin
    if _alpha < 255 then
      Inc(_alpha, _fade_amount)
    else
    begin
      if Assigned(OnFadeIn) then
        OnFadeIn(Self);
      if _blinking then
      begin
        _fadein := False;
        _fadeout := True;
      end
      else
      begin
        _fadein := False;
      end;
    end;
  end;
  if _fadeout and not _fadein then
  begin
    if _alpha > 0 then
      Dec(_alpha, _fade_amount)
    else
    begin
      if Assigned(OnFadeOut) then
        OnFadeOut(Self);
      if _blinking then
      begin
        _fadein := True;
        _fadeout := False;
      end
      else
      begin
        _fadeout := False;
      end;
    end;
  end;
end;

procedure TSZSprite.TextureResize(H, W: Integer);
begin
  if texture <> nil then
  begin
    texture.Height := H;
    texture.Width := W;
  end;
end;

procedure TSZSprite.FadeOut;
begin
  _fadein := False;
  _fadeout := True;
end;

procedure TSZSprite.FadeOut(Amount: Integer);
begin
  _fadein := False;
  _fade_amount := Amount;
  FadeOut;
end;

function TSZSprite.GetGesture(var LastCoordX, LastCoordY : Single) : zglTPoint2D;
begin
  if LastCoordX <> _camera_mouse_X then
  begin
    Result.X := LastCoordX - _camera_mouse_X;
    LastCoordX := _camera_mouse_X;
  end
  else Result.X := 0;
  if LastCoordY <> _camera_mouse_Y then
  begin
    Result.Y := LastCoordY - mouse_Y;
    LastCoordY := mouse_Y;
  end
  else Result.Y := 0;
end;

procedure TSZSprite.FadeIn;
begin
  _fadeout := False;
  _fadein := True;
end;

procedure TSZSprite.FadeIn(Amount: Integer);
begin
  _fadeout := False;
  _fade_amount := Amount;
  FadeIn;
end;

procedure TSZSprite.ChangeTexture(texture: zglPTexture);
begin
  if Assigned(texture) then
  begin
    Self.texture := texture;
    _notTexture := False;
    _textureloaded := True;
  end;
end;

procedure TSZSprite.ChangeTexture(ImagePath: string);
begin
  _textureloaded := False;
  _notTexture := False;
  _textureFilename := ImagePath;
end;

procedure TSZSprite.CollideWith(Sprite: TSZSprite);
begin
  if Assigned(Sprite) then
  begin
    if col2d_PointInRect(Sprite.Rect.X, Sprite.Rect.Y, Self._rectangle^) then
    begin
      if Assigned(OnCollision) then
        OnCollision(Sprite);
    end;
  end;
end;

procedure TSZSprite.CollideWithRectangle(Rectangle: zglPRect);
begin
  if Assigned(Rectangle) then
  begin
    if col2d_RectInRect(Rectangle^, _rectangle^) then
    begin
      if Assigned(OnCollision) then
        OnCollision(Self);
    end;
  end;
end;

procedure TSZSprite.ProcessTimer;
begin
  Inc(_time);
  _ElapsedTime := (_time * 16) div 1000;
end;

procedure TSZSprite.MouseClick;
begin
  if MouseCollide then
  begin
    if mouse_Wheel(M_WDOWN) then
    begin
      if Assigned(OnMouseWheel) then
        OnMouseWheel(Self, TDirection.dirDown, _camera_mouse_X - (_camera_rect.X), _camera_mouse_Y - (_camera_rect.Y));
    end
    else if mouse_Wheel(M_WUP) then
    begin
      if Assigned(OnMouseWheel) then
        OnMouseWheel(Self, TDirection.dirUp, _camera_mouse_X - (_camera_rect.X), _camera_mouse_Y - (_camera_rect.Y));
    end;
    if mouse_Click(M_BLEFT) then
    begin
      MouseLastCoords.LastMouseXLeftButton := mouse_X;
      MouseLastCoords.LastMouseYLeftButton := mouse_Y;
      if Assigned(OnMouseClick) then
        OnMouseClick(Self, M_BLEFT, _camera_mouse_X - (_camera_rect.X), _camera_mouse_Y - (_camera_rect.Y));
    end;
    if mouse_Down(M_BLEFT) then
    begin
      if Assigned(OnGesture) then
        OnGesture(Self, M_BLEFT, Getgesture(MouseLastCoords.LastMouseXLeftButton, MouseLastCoords.LastMouseYLeftButton));
    end;
    if mouse_Click(M_BRIGHT) then
    begin
      MouseLastCoords.LastMouseXRightButton := mouse_X;
      MouseLastCoords.LastMouseYRightButton := mouse_Y;
      if Assigned(OnMouseClick) then
        OnMouseClick(Self, M_BRIGHT, _camera_mouse_X - (_camera_rect.X), _camera_mouse_Y - (_camera_rect.Y));
    end;
    if mouse_Down(M_BRIGHT) then
    begin
      if Assigned(OnGesture) then
        OnGesture(Self, M_BRIGHT, Getgesture(MouseLastCoords.LastMouseXRightButton, MouseLastCoords.LastMouseYRightButton));
    end;
  end;
end;

function TSZSprite.MouseCollide: Boolean;
begin
  _camera_mouse_X := mouse_X + _camera.X * _camera.Zoom.X;
  _camera_mouse_Y := mouse_Y + _camera.Y * _camera.Zoom.Y;

  _camera_mouse_X := ( _camera_mouse_X + ( _camera.Center.X * _camera.Zoom.X - _camera.Center.X ) ) / _camera.Zoom.X;
  _camera_mouse_Y := ( _camera_mouse_Y + ( _camera.Center.Y * _camera.Zoom.Y - _camera.Center.Y ) ) / _camera.Zoom.Y;

  _camera_rect.X := Self.Rect^.X * _camera.Zoom.X;
  _camera_rect.Y := Self.Rect^.Y * _camera.Zoom.Y;

  _camera_rect.W := Self.Rect^.W;
  _camera_rect.H := Self.Rect^.H;

  if col2d_PointInRect(_camera_mouse_X, _camera_mouse_Y, _camera_rect) then
  begin
    if Assigned(OnMouseCollision) then
      OnMouseCollision(Self, _camera_mouse_X - (_camera_rect.X), _camera_mouse_Y - (_camera_rect.Y));
    Result := True;
  end
  else
    Result := False;
end;

procedure TSZSprite.MouseEvents;
begin
  if Active then
  begin
    if MouseCollide then
    begin
      _mouseOn := True;
      MouseClick;
    end
    else
    begin
      if _mouseOn then
      begin
        _mouseOn := False;
        if Assigned(OnMouseOut) then
          OnMouseOut(Self);
      end;
    end;
  end;
end;

constructor TSZAnimated.Create(_texture: zglPTexture; Spritebatch: TSZSpriteBath;
  X, Y, W, H, FrameH, FrameW: Integer; Name: string);
begin
  inherited Create(_texture, Name);
  _frame := 0;
  _spritebatch := Spritebatch;
  _alpha := 0;
  _textureframeh := FrameH;
  _textureframew := FrameW;
  _rectangle.X := X + Spritebatch.Rectangle.X;
  _rectangle.Y := Y + Spritebatch.Rectangle.Y;
  _rectangle.W := W;
  _rectangle.H := H;
end;

procedure TSZAnimated.DeleteAnimations;
begin
  if Assigned(_Animations) then
    _Animations.Free;
end;

procedure TSZTile.Input;
begin
  if IsInTheScreen then
    MouseEvents;
end;

function TSZTile._readytodraw: Boolean;
begin
  // Not implemented
  raise ENotImplemented.Create('Not implemented yet');
end;

constructor TSZSpriteBath.Create(Rect: zglTRect; Name: string = '');
begin
  _collideable := False;
  _camera_mouse_X := 0;
  _camera_mouse_Y := 0;
  _resx := Round(Rect.W);
  _resy := Round(Rect.H);
  cam2d_Init(_camera);
  _camera.X := 0;
  _camera.Y := 0;
  _rectangle := Rect;
  _Name := Name;
{$IFDEF DCC}
  spritelist := TObjectList<TSZSprite>.Create(True);
{$ENDIF}
{$IFDEF FPC}
  spritelist := TSpriteList.Create(True);
{$ENDIF}
end;

procedure TSZSpriteBath.SetRes(Width: Integer; Height: Integer);
begin
  _rectangle.W := Width;
  _rectangle.H := Height;
  _resx := Width;
  _resy := Height;
end;

procedure TSZSpriteBath.ProcessEvents;
var
  Event: TSZEvent;
begin
  for Event in Events do
  begin
    if (Self._time >= Event.FireAt) and not(Event.Running) then
    begin
      Event.Running := True;
      Event.CurrentTime := Self._time;
      if Assigned(Event.OnStart) then
        Event.OnStart(Event);
      Break;
    end;
    if (Event.Running and (Self._time < Event._EndAt)) or
      (Event.Running and Event.Infinite) then
    begin
      Event.CurrentTime := Self._time;
      if Assigned(Event.OnProcess) then
        Event.OnProcess(Event);
    end;
    if (Self._time >= Event.EndAt) and Event.Infinite then
    begin
      Event.CurrentTime := Self._time;
      if Assigned(Event.OnFinished) then
        Event.OnFinished(Event);
      Event.Free;
    end;
  end;
end;

procedure TSZSpriteBath.ProcessTimer;
var
  Sprite: TSZSprite;
begin
  for Sprite in spritelist do
  begin
    Sprite.ProcessTimer;
  end;
  Inc(_time);
  _ElapsedTime := (_time * 16) div 1000;
end;

procedure TSZSpriteBath.JoyControl;
begin
  _joycontrol := True;
end;

procedure TSZSpriteBath.NoJoyControl;
begin
  _joycontrol := False;
end;

procedure TSZSpriteBath.FadeIn;
var
  Sprite: TSZSprite;
begin
  _fadein := True;
  for Sprite in spritelist do
  begin
    Sprite.Active := True;
    Sprite.UnBlink;
    Sprite.FadeIn;
  end;
end;

procedure TSZSpriteBath.FadeOut;
var
  Sprite: TSZSprite;
begin
  _fadeout := True;
  if spritelist.Count <> 0 then
  begin
    for Sprite in spritelist do
    begin
      // Sprite.Active := False;
      Sprite.UnBlink;
      Sprite.FadeOut;
    end;
  end
  else
  begin
    if Assigned(OnFadeOut) then
      OnFadeOut(Self);
  end;
end;

function TSZSpriteBath.Add(Sprite: TSZSprite): TSZSprite;
begin
  Sprite._camera := @Self._camera;
  if _resx < (Sprite.Rect.W + Sprite.Rect.X) then
    Inc(_resx, Round(Sprite.Rect.W + Sprite.Rect.X));
  if _resy < (Sprite.Rect.H + Sprite.Rect.Y) then
    Inc(_resy, Round(Sprite.Rect.H + Sprite.Rect.Y));
  Sprite.Active := True;
  Sprite.Visible := True;
  spritelist.Add(Sprite);
  Sprite.Num := spritelist.Count;
  Result := Sprite;
end;

function TSZSpriteBath._GetCamera;
begin
  Result := @_camera;
end;

procedure TSZSpriteBath.Move(Animation: TSZMoveAnimation);
begin
  _moveanimation := Animation;
  _ismoving := True;

end;

function TSZSpriteBath.GetGesture(var LastCoordX, LastCoordY : Single): zglTPoint2D;
begin
  if LastCoordX <> mouse_X then
  begin
    Result.X := LastCoordX - mouse_X;
    LastCoordX := mouse_X;
  end
  else Result.X := 0;
  if LastCoordY <> mouse_Y then
  begin
    Result.Y := LastCoordY - mouse_Y;
    LastCoordY := mouse_Y;
  end
  else Result.Y := 0;
end;

function TSZSpriteBath.GetLastSprite;
begin
{$IFDEF DCC}
  Result := spritelist.Last;
{$ELSE}
  Result := TSZSprite(spritelist.Last);
{$ENDIF}
end;

function TSZSpriteBath.MouseCollide;
var
  temprec : TRectangle;
begin
  _camera_mouse_X := mouse_X + _camera.X * _camera.Zoom.X;
  _camera_mouse_Y := mouse_Y + _camera.Y * _camera.Zoom.Y;

  _camera_mouse_X := ( _camera_mouse_X + ( _camera.Center.X * _camera.Zoom.X - _camera.Center.X ) ) / _camera.Zoom.X;
  _camera_mouse_Y := ( _camera_mouse_Y + ( _camera.Center.Y * _camera.Zoom.Y - _camera.Center.Y ) ) / _camera.Zoom.Y;

  temprec.X := (Self.Rectangle.X + _camera.X) * _camera.Zoom.X;
  temprec.Y := (Self.Rectangle.Y + _camera.Y) * _camera.Zoom.Y;
  temprec.W := Self.Rectangle.W;
  temprec.H := Self.Rectangle.H;

  if col2d_PointInRect(_camera_mouse_X, _camera_mouse_Y, temprec) then
  begin
    if Assigned(OnMouseCollision) then
      OnMouseCollision(Self, _camera_mouse_X - (temprec.X), _camera_mouse_Y - (temprec.Y));
    Result := True;
  end
  else
    Result := False;
end;

function TSZSpriteBath.Getsprite(Name: string): TSZSprite;
var
  Sprite: TSZSprite;
begin
  for Sprite in spritelist do
  begin
    if Sprite._Name = Name then
    begin
      Result := Sprite;
      Break;
    end;
  end;
end;

procedure TSZSpriteBath.AddEvent(Event: TSZEvent);
begin
  Event.AssignedObject := Self;
  Event._ObjectClass := Self.ClassType;
  if _events = nil then _events := TSZEventList.Create(True);
  _events.Add(Event);
end;

procedure TSZSpriteBath.Clean;
begin
  spritelist.Clear;
end;

destructor TSZSpriteBath.Destroy;
begin
  spritelist.Free;
end;

procedure TSZSpriteBath.Draw;
var
  Sprite: TSZSprite;
  camerarec: zglTRect;
begin
  if _running then
  begin
    // if Assigned(self.OnBeforeDraw) then self.OnBeforeDraw(Self);
    batch2d_Begin;
    cam2d_Set(@_camera);
    scissor_Begin(Round(_rectangle.X), Round(_rectangle.Y), Round(_rectangle.W),
      Round(_rectangle.H), False);
    if Assigned(OnBeforeDraw) then
      OnBeforeDraw(Self);
    for Sprite in Self.spritelist do
    begin
      if Sprite._delete then
      begin
        Self.spritelist.Remove(Sprite);
        Break;
      end;
      if _running then
      begin
        if not Sprite._textureloaded and not Sprite._notTexture and not Sprite._noneedtexture  then
          Sprite.Loadtexture;
        if Sprite.Visible then
        begin
          // camerarec.X:=_camera.X + _rectangle.X;
          // camerarec.Y:=_camera.Y + _rectangle.y;
          // camerarec.W:=_rectangle.W;
          // camerarec.H:=_rectangle.H;
          // if sprite._isvisible(camerarec) then
          if Assigned(Sprite.OnBeforeDraw) then
            Sprite.OnBeforeDraw(Sprite);
          Sprite.Draw;
          if Assigned(Sprite.OnAfterDraw) then
            Sprite.OnAfterDraw(Sprite);
        end;
      end;
    end;
    scissor_End;
    cam2d_Set(nil);
    if ShowBorders then
      pr2d_Rect(_rectangle.X, _rectangle.Y, _rectangle.W, _rectangle.H,
        $FFFFFF, 255);
    batch2d_End;
    // if Assigned(self.OnAfterDraw) then OnAfterDraw(Self);
  end;
end;

procedure TSZSpriteBath.Start;
begin
  _running := True;
  if Assigned(OnStart) then OnStart(Self);
end;

procedure TSZSpriteBath._processAnimation;
begin
  // if _rectangle.X < _moveanimation.X  then _rectangle.X:=_rectangle.X + _moveanimation.Speed
  // else if _rectangle.X > _moveanimation.x then _rectangle.x:=_rectangle.X - _moveanimation.Speed;
  // if _rectangle.Y < _moveanimation.Y  then _rectangle.Y:=_rectangle.Y + _moveanimation.Speed
  // else if _rectangle.Y > _moveanimation.Y then _rectangle.Y:=_rectangle.Y - _moveanimation.Speed;
  // if (_rectangle.X = _moveanimation.X) and (_rectangle.Y = _moveanimation.Y) then
  // begin
  // _ismoving:=False;
  // end;
end;

procedure TSZSpriteBath.Update(dt: Double);
var
  Sprite: TSZSprite;
  visiblealready: Boolean;
  Finished: Boolean;
begin
  if _running then
  begin
    _dt := dt;
    for Sprite in spritelist do
    begin
      if Sprite._delete then
      begin
        spritelist.Remove(Sprite);
        Break
      end;
      if Sprite.Active then
      begin
        Sprite.Process;
        Sprite.ProcessEvents;
      end;
      if _fadeout then
        visiblealready := (Sprite._alpha > 0)
      else if _fadein then
        visiblealready := (Sprite._alpha < 255);
    end;
    if not Assigned(_myupdatethread) and _collideable then
    begin
      _myupdatethread := TSZSpriteCollisionThread.Create(Self);
      _myupdatethread.Start;
    end
    else if not _collideable and Assigned(_myupdatethread) then
    begin
      if not _myupdatethread.Suspended  then
      begin
        _myupdatethread.Terminate;
        _myupdatethread := nil;
      end;
    end;
    if _ismoving then
      _processAnimation;
    if not visiblealready and _fadeout then
    begin
      _fadeout := False;
      if Assigned(OnFadeOut) then
        OnFadeOut(Self);
    end
    else if not visiblealready and _fadein then
    begin
      _fadein := False;
      if Assigned(OnFadeIn) then
        OnFadeIn(Self);
    end;
  end;
end;

procedure TSZSpriteBath.Input;
var
  Sprite: TSZSprite;
  x : Integer;
begin
  if _running then
  begin
    if MouseCollide then
    begin
      for x := self.spritelist.Count - 1 downto 0 do
      begin
        Sprite := TSZSprite(self.spritelist[x]);
        if Sprite._delete then
        begin
          Self.spritelist.Remove(Sprite);
          Break;
        end;
        if Sprite.Active then Sprite.Input;
      end;
      if mouse_Wheel(M_WDOWN) then
      begin
        if Assigned(OnMouseWheel) then
          OnMouseWheel(Self, TDirection.dirDown, mouse_X, mouse_Y);
      end
      else if mouse_Wheel(M_WUP) then
      begin
        if Assigned(OnMouseWheel) then
          OnMouseWheel(Self, TDirection.dirUp, mouse_X, mouse_Y);
      end;
      if mouse_Click(M_BLEFT) then
      begin
        MouseLastCoords.LastMouseXLeftButton := mouse_X;
        MouseLastCoords.LastMouseYLeftButton := mouse_Y;
        if Assigned(OnMouseClick) then
          OnMouseClick(Self, M_BLEFT, mouse_X, mouse_Y);
      end;
      if mouse_Down(M_BLEFT) then
      begin
        if Assigned(OnGesture) then
          OnGesture(Self, M_BLEFT, Getgesture(MouseLastCoords.LastMouseXLeftButton, MouseLastCoords.LastMouseYLeftButton));
      end;
      if mouse_Click(M_BRIGHT) then
      begin
        MouseLastCoords.LastMouseXRightButton := mouse_X;
        MouseLastCoords.LastMouseYRightButton := mouse_Y;
        if Assigned(OnMouseClick) then
          OnMouseClick(Self, M_BRIGHT, mouse_X, mouse_Y);
      end;
      if mouse_Down(M_BRIGHT) then
      begin
        if Assigned(OnGesture) then
          OnGesture(Self, M_BRIGHT, Getgesture(MouseLastCoords.LastMouseXRightButton, MouseLastCoords.LastMouseYRightButton));
      end;
    end;
  end;
end;

procedure TSZSpriteBath.Stop;
var
  Sprite: TSZSprite;
begin
  if Assigned(_myupdatethread) and not _myupdatethread.Suspended then
  begin
    _myupdatethread.Terminate;
    _myupdatethread := nil;
  end;
  _running := False;
  // for sprite in spritelist do sprite._alpha:=255;
end;

procedure TSZSpriteBath.Resume;
begin
  _running := True;
end;

constructor TSZTile.Create(ImagePath: string; font: zglPFont;
  Spritebatch: TSZSpriteBath; X, Y, W, H: Integer; Name: string = '';
  LoadTextureNow: Boolean = False);
var
  tempguid: TGUID;
begin
  inherited Create(ImagePath, Name);
  _font := font;
  _spritebatch := Spritebatch;
  _alpha := 0;
  _rectangle.X := X;
  _rectangle.Y := Y;
  _rectangle.X := _rectangle.X + Spritebatch.Rectangle.X;
  _rectangle.Y := _rectangle.Y + Spritebatch.Rectangle.Y;
  _rectangle.W := W;
  _rectangle.H := H;
  if LoadTextureNow then
    Loadtexture;
end;

constructor TSZTile.Create(texture: zglPTexture; font: zglPFont;
  Spritebatch: TSZSpriteBath; X: Integer; Y: Integer; W: Integer; H: Integer;
  Name: string = ''; LoadTextureNow: Boolean = False);
var
  tempguid: TGUID;
begin
  inherited Create(texture, Name);
  _spritebatch := Spritebatch;
  _font := font;
  _alpha := 0;
  _rectangle.X := X;
  _rectangle.Y := Y;
  _rectangle.X := _rectangle.X + Spritebatch.Rectangle.X;
  _rectangle.Y := _rectangle.Y + Spritebatch.Rectangle.Y;
  _rectangle.W := texture.Height;
  _rectangle.H := texture.Width;
  if LoadTextureNow then
    Loadtexture;
end;

// procedure TAMSTile.ChangeTexture(idx: Integer);
// begin
// if ((idx > High(_textures)) or not (idx < Low(_textures))) then
// begin
// texture := _textures[idx];
// end;
// end;

constructor TSZTile.Create(ImagePath: string; Spritebatch: TSZSpriteBath;
  Rectangle: zglTRect; Name: string = ''; LoadTextureNow: Boolean = False);
begin
  inherited Create(ImagePath, Name);
  _spritebatch := Spritebatch;
  _alpha := 0;
  _rectangle^ := Rectangle;
  if LoadTextureNow then
    Loadtexture;
end;

procedure TSZTile.Loadtexture;
var
  memorystream: zglTMemory;
  stringstream: TStringStream;
  a: string;
begin
  if (_textureFilename = '') then
  begin
    _textureloaded := False;
    _notTexture := True;
  end
  else if _textureFilename <> '' then
  begin
{$IFNDEF LINUX}
    try
      texture := tex_LoadFromFile(_textureFilename, $FF00FF, TEX_DEFAULT_2D);
    except

    end;
{$ELSE}
    file_OpenArchive(PAnsiChar(zgl_Get(DIRECTORY_APPLICATION)));
    texture := tex_LoadFromFile(_textureFilename);
    file_CloseArchive;
{$ENDIF}
    if _textureframeh = 0 then
      _textureframeh := texture.Height;
    if _textureframew = 0 then
      _textureframew := texture.Width;
    if _rectangle.W = 0 then _rectangle.W := _textureframew;
    if _rectangle.H = 0 then _rectangle.H := _textureframeh;
    ResizeTextureFrame(_textureframeh, _textureframew);
    if Assigned(OnTextureLoaded) then OnTextureLoaded(Self);
    _textureloaded := True;
  end;
  if _textureloaded then
    FadeIn;
end;

procedure TSZAnimated.ProcessAnimation;
var
  Animation: TSZAnimation;
begin
  if Assigned(_Animations) then
  begin
    for Animation in _Animations do
    begin
      if not Animation.Finished then
      begin
        Animation.ProcessAnimation;
      end;
    end;
  end;
  if _rotate then
  begin
    if _angle < 360 then
      _angle := _angle + 1
    else if _angle = 360 then
      _angle := 0;
  end;
end;

procedure TSZAnimated.AssignAnimation(Animation: TSZAnimation);
begin
  if not Assigned(_Animations) then
    _Animations := TSZAnimationList.Create(True);
  _Animations.Add(Animation);
end;

procedure TSZTile.Process;
begin
  ProcessOpacity;
  ProcessAnimation;
end;

constructor TSZScene.Create(X, Y: Integer; H, W: Integer; font: zglPFont;
  BackgroundImage: string = ''; Name: string = '');
begin
  Events := TSZEventList.Create(True);
  _font := font;
  _time := 0;
  cam2d_Init(_camera);
  _Name := name;
  if BackgroundImage <> '' then
  begin
    _hasbackground := True;
    _backgroundtexturename := BackgroundImage;
    Loadtexture;
  end
  else
    _hasbackground := False;
  _x := X;
  _y := Y;
  _h := H;
  _w := W;
{$IFDEF DCC}
  _spritebatchList := TObjectList<TSZSpriteBath>.Create(True);
{$ENDIF}
{$IFDEF FPC}
  _spritebatchList := TSpriteBatchList.Create(True);
{$ENDIF}
end;

procedure TSZScene.ProcessEvents;
var
  Event: TSZEvent;
begin
  for Event in Events do
  begin
    if (Self._ElapsedTime >= Event.FireAt) and not(Event.Running) then
    begin
      Event.Running := True;
      Event.CurrentTime := Self._ElapsedTime;
      Event.ElapsedTime := Event.CurrentTime - Event.FireAt;
      if Assigned(Event.OnStart) then
        Event.OnStart(Event);
      Break;
    end;
    if (Event.Running and (Self._ElapsedTime < Event._EndAt)) or
      (Event.Running and Event.Infinite) then
    begin
      Event.CurrentTime := Self._time;
      Event.CurrentTime := Self._ElapsedTime;
      Event.ElapsedTime := Event.CurrentTime - Event.FireAt;
      if Assigned(Event.OnProcess) then
        Event.OnProcess(Event);
    end;
    if (Self._ElapsedTime >= Event.EndAt) and not Event.Infinite then
    begin
      Event.CurrentTime := Self._ElapsedTime;
      if Assigned(Event.OnFinished) then
        Event.OnFinished(Event);
    end;
  end;
end;

procedure TSZScene.ProcessTimer;
var
  Spritebatch: TSZSpriteBath;
begin
  for Spritebatch in _spritebatchList do
  begin
    Spritebatch.ProcessTimer;
  end;
  Inc(_time);

  _ElapsedTime := (_time * 16) div 1000;
end;

procedure TSZScene.ResetTimer;
begin
  _ElapsedTime := 0;
  _time := 0;
end;

function TSZScene.Getcoords: zglTRect;
begin
  Result.X := _x;
  Result.Y := _y;
  Result.W := _w;
  Result.H := _h;
end;

function TSZScene.Add(Spritebatch: TSZSpriteBath): TSZSpriteBath;
begin
{$IFDEF DCC}
  _spritebatchList.Add(Spritebatch);
  // _spritebatchList.Reverse;
{$ELSE}
  // _spritebatchList.Add(Spritebatch);
  _spritebatchList.Insert(_spritebatchList.Count, Spritebatch);
{$ENDIF}
  Result := Spritebatch;
end;

procedure TSZScene.Clean(Spritebatch: TSZSpriteBath);
begin
  Spritebatch.Clean;
  _spritebatchList.Remove(Spritebatch);
end;

function TSZScene.AddEvent(Event: TSZEvent): TSZEvent;
begin
  Event.AssignedObject := Self;
  Event._ObjectClass := Self.ClassType;
  Events.Add(Event);
  Result := Event;
end;

procedure TSZScene.Clean;
begin
  _spritebatchList.Clear;
end;

procedure TSZScene.Update(dt: Double);
var
  Spritebatch: TSZSpriteBath;
  Event: TSZEvent;
begin
  if _visible then
    for Spritebatch in _spritebatchList do
    begin
      if Spritebatch._running then
        Spritebatch.Update(dt);
    end;
  ProcessEvents;
end;

procedure TSZScene.Loadtexture;
begin
  try
    _background := tex_LoadFromFile(_backgroundtexturename);
    _textureloaded := True;
  finally

  end;
end;

procedure TSZScene.Draw;
var
  Spritebatch: TSZSpriteBath;
begin
  if _visible then
  begin
    if _hasbackground then
    begin
      if not _textureloaded then
        Loadtexture;
      ssprite2d_Draw(_background, _x, _y, _w, _h, 0, 255, 0);
    end;
    cam2d_Set(@_camera);
    for Spritebatch in _spritebatchList do
    begin
      if Spritebatch._running then
        Spritebatch.Draw;
    end;
    cam2d_Set(nil);
    if ShowTimer then
      text_Draw(_font, 0, 0, 'Time : ' + u_IntToStr(_ElapsedTime));
    if ShowFPS then
      text_Draw(_font, Self._w - 200, 0,
        'FPS : ' + u_IntToStr(zgl_Get(RENDER_FPS)))
  end;
end;

function TSZScene._GetCamera;
begin
  Result := @_camera;
end;

procedure TSZScene.Input;
var
  Spritebatch: TSZSpriteBath;
  x : Integer;
begin
  if _visible then
  for x:=_spritebatchList.Count - 1 downto 0 do
  begin
    TSZSpriteBath(_spritebatchList.Items[x]).Input;
  end;
  mouse_ClearState;
  if Assigned(_joystickHandler) then
    _joystickHandler.Poll;
  if Assigned(_keyboardHandler) then
    _keyboardHandler.Poll;
end;

procedure TSZScene.Start;
begin
  _visible := True;
end;

procedure TSZScene.Stop;
var
  Spritebatch: TSZSpriteBath;
begin
  for Spritebatch in _spritebatchList do
  begin
    Spritebatch.Stop;
  end;
  _visible := False;
end;

procedure TSZScene.Resume;
var
  Spritebatch: TSZSpriteBath;
begin
  for Spritebatch in _spritebatchList do
  begin
    Spritebatch.Start;
  end;
  _visible := True;
end;

function TSZScene.GetSpriteBatch(Name: string): TSZSpriteBath;
var
  Spritebatch: TSZSpriteBath;
begin
  Result := nil;
  for Spritebatch in _spritebatchList do
  begin
    if Spritebatch._Name = Name then
    begin
      Result := Spritebatch;
      Break;
    end;
  end;
end;

procedure TSZScene.InitJoysticks;
begin
  _joystickHandler := TSZJoystickHandler.Create;
  if _handleKeyboard then
    _keyboardHandler := TSZKeyboardHandler.Create;
end;

constructor TSZText.Create(fontPath: string; Spritebatch: TSZSpriteBath;
  X: Integer; Y: Integer; Name: string = '');
begin
  Events := TSZEventList.Create(True);
  _fade_amount := 5;
  _alpha := 255;
  _spritebatch := Spritebatch;
  _Name := Name;
  _scale := 1;
  new(_rectangle);
  _rectangle.X := X + Spritebatch.Rectangle.X;
  _rectangle.Y := Y + Spritebatch.Rectangle.Y;
  _textureloaded := False;
  _textureFilename := fontPath;
end;

constructor TSZText.Create(font: zglPFont; Spritebatch: TSZSpriteBath;
  X: Integer; Y: Integer; Name: string = '');
begin
  Events := TSZEventList.Create(True);
  _fade_amount := 5;
  _alpha := 255;
  _spritebatch := Spritebatch;
  _scale := 1;
  new(_rectangle);
  _rectangle.X := X + Spritebatch.Rectangle.X;
  _rectangle.Y := Y + Spritebatch.Rectangle.Y;
  _rectangle.W := Spritebatch._rectangle.W;
  _rectangle.H := font.MaxHeight;
  _Name := Name;
  texture := font;
  _textureloaded := True;
end;

procedure TSZText.Draw;
begin
  if _alpha < 0 then
    _alpha := 0
  else if _alpha > 255 then
    _alpha := 255;
  text_DrawEx(texture, _rectangle.X, _rectangle.Y, _scale, 1, _text, _alpha,
    $FFFFFF, TEXT_HALIGN_CENTER);
end;

procedure TSZText._setText(text: string);
var
  chr: zglPCharDesc;
begin
  _text := text;
  if texture <> nil then
  begin
    // _scale:=Round(_spritebatch.rectangle.H / texture.MaxHeight);
    _width := text_GetWidth(texture, text) * _scale;
    _height := texture.MaxHeight;
    // _rectangle.X:=(_spritebatch.rectangle.X - _width)
  end;
end;

procedure TSZText.Input;
begin
  MouseEvents;
end;

procedure TSZText.Loadtexture;
begin
  texture := font_LoadFromFile(_textureFilename);
  _textureloaded := True;
  if Assigned(OnTextureLoaded) then OnTextureLoaded(Self);
end;

procedure TSZText.Scroll;
begin
  _active := True;
  _scrolling := not _scrolling;
end;

procedure TSZText.Process;
begin
  ProcessOpacity;
  ProcessAnimation;
end;

procedure TSZText.ProcessAnimation;
begin
  if _scrolling then
  begin
    if (_rectangle.X - _width) <= (_spritebatch.Rectangle.W + _width) then
      _rectangle.X := _rectangle.X + 2
    else if (_rectangle.X - _width) >= (_spritebatch.Rectangle.W + _width) then
      _rectangle.X := (_spritebatch.Rectangle.X - _width);
  end;
end;

destructor TSZTile.Destroy;
begin
  if _textureowner then
  begin
    if texture <> nil then
      tex_Del(texture);
    if _LogoTexture <> nil then
      tex_Del(_LogoTexture);
  end;
  if _rectangle <> nil then Dispose(_rectangle);
end;

procedure TSZTile.Draw;
begin
  if IsInTheScreen then
  begin
    if not _notTexture then
    begin
      // pr2d_Rect(_rectangle.X, _rectangle.Y, texture.Width, texture.Height, $FFFFFF, 255, 0);
      if _alpha < 0 then
        _alpha := 0
      else if _alpha > 255 then
        _alpha := 255;
      ssprite2d_Draw(texture, _rectangle.X, _rectangle.Y, _rectangle.W,
        _rectangle.H, _angle, _alpha);
    end;
  end;
end;

procedure TSZTile.ProcessAnimation;
begin
  //
end;

constructor TSZTextBox.Create(fontPath: string; Spritebatch: TSZSpriteBath;
  X: Integer; Y: Integer; W: Integer; H: Integer; Name: string = ''; imgbackground : string = '') overload;
begin
  Events := TSZEventList.Create(True);
  _current_input_count := 0;
  _scroll_input_sensibility := 4;
  OnMouseWheel := _OnScroll;
  _spritebatch := Spritebatch;
  _Name := Name;
  cam2d_Init(_textboxcam);
  new(_rectangle);
  _rectangle.X := X + Spritebatch.Rectangle.X;
  _rectangle.Y := Y + Spritebatch.Rectangle.Y;
  _rectangle.W := W;
  _rectangle.H := H;
  _textureloaded := False;
  _textureFilename := fontPath;
  if imgbackground <> '' then
  begin
   _backtile := TSZTile.Create(imgbackground, Spritebatch, _rectangle^, '', True);
   _backtile._alpha := 255;
  end;
end;

procedure TSZTextBox.BlinkAnimationProc(Sender: TObject);
begin
  if Sender is TSZBlinkAnimation then
    _firstitemalpha := TSZBlinkAnimation(Sender).Alpha;
end;

constructor TSZTextBox.Create(font: zglPFont; Spritebatch: TSZSpriteBath;
  X: Integer; Y: Integer; W: Integer; H: Integer; Name: string = ''; imgbackground : string = '') overload;
begin
  Events := TSZEventList.Create(True);
  _current_input_count := 0;
  _scroll_input_sensibility := 4;
  _stringlist := TStringList.Create;
  OnMouseWheel := _OnScroll;
  _spritebatch := Spritebatch;
  new(_rectangle);
  cam2d_Init(_textboxcam);
  _rectangle.X := X + Spritebatch.Rectangle.X;
  _rectangle.Y := Y + Spritebatch.Rectangle.Y;
  _rectangle.W := W;
  _rectangle.H := H;
  _Name := Name;
  texture := font;
  _textureloaded := True;
  _scroller_height := _rectangle.H;
  _scroller_pos := _rectangle.Y;
  _currentline := 1;
  _visiblelines := Round(_rectangle.H / texture.MaxHeight);
  if imgbackground <> '' then
  begin
   _backtile := TSZTile.Create(imgbackground, Spritebatch, _rectangle^, '', True);
   _backtile._alpha := 255;
  end;
end;

procedure TSZTextBox.Draw;
var
  i: Integer;
  temprect: zglTRect;
begin
  pr2d_Rect(_rectangle.X, _rectangle.Y, _rectangle.W, _rectangle.H,
    $FFFFFF, 255, 0);
  pr2d_Rect((_rectangle.X + _rectangle.W) - 50, _rectangle.Y, 50, _rectangle.H,
    $FFFFFF, 255, PR2D_FILL);
  pr2d_Rect((_rectangle.X + _rectangle.W) - 50, _scroller_pos, 50,
    _scroller_height, $000000, 255, PR2D_FILL);
  cam2d_Set(@_textboxcam);
  scissor_Begin(Round(_rectangle.X), Round(_rectangle.Y), Round(_rectangle.W),
    Round(_rectangle.H), False);
  if Assigned(_backtile) then
    _backtile.Draw;
  for i := _currentline to (_visiblelines + _currentline) do
  begin
    if i <= _stringlist.Count then
    begin
      temprect := _rectangle^;
      temprect.Y := temprect.Y + ((i - 1) * (texture.MaxHeight * 2));
      if i = _currentline then
      begin
        if SelectedBlinks then
          text_DrawInRectEx(texture, temprect, 2, 1, _stringlist[i - 1],
            _firstitemalpha, $FFFFFF, TEXT_CLIP_RECT)
        else
          text_DrawInRectEx(texture, temprect, 2, 1, _stringlist[i - 1], 255,
            $FFFFFF, TEXT_CLIP_RECT);
      end
      else
        text_DrawInRectEx(texture, temprect, 2, 1, _stringlist[i - 1], 255,
          $FFFFFF, TEXT_CLIP_RECT);
    end;
  end;
  scissor_End;
  cam2d_Set(nil);
  // ssprite2d_Draw(texture, _rectangle.X, _rectangle.Y, texture.Width, texture.Height, _angle, _alpha);
end;

procedure TSZTextBox._setText(text: string);
begin
  _stringlist.Add(text);
  if texture <> nil then
    _textheight := ((texture.MaxHeight) * 2) * _stringlist.Count;
  _scroller_height := _rectangle.H / _textheight;
end;

procedure TSZTextBox._OnScroll(ASender: TObject; aDirection: TDirection; X, Y : Single);
begin
  case aDirection of
    dirUp:
      begin
        if (TSZTextBox(ASender).GetCamera.Y > 0) then
        begin
          if _currentline <> 1 then
          begin
            Dec(_currentline);
            TSZTextBox(ASender).GetCamera.Y := TSZTextBox(ASender).GetCamera.Y
              - (texture.MaxHeight * 2);
          end
          else
            Exit;
          // if _scroller_pos < _rectangle.Y then _scroller_pos:=_rectangle.Y;
        end;
      end;
    dirDown:
      begin
        if TSZTextBox(ASender).GetCamera.Y <= TSZTextBox(ASender).TextHeight
        then
        begin
          if _currentline <> _stringlist.Count then
          begin
            Inc(_currentline);
            TSZTextBox(ASender).GetCamera.Y := TSZTextBox(ASender).GetCamera.Y
              + (texture.MaxHeight * 2);
          end
          else
            Exit;
          // if _scroller_pos + _scroller_height >= _rectangle.H then _scroller_pos:=_rectangle.H;
        end;
      end;
  end;
  _current_input_count := 0;
  _scroller_pos := (_rectangle.Y - _scroller_height) +
    (_currentline * _rectangle.H / _stringlist.Count);
  if Assigned(OnItemSelected) then
    OnItemSelected(Self, _currentline);

end;

procedure TSZTextBox.Process;
begin
  if Assigned(_backtile) then _backtile.Rect^ := Self.Rect^;

  if _selectedblinks then
  begin
    if not Assigned(BlinkAnimation) then
    begin
      BlinkAnimation := TSZBlinkAnimation.Create(_blinkspeed, True);
      _firstitemalpha := 255;
      BlinkAnimation.OnProcess := BlinkAnimationProc;
    end;
    BlinkAnimation.ProcessAnimation;
  end;
  ProcessAnimation;
end;

procedure TSZTextBox.Input;
begin
  MouseEvents;
end;

procedure TSZTextBox.Loadtexture;
begin
  //
end;

procedure TSZTextBox.Scroll(Direction: TDirection);
begin
  if Assigned(OnMouseWheel) then
    OnMouseWheel(Self, Direction, mouse_X, mouse_y);
  if Assigned(OnItemSelected) then
    OnItemSelected(Self, _currentline);
end;

procedure TSZTextBox.SetOnItemClicked(const Value: TSZEventListBoxOnItemClicked);
begin
  FOnItemClicked := Value;
end;

procedure TSZTextBox.SetOnItemSelected(const Value
  : TSZEventListBoxOnItemSelected);
begin
  FOnItemSelected := Value;
end;

function TSZTextBox._GetCamera;
begin
  Result := @_textboxcam;
end;

constructor TSZAnimated.Create(ImagePath: string; Spritebatch: TSZSpriteBath;
  X, Y, W, H: Integer; FrameH, FrameW: Integer; Name: string = '';
  LoadTextureNow: Boolean = False);
begin
  inherited Create(texture, Name);
  _textureFilename := ImagePath;
  _frame := 0;
  _spritebatch := Spritebatch;
  _alpha := 0;
  _textureframeh := FrameH;
  _textureframew := FrameW;
  _rectangle.X := X + Spritebatch.Rectangle.X;
  _rectangle.Y := Y + Spritebatch.Rectangle.Y;
  _rectangle.W := W;
  _rectangle.H := H;
  if LoadTextureNow then
    Loadtexture;
end;

procedure TSZAnimated.Loadtexture;
var
  memorystream: zglTMemory;
  stringstream: TStringStream;
  a: string;
begin
  if (_textureFilename = '') then
  begin
    _textureloaded := False;
    _notTexture := True;
  end
  else if _textureFilename <> '' then
  begin
    try
      if texture <> nil then
        tex_Del(texture);
{$IFNDEF LINUX}
      texture := tex_LoadFromFile(_textureFilename, $FF00FF, TEX_DEFAULT_2D);
{$ELSE}
      file_OpenArchive(PAnsiChar(zgl_Get(DIRECTORY_APPLICATION)));
      texture := tex_LoadFromFile(_textureFilename);
      file_CloseArchive;
{$ENDIF}
      _textureloaded := True;
    except
      if Assigned(OnErrorLoadingTexture) then
        OnErrorLoadingTexture(Self);
      _notTexture := True;
    end;
  end;
  if _textureloaded then
  begin
    if _textureframeh = 0 then
      _textureframeh := texture.Height;
    if _textureframew = 0 then
      _textureframew := texture.Width;
    ResizeTextureFrame(_textureframeh, _textureframew);
    if Assigned(OnTextureLoaded) then OnTextureLoaded(Self);
    FadeIn;
  end;
  _frame := 0;
  if Assigned(texture) then
    _frames := High(texture.FramesCoord);
end;

destructor TSZAnimated.Destroy;
begin
  if _textureowner then
  begin
    if Assigned(_Animations) then
      _Animations.Free;
    if texture <> nil then
      tex_Del(texture);
  end;
  Dispose(_rectangle);
end;

function TSZAnimated.GeTSZAnimation(Name: string): TSZAnimation;
var
  animation : TSZAnimation;
begin
  for animation in _Animations do
  begin
    if animation.Name = Name then
    begin
      result := animation;
      Break;
    end;
  end;
end;

function TSZAnimated.GeTSZAnimations: TSZAnimationList;
begin
  Result := _Animations;
end;

procedure TSZAnimatedSprite.Draw;
begin
  if Assigned(Self) then
  begin
    if _alpha < 0 then
      _alpha := 0;
    if not _notTexture then
    begin
      if _flip then
        asprite2d_Draw(texture, _rectangle.X, _rectangle.Y, _rectangle.W, _rectangle.H, _angle,
          Round(_frame), _alpha, FX_BLEND or FX2D_FLIPX)
      else
        asprite2d_Draw(texture, _rectangle.X, _rectangle.Y, _rectangle.W, _rectangle.H, _angle,
          Round(_frame), _alpha, FX_BLEND);
    end;
  end;
end;

procedure TSZAnimatedSprite.Input;
begin
  MouseEvents;
end;

procedure TSZAnimatedSprite.Process;
begin
  ProcessOpacity;
  ProcessAnimation;
end;

constructor TSZAnimatedBackground.Create(ImagePath: string;
  Spritebatch: TSZSpriteBath; X: Integer; Y: Integer; W: Integer; H: Integer;
  FrameH: Integer; FrameW: Integer; Name: string = '';
  LoadTextureNow: Boolean = False; unlimited: Boolean = True);
begin
  inherited Create(ImagePath, Spritebatch, X, Y, W, H, FrameH, FrameW, Name,
    LoadTextureNow);
  _rectangle2.X := W;
  _rectangle2.W := W;
  _rectangle2.H := H;
  _rectangle2.Y := Y;
  _unlimited := unlimited;
  new(_cameraback);
  cam2d_Init(_cameraback^);
end;

procedure TSZAnimatedBackground.Draw;
begin
  cam2d_Set(_cameraback);
  if not _notTexture then
  begin
    ssprite2d_Draw(texture, _rectangle.X, _rectangle.Y, _rectangle.W,
      _rectangle.H, _angle, 255);
    if _unlimited then
    begin
      ssprite2d_Draw(texture, _rectangle2.X, _rectangle2.Y, _rectangle.W,
        _rectangle.H, _angle, 255);
    end;
  end;
  cam2d_Set(nil);
end;

procedure TSZAnimatedBackground.Process;
begin
  ProcessOpacity;
  ProcessAnimation;
end;

procedure TSZAnimatedBackground.Input;
begin
  MouseEvents;
end;

{ TBlinkAnimation }

constructor TSZBlinkAnimation.Create(Speed: Single; Loop: Boolean = True; Name : string = '');
begin
  _name := Name;
  _speed := Speed;
  _loop := Loop;
  _alpha := 255;
  _fadeout := True;
end;

procedure TSZBlinkAnimation.ProcessAnimation;
begin
  if _fadein and not _fadeout then
  begin
    if _alpha < 255 then
    begin
      Inc(_alpha, 4);
      if _alpha > 255 then
        _alpha := 255;
      if Assigned(OnProcess) then
        OnProcess(Self);
    end
    else
    begin
      if _loop then
      begin
        _fadein := False;
        _fadeout := True;
      end;
    end;
  end;
  if _fadeout and not _fadein then
  begin
    if _alpha > 1 then
    begin
      Dec(_alpha, 4);
      if _alpha < 0 then
        _alpha := 0;
      if Assigned(OnProcess) then
        OnProcess(Self);
    end
    else
    begin
      if _loop then
      begin
        _fadein := True;
        _fadeout := False;
      end;
    end;
  end;
end;

procedure TSZBlinkAnimation.Restart;
begin
  _alpha := 255;
  _fadeout := True;
  _finished := false;
end;

{ TSZEvent }

constructor TSZEvent.Create;
begin
  inherited;
  Running := False;
end;

{ TSpriteFont }

constructor TSZSpriteFont.Create(fontPath, texturePath: string;
  Spritebatch: TSZSpriteBath; Name: string);
begin
  inherited Create(texture, Name);
  _textureFilename := texturePath;
end;

constructor TSZSpriteFont.Create(fontPath: string; texture: zglPTexture;
  Spritebatch: TSZSpriteBath; Name: string);
begin
  //
end;

procedure TSZSpriteFont.Draw;
begin
  inherited;
end;

procedure TSZSpriteFont.Input;
begin
  MouseEvents;
end;

procedure TSZSpriteFont.LoadFont(Path: string);
var
  filefont: file of TSZSpriteFontFile;
  i: Integer;
begin
  try
    AssignFile(filefont, 'Path');
    try
      i := 1;
      while not EOF(filefont) do
      begin
        Read(filefont, fspritefont);
        Inc(i);
      end;
    finally
      CloseFile(filefont);
    end;
  except
    raise Exception.Create('Error opening font file');
  end;
end;

procedure TSZSpriteFont.Loadtexture;
begin
  inherited;
end;

procedure TSZSpriteFont.Process;
begin
  inherited;
end;

{ TSquare }

procedure TSZSquare.Draw;
begin
  if _alpha < 0 then _alpha := 0;
  if _alpha > 255 then _alpha := 255;
  if _filled then pr2d_Rect(Rect.X, Rect.Y, Rect.W, Rect.H, FillColor, _alpha, PR2D_FILL)
  else pr2d_Rect(Rect.X, Rect.Y, Rect.W, Rect.H, FillColor, _alpha);
end;

{ TPrimitive }

constructor TSZPrimitive.Create(Spritebatch: TSZSpriteBath; Name : string);
begin
  inherited Create('', Name);
  _alpha := 255;
  _noneedtexture := True;
  _rectangle.X := 0 + Spritebatch.Rectangle.X + Spritebatch._camera.X;
  _rectangle.Y := 0 + Spritebatch.Rectangle.Y + Spritebatch._camera.Y;
  _rectangle.W := 0;
  _rectangle.H := 0;
end;

constructor TSZPrimitive.Create(Spritebatch: TSZSpriteBath; X, Y, W, H: Integer; Name: string);
begin
  inherited Create('', Name);
  _alpha := 255;
  _noneedtexture := True;
  _rectangle.X := X + Spritebatch.Rectangle.X + Spritebatch._camera.X;
  _rectangle.Y := Y + Spritebatch.Rectangle.Y + Spritebatch._camera.Y;
  _rectangle.W := W;
  _rectangle.H := H;
end;

destructor TSZPrimitive.Destroy;
begin
  inherited;
end;

procedure TSZPrimitive.Input;
begin
  MouseEvents;
end;

procedure TSZPrimitive.Process;
begin
  ProcessOpacity;
end;

procedure TSZPrimitive._fillcolor(Color : Cardinal);
begin
  _color := Color;
  _filled := True;
end;

{$IFNDEF FPC}

{ TBMFFont }

function TBMFFont.rgbvalue(i:byte):longint;
begin
  result:=rgb[i].b shl 24 or rgb[i].g shl 16 or rgb[i].r shl 8 or 255;
end;


function TBMFFont.GenerateTexture: zglPTexture;
var
  i,j,k,x,y : integer;
  bmchar : TBmChar;
  currentchar : AnsiChar;
  a : PByteArray;
  colore : Integer;
  memorylen : Integer;
  currentwidth : Integer;
  maxh : integer;
begin
  // w := Length(tablo) * 32;
  // Allocate texture pointer memory RGBA array Height * Width * 4 Bytes
  currentwidth := 0;
  maxh := 0;
  a := GetMemory((5200 * 5200) * 4);
//  for currentchar := 'A' to 'Y' do
//  begin
//    begin
//      Inc(currentwidth, tablo[currentchar].w);
//      maxh := max(tablo[currentchar].h, maxh);
//      for y := 0 to tablo[currentchar].h do
//        for x := 0 to tablo[currentchar].w do
//        begin
//          a^[(y * (currentwidth + tablo[currentchar].w) + x) * 4 + 0] := rgb[(byte(system.ptr(integer(tablo[currentchar].d) + y * tablo[currentchar].w + x)^))].r;
//          a^[(y * currentwidth + x) * 4 + 1] := rgb[(byte(system.ptr(integer(tablo[currentchar].d) + y * tablo[currentchar].w + x)^))].g;
//          a^[(y * currentwidth + x) * 4 + 2] := rgb[(byte(system.ptr(integer(tablo[currentchar].d) + y * tablo[currentchar].w + x)^))].b;
//          //if (a^[(y * tablo[currentchar].w + x) * 4 + 0] or a^[(y * tablo'[currentchar].w + x) * 4 + 1] or a^[(y * tablo[currentchar].w + x) * 4 + 2]) = 255 then a^[(y * tablo[currentchar].w + x) * 4 + 3] := 255
//          a^[(y * currentwidth + x) * 4 + 3] := 255;
//        end;
//    end;
//  end;
  currentchar := 'A';
  Inc(currentwidth, tablo[currentchar].w);
  maxh := max(tablo[currentchar].h, maxh);
  for y := 0 to tablo[currentchar].h do
    for x := 0 to tablo[currentchar].w do
    begin
      a^[(y * currentwidth + x) * 4 + 0] := rgb[(byte(system.ptr(integer(tablo[currentchar].d) + y * tablo[currentchar].w + x)^))].r;
      a^[(y * currentwidth + x) * 4 + 1] := rgb[(byte(system.ptr(integer(tablo[currentchar].d) + y * tablo[currentchar].w + x)^))].g;
      a^[(y * currentwidth + x) * 4 + 2] := rgb[(byte(system.ptr(integer(tablo[currentchar].d) + y * tablo[currentchar].w + x)^))].b;
      //if (a^[(y * tablo[currentchar].w + x) * 4 + 0] or a^[(y * tablo[currentchar].w + x) * 4 + 1] or a^[(y * tablo[currentchar].w + x) * 4 + 2]) = 255 then a^[(y * tablo[currentchar].w + x) * 4 + 3] := 255
      a^[(y * currentwidth + x) * 4 + 3] := 255;
    end;
  Result := tex_Create(zglheader.PByteArray(a), currentwidth, maxh, TEX_FORMAT_RGBA);
  Exit;
end;


function TBMFFont.LoadBMF(path : UTF8String) : Boolean;
var
  f : file;
  c : AnsiChar;
  i : SmallInt;
  s : AnsiString;
  rgbentries : Byte;
  fontinfo : AnsiString;
  infolen : Byte;
  magickey : AnsiString;
  bmfver : Byte;
  ignorebytes : integer;
begin
//  BMF Data Structure
//  0	4	magic header (its hexa dump is: E1 E6 D5 1A)
//  4	1	version (currently 11h)
//  5	1	line-height
//  6	1	size-over the base line (-128..127)
//  7	1	size-under the base line(-128..127)
//  8	1	add-space after each char (-128..127)
//  9	1	size-inner (non-caps level) (-128..127)
//  10	1	count of used colors (should be <= 32)
//  11	1	highest used color attribute
//  12	4	reserved
//  16	1	number of RGB entries (P)
//  17	P*3	font palette (RGB bytes, 63=max)
//  17+P*3	1	info length (L)
//  18+P*3	L	info string
//  19+P*3+L	2	number of characters in font
//  20+P*3+L	?	list of bitmap character definitions [whichchar,entry, data]

  //We assigned the file
  assignfile(f,path);
  //Filemode to read
  FileMode:=0;
  //Reset file to first byte
  reset(f, 1); // 0
  //Allocate 4 Bytes string buffer memory
  SetLength(magickey, 4);
  //Read 4 Bytes and store to buffer
  blockread(f,magickey[1],4); // 4
  //Compare if string buffer has the magic header
  if magickey = BMFHEADER then
  begin
    //Read 1 Byte BMF version
    blockread(f,bmfver,1); // 5
    //Read 1 Byte line-height
    blockread(f,lineheight,1); // 6
    //Read 1 Byte size-over
    blockread(f,sizeover,1); // 7
    //Read 1 Byte size-under
    blockread(f,sizeunder,1); // 8
    //Read 1 Byte addspace
    blockread(f,addspace,1); // 9
    //Read 1 Byte size-inner
    blockread(f,sizeinner,1); // 10
    //Read 1 Byte usedcolors
    blockread(f,usedcolors,1); // 11
    //Read 1 Byte highest color
    blockread(f,highestcolor,1); // 12
    //Read and ignore Reserved 4 Bytes
    blockread(f,ignorebytes,4); // 16
    //Read 1 Byte number RGB entries and store to string first char
    BlockRead(f,rgbentries,1); // 17
    //Read 3 bytes * RGB entries (P)
    for i:=0 to pred(rgbentries) do
    begin
      // Populate RGB 3 Bytes
      blockread(f,rgb[i],3);
      //Left first R byte
      rgb[i].r:=rgb[i].r shl 2+3;
      //Left second G Byte
      rgb[i].g:=rgb[i].g shl 2+3;
      //Left third B Byte
      rgb[i].b:=rgb[i].b shl 2+3;
    end;
    //17 + P * 3
    //Read 1 byte info length (L)
    blockread(f,infolen,1);
    //18 + P * 3
    //Read I bytes to info string
    while infolen > 0 do
    begin
      //Read 1 char byte
      blockread(f,c,1);
      //Add to info string
      infostring:=infostring + c;
      //Dec iterator
      dec(infolen);
    end;
    //19+P*3+L	2	number of characters in font
    //Read 2 bytes to font char count
    blockread(f,charcount,2);
    i := charcount;
    //  20+P*3+L	?	list of bitmap character definitions [whichchar,entry, data]
    for i := pred(i) downto 0 do
    begin
      //      -1	1	which character
      //      0	1	character width (W)
      //      1	1	character height (H)
      //      2	1	relx – horizontal offset according to cursor (-128..127)
      //      3	1	rely – vertical offset according to cursor (-128..127)
      //      4	1	horizontal cursor shift after drawing the character
      //      5	W * H	character data itself (uncompressed, 8 bits per pixel)
      //Read 1 byte what char is
      blockread(f,c,1);
      //Read 5 bytes populate structure record
      blockread(f,tablo[c],5);
      with tablo[c] do
        if w or h<>0 then
        begin
          getmem(d, w * h); //Get w*h buffer to memory pointer
          blockread(f,d^, w * h); //read w*h to memory pointer
        end;
    end;
    Result := True;
  end;
  closefile(f);
end;
{$ENDIF}

{ TSimpleColorBackground }

constructor TSZSimpleColorBackground.Create(Color : Cardinal; Spritebatch: TSZSpriteBath; X, Y, W, H: Integer; Name: string = ''; unlimited: Boolean = True);
begin
  inherited Create('', Name);
  _color := Color;
  _alpha := 255;
  _noneedtexture := True;
  _rectangle.X := 0 + Spritebatch.Rectangle.X + Spritebatch._camera.X + x;
  _rectangle.Y := 0 + Spritebatch.Rectangle.Y + Spritebatch._camera.Y + y;
  _rectangle.W := w;
  _rectangle.H := h;
end;

procedure TSZSimpleColorBackground.Draw;
begin
  cam2d_Set(_cameraback);
  if not _notTexture then
  begin
    pr2d_Rect(_rectangle.X, _rectangle.Y, _rectangle.W, _rectangle.H, _color, _alpha, PR2D_FILL);
    if _unlimited then
    begin
      pr2d_Rect(_rectangle2.X, _rectangle2.Y, _rectangle2.W, _rectangle2.H, _color, _alpha);
    end;
  end;
  cam2d_Set(nil);
end;

procedure TSZSimpleColorBackground.Input;
begin
  //
end;

procedure TSZSimpleColorBackground.Process;
begin
  ProcessOpacity;
  ProcessAnimation;
end;


{ TCustomAnimation }

procedure TSZCustomAnimation.ProcessAnimation;
begin
  if Assigned(OnProcess) then
    OnProcess(Self);
end;

procedure TSZCustomAnimation.Restart;
begin
  //
end;

{ TLine }

procedure TSZLine.Draw;
begin
  if _visible then
  begin
  end;
end;

{ TMap }

constructor TSZMap.Create(Spritebatch : TSZSpriteBath; MapPath: UTF8String);
begin
  if FileExists(MapPath) then
  begin
    try
      LoadFromFile(MapPath);
    except
      raise Exception.Create('No map found');
    end;
  end;
end;

procedure TSZMap.Draw;
begin

end;

procedure TSZMap.LoadFromFile(const Path: UTF8String);
var
  F: zglTFile;
  Y: Integer;
  X: Integer;
  TexLen: Cardinal;
  HeaderLength: Cardinal;
  Header: UTF8String;
  FileLen: Integer;
  TtipoLen: Integer;
begin
  if file_Open(F, Path, FOM_OPENR) then
  begin
    FileLen := file_GetSize(F);
    // Cargamos los encabezados, nos daran info del mapa
    file_Read(F, HeaderLength, SizeOf(HeaderLength));
    SetLength(Header, HeaderLength);
    file_Read(F, Pointer(Header)^, HeaderLength);
    // Header Info
    // First Header
    // file_Read(f ,Header, Length('Turrican Map File') * SizeOf(Char));
    // 0..32 Mapa Count X
    file_Read(F, Self.map.Count.X, SizeOf(Integer));
    // 32..64 Mapa Count Y
    file_Read(F, Self.map.Count.Y, SizeOf(Integer));
    // 64..96 Mapa Width
    file_Read(F, Self.map.Size.W, SizeOf(Integer));
    // 96..128 Mapa Height
    file_Read(F, Self.map.Size.H, SizeOf(Integer));
    // 128..164 Tile Width
    file_Read(F, Self.TileW, SizeOf(Integer));
    // 164..196 Tile Height
    file_Read(F, Self.TileH, SizeOf(Integer));
    // Dimensionar el ARRAY dinámico de las TILES
    SetLength(Self.map.Tiles, Self.map.Count.X, Self.map.Count.Y);
    SetLength(Self.mapTexture.Tiles, Self.map.Count.X,
      Self.map.Count.Y);
    // Map Data
    for X := 0 to Self.map.Count.X - 1 do
    begin
      file_Read(F, Self.map.Tiles[X, 0], Self.map.Count.Y *
        SizeOf(Cardinal));
    end;
    // Texture type count
    file_Read(F, TtipoLen, SizeOf(TtipoLen));
    SetLength(Self.TipoTextura, TtipoLen);
    file_Read(F, Pointer(Self.TipoTextura)^,
      TtipoLen * SizeOf(TSZTextureType));
    {// Bitmap Load Count
    file_Read(F, Buffermap.bitmapCount, SizeOf(Integer));
    // Redim Bitmap Array
    SetLength(Buffermap.texBitmap, Buffermap.bitmapCount);
    // Bitmap Store Array
    for X := 0 to High(Buffermap.texBitmap) do
    begin
      // Load Bitmap Size
      file_Read(F, TexLen, SizeOf(Cardinal));
      Buffermap.texBitmap[X].Size := TexLen;
      Buffermap.texBitmap[X].Position := 0;
      // Allocate Bitmap Memory
      GetMem(Buffermap.texBitmap[X].Memory, TexLen);
      // Load Bitmap Data
      file_Read(F, Buffermap.texBitmap[X].Memory^, TexLen);
    end;}
    file_Read(F, TexLen, SizeOf(Cardinal));
    Self.texBitmap.Size := TexLen;
    Self.texBitmap.Position := 0;
    // Allocate Bitmap Memory
    GetMem(Self.texBitmap.Memory, TexLen);
    // Load Bitmap Data
    file_Read(F, Self.texBitmap.Memory^, TexLen);
    file_Close(F);
  end;
end;

procedure TSZMap.SaveToFile(const Path: UTF8String);
var
  F: zglTFile;
  Y: Integer;
  X: Integer;
  Z: Integer;
  TexLen: LongWord;
  HeaderLength: Cardinal;
  TtipoLen: Integer;
  HeaderName: UTF8String;
begin
  if not file_Exists(Path) then
    file_Open(F, Path, FOM_CREATE)
  else
    file_Open(F, Path, FOM_OPENRW);
  // Salvamos los encabezados, nos daran info del mapa
  // Header Info
  // First Header
  HeaderName := 'SZ Map File';
  HeaderLength := Length(HeaderName);
  file_Write(F, HeaderLength, SizeOf(HeaderLength));
  file_Write(F, Pointer(HeaderName)^, HeaderLength);
  // 0..32 Mapa Count X
  file_Write(F, Self.map.Count.X, SizeOf(Integer));
  // 32..64 Mapa Count Y
  file_Write(F, Self.map.Count.Y, SizeOf(Integer));
  // 64..96 Mapa Width
  file_Write(F, Self.map.Size.W, SizeOf(Integer));
  // 96..128 Mapa Height
  file_Write(F, Self.map.Size.H, SizeOf(Integer));
  // 128..164 Tile Width
  file_Write(F, Self.TileW, SizeOf(Integer));
  // 164..196 Tile Height
  file_Write(F, Self.TileH, SizeOf(Integer));
  // Map Data
  // Tiles
  for X := 0 to Self.map.Count.X - 1 do
  begin
    file_Write(F, Pointer(Self.map.Tiles[X])^, Self.map.Count.Y *
      SizeOf(Cardinal));
  end;
  // Texture tile type count
  TtipoLen := High(Self.TipoTextura) + 1;
  file_Write(F, TtipoLen, SizeOf(TtipoLen));
  // Texture tile type
  file_Write(F, Pointer(Self.TipoTextura)^,
    TtipoLen * SizeOf(TSZTextureType));
  // Bitmap Store Count
  {file_Write(F, Buffermap.bitmapCount, SizeOf(Integer));}
  // Bitmap Store Array
  {for X := 0 to High(Buffermap.texBitmap) do
  begin
    // Store Bitmap Size
    Buffermap.texBitmap[X].Position := 0;
    TexLen := Buffermap.texBitmap[X].Size;
    file_Write(F, TexLen, SizeOf(Cardinal));
    // Store Bitmap Data
    file_Write(F, Buffermap.texBitmap[X].Memory^, TexLen);
  end;}
  // Bitmap Store Size
  Self.texBitmap.Position := 0;
  TexLen := Self.texBitmap.Size;
  file_Write(F, TexLen, SizeOf(Cardinal));
  // Store Bitmap Data
  file_Write(F, Self.texBitmap.Memory^, TexLen);
  file_Close(F);
end;

//procedure TMap.Update;
//begin
//  inherited;
//
//end;

end.
