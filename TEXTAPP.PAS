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
    _mouseHandled: boolean;
    _keyHandled: boolean;
  public
    Desktop: PDesktop;
    procedure InitTextDriver(driver: TTextDrivers; modeId: string);
    procedure InitDefaultColors; virtual;
    procedure ProcessEvents; virtual;
    procedure Init; virtual;
    procedure Run; virtual;
    procedure MainLoop; virtual;
    destructor Done; virtual;
  end;

implementation

procedure TTextApplication.InitDefaultColors;
begin
  icDesktop := White;
  icDesktopBack := Green;
  icWindow := LightCyan;
  icWindowBack := Black;
  icBorder := LightCyan;
  icButton := Black;
  icButtonBack := Cyan;
  icButtonDown := White;
  icButtonDownBack := Green;
  icButtonHotKey := LightRed;
  icWindowTitle := Black;
  icWindowTitleBack := Cyan;
  icMenu := Black;
  icMenuBack := LightGray;
  icHotKey := LightRed;
  icScroll := Black;
  icScrollBack := Cyan;
  icEditor := Yellow;
  icEditorBack := Black;
  icDialog := Black;
  icDialogBack := Cyan;
  icSelect := White;
  icSelectBack := Green;
  icFocused := Green;
end;

procedure TTextApplication.Init;
var
  mouseState: TMouseState;
begin
  TApplication.Init;
  TypeName := 'TTextApplication';
  _mouseHandled := false;
  _keyHandled := false;
  Desktop := New(PDesktop, CreateParent('Desktop', nil));
  Desktop^.MouseState.Visible := true;
  Desktop^.MouseStack.Create('MouseStack');
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
  InitDefaultColors;
end;

procedure TTextApplication.ProcessEvents;
var
  ch: char;
  mouseState: TMouseState;
  rect: TRect;
begin
  GetMouseState(mouseState);
  Desktop^.MouseState.X := mouseState.X;
  Desktop^.MouseState.Y := mouseState.Y;
  if Desktop^.MouseState.Moved(Desktop^.OldMouseState) then
  begin
    Desktop^.ProcessMouse(mouseState, Desktop^.OldMouseState, _mouseHandled);
    Desktop^.OldMouseState := mouseState;
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
  Desktop^.OldMouseState := mouseState;
  Desktop^.MouseState.X := mouseState.X;
  Desktop^.MouseState.Y := mouseState.Y;
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