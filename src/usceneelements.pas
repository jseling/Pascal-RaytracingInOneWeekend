unit uSceneElements;

interface

uses
  uVectorTypes,
  SysUtils,
  uRayTracerTypes,
  uRandomUtils,
  Math;

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

  TDieletricMaterial = class(TBaseMaterial)
  public
    RefractionIndex: Single;
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
  private
    FLens_Radius: Single;
    w, u, v: TVector3f;
  public
    Position: TVector3f;
    LowerLeftCorner: TVector3f;
    Horizontal: TVector3f;
    Vertical: TVector3f;
     Height,
     Width: Integer;
//    BackgroundColor: TVector3f;   

    constructor Create(lookfrom, lookat, vup: Tvector3f; vfov, aspect_ratio, aperture, focus_dist: single);
    function GetRay(s, t: Single): TRay;
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
  FRadius := _AValue;
  FInvRadius := 1 / FRadius;
end;

{ TCamera }

constructor TCamera.Create(lookfrom, lookat, vup: Tvector3f; vfov, aspect_ratio, aperture, focus_dist: single);
var
  viewport_height: Single;
  viewport_width: Single;
  f: TVector3f;
  theta: Single;
  h: Single;
begin
  theta := DegToRad(vfov);
  h := Tan(theta/2);
  viewport_height := 2 * h;
  viewport_width := aspect_ratio * viewport_height;

  w := lookfrom.Subtract(lookat).Normalize;
  u := vup.CrossProduct(w).Normalize;
  v := w.CrossProduct(u);

  Position := lookfrom;
  Horizontal := u.Scale(viewport_width).Scale(focus_dist);
  Vertical := v.Scale(viewport_height).Scale(focus_dist);
  LowerLeftCorner := Position.Subtract(Horizontal.Scale(0.5)).Subtract(Vertical.Scale(0.5)).Subtract(w.Scale(focus_dist));

  FLens_Radius := aperture / 2;
end;

function TCamera.GetRay(s, t: Single): TRay;
var
  AOrig,
  ADir,
  rd,
  offset: TVector3f;
begin
  rd := TRandomUtils.RandomInUnitDisk().Scale(FLens_Radius);
  offset := u.Scale(rd.X).Add(v.Scale(rd.Y)); 

  AOrig := Self.Position.Add(offset);
  ADir := LowerLeftCorner.Add(Horizontal.Scale(s)).Add(Vertical.Scale(t)).Subtract(AOrig);//.Subtract(offset);
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

function TDieletricMaterial.Scatter(_ARayIn: TRay; _AHit: THit; out _AColorAttenuation: TVector3f; out _ARayScattered: TRay): Boolean;
var
  etai_over_etat: Single;
  unit_direction: TVector3f;
  refracted: TVector3f;  
  cos_theta: Single;
  sin_theta: Single;
  reflected: TVector3f;
  reflect_prob: Single;

  function schlick(cosine, ref_idx: single): single;
  var
    r0: Single;
  begin
    r0 := (1 - ref_idx) / (1 + ref_idx);
    r0 := r0 * r0;
    result := r0 + (1 - r0) * Power((1 - cosine), 5);
  end;
begin
  _AColorAttenuation.Create(1,1,1);

  if _AHit.FrontFace then
    etai_over_etat := 1 / RefractionIndex
  else
    etai_over_etat := RefractionIndex;

  unit_direction := _ARayIn.Dir.Normalize;
  cos_theta := Min(unit_direction.Scale(-1).DotProduct(_AHit.Normal), 1);
  sin_theta := Sqrt(1 - cos_theta * cos_theta);

  if (etai_over_etat * sin_theta > 1) or
     (TRandomUtils.RandomSingle() < schlick(cos_theta, etai_over_etat)) then
  begin
    reflected := unit_direction.Reflect(_AHit.Normal);
    _ARayScattered.Create(_AHit.Point, reflected);
    result := True;
    exit;
  end;

  refracted := unit_direction.Refract(_AHit.Normal, etai_over_etat);
  _ARayScattered.Create(_AHit.Point, refracted);
  result := True;
end;

end.
