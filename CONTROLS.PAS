{$I Compiler.inc}
unit Controls;

interface

uses
  Crt,
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
  );  TBorderStyles = set of TBorderStyle;
  PControlList = ^TControlList;
  PControl = ^TControl;
  PWindow = ^TWindow;
  PButton = ^TButton;
  PDialog = ^TDialog;
  PMouseEvent = ^TMouseEvent;
  TMouseEvent = procedure(sender: PControl; var state: TMouseState);
  PKeyboardEvent = ^TKeyboardEvent;
  TKeyboardEvent = procedure(sender: PControl; var key: word; var handled: boolean);
  PScrollButtonEvent = ^TScrollButtonEvent;
  TScrollButtonEvent = procedure(style: TScrollButtonStyle; self: PControl);
  PScrollButtonClickEvent = ^TScrollButtonEvent;
  TScrollButtonClickEvent = procedure(style: TScrollButtonStyle; oldValue: longint; self: PControl);
  TControlList = Object(TObjectList)
    function ToString: string; virtual;
    function GetItem(index: integer): PControl;
    function IndexOf(item: PControl): integer;
    function Add(item: PControl): integer;
    procedure Init; virtual;
    procedure Insert(index: integer; item: PControl);
  end;
  PButtonList = ^TButtonList;
  TButtonList = Object(TObjectList)
    function ToString: string; virtual;
    function GetItem(index: integer): PButton;
    function IndexOf(item: PButton): integer;
    function Add(item: PButton): integer;
    procedure Init; virtual;
    procedure Insert(index: integer; item: PButton);
  end;
  PStatusBar = ^TStatusBar;
  PDesktop = ^TDesktop;
  TControl = Object(TObject)
  private
    public
    DrawBackground: boolean;
    X,Y: integer;
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
    procedure DrawControls; virtual;
    procedure ProcessMouse(var state, oldState: TMouseState; var handled: boolean); virtual;
    procedure ProcessKeyPress(var key: word; var handled: boolean);
    procedure MouseMove(var state: TMouseState); virtual;
    procedure MouseUp(var state: TMouseState); virtual;
    procedure MouseDown(var state: TMouseState); virtual;
    procedure MouseClick(var state: TMouseState); virtual;
    procedure MouseEnter(var state: TMouseState); virtual;
    procedure MouseLeave(var state: TMouseState); virtual;
    procedure KeyPress(var key: word; var handled: boolean); virtual;
    procedure GetClientRect(var rect: TRect); virtual;
    procedure SetupControls; virtual;
    procedure SetXY(newX, newY: byte); virtual;
    procedure Focus; virtual;
    procedure Unfocus; virtual;
    procedure FocusFirst(var handled: boolean); virtual;
    function GetDesktop: PDesktop; virtual;
    function GetStatusBar: PStatusBar; virtual;
    function GetVisible: boolean; virtual;
    function GetEnabled: boolean; virtual;
    function GetModal: boolean; virtual;
  end;
  PPanel = ^TPanel;
  TPanel = Object(TControl)
  public
    HighlightColor: byte;
    ShadowColor: byte;
    procedure Init; virtual;
    procedure Draw; virtual;
  end;
  TButton = Object(TPanel)
    Text: string;
    TextAlign: TTextAlign;
    VertAlign: TVertAlign;
    Pressed: boolean;
    Toggle: boolean;
    Active: boolean;
    PressedBackColor: byte;
    PressedForeColor: byte;
    HotKeyColor: byte;
    HotKey: word;
    Margin: integer;
    constructor CreateText(newId, newText: string; newParent: PControl);
    function  TrueText(txt: string): string;
    procedure MouseEnter(var state: TMouseState); virtual;
    procedure MouseLeave(var state: TMouseState); virtual;
    procedure MouseDown(var state: TMouseState); virtual;
    procedure MouseClick(var state: TMouseState); virtual;
    procedure Init; virtual;
    procedure Draw; virtual;
  end;
  PDialogButton = ^TDialogButton;
  TDialogButton = object(TButton)
    Dialog: PDialog;
    procedure MouseClick(var state: TMouseState); virtual;
  end;
  PScrollBar = ^TScrollBar;
  PScrollButton = ^TScrollButton;
  TScrollButton = Object(TButton)
    Style: TScrollButtonStyle;
    ScrollBar: PScrollBar;
    constructor CreateStyle(newId: string; newParent: PControl;
      newStyle: TScrollButtonStyle);
    procedure MouseMove(var state: TMouseState); virtual;
    procedure MouseDown(var state: TMouseState); virtual;
    procedure MouseUp(var state: TMouseState); virtual;
    procedure Init; virtual;
    procedure Draw; virtual;
    procedure MouseClick(var state: TMouseState); virtual;
  end;
  TScrollBar = Object(TPanel)
    ScrollStyle: TScrollStyle;
    DecButton: PScrollButton;
    IncButton: PScrollButton;
    Slider: PScrollButton;
    MaxValue: LongInt;
    Value: LongInt;
    OnScrollButtonClick: PScrollButtonClickEvent;
    ScrollControl: PControl;
    Window: PWindow;
    constructor CreateStyle(newId: string; newParent: PControl;
      newStyle: TScrollStyle);
    procedure Init; virtual;
    procedure Draw; virtual;
    procedure SetScrollStyle(style: TScrollStyle); virtual;
    procedure SetValue(val: longint); virtual;
    procedure MouseClick(var state: TMouseState); virtual;
  end;
  PLabel = ^TLabel;
  TLabel = object(TPanel)
    Text: string;
    constructor CreateText(newId, newText: string; newParent: PControl);
    procedure Init; virtual;
    procedure Draw; virtual;
  end;
  PPopUp = ^TPopUp;
  TPopUp = object(TPanel)
    BackData: PByte;
    BackRect: TRect;
    constructor Create(newId: string);
    constructor CreateParent(newId: string; newParent: PControl);
    destructor Done; virtual;
    procedure Init; virtual;
    procedure Show; virtual;
    procedure Hide; virtual;
  end;
  TWindow = Object(TPopUp)
    HorzScrollBar: PScrollBar;
    VertScrollBar: PScrollBar;
    Contents: PPanel;
    Title: string;
    DrawTitleBack: boolean;
    function ScrollLeft: boolean; virtual;
    function ScrollRight: boolean; virtual;
    function ScrollUp: boolean; virtual;
    function ScrollDown: boolean; virtual;
    function ScrollPageUp: boolean; virtual;
    function ScrollPageDown: boolean; virtual;
    function ScrollPageLeft: boolean; virtual;
    function ScrollPageRight: boolean; virtual;
    function ScrollHome: boolean; virtual;
    function ScrollEnd: boolean; virtual;
    procedure Init; virtual;
    procedure Draw; virtual;
    procedure SetScreenCenter; virtual;
    procedure GetContentsExtent(var rect: TRect); virtual;
    procedure SetupControls; virtual;
  end;
  PMenuBar = ^TMenuBar;
  TMenuBar = object(TPanel)
    procedure Init; virtual;
    procedure Draw; virtual;
    procedure KeyPress(var key: word; var handled: boolean); virtual;
    procedure SetupControls; virtual;
    function ProcessHotKeys(control: PControl; key: word): boolean; virtual;
    function ProcessArrowKeys(key: word): boolean; virtual;
  end;
  PMenu = ^TMenu;
  PMenuItem = ^TMenuItem;
  TMenu = object(TPopUp)
    ActiveItem: PMenuItem;
    ParentItem: PMenuItem;
    constructor Create(newId: string);
    procedure KeyPress(var key: word; var handled: boolean); virtual;
    procedure Init; virtual;
    procedure Draw; virtual;
    procedure Show; virtual;
    procedure Hide; virtual;
    procedure SetupControls; virtual;
  end;
  TMenuItem = object(TButton)
    Separator: boolean;
    ShowHotKey: boolean;
    ParentMenu: PMenu;
    Menu: PMenu;
    MenuBar: PMenuBar;
    constructor CreateMenuBar
    (
      newId,
      newText: string;
      newMenubar: PMenuBar;
      newMenu: PMenu;
      newHotKey: word;
      click: PMouseEvent
    );
    constructor CreateText(newId, newText: string; newParent: PControl; newHotKey: word; click: PMouseEvent);
    constructor CreateSeparator(newId: string; newParent: PControl);
    procedure KeyPress(var key: word; var handled: boolean); virtual;
    procedure MouseEnter(var state: TMouseState); virtual;
    procedure MouseLeave(var state: TMouseState); virtual;
    procedure MouseDown(var state: TMouseState); virtual;
    procedure MouseClick(var state: TMouseState); virtual;
    procedure Draw; virtual;
    procedure Init; virtual;
  end;
  TStatusBar = object(TPanel)
    Text: string;
    TextPanel: PPanel;
    procedure ClearText; virtual;
    procedure Init; virtual;
    procedure Draw; virtual;
    procedure SetupControls; virtual;
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
  PImage = ^TImage;
  TImage = object(TPanel)
    Data: PByte;
    destructor Done; virtual;
    procedure Init; virtual;
    procedure Draw; virtual;
  end;
  TDialog = object(TWindow)
    Buttons: PButtonList;
    CancelButton: PButton;
    AcceptButton: PButton;
    OldFocusedControl: PControl;
    destructor Done; virtual;
    procedure Init; virtual;
    procedure Draw; virtual;
    procedure Show; virtual;
    procedure Hide; virtual;
    procedure AddButton(button: PDialogButton; accept, cancel: boolean; click: PMouseEvent); virtual;
    procedure KeyPress(var key: word; var handled: boolean); virtual;
    procedure SetupControls; virtual;
  end;
  PEditor = ^TEditor;
  TEditor = object(TPanel)
    SelectStart, SelectEnd: longint;
    SelectText, SelectBack: byte;
    WordDelimiters: set of Char;
    Selecting: boolean;
    Text: PWideString;
    MaxLength: word;
    CharSet: set of char;
    procedure Init; virtual;
    procedure Draw; virtual;
    procedure MouseDown(var state: TMouseState); virtual;
    procedure MouseClick(var state: TMouseState); virtual;
    procedure MouseMove(var state: TMouseState); virtual;
    procedure Mouseup(var state: TMouseState); virtual;
    procedure SelectAll; virtual;
    procedure SelectNone; virtual;
    procedure Select(startPos, endPos: longint); virtual;
    procedure Focus; virtual;
    procedure Unfocus; virtual;
    destructor Done; virtual;
  end;
  PEditBox = ^TEditBox;
  TEditBox = object(TEditor)
    procedure Init; virtual;
    procedure Draw; virtual;
    procedure DrawChar(index: word; rect: TRect); virtual;
    procedure KeyPress(var key: word; var handled: boolean); virtual;
    procedure CursorHome; virtual;
    procedure CursorEnd; virtual;
    procedure CursorLeft; virtual;
    procedure CursorRight; virtual;
    procedure CursorCtrlRight; virtual;
    procedure CursorCtrlLeft; virtual;
    procedure BackSpace; virtual;
    procedure Del; virtual;
  end;
  PIntegerEdit = ^TIntegerEdit;
  TIntegerEdit = object(TPanel)
    IncButton: PButton;
    DecButton: PButton;
    EditEntry: PEditBox;
    MinValue: longint;
    MaxValue: longint;
    Value: longint;
    AllowNegative: boolean;
    procedure Init; virtual;
    procedure Draw; virtual;
    procedure SetupControls; virtual;
  end;

