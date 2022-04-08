{$I Compiler.inc}
unit TextApp;

interface

uses
  Objects,
  Controls,
  Crt,
  Collects,
  Apps,
  TextDrv,
  TextIni,
  Drawing,
  MouseDrv,
  KeyDrv,
  Utils;

type
  PTextApplication = ^TTextApplication;
  TTextApplication = object(TApplication)
  private
    _oldMouseState: TMouseState;
    _mouseHandled: boolean;
    _keyHandled: boolean;
    _mouseVisible: boolean;
    _mouseX: integer;
    _mouseY: integer;
  public
    Desktop: PDesktop;
    procedure InitTextDriver(driver: TTextDrivers; modeId: string);
    procedure ProcessEvents; virtual;
    procedure Init; virtual;
    procedure Run; virtual;
    procedure MainLoop; virtual;
    destructor Done; virtual;
  end;

implementation

procedure TTextApplication.Init;
var
  mouseState: TMouseState;
begin
  TApplication.Init;
  TypeName := 'TTextApplication';
  _mouseHandled := false;
  _keyHandled := false;
  Desktop := New(PDesktop, CreateParent('Desktop', nil));
  _mouseVisible := true;
  _mouseX := 0;
  _mouseY := 0;
  FillChar(_oldMouseState, SizeOf(TMouseState), 0);
end;

procedure TTextApplication.InitTextDriver(driver: TTextDrivers; modeId: string);
var
  factory: TTextDriverFactory;
  modeIndex: integer;
  mode: PTextMode;
begin
  factory.CreateTextDriver(driver, TextDriver);
  modeIndex := TextDriver.Modes.IndexOfId(modeId);
  if (modeIndex < 0) then
  begin
    CreateError(TextDriver.Error, ecTextModeNotFound, esError);
    exit;
  end;
  mode := TextDriver.Modes.GetItem(modeIndex);
  TextDriver.SetMode(mode^);
end;

procedure TTextApplication.ProcessEvents;
var
  ch: char;
  mouseState: TMouseState;
  rect: TRect;
begin
  GetMouseState(mouseState);
  _mouseX := mouseState.X;
  _mouseY := mouseState.Y;
  if not Equal(mouseState, _oldMouseState, SizeOf(TMouseState)) then
  begin
    Desktop^.ProcessMouse(mouseState, _oldMouseState, _mouseHandled);
    _oldMouseState := mouseState;
  end;
  if (KeyPressed) then
  begin
    ch := ReadKey;
    if (ch = #27) then Close;
  end;
end;

procedure TTextApplication.Run;
var
  mouseState: TMouseState;
begin
  GetMouseState(mouseState);
  _oldMouseState := mouseState;
  _mouseX := mouseState.X;
  _mouseY := mouseState.Y;
  TApplication.Run;
end;

procedure TTextApplication.MainLoop;
begin
  _mouseHandled := false;
  _keyHandled := false;
  TApplication.MainLoop;
end;

destructor TTextApplication.Done;
begin
  TApplication.Done;
  Dispose(Desktop, Done);
  TextDriver.Done;
end;

end.