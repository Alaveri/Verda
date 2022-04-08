{$I Compiler.inc}
unit Controls;

interface

uses
  Objects,
  Collects,
  Drawing,
  KeyDrv,
  WideStr,
  Utils,
  TextDrv,
  MouseDrv;

type
  TBorderStyle =
  (
    bsNone,
    bsSingle,
    bsDouble
  );
  TScrollStyle =
  (
    ssVert,
    ssHorz
  );
  TScrollButtonStyle =
  (
    sbInc,
    sbDec,
    sbSlider
  );
  TTextAlign =
  (
    taLeft,
    taRight,
    taCenter
  );
  TVertAlign =
  (
    vaTop,
    vaBottom,
    vaCenter
  );
  TScreenPosition =
  (
    spAbsolute,
    spRelative
  );
  TBorderStyles = set of TBorderStyle;
  PControl = ^TControl;
  PControlList = ^TControlList;
  PDesktop = ^TDesktop;
  PMouseEvent = ^TMouseEvent;
  TMouseEvent = procedure(sender: PControl; var state: TMouseState);
  PKeyboardEvent = ^TKeyboardEvent;
  TKeyboardEvent = procedure(sender: PControl; var key: word; var handled: boolean);
  TControl = Object(TObject)
  private
  public
    DrawBackground: boolean;
    X, Y: integer;
    Width, Height: word;
    Visible: boolean;
    OnMouseMove: PMouseEvent;
    OnMouseUp: PMouseEvent;
    OnMouseDown: PMouseEvent;
    OnMouseClick: PMouseEvent;
    OnMouseEnter: PMouseEvent;
    OnMouseLeave: PMouseEvent;
    OnKeyPress: PKeyboardEvent;
    Controls: PControlList;
    Parent: PControl;
    BorderStyle: TBorderStyle;
    BorderColor: byte;
    ForeColor: byte;
    BackColor: byte;
    FocusedForeColor: byte;
    FocusedBackColor: byte;
    Modal: boolean;
    IsLeftMouseDown: boolean;
    IsRightMouseDown: boolean;
    IsMouseOver: boolean;
    ScrollX: longint;
    ScrollY: longint;
    ToolTip: string;
    ShowToolTip: boolean;
    Position: TScreenPosition;
    MoveStartX, MoveStartY: longint;
    Moving: boolean;
    Grouped: boolean;
    TakesControl: boolean;
    TextX, TextY: integer;
    OldCursorOn: boolean;
    Enabled: boolean;
    Focused: boolean;
    CanFocus: boolean;
    UsesCursor: boolean;
    AcceptEnter: boolean;
    AcceptTab: boolean;
    DrawEnabled: boolean;
    Manipulating: boolean;
    constructor Create(newId: string);
    constructor CreateParent(newId: string; newParent: PControl);
    procedure Init; virtual;
    destructor Done; virtual;
    procedure Hide; virtual;
    procedure Show; virtual;
    procedure Draw; virtual;
    procedure SetParent(newParent: PControl); virtual;
    procedure GetBounds(var rect: TRect); virtual;
    procedure SetBounds(newX, newY, newWidth, newHeight: integer); virtual;
    procedure SetBounds2(rect: TRect); virtual;
    procedure GetScreenBounds(var rect : TRect); virtual;
    procedure GetClientScreenBounds(var rect: TRect); virtual;
    procedure GetClipRect(var rect: TRect); virtual;
    procedure GetClientRect(var rect: TRect); virtual;
    function GetDesktop: PDesktop; virtual;
    procedure DrawControls; virtual;
    procedure ProcessMouse(var state, oldState: TMouseState; var handled: boolean); virtual;
    procedure ProcessKeyPress(var key: word; var handled: boolean); virtual;
    {procedure MouseMove(var state: TMouseState); virtual;
    procedure MouseUp(var state: TMouseState); virtual;
    procedure MouseDown(var state: TMouseState); virtual;
    procedure MouseClick(var state: TMouseState); virtual;
    procedure MouseEnter(var state: TMouseState); virtual;
    procedure MouseLeave(var state: TMouseState); virtual;
    procedure KeyPress(var key: word; var handled: boolean); virtual;
    procedure SetupControls; virtual;
    procedure SetXY(newX, newY: byte); virtual;
    procedure Focus; virtual;
    procedure Unfocus; virtual;
    procedure FocusFirst(var handled: boolean); virtual;
    procedure SetFont(newFont: PFont); virtual;
    function GetStatusBar: PStatusBar; virtual;
    function GetVisible: boolean; virtual;
    function GetEnabled: boolean; virtual;
    function GetModal: boolean; virtual;
    function Font: PFont; virtual;}
  end;
  TControlList = Object(TObjectList)
    function ToString: string; virtual;
    function GetItem(index: integer): PControl;
    function IndexOf(item: PControl): integer;
    function Add(item: PControl): integer;
    procedure Init; virtual;
    procedure Insert(index: integer; item: PControl);
  end;
  PPanel = ^TPanel;
  TPanel = Object(TControl)
  public
    HighlightColor: byte;
    ShadowColor: byte;
    procedure Init; virtual;
    procedure Draw; virtual;
  end;
  PPopUp = ^TPopUp;
  TPopUp = object(TPanel)
  private
  public
    {BackData: PByte;
    BackRect: TRect;
    constructor Create(newId: string);
    constructor CreateParent(newId: string; newParent: PControl);
    destructor Done; virtual;
    procedure Init; virtual;
    procedure Show; virtual;
    procedure Hide; virtual;}
  end;
  PMenu = ^TMenu;
  {PMenuItem = ^TMenuItem;}
  TMenu = object(TPopUp)
  private
  public
   { ActiveItem: PMenuItem;
    ParentItem: PMenuItem;
    constructor Create(newId: string);
    procedure KeyPress(var key: word; var handled: boolean); virtual;
    procedure Init; virtual;
    procedure Draw; virtual;
    procedure Show; virtual;
    procedure Hide; virtual;
    procedure SetupControls; virtual;}
  end;
  PMenuBar = ^TMenuBar;
  TMenuBar = object(TPanel)
  private
  public
    {procedure Init; virtual;
    procedure Draw; virtual;
    procedure KeyPress(var key: word; var handled: boolean); virtual;
    procedure SetupControls; virtual;
    function ProcessHotKeys(control: PControl; key: word): boolean; virtual;
    function ProcessArrowKeys(key: word): boolean; virtual;}
  end;
  PStatusBar = ^TStatusBar;
  TStatusBar = object(TPanel)
  private
  public
    Text: string;
    TextPanel: PPanel;
    {procedure ClearText; virtual;
    procedure Init; virtual;
    procedure Draw; virtual;
    procedure SetupControls; virtual;}
  end;
  TDesktop = object(TPanel)
    MenuBar: PMenuBar;
    StatusBar: PStatusBar;
    MouseOverControl: PControl;
    ActiveControl: PControl;
    ActiveMenu: PMenu;
    procedure Init; virtual;
    procedure Draw; virtual;
    procedure GetClientRect(var rect: TRect); virtual;
    procedure KeyPress(var key: word; var handled: boolean); virtual;
    function FindNextControl(control: PControl): PControl; virtual;
    function FindPreviousControl(control: PControl): PControl; virtual;
  end;