var
  icDesktop: byte;
  icDesktopBack: byte;
  icWindow: byte;
  icWindowBack: byte;
  icBorder: byte;
  icButton: byte;
  icButtonBack: byte;
  icButtonDown: byte;
  icButtonDownBack: byte;
  icButtonHotKey: byte;
  icButtonShadow: byte;
  icButtonHighLight: byte;
  icWindowTitle: byte;
  icWindowTitleBack: byte;
  icMenu: byte;
  icMenuBack: byte;
  icHotKey: byte;
  icScroll: byte;
  icScrollBack: byte;
  icEditor: byte;
  icEditorBack: byte;
  icDialog: byte;
  icDialogBack: byte;
  icSelect: byte;
  icSelectBack: byte;
  icFocused: byte;
  icFocusedBack: byte;

implementation

constructor TControl.Create(newId: string);
begin
  Id := newId;
  Parent := nil;
  Enabled := true;
  OnMouseClick := nil;
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
  Enabled := true;
  OnMouseClick := nil;
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

procedure TControl.DrawControls;
var
  index: integer;
  control: PControl;
begin
  if (not Enabled) then exit;
  if (Controls^.Count = 0) then exit;
  for index := Controls^.Count - 1 downto 0 do
  begin
    control := Controls^.GetItem(Index);
    control^.Draw;
  end;
end;

function TControl.GetVisible: boolean;
var
  par: PControl;
begin
  GetVisible := false;
  if (not Visible) then exit;
  par := Parent;
  while (par <> nil) do
  begin
    if (not par^.Visible) then exit;
    par := par^.Parent;
  end;
  GetVisible := true;
end;

function TControl.GetEnabled: boolean;
var
  par: PControl;
begin
  GetEnabled := false;
  if (not Enabled) then exit;
  par := Parent;
  while (par <> nil) do
  begin
    if (not par^.Enabled) then exit;
    par := par^.Parent;
  end;
  GetEnabled := true;
end;

function TControl.GetModal: boolean;
var
  par: PControl;
begin
  GetModal := true;
  if (Modal) then
    exit;
  par := Parent;
  while (par <> nil) do
  begin
    if (par^.Modal) then exit;
    par := par^.Parent;
  end;
  GetModal := false;
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

procedure TControl.Show;
begin
  Visible := true;
  HideMouse;
  Draw;
  ShowMouse;
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

procedure TControl.SetupControls;
begin
end;

procedure TControl.SetXY(newX, newY: byte);
var
  rect: TRect;
begin
  TextX := newX;
  TextY := newY;
  GetClipRect(rect);
  GotoXY(TextX + rect.X + 1, TextY + rect.Y + 1);
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

procedure TControl.Focus;
var
  desktop: PDesktop;
begin
{  desktop := GetDesktop;
  if not (CanFocus and GetVisible and GetEnabled) then
    exit;
  Focused := true;
  desktop^.ActiveControl := @self;
  GraphDriver^.CursorOff;
  HideMouse;
  Draw;
  ShowMouse;
  SetXY(TextX, TextY);
  if (UsesCursor) then
    Drawer.CursorOn;}
end;

procedure TControl.Unfocus;
var
  desktop: PDesktop;
begin
{  desktop := GetDesktop;
  if (not CanFocus) or (not Focused) then exit;
  Focused := false;
  Drawer.CursorOff;
  HideMouse;
  Draw;
  ShowMouse;
  desktop^.ActiveControl := nil;}
end;

procedure TControl.FocusFirst(var handled: boolean);
var
  index: integer;
  control: PControl;
  found: boolean;
begin
{  if (Controls^.Count <> 0) then
  begin
    for index := 0 to Controls^.Count - 1 do
    begin
      control := Controls^.GetItem(index);
      control^.FocusFirst(handled);
      if (handled) then exit;
    end;
  end;
  if (CanFocus and not Handled) then
  begin
    Focus;
    Handled := true;
    if (UsesCursor) then
      Drawer.CursorOn;
  end;}
end;

procedure TControl.Draw;
begin
end;

procedure TControl.MouseMove(var state: TMouseState);
begin
end;

procedure TControl.MouseUp(var state: TMouseState);
begin
end;

procedure TControl.MouseDown(var state: TMouseState);
begin
end;

procedure TControl.MouseClick(var state: TMouseState);
begin
end;

procedure TControl.MouseEnter(var state: TMouseState);
begin
end;

procedure TControl.MouseLeave(var state: TMouseState);
begin
end;

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

function TControl.GetStatusBar: PStatusBar;
begin
  GetStatusBar := GetDesktop^.StatusBar;
end;

procedure TControl.ProcessKeyPress(var key: word; var handled: boolean);
var
  index: word;
  control: PControl;
begin
  if not (GetVisible and GetEnabled and (not handled)) then Exit;
  if Controls^.Count > 0 then
  begin
    for index := 0 to Controls^.Count - 1 do
    begin
      control := Controls^.GetItem(index);
      control^.ProcessKeyPress(key, handled);
      if handled then exit;
    end;
  end;
  if (OnKeyPress <> nil) then
    TKeyboardEvent(OnKeyPress)(@self, key, handled);
  if (not handled) then KeyPress(key, handled);
end;

procedure TControl.KeyPress(var key: word; var handled: boolean);
begin
end;

procedure TControl.ProcessMouse(var state, oldState: TMouseState; var handled: boolean);
var
  Index: word;
  rect: TRect;
  clientRect: TRect;
  intersects: boolean;
  newState: TMouseState;
  desktop: PDesktop;
  control: PControl;
begin
  if not (GetVisible and GetEnabled) then Exit;

  GetClipRect(rect);
  intersects := rect.IntersectPoint(state.X, state.Y);
  desktop := GetDesktop;

  if Controls^.Count > 0 then
  begin
    for index := 0 to Controls^.Count - 1 do
    begin
      control := Controls^.GetItem(index);
      control^.ProcessMouse(state, oldState, handled);
    end;
  end;

  if (oldState.X <> state.X) or (oldState.Y <> state.Y) then
  begin
    if IsMouseOver and (not intersects) then
    begin
      MouseLeave(state);
      if (OnMouseLeave <> nil) then
        TMouseEvent(OnMouseLeave)(@self, state);
      IsMouseOver := false;
      desktop^.MouseOverControl := nil;
    end;
    if (intersects and (not handled)) or Moving or Manipulating then
    begin
      newState := state;
      Dec(newState.X, rect.X);
      Dec(newState.Y, rect.Y);
      if (not IsMouseOver) then
      begin
        if (desktop^.MouseOverControl <> nil)
          and (desktop^.MouseOverControl <> @Self)
          then
          desktop^.MouseOverControl^.MouseLeave(state);
        desktop^.MouseOverControl := @self;
        MouseEnter(state);
        if (OnMouseEnter <> nil) then
          TMouseEvent(OnMouseEnter)(@self, state);
        IsMouseOver := true;
      end;
      OldState := state;
      IsLeftMouseDown := (bsLeft in state.ButtonState);
      IsRightMouseDown := (bsRight in state.ButtonState);
      MouseMove(newState);
      if (OnMouseMove <> nil) then
        TMouseEvent(OnMouseMove)(@self, newState);
      handled := true;
    end;
  end;

  if handled then exit;

  if (bsLeft in state.ButtonState) and (not (bsLeft in oldState.ButtonState)) then
  begin
    if (Desktop^.ActiveMenu <> nil) then
    begin
      Desktop^.ActiveMenu^.GetScreenBounds(rect);
      if (not rect.IntersectPoint(state.X, state.Y)) then
      begin
        Desktop^.ActiveMenu^.Hide;
        if (Desktop^.ActiveMenu^.Parent <> nil) and
           (TypeOf(Desktop^.ActiveMenu^.Parent^) = TypeOf(TMenuItem)) then
        begin
          PMenuItem(Desktop^.ActiveMenu^.Parent)^.Pressed := false;
          PMenuItem(Desktop^.ActiveMenu^.Parent)^.Active := false;
          PMenuItem(Desktop^.ActiveMenu^.Parent)^.Draw;
        end;
        Desktop^.ActiveMenu := nil;
      end;
    end;
    if intersects or Modal then
    begin
      Handled := true;
      newState := state;
      Dec(newState.X, rect.X);
      Dec(newState.Y, rect.Y);
      IsLeftMouseDown := true;
      OldState := state;
      MouseDown(newState);
      if (OnMouseDown <> nil) then
        TMouseEvent(OnMouseDown)(@self, newState);
    end;
  end;

  if (bsRight in state.ButtonState) and (not (bsRight in oldState.ButtonState)) then
  begin
    if Intersects or Modal then
    begin
      Handled := true;
      newState := state;
      Dec(newState.X, rect.X);
      Dec(newState.Y, rect.Y);
      IsRightMouseDown := true;
      OldState := state;
      MouseDown(newState);
      if (OnMouseDown <> nil) then
        TMouseEvent(OnMouseDown)(@self, newState);
    end;
  end;

  if (not (bsLeft in state.ButtonState)) and (bsLeft in oldState.ButtonState) then
  begin
    if Intersects or Modal or Moving or Manipulating then
    begin
      Handled := true;
      newState := state;
      Dec(newState.X, rect.X);
      Dec(newState.Y, rect.Y);
      OldState := state;
      Include(newState.ButtonState, bsLeft);
      if (IsLeftMouseDown) then
      begin
        MouseUp(newState);
        MouseClick(newState);
        if (OnMouseUp <> nil) then
          TMouseEvent(OnMouseUp)(@Self, newState);
        if (OnMouseClick <> nil) then
          TMouseEvent(OnMouseClick)(@self, newState);
      end;
      IsLeftMouseDown := false;
    end;
  end;

  if (not (bsRight in state.ButtonState)) and (bsRight in oldState.ButtonState) then
  begin
    if Intersects or Modal or Moving or Manipulating then
    begin
      Handled := true;
      newState := state;
      Dec(newState.X, rect.X);
      Dec(newState.Y, rect.Y);
      OldState := state;
      Include(newState.ButtonState, bsRight);
      if (IsRightMouseDown) then
      begin
        MouseUp(newState);
        MouseClick(newState);
        if (OnMouseUp <> nil) then
          TMouseEvent(OnMouseUp)(@self, newState);
        if (OnMouseClick <> nil) then
          TMouseEvent(OnMouseClick)(@self, newState);
      end;
      IsRightMouseDown := false;
    end;
  end;
end;

procedure TPanel.Init;
begin
  TControl.Init;
  TypeName := 'TPanel';
  ForeColor := icWindow;
  BackColor := icWindowBack;
  BorderColor := icBorder;
  BorderStyle := bsSingle;
  HighlightColor := icButtonHighlight;
  ShadowColor := icButtonShadow;
  FocusedForeColor := icFocusedBack;
  FocusedBackColor := icFocused;
  DrawBackground := true;
