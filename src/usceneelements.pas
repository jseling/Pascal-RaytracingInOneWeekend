unit uSceneElements;

interface

uses
  uVectorTypes,
  System.SysUtils,
  uRayTracerTypes,
  uRandomUtils;

type

  TLight = class
  public
    Position: TVector3f;
    Intensity: Single;
  end;


  { TMaterial }

  TLambertianMaterial = class(TBaseMaterial)
  public
    function Scatter(_ARayIn: TRay; _AHit: THit; out _AColorAttenuation: TVector3f; out _ARayScattered: TRay): Boolean; override;
  end;

  TMetalMaterial = class(TBaseMaterial)
  public
    Fuzz: Single;
    function Scatter(_ARayIn: TRay; _AHit: THit; out _AColorAttenuation: TVector3f; out _ARayScattered: TRay): Boolean; override;
  end;

  TMeshObject = class
  public
    Center: TVector3f;
    Material: TBaseMaterial;

    function RayIntersect(_ARay: TRay; _At_min, _At_max: Single; out _AHit: THit): Boolean; virtual; abstract;
  end;

  TSphere = class(TMeshObject)
  private
    FInvRadius: Single;
    FRadius: Single;
    procedure SetRadius(_AValue: Single);
  public
    property Radius: Single read FRadius write SetRadius;
    function RayIntersect(_ARay: TRay; _At_min, _At_max: Single;  out _AHit: THit): Boolean; override;
    function InvRadius(): Single;
  end;

  TCamera = class
  public
    Position: TVector3f;
    LowerLeftCorner: TVector3f;
    FOV: Single;
    Horizontal: TVector3f;
    Vertical: TVector3f;
    Height,
    Width: Integer;
//    BackgroundColor: TVector3f;

    constructor Create();
    function GetRay(u, v: Single): TRay;

  end;

implementation

{ TSphere }

function TSphere.InvRadius: Single;
begin
  result := FInvRadius;
end;

function TSphere.RayIntersect(_ARay: TRay; _At_min, _At_max: Single;  out _AHit: THit): Boolean;
var
  oc: TVector3f;
  a, half_b, c: Single;
  discriminant: Single;
  root, temp: Single;
  normal: TVector3f;
begin
  oc := _ARay.Orig.Subtract(Center);
  a := _ARay.Dir.MagnitudeSquared();
  half_b := oc.DotProduct(_ARay.Dir);
  c := oc.MagnitudeSquared() - Radius * Radius;
  discriminant := half_b * half_b - a * c;

  if discriminant <= 0 then
  begin
    result := false;
    exit;
  end;

  root := sqrt(discriminant);

  temp := (-half_b - root) / a;
  if (temp < _At_max) and (temp > _At_min) then
  begin
    _AHit.t := temp;
    _AHit.Point := _ARay.At(_AHit.t);

    normal := _AHit.Point.Subtract(Center).Scale(InvRadius());
    _AHit.SetFaceNormal(_ARay, normal);
    _AHit.Material := Material;

    result := true;
    exit;
  end;

  temp := (-half_b + root) / a;
  if (temp < _At_max) and (temp > _At_min) then
  begin
    _AHit.t := temp;
    _AHit.Point := _ARay.At(_AHit.t);

    normal := _AHit.Point.Subtract(Center).Scale(InvRadius());
    _AHit.SetFaceNormal(_ARay, normal);
    _AHit.Material := Material;

    result := true;
    exit;
  end;

  result := false;
end;

procedure TSphere.SetRadius(_AValue: Single);
begin
  if (_AValue <= 0) then
    raise Exception.Create('TSphere: Invalid radius value setting.');

  FRadius := _AValue;
  FInvRadius := 1 / FRadius;
end;

{ TCamera }

constructor TCamera.Create;
var
  aspect_ratio: Single;
  viewport_height: Single;
  viewport_width: Single;
  f: TVector3f;
begin
  aspect_ratio := 4 / 3;
  viewport_height := 2;
  viewport_width := viewport_height * aspect_ratio;

  FOV := 1;
  f.Create(0, 0, FOV);

  Position.Create(0,0,0);
  Horizontal.Create(viewport_width,0,0);
  Vertical.Create(0,viewport_height,0);
  LowerLeftCorner := Position.Subtract(Horizontal.Scale(1/2)).Subtract( Vertical.scale(1/2)).Subtract(f);
end;

function TCamera.GetRay(u, v: Single): TRay;
var
  AOrig,
  ADir: TVector3f;
begin
  AOrig := Self.Position;
  ADir := LowerLeftCorner.Add(Horizontal.Scale(u)).Add(Vertical.Scale(v)).Subtract(AOrig);
  //ADir := Adir.Normalize();

  Result.Create(AOrig, ADir);
end;

{ TLambertianMaterial }

function TLambertianMaterial.Scatter(_ARayIn: TRay; _AHit: THit; out _AColorAttenuation: TVector3f;
  out _ARayScattered: TRay): Boolean;
var
  scatter_direction: TVector3f;
begin
  scatter_direction := _AHit.Normal.Add(TRandomUtils.RandomUnitVector());
  _ARayScattered.Create(_AHit.Point, scatter_direction);
  _AColorAttenuation := Albedo;

  Result := True;
end;

{ TMetalMaterial }

function TMetalMaterial.Scatter(_ARayIn: TRay; _AHit: THit; out _AColorAttenuation: TVector3f;
  out _ARayScattered: TRay): Boolean;
var
  reflect: TVector3f;
begin
  reflect := _ARayIn.Dir.Reflect(_AHit.Normal);
  reflect := reflect.Add(TRandomUtils.RandomInUnitSphere().Scale(Fuzz));
  _ARayScattered.Create(_AHit.Point, reflect);
  _AColorAttenuation := Albedo;

  Result := _ARayScattered.Dir.DotProduct(_AHit.Normal) > 0;
end;

end.
