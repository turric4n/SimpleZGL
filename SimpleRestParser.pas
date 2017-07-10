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
         

nit SimpleRestParser;

interface

uses
  SysUtils,
  SynCommons,
  mORMot,
  SynCrtSock,
  {$IFnDEF FPC}
  IdHTTP,
  IdSSL,
  IdSSLOpenSSL,
  IdMultipartFormData,
  IdCompressorZLib,
  {$ENDIF}
  Classes,
  {$IFnDEF FPC}
    JSON,
    jsondoc,
    Contnrs,
    WideStrUtils;
  {$ELSE}
    contnrs,
    fphttpclient;
  {$ENDIF}
Type

  ThreadState = (stIdle = 0, stFetching, stFailed, stParsingJSON);

  TMethodType = (stGet = 0, stPost, stDelete);

  TListParseResults = TObjectList;

  //Events
  TOnGet = procedure(aSender: TObject) of object;
  TOnParse = procedure(aSender: TObject) of object;
  TOnPost = procedure(aSender: TObject) of object;
  TOnErrors = procedure(aSender: TObject; aException: Exception) of object;
  TOnLog = procedure(aText: string) of object;
  TCoreParseFinished = procedure(aSender: TObject) of object;

  TRestParser = class(TThread)
  private
    {$IFnDEF FPC}
    qHTTP : TIdHTTP;
    qGZip : TIdCompressorZLib;
    qSSLHandler : TIdSSLIOHandlerSocketOpenSSL;
    {$ELSE}
    qHTTP : TFPHttpClient;
    {$ENDIF}
    pDataPost: TStream;
    qJSONResult: UTF8String;
    fvalidjson: Boolean;
    fjsonclass: TClass;
    fasync: Boolean;
    fOnGet: TOnGet;
    fOnErrors: TOnErrors;
    fOnLog: TOnLog;
    fOnParse: TOnParse;
    fOnPost: TOnPost;
    fOnfinished: TCoreParseFinished;
    function Get(url : string) : Boolean;
    function Post(url : string) : Boolean;
    function Delete(url: string) : Boolean;
  public
    SendDateTimeAsExtended : Boolean;
    PostData : string;
    ParseResults : TListParseResults;
    LastError: string;
    Method: TMethodType;
    Status: ThreadState;
    URL: string;
    Connected: Boolean;
    Failed: Boolean;
    Error: string;
    IsFinished : Boolean;
    DebugMode : Boolean;
    property OnGet: TOnGet read fOnGet write fOnGet;
    property OnLog: TOnLog read fOnLog write fOnLog;
    property OnErrors: TOnErrors read fOnErrors write fOnErrors;
    property OnParse: TOnParse read fOnParse write fOnParse;
    property OnPost: TOnPost read fOnPost write fOnPost;
    property OnFinished: TCoreParseFinished read fOnfinished write fOnfinished;
    constructor Create(Suspended: Boolean; JSONClass: TClass; ASync: Boolean);
    destructor Destroy; override;
    procedure Execute; override;
    procedure Clear;
    class function GetString(aURL: string): string;
  end;

implementation

function BoolToStrEx(cBoolean : Boolean) : string;
begin
  if cBoolean then Result := 'True'
    else Result := 'False';
end;

class function TRestParser.GetString(aURL: string) : string;
begin
  {$IFnDEF FPC}
  with TIdHTTP.Create(nil) do
  begin
    Result:=Get(aURL);
    Free;
  end;
  {$ELSE}
  with TFPHttpClient.Create(nil) do
  begin
    Result:=Get(aURL);
    Free;
  end;
  {$ENDIF}
end;


constructor TRestParser.Create(Suspended : Boolean; JSONClass: TClass; Async: Boolean);
Begin
  inherited Create(Suspended);
  FreeOnTerminate:=True;
  SendDateTimeAsExtended := True;
  IsFinished := False;
  DebugMode := False;
  fasync:=ASync;
  ParseResults:=TObjectList.Create(true);
  fjsonclass:=JSONClass;
  {$IFnDEF FPC}
  qSSLHandler:=TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  qHTTP:=TIdHTTP.Create(nil);
  qGZip := TIdCompressorZLib.Create(nil);
  qHTTP.Compressor := qGZip;
  {$ELSE}
  qHTTP:=TFPHttpClient.Create(nil);
  {$endif}
  PostData:='';