implementation

procedure TControlList.Init;
begin
  TObjectList.Init;
  TypeName := 'TControlList';
end;

function TControlList.ToString: string;
begin
  ToString := 'TControlList';
end;

function TControlList.GetItem(index: integer): PControl;
begin
  GetItem := pointer(TObjectList.GetItem(index));
end;

function TControlList.IndexOf(item: PControl): integer;
begin
  IndexOf := TObjectList.IndexOf(item);
end;

function TControlList.Add(item: PControl): integer;
begin
  Add := TObjectList.Add(item);
end;

procedure TControlList.Insert(index: integer; item: PControl);
begin
  TObjectList.Insert(index, item);
end;

constructor TControl.Create(newId: string);
begin
  Id := newId;
  Parent := nil;
  Init;
end;

procedure TControl.SetParent(newParent: PControl);
begin
  Parent := newParent;
  if (Parent <> nil) then
    Parent^.Controls^.Add(@self);
end;

constructor TControl.CreateParent(newId: string; newParent: PControl);
begin
  Id := newId;
  SetParent(newParent);
  Init;
end;

procedure TControl.Init;
begin
  TObject.Init;
  TypeName := 'TControl';
  Controls := New(PControlList, Create('~Controls'));
  SetBounds(0, 0, 0, 0);
  Visible := true;
  Moving := false;
  Position := spRelative;
  BorderStyle := bsNone;
  BorderColor := 0;
  ForeColor := 0;
  FocusedForeColor := 0;
  FocusedBackColor := 0;
  OnMouseMove := nil;
  OnMouseUp := nil;
  OnMouseDown := nil;
  OnKeyPress := nil;
  OnMouseEnter := nil;
  OnMouseLeave := nil;
  OnMouseClick := nil;
  Enabled := true;
  DrawBackground := true;
  Modal := false;
  IsLeftMouseDown := false;
  IsRightMouseDown := false;
  IsMouseOver := false;
  ShowToolTip:= false;
  Grouped := false;
  ScrollX := 0;
  ScrollY := 0;
  TakesControl := false;
  TextX := 0;
  TextY := 0;
  OldCursorOn := true;
  Focused := false;
  CanFocus := false;
  UsesCursor := false;
  AcceptEnter := false;
  AcceptTab := false;
  DrawEnabled := true;
  Manipulating := false;
