unit uSceneElements;

interface

uses
  uVectorTypes, System.SysUtils;

type

  TLight = class
  public
    Position: TVector3f;
    Intensity: Single;
  end;

  { TMaterial }

  TMaterial = class
  public
    Name: string;
    DiffuseColor: TVector3f;
    Albedo: TVector4f;
    SpecularExponent: Single;
    RefractiveIndex: Single;
    constructor Create(const _AName: string);
    function CalculateDiffuseColorInScene(const _ADiffuseLightIntensity: Single): TVector3f;
    function CalculateSpecularColorInScene(const _ASpecularLightIntensity: Single): TVector3f;
    function CalculateReflectColorInScene(const _AReflectColor: TVector3f): TVector3f;
    function CalculateRefractColorInScene(const _ARefractColor: TVector3f): TVector3f;
  end;

  TMeshObject = class
  public
    Center: TVector3f;
    Material: TMaterial;

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

{ TMaterial }

function TMaterial.CalculateDiffuseColorInScene(const _ADiffuseLightIntensity: Single): TVector3f;
begin
  Result := Self.DiffuseColor.Scale(_ADiffuseLightIntensity * Self.Albedo.X)
end;

function TMaterial.CalculateReflectColorInScene(const _AReflectColor: TVector3f): TVector3f;
begin
  Result := _AReflectColor.Scale(Self.Albedo.Z);
end;

function TMaterial.CalculateRefractColorInScene(const _ARefractColor: TVector3f): TVector3f;
begin
  Result := _ARefractColor.Scale(Self.Albedo.W);
end;

function TMaterial.CalculateSpecularColorInScene(const _ASpecularLightIntensity: Single): TVector3f;
var
  ASpecularFactor: Single;
begin
  ASpecularFactor := _ASpecularLightIntensity * Self.Albedo.Y;
  Result.Create(ASpecularFactor, ASpecularFactor, ASpecularFactor);
end;

constructor TMaterial.Create(const _AName: string);
begin
  DiffuseColor.Create(0.0, 0.0, 0.0);
  Albedo.Create(1, 0, 0, 0);
  SpecularExponent := 50;
  RefractiveIndex := 1;

  Name := _AName;
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

end.