end;

procedure TPanel.Draw;
var
  rect: TRect;
begin
  if not GetVisible then exit;
  GetClipRect(rect);
{  if (DrawBackground) then
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
  end;
  Graphics.PopState;   }
  DrawControls;
end;

constructor TLabel.CreateText(newId, newText: string; newParent: PControl);
begin
  SetParent(newParent);
  Id := newId;
  Parent := newParent;
  Enabled := true;
  Text := newText;
  OnMouseClick := nil;
  Init;
end;

procedure TLabel.Init;
begin
  TPanel.Init;
  TypeName := 'TLabel';
  borderStyle := bsNone;
  DrawBackground := false;
  ForeColor := icWindow;
  BackColor := icWindowBack;
end;

procedure TLabel.Draw;
var
  rect: TRect;
begin
{  if not GetVisible then exit;
  TPanel.Draw;
  GetClientScreenBounds(rect);
  Drawer.ForeColor := ForeColor;
  Drawer.BackColor := BackColor;
  Drawer.DrawText(Text, rect.X, rect.Y, rect);}
end;

constructor TButton.CreateText(newId, newText: string; newParent: PControl);
begin
  SetParent(newParent);
  Id := newId;
  Enabled := true;
  OnMouseClick := nil;
  Text := newText;
  Init;
end;

procedure TButton.Init;
begin
  TPanel.Init;
  TypeName := 'TButton';
  ToolTip := '';
  CanFocus := true;
  Active := false;
  IsMouseOver := false;
  ForeColor := icButton;
  BackColor := icButtonBack;
  HotKeyColor := icButtonHotKey;
  BorderStyle := bsNone;
  TextAlign := taCenter;
  VertAlign := vaCenter;
  Margin := 0;
  Pressed := false;
  Toggle := false;
  Grouped := false;
  PressedBackColor := icButtonDownBack;
  PressedForeColor := icButtonDown;
end;

function TButton.TrueText(txt: string): string;
var
  index: integer;
  textIndex: integer;
  result: string;
begin
  result := '';
  for index := 1 to Length(txt) do
  begin
    if (txt[index] <> '&') then result := result + txt[index];
  end;
  TrueText := result;
end;

function TButtonList.ToString: string;
begin
  ToString := TypeName;
end;

function TButtonList.GetItem(index: integer): PButton;
begin
  GetItem := pointer(TObjectList.GetItem(index));
end;

function TButtonList.IndexOf(item: PButton): integer;
begin
  IndexOf := TObjectList.IndexOf(item);
end;

function TButtonList.Add(item: PButton): integer;
begin
  Add := TObjectList.Add(item);
end;

procedure TButtonList.Init;
begin
  TObjectList.Init;
  TypeName := 'TButtonList';
end;

procedure TButtonList.Insert(index: integer; item: PButton);
begin
  TObjectList.Insert(index, item);
end;


procedure TButton.Draw;
var
  textXPos, textYPos: byte;
  clipRect: TRect;
  index: integer;
  isHotKey: boolean;
  textIndex: integer;
  ch: char;
begin
  if not GetVisible then exit;
  HideMouse;
 { Graphics.PushState;
  if (Pressed or Active) then
  begin
    Graphics.SetForeColor(PressedForeColor);
    Graphics.SetBackColor(PressedBackColor);
  end
  else if (Focused) then
  begin
    Graphics.SetForeColor(FocusedForeColor);
    Graphics.SetBackColor(FocusedBackColor);
  end
  else
  begin
    Graphics.SetForeColor(ForeColor);
    Graphics.SetBackColor(BackColor);
  end;
  TPanel.Draw;
  GetClipRect(clipRect);
  case TextAlign of
    taLeft: textXPos := clipRect.X;
    taRight: textXPos := clipRect.X + clipRect.Width - Font^.TextWidth(Text);
    taCenter: textXPos := clipRect.X + (clipRect.Width - Font^.TextWidth(Text)) div 2;
  end;
  case VertAlign of
    vaTop: textYPos := clipRect.Y;
    vaBottom: textYPos := clipRect.Height - Font^.Height - 1;
    vaCenter: textYPos := (clipRect.Height - Font^.Height) div 2;
  end;
  index := 1;
  textIndex := 1;
  isHotKey := false;
  while textIndex <= Length(Text) do
  begin
    if (Text[index] = '&') then
    begin
      isHotKey := true;
      Inc(textIndex);
    end;
    if (isHotKey) then
    begin
      isHotKey := false;
      Graphics.SetForeColor(HotKeyColor);
    end
    else
      Graphics.SetForeColor(ForeColor);
    ch := Text[textIndex];
    Graphics.DrawText(index + textXPos + Margin, textYPos, ch);
    Inc(index, Font^.TextWidth(ch));
    Inc(textIndex);
  end;}
  ShowMouse;
end;

procedure TButton.MouseEnter(var state: TMouseState);
begin
  if not (Enabled and Visible) then exit;
  GetStatusBar^.Text := ToolTip;
  if (state.ButtonState = [bsLeft]) then Pressed := true;
  Draw;
  GetStatusBar^.Draw;
end;

procedure TButton.MouseLeave(var state: TMouseState);
begin
  if not (Enabled and Visible) then exit;
  GetStatusBar^.Text := '';
  if (state.ButtonState = [bsLeft]) then Pressed := false;
  Draw;
  GetStatusBar^.Draw;
end;

procedure TButton.MouseDown(var state: TMouseState);
var
  index: word;
  control: PControl;
  button: PButton;
begin
  if not (GetVisible and GetEnabled) then exit;
  if CanFocus then
    Focus;
  if Toggle and Grouped and (Parent <> nil) then
  begin
    for index := 0 to Parent^.Controls^.Count - 1 do
    begin
      control := Parent^.Controls^.GetItem(index);
      if (control^.Grouped) then
      begin
        button := pointer(control);
        button^.Pressed := false;
        HideMouse;
        control^.Draw;
        ShowMouse;
      end;
    end;
  end;
  Pressed := true;
  HideMouse;
  Draw;
  ShowMouse;
end;

procedure TButton.MouseClick(var state: TMouseState);
begin
  if (not Toggle) then
  begin
    Pressed := false;
    HideMouse;
    Draw;
    ShowMouse;
  end;
  TPanel.MouseClick(state);
end;

procedure TWindow.SetScreenCenter;
var
  desktop: PDesktop;
begin
  desktop := GetDesktop;
  X := desktop^.X + (desktop^.Width - Width) div 2;
  Y := desktop^.Y + (desktop^.Height - Height) div 2;
end;

procedure TWindow.GetContentsExtent(var rect: TRect);
var
  index: word;
  control: PControl;
begin
  rect.CreateEmpty;
  if (Contents^.Controls^.Count = 0) then Exit;
  for index := 0 to Contents^.Controls^.Count - 1 do
  begin
    control := Contents^.Controls^.GetItem(index);
    if (control^.X + control^.Width > rect.X + rect.Width) then
      rect.Width := control^.X + control^.Width;
    if (control^.Y + control^.Height > rect.Y + rect.Height) then
      rect.Height := control^.Y + control^.Height;
  end;
end;

procedure TWindow.Init;
begin
  TPopUp.Init;
  TypeName := 'TWindow';
  BorderStyle := bsSingle;
  BorderColor := 0;
  ForeColor := icWindow;
  BackColor := icWindowBack;
  DrawTitleBack := true;
  Contents := New(PPanel, CreateParent('~WindowContents', @self));
  with Contents^ do
  begin
    Visible := true;
    ForeColor := icWindow;
    BackColor := icWindowBack;
    BorderStyle := bsNone;
    DrawBackground := false;
  end;
  HorzScrollBar := New(PScrollBar, CreateStyle('~WindowHorzScrollbar', @self, ssHorz));
  with HorzScrollbar^ do
  begin
    Visible := false;
    Position := spAbsolute;
    ScrollControl := Contents;
    Window := @self;
  end;
  VertScrollBar := New(PScrollBar, CreateStyle('~WindowVertScrollbar', @self, ssVert));
  with VertScrollbar^ do
  begin
    Position := spAbsolute;
    Visible := false;
    ScrollControl := Contents;
    Window := @self;
  end;
end;

procedure TWindow.SetupControls;
var
  borderWidth: word;
  extentRect: TRect;
  clientRect: TRect;
  clipRect: TRect;
  rect: TRect;
begin
  borderWidth := 0;
  if (BorderStyle <> bsNone) then
    borderWidth := 1;

  HorzScrollBar^.Visible := false;
  VertScrollBar^.Visible := false;

  GetContentsExtent(extentRect);
  GetClientRect(clientRect);

  if (clientRect.X + extentRect.Width > clientRect.X + clientRect.Width) and
     (clientRect.Y + extentRect.Height > clientRect.Y + clientRect.Height) then
  begin
    HorzScrollBar^.Visible := true;
    VertScrollBar^.Visible := true;
  end
  else if (clientRect.X + extentRect.Width > clientRect.X + clientRect.Width) then
  begin
    HorzScrollBar^.Visible := true;
  end
  else if (clientRect.Y + extentRect.Height > clientRect.Y + clientRect.Height) then
  begin
    VertScrollBar^.Visible := true;
  end;

  GetScreenBounds(rect);
  Contents^.SetBounds2(extentRect);
  Contents^.GetClipRect(clipRect);
  HorzScrollBar^.MaxValue := extentRect.Width - clipRect.Width;
  VertScrollBar^.MaxValue := extentRect.Height - clipRect.Height;
  HorzScrollbar^.SetBounds(rect.X + 1, rect.Y + rect.Height - 1, rect.Width - 2, 1);
  VertScrollbar^.SetBounds(rect.X + rect.Width - 1, 2, 1, rect.Height - 2);
  HorzScrollBar^.SetScrollStyle(ssHorz);
  VertScrollBar^.SetScrollStyle(ssVert);
  HorzScrollBar^.SetValue(HorzScrollbar^.Value);
  VertScrollBar^.SetValue(VertScrollbar^.Value);
end;

procedure TWindow.Draw;
var
  clientRect: TRect;
  rect: TRect;
  index: integer;
begin
{  SetupControls;
  if (not GetVisible) then exit;
  TPanel.Draw;
  GetClipRect(rect);
  if (Parent <> nil) then
  begin
    rect.SetX(rect.X - parent^.ScrollX);
    rect.SetY(rect.Y - parent^.ScrollY);
  end;
  ch.Character := 219;
  ch.Attributes := Drawer.GetCharAttributes(icTitleBack, icTitleBack);
  if (DrawTitleBack) then
  begin
    for index := rect.X + 1 to rect.X + rect.Width - 2 do
      Drawer.CurrentScreen^[rect.Y, index] := ch;
  end;
  rect.SetWidth(rect.Width - 1);
  Drawer.ForeColor := icTitleText;
  Drawer.BackColor := icTitleBack;
  Drawer.DrawText(Title, rect.X + 2, rect.Y, rect);
  HorzScrollBar^.Draw;
  VertScrollbar^.Draw;}
end;

function TWindow.ScrollUp: boolean;
var
  rect: TRect;