end;

procedure TControl.GetBounds(var rect: TRect);
begin
  rect.Create(X, Y, Width, Height);
end;

procedure TControl.SetBounds(newX, newY, newWidth, newHeight: integer);
begin;
  X := newX;
  Y := newY;
  Width := newWidth;
  Height := newHeight;
end;

procedure TControl.SetBounds2(rect: TRect);
begin
  SetBounds(rect.X, rect.Y, rect.Width, rect.Height);
end;

procedure TControl.GetClientScreenBounds(var rect: TRect);
var
  par: PControl;
  parRect, result: TRect;
begin
  GetClientRect(rect);
  rect.X := rect.X + X;
  rect.Y := rect.Y + Y;
  par := Parent;
  while par <> nil do
  begin
    par^.GetClientRect(parRect);
    rect.X := rect.X + par^.X + parRect.X;
    rect.Y := rect.Y + par^.Y + parRect.Y;
    par := par^.Parent;
  end;
end;

procedure TControl.GetScreenBounds(var rect: TRect);
var
  par: PControl;
  parRect: TRect;
begin
  GetBounds(rect);
  if (Position = spAbsolute) or (Parent = nil) then
    exit;
  par := Parent;
  repeat
    if (par^.Position = spAbsolute) then
    begin
      par^.GetBounds(parRect);
      rect.X := rect.X + parRect.X;
      rect.Y := rect.Y + parRect.Y;
      break;
    end
    else
    begin
      par^.GetClientRect(parRect);
      rect.X := rect.X + parRect.X + par^.X;
      rect.Y := rect.Y + parRect.Y + par^.Y;
    end;
    par := par^.Parent;
  until (par = nil);
end;

procedure TControl.GetClientRect(var rect: TRect);
var
  borderWidth: byte;
begin
  borderWidth := 0;
  if (BorderStyle <> bsNone) then
    borderWidth := 1;
  rect.Create(borderWidth, borderWidth, Width - borderWidth * 2, Height - borderWidth * 2);
end;

procedure TControl.GetClipRect(var rect: TRect);
var
  par: PControl;
  parRect, result: TRect;
