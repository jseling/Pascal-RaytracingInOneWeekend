unit uRaytracerTypes;

interface

uses
  uVectorTypes;

type
  TRay = record
  public
    Orig: TVector3f;
    Dir: TVector3f;
    procedure Create(_AOrig, _ADir: TVector3f);
    function At(_AFactor: Single): TVector3f;
  end;

  TBaseMaterial = class;

  THit = record
  public
    Point: TVector3f;
    Normal: TVector3f;
    Material: TBaseMaterial;
    t: Single;
    FrontFace: Boolean;
    procedure Create(_APoint, _ANormal: TVector3f; _At: Single);
    procedure SetFaceNormal(_ARay: TRay; _ANormal: TVector3f);
  end;

  TBaseMaterial = class
  public
    Name: string;
    Albedo: TVector3f;
    function Scatter(_ARayIn: TRay; _AHit: THit; out _AColorAttenuation: TVector3f; out _ARayScattered: TRay): Boolean; virtual; abstract;
  end;


implementation

{ TRay }

function TRay.At(_AFactor: Single): TVector3f;
begin
  Result := Orig.Add(Dir.Scale(_AFactor));
end;

procedure TRay.Create(_AOrig, _ADir: TVector3f);
begin
  Orig := _AOrig;
  Dir := _ADir;
end;

{ THit }

procedure THit.Create(_APoint, _ANormal: TVector3f; _At: Single);
begin
  Point := _APoint;
  Normal := _ANormal;
  t := _At;
end;

procedure THit.SetFaceNormal(_ARay: TRay; _ANormal: TVector3f);
begin
  FrontFace := _ARay.Dir.DotProduct(_ANormal) < 0;

  if FrontFace then
    Normal := _ANormal
  else
    Normal := _ANormal.Scale(-1);
end;

end.