begin
  GetClipRect(rect);
  if (Contents^.ScrollY > 0) then
  begin
    ScrollUp := true;
    Dec(Contents^.ScrollY);
    VertScrollBar^.SetValue(VertScrollBar^.Value - 1);
    VertScrollBar^.Draw;
    Contents^.Draw;
  end
  else
    ScrollUp := false;
end;

function TWindow.ScrollDown: boolean;
var
  rect: TRect;
begin
  GetClipRect(rect);
  if (Contents^.ScrollY + 1 <= VertScrollbar^.MaxValue) then
  begin
    ScrollDown := true;
    Inc(Contents^.ScrollY);
    VertScrollBar^.SetValue(VertScrollBar^.Value + 1);
    VertScrollBar^.Draw;
    Contents^.Draw;
  end
  else
    ScrollDown := false;
end;

function TWindow.ScrollPageUp: boolean;
var
  rect: TRect;
begin
  ScrollPageUp := true;
  Dec(Contents^.ScrollY, rect.Height - 1);
  if (Contents^.ScrollY < 0) then
    Contents^.ScrollY := 0;
  VertScrollBar^.SetValue(VertScrollBar^.Value - (rect.Height - 1));
  VertScrollBar^.Draw;
  Contents^.Draw;
end;

function TWindow.ScrollPageLeft: boolean;
var
  rect: TRect;
begin
  ScrollPageLeft := true;
  Dec(Contents^.ScrollX, rect.Width - 1);
  if (Contents^.ScrollX < 0) then
    Contents^.ScrollX := 0;
  HorzScrollBar^.SetValue(HorzScrollBar^.Value - (rect.Width - 1));
  HorzScrollBar^.Draw;
  Contents^.Draw;
end;

function TWindow.ScrollPageDown: boolean;
var
  rect: TRect;
begin
  GetClipRect(rect);
  ScrollPageDown := true;
  Inc(Contents^.ScrollY, rect.Height - 1);
  if (Contents^.ScrollY > VertScrollbar^.MaxValue) then
    Contents^.ScrollY := VertScrollbar^.MaxValue;
  VertScrollBar^.SetValue(VertScrollBar^.Value + rect.Height - 1);
  VertScrollBar^.Draw;
  Contents^.Draw;
end;

function TWindow.ScrollPageRight: boolean;
var
  rect: TRect;
begin
  GetClipRect(rect);
  ScrollPageRight := true;
  Inc(Contents^.ScrollX, rect.Width - 1);
  if (Contents^.ScrollX > HorzScrollbar^.MaxValue) then
    Contents^.ScrollX := HorzScrollbar^.MaxValue;
  HorzScrollBar^.SetValue(HorzScrollBar^.Value + rect.Width - 1);
  HorzScrollBar^.Draw;
  Contents^.Draw;
end;

function TWindow.ScrollHome: boolean;
var
  rect: TRect;
begin
  GetClipRect(rect);
  ScrollHome := true;
  Contents^.ScrollX := 0;
  HorzScrollBar^.SetValue(0);
  HorzScrollBar^.Draw;
  Contents^.Draw;
end;

function TWindow.ScrollEnd: boolean;
var
  rect: TRect;
begin
  GetClipRect(rect);
  ScrollEnd := true;
  Contents^.ScrollX := Contents^.ScrollX + rect.Width - 1;
  Contents^.Draw;
  HorzScrollBar^.SetValue(HorzScrollBar^.MaxValue);
  HorzScrollBar^.Draw;
end;

function TWindow.ScrollLeft: boolean;
var
  rect: TRect;
begin
  GetClipRect(rect);
  if (Contents^.ScrollX > 0) then
  begin
    ScrollLeft := true;
    Dec(Contents^.ScrollX);
    HorzScrollBar^.SetValue(HorzScrollBar^.Value - 1);
    HorzScrollBar^.Draw;
    Contents^.Draw;
  end
  else
   ScrollLeft := false;
end;

function TWindow.ScrollRight: boolean;
var
  rect: TRect;
begin
  GetClipRect(rect);
  if (Contents^.ScrollX + rect.Width - 1 <= Contents^.Width) then
  begin
    ScrollRight := true;
    Inc(Contents^.ScrollX);
    HorzScrollBar^.SetValue(HorzScrollBar^.Value + 1);
    HorzScrollBar^.Draw;
    Contents^.Draw;
  end
  else
   ScrollRight := false;
end;

constructor TScrollbar.CreateStyle(newId: string; newParent: PControl;
  newStyle: TScrollStyle);
begin
  SetParent(newParent);
  Id := newId;
  ScrollStyle := newStyle;
  Enabled := true;
  OnMouseClick := nil;
  Init;
end;

procedure TScrollBar.Init;
begin
  TPanel.Init;
  TypeName := 'TScrollBar';
  ScrollStyle := ssHorz;
  MaxValue := 0;
  BorderStyle := bsNone;
  DrawBackground := false;
  OnScrollButtonClick := nil;
  ScrollControl := nil;
  Window := nil;

  DecButton := New(PScrollButton, CreateStyle('~DecButton', @self, sbDec));
  with DecButton^ do
  begin
    ScrollBar := @self;
  end;

  IncButton := New(PScrollButton, CreateStyle('~IncButton', @self, sbInc));
  with IncButton^ do
  begin
    ScrollBar := @self;
  end;

  Slider := New(PScrollButton, CreateStyle('~Slider', @self, sbSlider));
  with Slider^ do
  begin
    ScrollBar := @self;
  end;

  Value := 0;
  SetValue(0);
end;

procedure TScrollBar.MouseClick(var state: TMouseState);
var
  rect: TRect;
begin
  GetClipRect(rect);
  IncButton^.GetClipRect(rect);
  GetClipRect(rect);
  if (ScrollStyle = ssHorz) then
  begin
    if (state.X < Slider^.X) then
    begin
      if (Window <> nil) then
      begin
        Window^.GetClipRect(rect);
        Dec(Value, rect.Width - 1);
        if (Value < 0) then Value := 0;
        SetValue(Value);
        Window^.ScrollPageLeft;
      end
      else
      begin
        Dec(Value);
        if (Value < 0) then Value := 0;
        SetValue(Value);
      end;
    end
    else
    begin
      if (Window <> nil) then
      begin
        Window^.GetClipRect(rect);
        Inc(Value, rect.Width - 1);
        if (Value > MaxValue) then Value := MaxValue;
        SetValue(Value);
        Window^.ScrollPageRight;
      end
      else
      begin
        Inc(Value);
        if (Value > MaxValue) then Value := MaxValue;
        SetValue(Value);
        Window^.ScrollLeft;
      end;
    end;
  end
  else
  begin
    if (state.Y < slider^.Y) then
    begin
      if (Window <> nil) then
      begin
        Window^.GetClipRect(rect);
        Dec(Value, rect.Height - 1);
        if (Value < 0) then Value := 0;
        SetValue(Value);
        Window^.ScrollPageUp;
      end
      else
      begin
        Dec(Value);
        if (Value < 0) then Value := 0;
        SetValue(Value);
        Window^.ScrollUp;
      end;
    end
    else
    begin
      if (Window <> nil) then
      begin
        Window^.GetClipRect(rect);
        Inc(Value, rect.Height - 1);
        if (Value > MaxValue) then Value := MaxValue;
        SetValue(Value);
        Window^.ScrollPageDown;
      end
      else
      begin
        Inc(Value);
        if (Value > MaxValue) then Value := MaxValue;
        SetValue(Value);
        Window^.ScrollUp;
      end;
    end;
  end;
  Draw;
  ShowMouse;
end;

procedure TScrollBar.Draw;
var
  rect: TRect;
begin
{  if (not GetVisible) then exit;
  HideMouse;
  GetClipRect(rect);
  ch.Character := 176;
  ch.Attributes := Drawer.GetCharAttributes(icScrollBack, icWindow);
  if (ScrollStyle = ssHorz) then
    Drawer.HorzLine(ch, rect.X + 1, rect.Y, rect.Width - 2)
  else
    Drawer.VertLine(ch, rect.X, rect.Y + 1, rect.Height - 2);
  TPanel.Draw;
  showMouse;}
end;

constructor TScrollButton.CreateStyle(newId: string; newParent: PControl;
  newStyle: TScrollButtonStyle);
begin
  SetParent(newParent);
  Id := newId;
  Style := newStyle;
  OnMouseClick := nil;
  Enabled := true;
  Init;
end;

procedure TScrollButton.Init;
begin
  TButton.Init;
  TypeName := '~TScrollButton';
  BorderStyle := bsNone;
  DrawBackground := false;
  ScrollBar := nil;
  CanFocus := false;
end;

procedure TScrollButton.MouseDown(var state: TMouseState);
begin
  TButton.MouseDown(state);
  if (Style <> sbSlider) then
    exit;
  if (not Moving) and IsLeftMouseDown then
  begin
    MoveStartX := state.X;
    MoveStartY := state.Y;
    Moving := true;
  end;
end;

procedure TScrollButton.MouseUp(var state: TMouseState);
begin
  TButton.MouseUp(state);
  if (Style <> sbSlider) then exit;
  Moving := false;
  if (Scrollbar^.Window <> nil) then
  begin
    if (Scrollbar^.ScrollStyle = ssHorz) then
      Scrollbar^.Window^.Contents^.ScrollX := Scrollbar^.Value
    else
      Scrollbar^.Window^.Contents^.ScrollY := Scrollbar^.Value;
    Scrollbar^.Window^.Contents^.Draw;
  end;
end;

procedure TScrollButton.MouseMove(var state: TMouseState);
begin
  TButton.MouseMove(state);
  if (Style <> sbSlider) or (not IsLeftMouseDown) then exit;
  if (Moving) then
  begin
    if (Scrollbar^.ScrollStyle = ssHorz) then
    begin
      Scrollbar^.SetValue(ScrollBar^.Value + state.X - MoveStartX);
      Scrollbar^.Draw;
    end;
    if (Scrollbar^.ScrollStyle = ssVert) then
    begin
      Scrollbar^.SetValue(ScrollBar^.Value + state.Y - MoveStartY);
      Scrollbar^.Draw;
    end;
  end;
end;

procedure TScrollButton.Draw;
var
  rect: TRect;
begin
{  if (not GetVisible) then exit;
  if (Style = sbSlider) then
  begin
    GetScreenBounds(rect);
    ch.Attributes := Drawer.GetCharAttributes(ForeColor, BackColor);
    ch.Character := 32;
    Drawer.FillRect(rect, ch);
    exit;
  end;
  GetScreenBounds(rect);
  ch.Attributes := Drawer.GetCharAttributes(icButtonText, icButtonFace);
  if (Style = sbInc) and (Scrollbar^.ScrollStyle = ssHorz) then
    ch.Character := 26
  else if (Style = sbDec) and (Scrollbar^.ScrollStyle = ssHorz) then
    ch.Character := 27
  else if (Style = sbDec) and (Scrollbar^.ScrollStyle = ssVert) then
    ch.Character := 24
  else if (Style = sbInc) and (Scrollbar^.ScrollStyle = ssVert) then
    ch.Character := 25;

  Drawer.CurrentScreen^[rect.Y, rect.X] := ch;}
