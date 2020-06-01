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
    class function RandomUnitVector(): TVector3f;
    class function RandomInHemisphere(_ANormal: TVector3f): TVector3f;
  end;

implementation

{ TRandomUtils }

class function TRandomUtils.RandomSingle(): Single;
begin
 Result := Random();
end;

class function TRandomUtils.RandomInHemisphere(_ANormal: TVector3f): TVector3f;
var
  in_unit_sphere: TVector3f;
begin
  in_unit_sphere := RandomInUnitSphere();
  if (in_unit_sphere.DotProduct(_ANormal) > 0) then// In the same hemisphere as the normal
    result := in_unit_sphere
  else
    result := in_unit_sphere.Scale(-1);
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

class function TRandomUtils.RandomUnitVector: TVector3f;
var
  a,
  z,
  r: single;
begin
  a := RandomSingle(0, 2 * PI);
  z := RandomSingle(-1, 1);
  r := sqrt(1 - z*z);
    Result.Create(r * cos(a), r * sin(a), z);
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
