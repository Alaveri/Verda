unit GrTxtApp;

interface

uses
  Objects,
  MouseDrv,
  GraphDrv,
  TextDrv,
  Drawing,
  TextIni,
  TextApp;

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
  PGraphicTextApplication = ^TGraphicTextApplication;
  TGraphicTextApplication = object(TTextApplication)
  private
    _mouseCursor: PMouseCursor;
  public
    procedure Init; virtual;
    procedure Run; virtual;
    procedure ProcessEvents; virtual;
    procedure ShowMouseCursor; virtual;
    procedure HideMouseCursor; virtual;
    procedure InitTextDriver(driver: TTextDrivers; modeId: string); virtual;
    destructor Done; virtual;
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

procedure TGraphicTextApplication.Init;
begin
  _mouseCursor := nil;
  TTextApplication.Init;
end;

procedure TGraphicTextApplication.InitTextDriver(driver: TTextDrivers; modeId: string);
begin
  TTextApplication.InitTextDriver(driver, modeId);
end;

procedure TGraphicTextApplication.ProcessEvents;
var
  mouseState: TMouseState;
begin
  MouseDriver^.GetMouseState(mouseState);
  _mouseCursor^._X := mouseState.X;
  _mouseCursor^._Y := mouseState.Y;
  if not mouseState.Equals(OldMouseState^) then begin
    Graphics^.PushState;
    Graphics^.SetBackColor(Desktop^.BackColor);
    if (_mouseCursor^.BackData <> nil) then begin
      Graphics^.DrawImage(OldMouseState^.X, OldMouseState^.Y,
        _mouseCursor^.Width, _mouseCursor^.Height, _mouseCursor^.BackData);
    end;
    _mouseCursor^.StoreBackground(mouseState);
    _mouseCursor^.Draw;
    Graphics^.PopState;
    OldMouseState^ := mouseState;
    Desktop^.ProcessMouse(mouseState, OldMouseState^, MouseHandled);
  end;
end;

procedure TGraphicTextApplication.ShowMouseCursor;
begin
  _mouseCursor^._Visible := true;
  _mouseCursor^.Draw;
end;

procedure TGraphicTextApplication.HideMouseCursor;
begin
  Graphics^.DrawImage(_mouseCursor^._X, _mouseCursor^._Y, _mouseCursor^.Width, _mouseCursor^.Height, _mouseCursor^.BackData);
  _mouseCursor^._visible := false;
end;

destructor TGraphicTextApplication.Done;
begin
  if (_mouseCursor <> nil) then begin
    Dispose(_mouseCursor, Done);
  end;
  TTextApplication.Done;
end;

procedure TGraphicTextApplication.Run;
var
  mouseState: TMouseState;
begin
  MouseDriver^.GetMouseState(mouseState);
  _mouseCursor := New(PMouseCursor, Create);
  _mouseCursor^._X := mouseState.X;
  _mouseCursor^._Y := mouseState.Y;
  _mouseCursor^.StoreBackground(mouseState);
  ShowMouseCursor;
  TTextApplication.Run;
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
  Graphics^.DrawImage(_x, _y, _width, _height, @_image);
end;

procedure TMouseCursor.StoreBackground(var mouseState: TMouseState);
var
  rect: TRect;
begin
  if (BackData = nil) then GetMem(BackData, Width * Height);
  rect.Create(mouseState.X, mouseState.Y, Width, Height);
  Graphics^.GetImage(BackData, rect);
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
  TBaseObject.Done;
end;

end.