end;

procedure TScrollButton.MouseClick(var state: TMouseState);
var
  oldValue: longint;
begin
  TButton.MouseClick(state);
  case Style of
    sbInc:
    begin
      if (ScrollBar^.ScrollControl <> nil) then
      begin
        oldValue := ScrollBar^.Value;
        if (Scrollbar^.Window <> nil) then
        begin
          if (Scrollbar^.ScrollStyle = ssHorz) then
            Scrollbar^.Window^.ScrollRight
          else
            Scrollbar^.Window^.ScrollDown;
        end
        else
        begin
          Inc(ScrollBar^.Value);
          if (ScrollBar^.Value > ScrollBar^.MaxValue) then
            ScrollBar^.Value := ScrollBar^.MaxValue;
          ScrollBar^.Draw;
        end;
        if (ScrollBar^.OnScrollButtonClick <> nil) then
          TScrollButtonClickEvent(ScrollBar^.OnScrollButtonClick)(Style, oldValue, @self);
      end;
    end;
    sbDec:
    begin
      if (ScrollBar^.ScrollControl <> nil) then
      begin
        oldValue := ScrollBar^.Value;
        if (Scrollbar^.Window <> nil) then
        begin
          if (Scrollbar^.ScrollStyle = ssHorz) then
            Scrollbar^.Window^.ScrollLeft
          else
            Scrollbar^.Window^.ScrollUp;
        end
        else
        begin
          Inc(ScrollBar^.Value);
          if (ScrollBar^.Value > ScrollBar^.MaxValue) then
            ScrollBar^.Value := ScrollBar^.MaxValue;
          ScrollBar^.Draw;
        end;
        if (ScrollBar^.OnScrollButtonClick <> nil) then
          TScrollButtonClickEvent(ScrollBar^.OnScrollButtonClick)(Style, oldValue, @self);
      end;
    end;
    sbSlider:
    begin
    end;
  end;
end;

procedure TScrollBar.SetScrollStyle(style: TScrollStyle);
var
  sliderSize: LongInt;
begin
  if (Width = 0) or (Height = 0) then exit;
  DecButton^.Width := 1;
  DecButton^.Height := 1;
  IncButton^.Height := 1;
  IncButton^.Width := 1;
  Slider^.Width := 1;
  Slider^.Height := 1;
  ScrollStyle := style;

  if (ScrollStyle) = ssHorz then
  begin
    Height := 1;
    DecButton^.X := 0;
    DecButton^.Y := 0;
    DecButton^.Width := 1;
    DecButton^.Height := 1;

    IncButton^.X := Width - 1;
    IncButton^.Y := 0;
    IncButton^.Width := 1;
    IncButton^.Height := 1;

    sliderSize := Width - MaxValue - 2;
    if (sliderSize < 1) then
      sliderSize := 1;
    slider^.Width := sliderSize;
    slider^.Y := 0;
  end
  else
  begin
    Width := 1;
    DecButton^.X := 0;
    DecButton^.Y := 0;
    DecButton^.Width := 1;
    DecButton^.Height := 1;

    IncButton^.X := 0;
    IncButton^.Y := Height - 1;
    IncButton^.Width := 1;
    IncButton^.Height := 1;

    sliderSize := Height - MaxValue - 2;
    if (sliderSize < 1) then
      sliderSize := 1;
    slider^.Height := sliderSize;
    slider^.X := 0;
  end;
end;

procedure TScrollBar.SetValue(val: longint);
var
  sliderSize: LongInt;
  rect: TRect;
  clipRect: TRect;
begin
  if (MaxValue = 0) then exit;
  if (val < 0) then val := 0;
  if (val > MaxValue) then val := MaxValue;

  Value := val;
  ScrollControl^.GetClientRect(rect);
  ScrollControl^.GetClipRect(clipRect);
  if (ScrollStyle = ssHorz) then
  begin
    sliderSize := Width - MaxValue - 2;
    if (sliderSize <= 1) then
    begin
      sliderSize := 1;
      Slider^.X := 0;
    end
    else
      Slider^.X := val + 1
  end
  else
  begin
    sliderSize := rect.Height - MaxValue - 2;
    if (sliderSize <= 1) then
    begin
      sliderSize := rect.Height;
      Slider^.Y := Round((val / MaxValue) * sliderSize) + 1
    end
    else
      Slider^.Y := val + 1
  end;
  SetScrollStyle(ScrollStyle);
end;


procedure TDesktop.Init;
begin
  TPanel.Init;
  TypeName := 'TDesktop';
  DrawBackground := true;
  BorderStyle := bsNone;
  ActiveControl := nil;
  ActiveMenu := nil;
  MouseOverControl := nil;
  ForeColor := icDesktop;
  BackColor := icDesktopBack;
  MenuBar := New(PMenuBar, CreateParent('DesktopMenuBar', @self));
  StatusBar := New(PStatusBar, CreateParent('DesktopStatusBar', @self));
end;

procedure TDesktop.Draw;
var
  rect: TRect;
begin
  GetBounds(rect);
  BorderStyle := bsNone;
  DrawBackground := true;
  TPanel.Draw;
end;

procedure TDesktop.GetClientRect(var rect: TRect);
begin
  rect.Create(0, 0, Txt^.Mode.Width, Txt^.Mode.Height);
end;

function TDesktop.FindNextControl(control: PControl): PControl;
var
  index: integer;
  par: PControl;
  current: PControl;
begin
  FindNextControl := nil;
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
     ActiveControl^.UnFocus;
     current^.Focus;
     ShowMouse;
    end;
  end
  else
  begin
    if (current <> nil) and (not current^.AcceptTab) then
      FindNextControl := FindNextControl(current);
  end;
end;

function TDesktop.FindPreviousControl(control: PControl): PControl;
begin

end;

procedure TDesktop.KeyPress(var key: word; var handled: boolean);
var
  control: PControl;
  stop: boolean;
begin
  if (key = 9) then
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
  end;
end;

procedure TStatusBar.Init;
begin
  TPanel.Init;
  TypeName := 'TStatusBar';
  Text := '';
  ForeColor := icMenu;
  BackColor := icMenuBack;
  BorderStyle := bsNone;
  TextPanel := New(PPanel, CreateParent('~TextPanel', @self));
end;

procedure TStatusBar.SetupControls;
var
  rect: TRect;
begin
  GetDesktop^.GetBounds(rect);
  SetBounds(0, rect.Bottom, rect.Width, rect.Bottom);
  with TextPanel^ do
  begin
    BorderStyle := bsNone;
    ForeColor := icMenu;
    BackColor := icMenuBack;
    SetBounds(0, 0, self.Width, self.Height);
  end;
end;

procedure TImage.Init;
begin
  TPanel.Init;
  TypeName := 'TImage';
  Drawbackground := false;
  BorderStyle := bsNone;
  ForeColor := White;
  BackColor := Black;
  Data := nil;
end;

procedure TImage.Draw;
var
  sourceRect, destRect: TRect;
begin
{  if ((not GetVisible) or (Data = nil)) then exit;
  GetClipRect(destRect);
  GetBounds(sourceRect);
  if (Parent <> nil) then
  begin
    sourceRect.Translate(Parent^.ScrollX, Parent^.ScrollY);
  end;
  Drawer.DrawImage(Data, Width, Height, sourceRect, destRect);}
end;

destructor TImage.Done;
begin
{  if (Data <> nil) then
    FreeMem(Data, Width * Height * 2);
  TPanel.Done;}
end;

procedure TStatusBar.ClearText;
var
  rect: TRect;
begin
{  ch.Character := 32;
  ch.Attributes := Drawer.GetCharAttributes(icMenuText, icMenuBack);
  TextPanel^.GetClipRect(rect);
  Drawer.FillRect(rect, ch);}
end;

procedure TStatusBar.Draw;
var
  rect: TRect;
begin
  if not GetVisible then exit;
  SetupControls;
  TPanel.Draw;
  TextPanel^.GetClipRect(rect);
  {Graphics.PushState;
  Graphics.SetForeColor(BorderColor);
  Graphics.HLine(rect.X, rect.Y, rect.Width);
  Graphics.PopState;
  ClearText;
  Graphics.DrawText(rect.X + 1, rect.Y, Text);}
end;

constructor TPopUp.Create(newId: string);
begin
  Id := newId;
  Enabled := true;
  OnMouseClick := nil;
  Init;
end;

constructor TPopUp.CreateParent(newId: string; newParent: PControl);
begin
  Id := newId;
  SetParent(newParent);
  Enabled := true;
  OnMouseClick := nil;
  Init;
end;

procedure TPopUp.Init;
begin
  TPanel.Init;
  TypeName := 'TPopUp';
  BackData := nil;
end;

destructor TPopUp.Done;
var
  rect: TRect;
begin
  GetBounds(rect);
  if (BackData <> nil) then
    FreeMem(BackData, rect.Width * rect.Height * 2);
  TPanel.Done;
end;

procedure TPopUp.Show;
var
  rect: TRect;
begin
{  GetClipRect(rect);
  HideMouse;
  if (BackData <> nil) then
    FreeMem(BackData, rect.Width * rect.Height * 2);
  GetMem(BackData, rect.Width * rect.Height * 2);
  Drawer.GetScreenRect(BackData, rect);
  TPanel.Show;
  ShowMouse;}
end;

procedure TPopUp.Hide;
var
  sourceRect, destRect: TRect;
begin
{  GetClipRect(destRect);
  HideMouse;
  sourceRect.Assign(destRect);
  sourceRect.Translate(-destRect.X, -destRect.Y);
  if (BackData <> nil) then
  begin
    Drawer.DrawImage(BackData, sourceRect.Width, sourceRect.Height, sourceRect, destRect);
    FreeMem(BackData, sourceRect.Width * sourceRect.Height * 2);
  end;
  BackData := nil;
  ShowMouse;
  TPanel.Hide;}
end;

constructor TMenu.Create(newId: string);
begin
  Id := newId;
  Enabled := true;
  OnMouseClick := nil;
  ParentItem := nil;
  Init;
end;

procedure TMenu.Init;
begin
  TPopUp.Init;
  TypeName := 'TMenu';
  ParentItem := nil;
  Position := spAbsolute;
  Visible := false;
  ForeColor := icMenu;
  BackColor := icMenuBack;
  BorderStyle := bsSingle;
  ActiveItem := nil;
end;

procedure TMenu.Draw;
begin
  if (not Visible) then exit;
  SetupControls;
  TPanel.Draw;
end;

procedure TMenu.Show;
begin;
{  OldCursorOn := Drawer.IsCursorOn;
  Drawer.CursorOff;
  SetupControls;
  TPopUp.Show;}
end;

procedure TMenu.Hide;
var
  destRect: TRect;
  sourceRect: TRect;
begin
{  if (not GetVisible) then exit;
  if (OldCursorOn) then
    Drawer.CursorOn
  else
    Drawer.CursorOff;
  TPopUp.Hide;}
end;

procedure TMenu.SetupControls;
var
  maxWidth: byte;
  index: word;
  item: PMenuItem;
  borderWidth: byte;
  hotKeyWidth: byte;