begin
  GetScreenBounds(rect);
  if (Position = spAbsolute) or (Parent = nil) then
    exit;
  par := Parent;
  repeat
    if (par^.Position = spAbsolute) then
    begin
      par^.GetScreenBounds(parRect);
      rect.Intersection(ParRect, result);
      rect := result;
      break;
    end
    else
    begin
      par^.GetClientScreenBounds(parRect);
      rect.Intersection(ParRect, result);
      rect := result;
    end;
    par := par^.Parent;
  until (par = nil);
end;


destructor TControl.Done;
var
  index: word;
  item: PObject;
begin
  if (Controls^.Count > 0) then
  begin
    for index := 0 to Controls^.Count - 1 do
    begin
     item := Controls^.GetItem(index);
     Dispose(item, Done);
    end;
  end;
  TObject.Done;
end;

function TControl.GetDesktop: PDesktop;
var
  par: PControl;
begin
  if (Parent = nil) then
  begin
    GetDesktop := @Self;
    exit;
  end;
  par := Parent;
  while (par^.Parent <> nil) do
  begin
    par := par^.Parent;
  end;
  GetDesktop := PDesktop(par);
end;

procedure TControl.Hide;
var
  index: integer;
  control: PControl;
  desktop: PDesktop;
begin
  desktop := GetDesktop;
  for index := 0 to Controls^.Count - 1 do
  begin
    control := Controls^.GetItem(index);
    control^.IsMouseOver := false;
    control^.IsLeftMouseDown := false;
    control^.IsRightMouseDown := false;
    control^.Moving := false;
    if (desktop^.ActiveControl = control) then
      desktop^.ActiveControl := nil;
  end;
  Visible := false;
  HideMouse;
  Draw;
  ShowMouse;
end;

procedure TControl.Show;
begin
  Visible := true;
  HideMouse;
  Draw;
  ShowMouse;
end;

procedure TControl.Draw;
begin
end;

procedure TControl.DrawControls;
begin
end;

procedure TControl.ProcessMouse(var state, oldState: TMouseState; var handled: boolean);
begin
end;

procedure TControl.ProcessKeyPress(var key: word; var handled: boolean);
begin
end;

procedure TPanel.Init;
begin
  TControl.Init;
  TypeName := 'TPanel';
  {ForeColor := icWindow;
  BackColor := icWindowBack;
  BorderColor := icBorder;
  BorderStyle := bsSingle;
  HighlightColor := icButtonHighlight;
  ShadowColor := icButtonShadow;
  FocusedForeColor := icFocusedBack;
  FocusedBackColor := icFocused;
  DrawBackground := true;}
end;

procedure TPanel.Draw;
var
  rect: TRect;
begin
 { if not GetVisible then exit;
  TextDriver.PushState;
  GetClipRect(rect);
  Graphics.SetForeColor(BackColor);
  if (DrawBackground) then
    Graphics.FillRect(rect);
  case BorderStyle of
    bsRaised:
    begin
      Graphics.SetForeColor(shadowColor);
      Graphics.Line(rect.Right, rect.Y, rect.Right, rect.Bottom);
      Graphics.Line(rect.X, rect.Bottom, rect.Right, rect.Bottom);
      Graphics.SetForeColor(HighlightColor);
      Graphics.Line(rect.X, rect.Y, rect.Right, rect.Y);
      Graphics.Line(rect.X, rect.Y, rect.X, rect.Bottom);
    end;
    bsLowered:
    begin
      Graphics.SetForeColor(HighlightColor);
      Graphics.Line(rect.Right, rect.Y, rect.Right, rect.Bottom);
      Graphics.Line(rect.X, rect.Bottom, rect.Right, rect.Bottom);
      Graphics.SetForeColor(ShadowColor);
      Graphics.Line(rect.X, rect.Y, rect.Right, rect.Y);
      Graphics.Line(rect.X, rect.Y, rect.X, rect.Bottom);
    end;
    bsSingle:
    begin
      Graphics.SetForeColor(BorderColor);
      Graphics.Rectangle(rect.X, rect.Y, rect.Right, rect.Bottom);
    end;
    bsDouble:
    begin
      Graphics.SetForeColor(BorderColor);
      Graphics.Rectangle(rect.X, rect.Y, rect.Right, rect.Bottom);
      Graphics.SetForeColor(BorderColor);
      Graphics.Rectangle(rect.X + 1, rect.Y + 1, rect.Right - 1, rect.Bottom - 1);
    end;
  end;
  if (Focused and GetEnabled) then
  begin
    rect.Create(MaxL(rect.X - 2, 0), MaxL(rect.Y - 2, 0),
      MinL(rect.Right + 2, Graphics.Mode^.Width), MinL(rect.Bottom + 2, Graphics.Mode^.Height));
    Graphics.SetForeColor(FocusedForeColor);
    Graphics.Rectangle(rect.X - 1, rect.Y - 1, rect.Right + 1, rect.Bottom + 1);
    Graphics.Rectangle(rect.X - 2, rect.Y - 2, rect.Right + 2, rect.Bottom + 2);
  end;}
  TextDriver.PopState;
  {DrawControls};
