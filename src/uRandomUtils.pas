unit uRandomUtils;

interface

uses
  uVectorTypes;

type
  TRandomUtils = class
  public
    class function RandomSingle(): Single; overload;
    class function RandomSingle(_AMin, _AMax: Single): Single; overload;
    class function RandomVector(): TVector3f; overload;
    class function RandomVector(_AMin, _AMax: Single): TVector3f; overload;
    class function RandomInUnitSphere(): TVector3f;
  end;

implementation

{ TRandomUtils }

class function TRandomUtils.RandomSingle(): Single;
begin
 Result := Random();
end;

class function TRandomUtils.RandomInUnitSphere: TVector3f;
begin
//  while (true) do
//  begin
//    Result := RandomVector(-1, 1);
//    if (Result.MagnitudeSquared() >= 1) then
//      Continue;
//    Break;
//  end;
  repeat
    Result := RandomVector(-1, 1)
  until (Result.MagnitudeSquared() < 1);
end;

class function TRandomUtils.RandomSingle(_AMin, _AMax: Single): Single;
begin
 Result := _AMin + (_AMax -_AMin) * RandomSingle();
end;

class function TRandomUtils.RandomVector(_AMin, _AMax: Single): TVector3f;
begin
  Result.Create(RandomSingle(_AMin, _AMax), RandomSingle(_AMin, _AMax), RandomSingle(_AMin, _AMax));
end;

class function TRandomUtils.RandomVector: TVector3f;
begin
  Result.Create(RandomSingle(), RandomSingle(), RandomSingle());
end;

initialization
  Randomize();

end.