End;

destructor TRestParser.Destroy;
Begin
  {$IFnDEF FPC}
  qHTTP.Free;
  qSSLHandler.Free;
  qGZip.Free;
  {$ELSE}
  qHTTP.Free;
  {$endif}
  ParseResults.Free;
  inherited;
End;

procedure TRestParser.Execute;
begin
  case Method of
    stGet :
    begin
      if Get(URL) then
      begin
        Status:=stParsingJSON;
        JSONToObject(ParseResults, Pointer(qJSONResult), fvalidjson, fjsonclass, [TJSONToObjectOption.j2oIgnoreUnknownProperty]);
      end
      else Exit;
    end;
    stPost : Post(URL);
    stDelete : Delete(URL);
  end;
  ReturnValue := 1;
  IsFinished := True;
  if Assigned(fOnfinished) then fOnfinished(Self);
  if not fasync then OnTerminate(Self);
end;

function TRestParser.Get(url : string) : Boolean;
var
  IsSSL : Boolean;
  {$IFDEF FPC}
  stream: TStringStream;
  temp: string;
  {$endif}
Begin
  if Assigned(fOnGet) then fOnGet(Self);
  Status:=stFetching;
  If Pos('https://',url)>0 Then IsSSL:=True
    else IsSSL:=False;
  Try
    //qHTTP.Request.CharSet:='utf-8';
    //qHTTP.Request.AcceptCharSet := 'utf-8';
    {$IFnDEF FPC}
    qhttp.Request.Accept:='application/json';
    If IsSSL Then qHTTP.IOHandler:=qSSLHandler;
    qJSONResult:=qHTTP.Get(url);
    {$ELSE}
    qJSONResult:=qhttp.Get(url);
    {$ENDIF}
    Result := True;
  Except
    On E : Exception do
    Begin
      LastError:=e.Message;
      if Assigned(fOnErrors) then fOnErrors(Self, e);
      Result:=False;
    End;
  End;
End;

function TRestParser.Post(url: string) : Boolean;
var
  jsonresult : string;
  IsSSL : Boolean;
begin
  Status:=stFetching;
  LastError:='';
  PostData:='{' + PostData + '}';
  If pDataPost <> nil then pDataPost.Free;
  pDataPost:=TStringStream.Create(PostData);
  Try
    If Pos('https://',url)>0 Then IsSSL:=True
      else IsSSL:=False;
    Try
      If IsSSL Then
      Begin
        {$IFnDEF FPC}
        qHTTP.IOHandler:=qSSLHandler;
        qSSLHandler.Open;
        {$endif}
      end;
      {$IFnDEF FPC}
      qHTTP.Request.ContentType:='application/json';
      qHTTP.Request.CharSet:='utf-8';
      if pDataPost <> nil then LastError := qHTTP.Post(url, pDataPost);
      {$endif}
      Result:=True;
    Except
      On E : Exception do
      Begin
        Result:=False;
        LastError:=e.Message;
      End;
    End;
  Finally
    pDataPost.Free;
  End;
end;

function TRestParser.Delete(url: string) : Boolean;
var
  jsonresult : string;
  IsSSL : Boolean;
begin
  Status:=stFetching;
  LastError:='';
  Result := False;
  If Pos('https://',url)>0 Then IsSSL:=True
    else IsSSL:=False;
  Try
    If IsSSL Then
    Begin
      {$IFnDEF FPC}
      qHTTP.IOHandler:=qSSLHandler;
      qSSLHandler.Open;
      {$endif}
    End;
    {$IFnDEF FPC}
    qHTTP.Request.ContentType:='application/json';
    qHTTP.Request.CharSet:='utf-8';
    if url <> '' then qHTTP.Delete(url);
    {$endif}
    Result:=True;
  Except
    On E : Exception do
    Begin
      LastError:=e.Message;
    End;
  End;
end;

procedure TRestParser.Clear;
Begin
  PostData:='';
End;


end.