end;

procedure TDesktop.Init;
begin
  TPanel.Init;
  TypeName := 'TDesktop';
  DrawBackground := true;
  BorderStyle := bsNone;
  ActiveControl := nil;
  ActiveMenu := nil;
  {MouseOverControl := nil;
  ForeColor := icDesktop;
  BackColor := icDesktopBack;
  MenuBar := New(PMenuBar, CreateParent('DesktopMenuBar', @self));
  StatusBar := New(PStatusBar, CreateParent('DesktopStatusBar', @self));}
end;

procedure TDesktop.Draw;
begin
  TPanel.Draw;
end;

procedure TDesktop.GetClientRect(var rect: TRect);
begin
  rect.Create(0, 0, TextDriver.Mode.Width, TextDriver.Mode.Height);
end;

function TDesktop.FindNextControl(control: PControl): PControl;
var
  index: integer;
  par: PControl;
  current: PControl;
begin
  {FindNextControl := nil;
  par := control^.Parent;
  if ((par = nil) or (not par^.GetVisible) or (not par^.GetEnabled)
    or (par^.Controls^.Count = 0)) then
    exit;
  index := par^.Controls^.IndexOf(control);
  Inc(index);
  if (index > par^.Controls^.Count - 1) then
  begin
    if par^.GetModal then
    begin
      index := 0;
      current := par^.Controls^.GetItem(index);
    end
    else
    begin
      par := par^.Parent;
      if (par = nil) or (par^.Controls^.Count = 0) then exit;
      current := par^.Controls^.GetItem(0);
    end;
  end
  else
    current := par^.Controls^.GetItem(index);
  if ((current <> nil) and current^.GetVisible and current^.GetEnabled and current^.CanFocus) then
  begin
    if (ActiveControl <> nil) then
    begin
     HideMouse;
     ActiveControl^.Unfocus;
     current^.Focus;
     ShowMouse;
    end;
  end
  else
  begin
    if (current <> nil) and (not current^.AcceptTab) then
      FindNextControl := FindNextControl(current);
  end;}
end;

function TDesktop.FindPreviousControl(control: PControl): PControl;
begin

end;

procedure TDesktop.KeyPress(var key: word; var handled: boolean);
var
  control: PControl;
  stop: boolean;
begin
  {if (key = 9) then
  begin
    handled := true;
    if (Controls^.Count = 0) then exit;
    control := ActiveControl;
    if (control = nil) then
      control := Controls^.GetItem(0);
    if (control^.GetVisible and control^.GetEnabled and (control = ActiveControl))
      and (control^.AcceptTab) then
      exit;
    stop := false;
    control := FindNextControl(control);
    if (control <> nil) then
      handled := true;
  end;}
end;

end.