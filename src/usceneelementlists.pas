unit uSceneElementLists;

interface

{$inline on}

uses
  Classes,
  SysUtils,
  uBaseList,
  uSceneElements,
  uRaytracerTypes;

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
    function Get(Index: Integer): TBaseMaterial; reintroduce; inline;
    function GetByName(const _AName: string): TBaseMaterial;
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

function TMaterialList.Get(Index: Integer): TBaseMaterial;
begin
  Result := TBaseMaterial(inherited Get(Index));
end;

function TMaterialList.GetByName(const _AName: string): TBaseMaterial;
var
  i: integer;
  AMaterial: TBaseMaterial;
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

