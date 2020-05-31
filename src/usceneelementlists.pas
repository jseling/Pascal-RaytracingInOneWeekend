unit uSceneElementLists;

interface

{$inline on}

uses
  Classes,
  SysUtils,
  uBaseList,
  uSceneElements;

type
  TMeshObjectList = class(TBaseList)
  public
    function Get(Index: Integer): TMeshObject; reintroduce; inline;
  end;

  TLightList = class(TBaseList)
  public
    function Get(Index: Integer): TLight; reintroduce; inline;
  end;

  TMaterialList = class(TBaseList)
  public
    function Get(Index: Integer): TMaterial; reintroduce; inline;
    function GetByName(const _AName: string): TMaterial;
  end;

implementation

function TMeshObjectList.Get(Index: Integer): TMeshObject;
begin
  Result := TMeshObject(inherited Get(Index));
end;

function TLightList.Get(Index: Integer): TLight;
begin
  Result := TLight(inherited Get(Index));
end;

function TMaterialList.Get(Index: Integer): TMaterial;
begin
  Result := TMaterial(inherited Get(Index));
end;

function TMaterialList.GetByName(const _AName: string): TMaterial;
var
  i: integer;
  AMaterial: TMaterial;
begin
  for i := 0 to Self.Count -1 do
  begin
    AMaterial := Self.Get(i);

    if AMaterial <> nil then
      if AMaterial.Name = _AName then
      begin
        result := AMaterial;
        exit;
      end;
  end;

  result := nil;
end;

end.

