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
  GraphDrv,
  KeyDrv,
  Utils;

type
  TMouseCursorImage = array[0..12, 0..9] of byte;
  PMouseCursor = ^TMouseCursor;
  TMouseCursor = object(TBaseObject)
  private
    _image: TMouseCursorImage;
    _width, _height: word;
    _visible: boolean;
    _x, _y: integer;
  public
    BackData: PByte;
    procedure Draw; virtual;
    procedure Init; virtual;
    destructor Done; virtual;
    function Width: integer; virtual;
    function Height: integer; virtual;
    procedure StoreBackground(var mouseState: TMouseState); virtual;
  end;
  PTextApplication = ^TTextApplication;
  TTextApplication = object(TApplication)
  private
    _oldMouseState: TMouseState;
    _mouseHandled: boolean;
    _keyHandled: boolean;
    _mouseCursor: TMouseCursor;
    _mouseVisible: boolean;
  public
    Desktop: PDesktop;
    MenuBar: PMenuBar;
    procedure InitTextDriver(driver: TTextDrivers; modeId: string);
    procedure InitDefaultColors; virtual;
    procedure InitControls;
    procedure ProcessEvents; virtual;
    procedure Init; virtual;
    procedure Run; virtual;
    procedure MainLoop; virtual;
    destructor Done; virtual;
    procedure ShowMouseCursor; virtual;
    procedure HideMouseCursor; virtual;
  end;

implementation

const
  DefaultMouseCursor: TMouseCursorImage =
  (
    ($27, $01, $01, $01, $01, $01, $01, $01, $01, $01),
    ($27, $27, $01, $01, $01, $01, $01, $01, $01, $01),
    ($27, $00, $27, $01, $01, $01, $01, $01, $01, $01),
    ($27, $00, $00, $27, $01, $01, $01, $01, $01, $01),
    ($27, $00, $00, $00, $27, $01, $01, $01, $01, $01),
    ($27, $00, $00, $00, $00, $27, $01, $01, $01, $01),
    ($27, $00, $00, $00, $00, $00, $27, $01, $01, $01),
    ($27, $00, $00, $00, $00, $00, $00, $27, $01, $01),
    ($27, $00, $00, $00, $00, $00, $00, $00, $27, $01),
    ($27, $00, $00, $27, $27, $27, $27, $27, $27, $27),
    ($27, $00, $27, $01, $01, $01, $01, $01, $01, $01),
    ($27, $27, $01, $01, $01, $01, $01, $01, $01, $01),
    ($27, $01, $01, $01, $01, $01, $01, $01, $01, $01)
  );

procedure TTextApplication.InitDefaultColors;
begin
  TextDriver.BppMode := 4;
  icDesktop := White;
  icDesktopBack := LightGreen;
  icWindow := LightCyan;
  icWindowBack := Black;
  icBorder := Black;
  icButton := Black;
  icButtonBack := Cyan;
  icButtonDown := White;
  icButtonDownBack := Green;
  icButtonHotKey := LightRed;
  icWindowTitle := Black;
  icWindowTitleBack := Cyan;
  icMenu := Black;
  icMenuBack := White;
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

procedure TTextApplication.InitControls;
begin
  with Desktop^ do begin
    SetBounds(0, 0, TextDriver.Mode.Width, TextDriver.Mode.Height);
    ForeColor := icDesktop;
    BackColor := icDesktopBack;
    SetupControls;
  end;
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
  Desktop^.MouseStack.Create;
  _mouseCursor.Create;
  _mouseVisible := true;
  InitControls;
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
  MouseDriver.GetMouseState(mouseState);
  _mouseCursor._X := mouseState.X;
  _mouseCursor._Y := mouseState.Y;
  if not mouseState.Equals(_oldMouseState) then
  begin
    Graphics.PushState;
    Graphics.SetBackColor(Desktop^.BackColor);
    if (_mouseCursor.BackData <> nil) then begin
      Graphics.DrawImage(_oldMouseState.X, _oldMouseState.Y,
        _mouseCursor.Width, _mouseCursor.Height, _mouseCursor.BackData);
    end;
    _oldMouseState.Assign(mouseState);
    Desktop^.ProcessMouse(mouseState, _oldMouseState, _mouseHandled);
    _mouseCursor.StoreBackground(mouseState);
    _mouseCursor.Draw;
    Graphics.PopState;
  end;
end;

procedure TTextApplication.Run;
var
  mouseState: TMouseState;
begin
  MouseDriver.GetMouseState(mouseState);
  _oldMouseState.Create;
  _oldMouseState.Assign(mouseState);
  _mouseCursor._X := mouseState.X;
  _mouseCursor._Y := mouseState.Y;
  _mouseCursor.StoreBackground(mouseState);
  _mouseCursor.Draw;
  TApplication.Run;
end;

procedure TTextApplication.MainLoop;
begin
  _mouseHandled := false;
  _keyHandled := false;
  TApplication.MainLoop;
end;

procedure TTextApplication.ShowMouseCursor;
var
  mouseState: TMouseState;
begin
  MouseDriver.GetMouseState(mouseState);
  _mouseCursor._Visible := true;
  _mouseCursor.Draw;
end;

procedure TTextApplication.HideMouseCursor;
begin
  Graphics.DrawImage(_mouseCursor._X, _mouseCursor._Y,
    _mouseCursor.Width, _mouseCursor.Height, _mouseCursor.BackData);
  _mouseCursor._visible := false;
end;

destructor TTextApplication.Done;
begin
  TApplication.Done;
  Dispose(Desktop, Done);
  _mouseCursor.Done;
  TextDriver.Done;
end;

procedure TMouseCursor.Init;
begin
  TBaseObject.Init;
  _width := 10;
  _height := 13;
  _visible := true;
  _y := 0;
  _x := 0;
  BackData := nil;
  _image := DefaultMouseCursor;
end;

procedure TMouseCursor.Draw;
var
  xIndex, yIndex: integer;
  pixel: PByte;
  rect, mouseRect, clipRect: TRect;
  xPos, yPos, startX, startY: integer;
begin
  if not _visible then exit;
  Graphics.DrawImage(_x, _y, _width, _height, @_image);
end;

procedure TMouseCursor.StoreBackground(var mouseState: TMouseState);
var
  rect: TRect;
begin
  if (BackData = nil) then GetMem(BackData, Width * Height);
  rect.Create(mouseState.X, mouseState.Y, Width, Height);
  Graphics.GetImage(BackData, rect);
end;

function TMouseCursor.Width: integer;
begin
  Width := _width;
end;

function TMouseCursor.Height: integer;
begin
  Height := _height;
end;

destructor TMouseCursor.Done;
begin
  if (BackData <> nil) then
    FreeMem(BackData, _width * _height);
end;

end.