begin
  X := 0;
  Y := 0;
  maxWidth := 0;
  borderWidth := 1;
  if (BorderStyle = bsNone) then
    borderWidth := 0;
  if (Parent <> nil) and (TypeOf(Parent^) = TypeOf(TMenuItem)) then
  begin
    X := Parent^.X;
    Y := Parent^.Y + 1;
  end;
  if (Controls^.Count = 0) then exit;
  for index := 0 to Controls^.Count - 1 do
  begin
    item := PMenuItem(Controls^.GetItem(index));
    hotKeyWidth := 0; {Length(GetKeyDesc(item^.HotKey)) + 2;}
    if (item^.HotKey = 0) or (not item^.ShowHotKey) then
      hotKeyWidth := 0;
    if (Length(item^.Text) + hotKeyWidth + 2 > maxWidth) then
      maxWidth := Length(item^.Text) + hotKeyWidth + 2;
  end;
  Width := MaxWidth + 1 + 2 * borderWidth;
  Height := Controls^.Count + 2 * borderWidth;
  for index := 0 to Controls^.Count - 1 do
  begin
    item := PMenuItem(Controls^.GetItem(index));
    with item^ do
    begin
      TextAlign := taLeft;
      Margin := 0;
      X := 1;
      Y := index + 1;
      Width := MaxWidth + 1;
      Height := 1;
    end;
  end;
end;

procedure TMenu.KeyPress(var key: word; var handled: boolean);
var
  desktop: PDesktop;
  index: integer;
  newItem: PMenuItem;
begin
  if not (GetEnabled and GetVisible) then exit;
  desktop := GetDesktop;
  if (handled) then exit;
  if (desktop^.ActiveMenu = @self) then
  begin
    if (ActiveItem <> nil) then
    begin
      if (key = kDown) or (key = kUp) then
      begin
        handled := true;
        index := Controls^.IndexOf(ActiveItem);
        ActiveItem^.Pressed := false;
        ActiveItem^.Active := false;
        ActiveItem^.Draw;
        if (key = kDown) then
        begin
          Inc(index);
          if (index > Controls^.Count - 1) then
            index := 0;
          newItem := PMenuItem(Controls^.GetItem(index));
          while (newItem^.Separator) and (index + 1 < Controls^.Count) do
          begin
            Inc(index);
            newItem := PMenuItem(Controls^.GetItem(index));
          end;
        end
        else
        begin
          Dec(index);
          if (index < 0) then
            index := Controls^.Count - 1;
          newItem := PMenuItem(Controls^.GetItem(index));
          while (newItem^.Separator) and (index - 1 >= 0) do
          begin
            Dec(index);
            newItem := PMenuItem(Controls^.GetItem(index));
          end;
        end;
        ActiveItem := newItem;
        newItem^.Active := true;
        newItem^.Pressed := true;
        newItem^.Draw;
      end
    end;
    if (key = 27) then
    begin
      HideMouse;
      if (ParentItem = nil) then exit;
      ParentItem^.Pressed := false;
      ParentItem^.Active := false;
      ParentItem^.Draw;
      ActiveItem^.Pressed := false;
      ActiveItem^.Active := false;
      ActiveItem := nil;
      desktop^.ActiveMenu := nil;
      Hide;
      handled := true;
      ShowMouse;
    end;
  end;
end;

constructor TMenuItem.CreateText(newId, newText: string; newParent: PControl; newHotKey: word; click: PMouseEvent);
begin
  SetParent(newParent);
  Id := newId;
  Text := newText;
  Separator := false;
  MenuBar := nil;
  Enabled := true;
  HotKey := newHotKey;
  ShowHotKey := true;
  OnMouseClick := click;
  ParentMenu := nil;
  if (TypeOf(newParent^) = TypeOf(TMenu)) then
    ParentMenu := PMenu(newParent);
  Menu := nil;
  Init;
end;

constructor TMenuItem.CreateSeparator(newId: string; newParent: PControl);
begin
  SetParent(newParent);
  Id := 'MenuSeparator';
  Enabled := false;
  Text := '-';
  MenuBar := nil;
  ShowHotKey := false;
  Separator := true;
  ParentMenu := nil;
  if (TypeOf(newParent^) = TypeOf(TMenu)) then
    ParentMenu := PMenu(newParent);
  menu := nil;
  Init;
end;

constructor TMenuItem.CreateMenuBar
(
  newId,
  newText: string;
  newMenubar: PMenuBar;
  newMenu: PMenu;
  newHotKey: word;
  click: PMouseEvent
);
begin
  SetParent(newMenuBar);
  MenuBar := newMenuBar;
  Id := newId;
  Text := newText;
  Separator := false;
  Enabled := true;
  HotKey := newHotKey;
  ShowHotKey := false;
  OnMouseClick := click;
  ParentMenu := nil;
  Menu := newMenu;
  Init;
  newMenu^.SetParent(@self);
  newMenu^.ParentItem := @self;
end;

procedure TMenuItem.Init;
begin
  TButton.Init;
  TypeName := 'TMenuItem';
  ForeColor := icMenu;
  BackColor := icMenuBack;
  BorderStyle := bsNone;
  Grouped := true;
  Toggle := true;
end;

procedure TMenuItem.KeyPress(var key: word; var handled: boolean);
var
  state: TMouseState;
begin
  if (Menu <> nil) then
    Menu^.KeyPress(key, handled);
  if (handled) then exit;
  FillChar(state, SizeOf(State), 0);
  if (key = 13) and GetVisible and GetEnabled and Active then
  begin
    if (ParentMenu <> nil) then
    begin
      ParentMenu^.ActiveItem^.Pressed := false;
      ParentMenu^.ActiveItem^.Active := false;
      handled := true;
    end;
    state.ButtonState := [bsLeft];
    MouseClick(state);
  end;
end;

procedure TMenuItem.Draw;
var
  rect: TRect;
  desc: string;
