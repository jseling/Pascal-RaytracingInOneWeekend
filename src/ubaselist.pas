unit uBaseList;

interface

{$inline on}

uses
  Classes,
  SysUtils;

type
  TBaseList = class
  private
    FList: array of TObject;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(Obj: TObject): TBaseList;
    function Get(Index: Integer): TObject; inline;
    function Count: Integer; inline;
  end;

implementation

constructor TBaseList.Create;
begin
  SetLength(FList, 0);
end;

destructor TBaseList.Destroy;
var
  i: integer;
begin
  for i := 0 to Self.Count - 1 do
  begin
    FList[i].Free;
  end;

  inherited;
end;

function TBaseList.Add(Obj: TObject): TBaseList;
begin
  Result := Self;

  SetLength(FList, Length(FList) + 1);
  FList[High(FList)] := Obj;
end;

function TBaseList.Get(Index: Integer): TObject;
begin
  Result := FList[Index];
end;

function TBaseList.Count: Integer;
begin
  Result := Length(FList);
end;

end.

