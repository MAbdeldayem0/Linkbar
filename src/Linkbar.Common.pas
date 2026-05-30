{*******************************************************}
{          Linkbar - Windows desktop toolbar            }
{            Copyright (c) 2010-2021 Asaq               }
{*******************************************************}

unit Linkbar.Common;

{$i linkbar.inc}

interface

uses
  Windows, SysUtils, Classes;

  procedure ReduceSysMenu(AWnd: HWND);
  procedure PreventSizing(var AResult: LPARAM);
  function RemovePrefix(A: string): string;
  procedure SilentDisplayTransitionException(Sender: TObject; E: Exception);

implementation

function RemovePrefix(A: string): string;
begin
  Result := StringReplace(A, '&', '', []);
end;

procedure ReduceSysMenu(AWnd: HWND);
var menu: HMENU;
    i: Integer;
    id: Cardinal;
begin
  menu := GetSystemMenu(AWnd, False);
  if (menu > 0)
  then begin
    i := 0;
    while i < GetMenuItemCount(menu) do
    begin
      id := GetMenuItemID(menu, i);
      if (id = SC_CLOSE) or (id = SC_MOVE)
      then Inc(i)
      else DeleteMenu(menu, id, MF_BYCOMMAND);
    end;
  end;
end;

procedure PreventSizing(var AResult: LPARAM);
begin
  if (AResult = HTCAPTION)
     or (AResult = HTCLOSE)
     or (AResult = HTNOWHERE)
     or (AResult = LPARAM(HTERROR))
  then Exit;

  if (AResult = HTTOP) or (AResult = HTTOPLEFT) or (AResult = HTTOPRIGHT)
  then AResult := HTCAPTION
  else AResult := HTCLIENT;
end;

procedure SilentDisplayTransitionException(Sender: TObject; E: Exception);
begin
  // GDI+ raises EGdipError('Out of Memory') when it's handed a NULL HDC or a
  // bitmap with 0-dim. This happens transiently while a slow display (OLED,
  // DP-MST) is waking up and the bar's backing bitmap is mid-recreate. Without
  // this handler each paint cycle during the gap pops its own modal dialog,
  // stacking several before the bar settles. Swallow only that exact message
  // so genuine bugs still surface through the default handler.
  if (E <> nil) and (E.Message = 'Out of Memory')
  then Exit;

  // Default: let Application show it.
  if (E <> nil)
  then SysUtils.ShowException(E, ExceptAddr);
end;

end.