begin
  if (not GetVisible) then exit;
{  Graphics.PushState;
  Graphics.SetForeColor(ForeColor);
  Graphics.SetBackColor(BackColor);
  if Separator then
  begin
    GetScreenBounds(rect);
    Graphics.SetForeColor(BorderColor);
    Graphics.HLine(rect.X, Rect.Y + (rect.Height div 2), rect.Width);
  end
  else
    TButton.Draw;
  if (ShowHotKey and (HotKey <> 0)) then
  begin
    if (Pressed or Active) then
    begin
      Graphics.SetForeColor(PressedForeColor);
      Graphics.SetBackColor(PressedBackColor);
    end;
    GetClipRect(rect);
    desc := '';{GetKeyDesc(HotKey);
    Graphics.DrawText(rect.X + rect.Width - Font^.TextWidth(desc), rect.Y, desc);
  end;
  Graphics.PopState;}
end;

procedure TMenuBar.Init;
var
  rect: TRect;
begin
  TPanel.Init;
  TypeName := 'TMenuBar';
  ForeColor := icMenu;
  BackColor := icMenuBack;
  BorderStyle := bsNone;
end;

procedure TMenuBar.SetupControls;
var
  index: word;
  currentX: word;
  control: PMenuItem;
begin
  currentX := 0;
  SetBounds(0, 0, GetDesktop^.Width, 1);
  if Controls^.Count = 0 then exit;
  for index := 0 to Controls^.Count - 1 do
  begin
    control := PMenuItem(Controls^.GetItem(index));
    with control^ do
    begin
      TextAlign := taCenter;
      X := currentX;
      Y := 0;
      Height := self.Height;
      Width := Length(TrueText(Text + '  '));
      Margin := 1;
      Inc(currentX, Width);
    end;
  end;
end;

function TMenuBar.ProcessHotKeys(control: PControl; key: word): boolean;
var
  index: integer;
  state: TMouseState;
  menuItem: PMenuItem;
  menu: PMenu;
  processed: boolean;
  handled: boolean;
begin
  handled := false;
  ProcessHotKeys := false;
  FillChar(state, SizeOf(state), 0);
  state.ButtonState := [bsLeft];
  for index := 0 to control^.Controls^.Count - 1 do
  begin
    begin
      menuItem := PMenuItem(control^.Controls^.GetItem(index));
      menu := nil;
      if (TypeOf(control^) = TypeOf(TMenuBar)) then
        menu := menuItem^.Menu;
      if (menu <> nil) then
      begin
         processed := ProcessHotKeys(menu, key);
        if (processed) then
        begin
          ProcessHotKeys := processed;
          exit;
        end;
      end
      else if (TypeOf(control^) = TypeOf(TMenu)) then
        menu := PMenu(control);
    end;
    if (key = menuItem^.HotKey) then
    begin
      handled := true;
      if (menu^.ActiveItem <> nil) and (menu^.GetVisible) then
      begin
        menu^.ActiveItem^.Pressed := false;
        menu^.ActiveItem^.Active := false;
        menu^.ActiveItem := nil;
      end;
      menuItem^.MouseDown(state);
      menuItem^.MouseClick(state);
      ProcessHotKeys := true;
      exit;
    end;
  end;
end;

function TMenuBar.ProcessArrowKeys(key: word): boolean;
var
  menu: PMenu;
  desktop: PDesktop;
  activeItem: PMenuItem;
  index: integer;
begin
  desktop := GetDesktop;
  ProcessArrowKeys := false;
  if (key = kLeft) or (key = kRight) and (desktop^.ActiveMenu <> nil) then
  begin
    menu := desktop^.ActiveMenu;
    activeItem := menu^.ParentItem;
    activeItem^.Pressed := false;
    activeItem^.Active := false;
    HideMouse;
    activeItem^.Draw;
    if (menu^.ActiveItem <> nil) then
    begin
      menu^.ActiveItem^.Pressed := false;
      menu^.ActiveItem^.Active := false;
      menu^.ActiveItem := nil;
    end;
    index := Controls^.IndexOf(menu^.ParentItem);
    if (key = kRight) then
    begin
      ProcessArrowKeys := true;
      menu^.Hide;
      Inc(index);
      if (index > Controls^.Count - 1) then
        index := 0;
    end;
    if (key = kLeft) then
    begin
      ProcessArrowKeys := true;
      menu^.Hide;
      Dec(index);
      if (index < 0) then
        index := Controls^.Count - 1;
    end;
    activeItem := PMenuItem(Controls^.GetItem(index));
    menu := activeItem^.Menu;
    activeItem^.Pressed := true;
    activeItem^.Active := true;
    activeItem^.Draw;
    menu^.ActiveItem := PMenuItem(menu^.Controls^.GetItem(0));
    desktop^.ActiveMenu := menu;
    menu^.ActiveItem^.Pressed := true;
    menu^.ActiveItem^.Active := true;
    menu^.Show;
    ShowMouse;
  end;
end;

procedure TMenuBar.KeyPress(var key: word; var handled: boolean);
var
  index, textIndex, controlIndex: integer;
  menuItem: PMenuItem;
  keyLetter: char;
  state: TMouseState;
  menu: PMenu;
  keyChar: char;
  desktop: PDesktop;
begin
  handled := false;
  desktop := GetDesktop;
  if not (GetEnabled and GetVisible) then exit;
  if (ProcessHotKeys(@self, key)) then exit;
  if (Desktop^.ActiveMenu = nil) then exit;
  menu := Desktop^.ActiveMenu;
  keyLetter := #0;
  for index := 0 to menu^.Controls^.Count do
  begin
    menuItem := PMenuItem(Controls^.GetItem(index));
    for textIndex := 1 to Length(menuItem^.Text) do
    begin
      if (menuItem^.Text[textIndex] = '&') then
      begin
        if textIndex + 1 <= Length(menuItem^.Text) then
        begin
          keyLetter := UpCase(menuItem^.Text[textIndex + 1]);
        end;
        break;
      end;
    end;
    if (ProcessArrowKeys(key)) then
    begin
      handled := true;
      exit;
    end;
    if (key < 127) and not (menu^.GetVisible) then exit;
    for controlIndex := 0 to menu^.Controls^.Count - 1 do
    begin
      keyLetter := #0;
      menuItem := PMenuItem(menu^.Controls^.GetItem(controlIndex));
      if (menuItem^.Separator) then continue;
      for textIndex := 1 to Length(menuItem^.Text) do
      begin
        if (menuItem^.Text[textIndex] = '&') then
        begin
          if textIndex + 1 <= Length(menuItem^.Text) then
          begin
            keyLetter := UpCase(menuItem^.Text[textIndex + 1]);
            break;
          end;
        end;
      end;
      if (KeyLetter <> #0) then
      begin
        keyChar := #0;
        if (key < 127) then keyChar := UpCase(Chr(key));
        if (keyChar = keyLetter) then
        begin
          handled := true;
          FillChar(state, SizeOf(state), 0);
          state.ButtonState := [bsLeft];
          menuItem^.MouseClick(state);
         exit;
        end;
      end;
    end;
  end;
end;

procedure TMenuItem.MouseEnter(var state: TMouseState);
var
  desktop: PDesktop;
begin
  if not (GetVisible and GetEnabled and not IsMouseOver) then exit;
  if (Separator) then exit;
  GetStatusBar^.Text := ToolTip;
  GetStatusBar^.Draw;
  if (Parent <> nil) then
  begin
    if (ParentMenu <> nil) then
    begin
      if (ParentMenu^.ActiveItem <> nil) and (ParentMenu^.ActiveItem^.Active) then
      begin
        ParentMenu^.ActiveItem^.Active := false;
        ParentMenu^.ActiveItem^.Pressed := false;
        ParentMenu^.ActiveItem^.Draw;
      end;
    end;
  end;
  Pressed := true;
  HideMouse;
  Draw;
  ShowMouse;
end;

procedure TMenuItem.MouseLeave(var state: TMouseState);
begin
  if not (GetVisible and GetEnabled) then exit;
  if (Separator) then exit;
  Pressed := false;
  HideMouse;
  GetStatusBar^.Text := '';
  GetStatusBar^.Draw;
  Draw;
  ShowMouse;
end;

procedure TMenuItem.MouseDown(var state: TMouseState);
var
  desktop: PDesktop;
  parentItem: PMenuItem;
begin
  TControl.MouseDown(state);
  if (not GetEnabled) then exit;
  desktop := GetDesktop;
  if (desktop^.ActiveMenu <> nil) and (desktop^.ActiveMenu <> ParentMenu) then
  begin
    desktop^.ActiveMenu^.Hide;
    parentItem := PMenuItem(desktop^.ActiveMenu^.ParentItem);
    if (parentItem <> nil) then
    begin
      parentItem^.Pressed := false;
      parentItem^.Active := false;
      HideMouse;
      parentItem^.Draw;
      ShowMouse;
    end;
  end;
  if (Menu <> nil) then
  begin
    desktop^.ActiveMenu := Menu;
    Pressed := true;
    if (not Active) then
    begin
      Active := true;
      HideMouse;
      Menu^.ActiveItem := PMenuItem(Menu^.Controls^.GetItem(0));
      Menu^.ActiveItem^.Pressed := true;
      Menu^.ActiveItem^.Active := true;
      Menu^.Show;
      Draw;
      ShowMouse;
    end;
  end;
end;

procedure TMenuItem.MouseClick(var state: TMouseState);
var
  menuItem: PMenuItem;
  desktop: PDesktop;
begin
  if not (GetEnabled) then exit;
  if (ParentMenu <> nil) then
  begin
    ParentMenu^.ActiveItem := nil;
    Pressed := false;
    Active := false;
    IsMouseOver := false;
    if (ParentMenu^.ParentItem <> nil) then
    begin
      menuItem := PMenuItem(ParentMenu^.ParentItem);
      menuItem^.Pressed := false;
      menuItem^.Active := false;
      HideMouse;
      menuItem^.Draw;
      ParentMenu^.Hide;
      ShowMouse;
    end;
    desktop := GetDesktop;
    desktop^.ActiveMenu := nil;
  end;

  if (OnMouseClick <> nil) then
    TMouseEvent(OnMouseClick)(@self, state);
end;

procedure TMenuBar.Draw;
var
  rect: TRect;
begin
  SetupControls;
  TPanel.Draw;
  GetScreenBounds(rect);
 { Graphics.PushState;
  Graphics.SetForeColor(BorderColor);
  Graphics.HLine(rect.X, rect.Bottom, rect.Width);
  Graphics.PopState; }
end;

procedure TDialog.Init;
begin
  TWindow.Init;
  Buttons := New(PButtonList, Create('~Buttons'));
  Buttons^.DisposeObjects := false;
  Modal := true;
  ForeColor := icDialog;
  BackColor := icDialogBack;
  Visible := false;
  CancelButton := nil;
  AcceptButton := nil;
  OldFocusedControl := nil;
end;

procedure TDialog.Draw;
var
  index: integer;
begin
  SetupControls;
  HideMouse;
  TWindow.Draw;
  ShowMouse;
end;

procedure TDialog.AddButton(button: PDialogButton; accept, cancel: boolean; click: PMouseEvent);
begin
  button^.SetParent(Contents);
  Buttons^.Add(button);
  button^.OnMouseClick := Click;
  button^.Dialog := @Self;
  if (accept) then
  begin
    AcceptButton := button;
  end;
  if (cancel) then
  begin
    CancelButton := button;
  end;
end;

procedure TDialog.SetupControls;
var
  index: integer;
  currentX: integer;
  button: PButton;
  rect: TRect;
begin
  if (Buttons^.Count = 0) then exit;
  GetClientRect(rect);
  currentX := rect.Width;
  for index := Buttons^.Count - 1 downto 0 do
  begin
    button := PButton(Buttons^.GetItem(index));
    button^.Width := Length(button^.Text) + 2;
    if (button^.Width < 6) then
      button^.Width := 6;
    button^.Height := 1;
    Dec(currentX, button^.Width + 1);
    button^.X := currentX;
    button^.Y := rect.Height - 1;
  end;
  TWindow.SetupControls;
end;

procedure TDialog.KeyPress(var key: word; var handled: boolean);
var
  state: TMouseState;
begin
  FillChar(state, SizeOf(state), 0);
  state.ButtonState := [bsLeft];
  if (key = 27) and (cancelButton <> nil) then
    CancelButton^.MouseClick(state)
  else if (key = 13) and (acceptButton <> nil) then
    acceptButton^.MouseClick(state);
end;

procedure TDialog.Show;
var
  desktop: PDesktop;
  handled: boolean;
begin
  desktop := GetDesktop;
  desktop^.MenuBar^.Enabled := false;
  OldFocusedControl := desktop^.ActiveControl;
  TWindow.Show;
  Handled := false;
  FocusFirst(handled);
end;

procedure TDialog.Hide;
var
  desktop: PDesktop;
begin
{  desktop := GetDesktop;
  if (desktop^.ActiveControl <> nil) then
  begin
    desktop^.ActiveControl^.UnFocus;
  end;
  if (OldFocusedControl <> nil) then
    OldFocusedControl^.Focus
  else
    Drawer.CursorOff;
  TWindow.Hide;
  desktop^.MenuBar^.Enabled := true;}
end;

destructor TDialog.Done;
begin
  Dispose(Buttons, Done);
end;

procedure TDialogButton.MouseClick(var state: TMouseState);
var
  desktop: PDesktop;
begin
  desktop := Dialog^.GetDesktop;
  HideMouse;
  Pressed := false;
  Dialog^.Hide;
  ShowMouse;
  if (OnMouseClick <> nil) then
    TMouseEvent(OnMouseClick)(@self, state);
end;

procedure TEditor.Init;
begin
{  TPanel.Init;
  TypeName := 'TEditor';
  SelectStart := -1;
  SelectEnd := -1;
  SelectText := icSelectText;
  SelectBack := icSelectBack;
  Selecting := false;
  WordDelimiters := DefaultWordDelimiters;
  Text := New(PWideString, Create);
  MaxLength := 255;
  CharSet := kAlphaNumeric + kPuncuation + [chr(32)];}
end;

destructor TEditor.Done;
begin
  if (Text <> nil) then
    dispose(Text, done);
end;

procedure TEditor.Draw;
begin
  TPanel.Draw;
end;

procedure TEditor.MouseDown(var state: TMouseState);
begin
  if not (GetVisible and GetEnabled) then exit;
  if not Focused then
    Focus;
  SelectStart := state.X + ScrollX;
  if (SelectStart > Text^.Len) then
    SelectStart := Text^.Len;
  SelectEnd := SelectStart - 1;
  Selecting := true;
  Manipulating := true;
  TextX := MaxL(MinL(state.X, Text^.Len - ScrollX), 0);
  SetXY(TextX, TextY);
  Draw;
  ShowMouse;
  TPanel.MouseDown(state);
end;

procedure TEditor.MouseClick(var state: TMouseState);
begin
  TPanel.MouseClick(state);
end;

procedure TEditor.MouseUp(var state: TMouseState);
begin
  if (Selecting) then
  begin
    Selecting := false;
    Manipulating := false;
    if (SelectEnd < SelectStart) and (SelectEnd >= 0) then
      SwapL(SelectStart, SelectEnd);
  end;
  TPanel.MouseMove(state);
end;

procedure TEditor.MouseMove(var state: TMouseState);
var
  rect: TRect;
begin
  GetClientRect(rect);
  if not (GetVisible and GetEnabled) then exit;
  if (Selecting) then
  begin
    state.X := MinL(state.X, rect.Width - 1);
    SelectEnd := state.X + ScrollX;
    if (SelectEnd > Text^.Len - 1) then
      SelectEnd := Text^.Len - 1;
    if (SelectEnd < 0) then
      SelectEnd := 0;
    TextX := MaxL(MinL(state.X, Text^.Len - ScrollX), 0);
    Draw;
    ShowMouse;
    SetXY(TextX, TextY);
  end;
  TPanel.MouseMove(state);
end;

procedure TEditor.SelectAll;
begin
  if (Text^.Len = 0) then exit;
  SelectStart := 0;
  SelectEnd := Text^.Len - 1;
  Draw;
end;

procedure TEditor.Select(startPos, endPos: longint);
begin
  SelectStart := startPos;
  SelectEnd := endPos;
  Draw;
end;

procedure TEditor.SelectNone;
begin
  SelectStart := -1;
  SelectEnd := -1;
  Draw;
end;

procedure TEditor.Focus;
begin
  TPanel.Focus;
  if (SelectStart < 0) or (SelectEnd < SelectStart) then
    SelectAll;
end;

procedure TEditor.Unfocus;
begin
  TPanel.Unfocus;
  Draw;
end;

procedure TEditBox.Init;
begin
  TEditor.Init;
  TypeName := 'TEditBox';
  BorderStyle := bsNone;
  CanFocus := true;
  UsesCursor := true;
  ForeColor := icEditor;
  BackColor := icEditorBack;
  DrawBackground := false;
end;

procedure TEditBox.DrawChar(index: word; rect: TRect);
var
  ch: char;
  xPos: word;
begin
{  ch := #32;
  xPos := index;
  if (xPos < Text^.Len) then
    ch := Text^.GetChar(xPos);
  Drawer.BackColor := BackColor;
  Drawer.ForeColor := ForeColor;
  if ((SelectEnd >= SelectStart) and (xPos >= SelectStart) and (xPos <= SelectEnd))
    or ((SelectEnd < SelectStart) and (xPos > SelectEnd) and (xPos < SelectStart)) then
  begin
    Drawer.ForeColor := SelectText;
    Drawer.BackColor := SelectBack;
  end;
  Drawer.DrawText(ch, rect.X + index - ScrollX, rect.Y, rect);}
end;

procedure TEditBox.Draw;
var
  rect: TRect;
  index: integer;
begin
{  if (not GetVisible) or (Text^.Len = 0) then exit;
  GetClipRect(rect);
  Drawer.CursorOff;
  TPanel.Draw;
  for index := 0 to rect.Width - 1 do
  begin
    DrawChar(index + ScrollX, rect);
  end;
  Drawer.CursorOn;}
end;

procedure TEditBox.CursorHome;
begin
{  if (TextX > 0) or (ScrollX > 0) then
  begin
    TextX := 0;
    ScrollX := 0;
    SetXY(TextX, TextY);
    Selecting := false;
    Manipulating := false;
    if (SelectStart >= 0) then
      SelectNone;
    if (DrawEnabled) then
      Draw;
  end;}
end;

procedure TEditBox.CursorEnd;
begin
  if (TextX + ScrollX < Text^.Len) then
  begin
    TextX := MinL(Width - 1, Text^.Len);
    ScrollX := LongInt(Text^.Len) - Width + 1;
    if (ScrollX < 0) then ScrollX := 0;
    SetXY(TextX, TextY);
    Selecting := false;
    Manipulating := false;
    if (SelectStart >= 0) then
      SelectNone;
    if (DrawEnabled) then
      Draw;
  end;
end;

procedure TEditBox.CursorLeft;
var
  doDraw: boolean;
begin
  doDraw := false;
  Selecting := false;
  Manipulating := false;
  if (ScrollX = 0) and (TextX = 0) then exit;
  if (TextX - 1 < 0) then
  begin
    if (ScrollX > 0) then
      Dec(ScrollX);
    doDraw := true;
  end
  else
  begin
    SetXY(TextX - 1, TextY);
  end;
  if (SelectStart >= 0) then
  begin
    SelectNone;
    doDraw := true;
  end;
  if (doDraw and DrawEnabled) then
    Draw;
end;

procedure TEditBox.CursorRight;
var
  doDraw: boolean;
begin
  doDraw := false;
  begin
    if Selecting then
    begin

    end
    else
    begin
      SelectStart := TextX + ScrollX;
      SelectEnd := SelectStart + 1;
      Selecting := true;
    end;
  end;
  Selecting := false;
  Manipulating := false;
  if (TextX + ScrollX > Text^.Len - 1) then exit;
  if (TextX + 1 > Width - 1) then
  begin
    if (ScrollX + TextX < Text^.Len) then
      Inc(ScrollX);
    SetXY(TextX, TextY);
    doDraw := true;
  end
  else
  begin
    SetXY(TextX + 1, TextY);
  end;
  if (SelectStart >= 0) then
  begin
    SelectNone;
    doDraw := true;
  end;
  if (doDraw and DrawEnabled) then
    Draw;
end;

procedure TEditBox.BackSpace;
var
  oldStart, oldEnd: longint;
begin
  Selecting := false;
  Manipulating := false;
  if (ScrollX = 0) and (TextX = 0) then exit;
  DrawEnabled := false;
  oldStart := SelectStart;
  oldEnd := SelectEnd;
  CursorLeft;
  SelectStart := oldStart;
  SelectEnd := oldEnd;
  Del;
  DrawEnabled := true;
end;

procedure TEditBox.Del;
var
  rect: TRect;
  index: word;
  xPos: word;
begin
  GetClipRect(rect);
  Selecting := false;
  Manipulating := false;
  if (TextX + ScrollX >= Text^.Len) and (SelectStart < 0) then exit;
  xPos := TextX + ScrollX;
  if (SelectStart >= 0) and (SelectEnd >= SelectStart) then
  begin
    while (SelectEnd > SelectStart) do
    begin
      Text^.Delete(SelectStart);
      Dec(SelectEnd);
    end;
    TextX := SelectEnd - ScrollX;
    if (TextX < 0) then
      TextX := 0;
    SetXY(TextX, TextY);
    SelectNone;
  end
  else
  begin
    Text^.Delete(xPos);
  end;
  for index := TextX to TextX + rect.Width - 1 do
    DrawChar(index + ScrollX, rect);
end;

procedure TEditBox.CursorCtrlRight;
var
  index: word;
  ch: char;
  rect: TRect;
  found: boolean;
  charIndex: integer;
begin
  index := TextX + ScrollX;
  Selecting := false;
  Manipulating := false;
  if (index >= Text^.Len) then exit;
  GetClientRect(rect);
  found := false;
  repeat
    ch := Text^.GetChar(index);
    if (ch in WordDelimiters) then
    begin
      found := true;
      while (ch in WordDelimiters) do
      begin
        if (index + 1 > Text^.Len) then
          break;
        Inc(index);
        ch := Text^.GetChar(index);
      end;
    end
    else
      Inc(index);
  until (index + 1 > Text^.Len - 1) or found;
  if (index < TextX + ScrollX) then exit;
  DrawEnabled := false;
  for charIndex := (TextX + ScrollX) to index - 1 do
    CursorRight;
  DrawEnabled := true;
  Draw;
end;

procedure TEditBox.CursorCtrlLeft;
var
  index: longint;
  ch: char;
  rect: TRect;
  found: boolean;
  charIndex: longint;
begin
  index := TextX + ScrollX - 1;
  Selecting := false;
  Manipulating := false;
  if (index <= 0) then exit;
  GetClientRect(rect);
  found := false;

  ch := Text^.GetChar(index);
  while (ch in WordDelimiters) do
    begin
    if (index <= 0) then
      break;
    Dec(index);
    ch := Text^.GetChar(index);
  end;
  while not (ch in WordDelimiters) do
  begin
    if (index <= 0) then
      break;
    Dec(index);
    ch := Text^.GetChar(index);
  end;
  if (index > 0) then
    Inc(index);
  if (index < 0) then index := 0;
  if (index + 1 > TextX + ScrollX) then
    exit;
  DrawEnabled := false;
  for charIndex := (TextX + ScrollX) downto index + 1 do
    CursorLeft;
  DrawEnabled := true;
  Draw;
end;

procedure TEditBox.KeyPress(var key: word; var handled: boolean);
var
  ch: char;
begin
  if not (GetVisible and GetEnabled and Focused) then exit;
  Selecting := false;
  Manipulating := false;
  if (Key = kDel) then
  begin
    handled := true;
    Del;
  end;
  if (key = kBackSpace) then
  begin
    handled := true;
    BackSpace;
  end;
  if (key = kLeft) then
  begin
    handled := true;
    CursorLeft;
  end;
  if (key = kRight) then
  begin
    handled := true;
    CursorRight
  end;
  if (Key = kHome) then
  begin
    handled := true;
    CursorHome;
  end;
  if (Key = kEnd) then
  begin
    handled := true;
    CursorEnd;
  end;
  if (Key = kCtrlLeft) then
  begin
    handled := true;
    CursorCtrlLeft;
  end;
  if (Key = kCtrlRight) then
  begin
    handled := true;
    CursorCtrlRight;
  end;

  if (key >= 32) and (key < 127) and (char(key) in CharSet) then
  begin
    if (SelectStart >= 0) and (SelectEnd > SelectStart) then
      Del;
    handled := true;
    if (Text^.Len + 1 > MaxLength) then exit;
    if (TextX > Width - 2) then
    begin
      Inc(ScrollX);
    end
    else
    begin
      SetXY(TextX + 1, TextY);
    end;
    if (TextX + ScrollX > Text^.Len) then
      Text^.Append(Chr(key))
    else
      Text^.Insert(TextX + ScrollX, Chr(key));
    Draw;
  end;
end;

procedure TIntegerEdit.Init;
begin
  TPanel.Init;
  TypeName := 'TIntegerEdit';
  MinValue := 0;
  MaxValue := High(longInt);
  AllowNegative := false;
  CanFocus := true;
  BorderStyle := bsNone;
  Value := 0;
  ForeColor := icEditor;
  BackColor := icEditorBack;
  IncButton := New(PButton, CreateText('~IncButton', Chr(26), @self));
  DecButton := New(PButton, CreateText('~DecButton', Chr(27), @self));
  EditEntry := New(PEditBox, CreateParent('~EditEntry', @self));
end;

procedure IntegerEditKeyPress(var key: word; self: PControl; var handled: boolean); far;
begin
  with PIntegerEdit(self)^ do
  begin
    if (key = Ord('-')) and (EditEntry^.TextX + EditEntry^.ScrollX > 1) then
      handled := true;
  end;
end;

procedure TIntegerEdit.SetupControls;
var
  valueString: string;
  maxValueString: string;
  minValueString: string;
  textWidth: integer;
begin
  ValueString := IntToStr(Value);
  maxValueString := IntToStr(MaxValue);
  minValueString := IntToStr(MinValue);
  textWidth := MaxL(Length(minValueString), Length(maxValueString));
  EditEntry^.SetBounds(2, 0, textWidth + 1, 1);
  EditEntry^.OnKeyPress := @IntegerEditKeyPress;
  EditEntry^.Text^.SetString(IntToStr(Value));
  EditEntry^.CharSet := kNumeric;
  EditEntry^.ForeColor := icEditor;
  EditEntry^.BackColor := icEditorBack;
  EditEntry^.CanFocus := true;
  EditEntry^.UsesCursor := true;
  EditEntry^.MaxLength := textWidth;
  if (AllowNegative) then
  begin
    Include(EditEntry^.Charset, '-');
  end;
  IncButton^.SetBounds(textWidth + 4, 0, 1, 1);
  IncButton^.CanFocus := false;
  DecButton^.SetBounds(0, 0, 1, 1);
  DecButton^.CanFocus := false;
  Width := textWidth + 5;
  Height := 1;
end;

procedure TIntegerEdit.Draw;
begin
  SetupControls;
  TPanel.Draw;
end;

end.
