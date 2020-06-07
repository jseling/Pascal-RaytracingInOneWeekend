unit uVectorTypes;

{$IFDEF FPC}
  {$modeswitch advancedrecords}
{$ENDIF}

{$inline on}

interface

uses
  SysUtils,
  Math;

type

  { TVector3f }

  //memory allocation at stack in this case is fastest than using class at heap
  TVector3f = record
  public
    X: Single;
    Y: Single;
    Z: Single;

    //this is fastest than a formal constructor
    procedure Create(_AX, _AY, _AZ: Single); inline;

    function Add(_AVector: TVector3f): TVector3f; inline;
    function Subtract(_AVector: TVector3f): TVector3f; inline;
    function Scale(_AFactor: Single): TVector3f; overload; inline;
    function Scale(_AFactor: TVector3f): TVector3f; overload; inline;
    function DotProduct(_AVector: TVector3f): Single; inline;
    function Magnitude(): Single; inline;
    function MagnitudeSquared(): Single; inline;
    function Normalize(): TVector3f; inline;
    function Reflect(_ANormal: TVector3f): TVector3f; inline;
    function Refract(_AN: TVector3f; eta_t: Single; eta_i: Single = 1): TVector3f; inline;

        function PrettyString(): string;
  end;

  TVector4f = record
  public
    X: Single;
    Y: Single;
    Z: Single;
    W: Single;
    procedure Create(_AX, _AY, _AZ, _AW: Single);
  end;

  PColor = ^TColor;

  { TColor }

  TColor = record
  public
    R: Single;
    G: Single;
    B: Single;
    function Create(_AR, _AG, _AB: Single): PColor;
    function Add(const _AOtherColor: TColor): PColor;
  end;

  TByteColor = record
  public
    R: Byte;
    G: Byte;
    B: Byte;

    //expect a vector with RGB values within 0..1 interval.
    procedure SetFromVector3f(const _AVectorColor: TVector3f);
  end;

  TArrayVector3f = array of TVector3f;
  TArraySingle = array of Single;

implementation

{ TColor }

function TColor.Create(_AR, _AG, _AB: Single): PColor;
begin
  R := _AR;
  G := _AG;
  B := _AB;
  Result := @Self;
end;

function TColor.Add(const _AOtherColor: TColor): PColor;
begin
  R := R + _AOtherColor.R;
  G := G + _AOtherColor.G;
  B := B + _AOtherColor.B;
  Result := @Self;
end;

{ TiColor }

procedure TByteColor.SetFromVector3f(const _AVectorColor:TVector3f);
var
  AR, AG, AB: Integer;

  function FixRange(_AValue: Integer): Byte;
  begin
    Result := _AValue;
    if _AValue > 255 then
      Result := 255;

    if _AValue < 0 then
      Result := 0;
  end;
begin
  AR := Trunc(_AVectorColor.x * 255);
  AG := Trunc(_AVectorColor.y * 255);
  AB := Trunc(_AVectorColor.Z * 255);

  R := FixRange(AR);
  G := FixRange(AG);
  B := FixRange(AB);
end;

{ TVector3f }

function TVector3f.Add(_AVector: TVector3f): TVector3f;
begin
  Result.Create(self.X + _AVector.X,
               self.Y + _AVector.Y,
               self.Z + _AVector.Z);
end;

procedure TVector3f.Create(_AX, _AY, _AZ: Single);
begin
  X := _AX;
  Y := _AY;
  Z := _AZ;
end;

function TVector3f.DotProduct(_AVector: TVector3f): Single;
begin
  Result := X * _AVector.X +
            Y * _AVector.Y +
            Z * _AVector.Z;
end;

function TVector3f.Magnitude(): Single;
begin
  Result := Sqrt(X * X +
                 Y * Y +
                 Z * Z);
end;

function TVector3f.MagnitudeSquared: Single;
begin
  Result := X * X +
            Y * Y +
            Z * Z;
end;

function TVector3f.Normalize(): TVector3f;
var
  AMag: Single;
begin
  AMag := Self.Magnitude();
  Result.Create(X / AMag,
               Y / AMag,
               Z / AMag);
end;

function TVector3f.PrettyString: string;
begin
  Result := '[' + floattostr(x) + ', ' + floattostr(y) + ', ' + floattostr(z) + ']';
end;

function TVector3f.Reflect(_ANormal: TVector3f): TVector3f;
var
  AIDotN: Single;
  ANScale2: TVector3f;
begin
  ANScale2 := _ANormal.Scale(2);
  AIDotN := Self.DotProduct(_ANormal);

  Result := Self.Subtract(ANScale2.Scale(AIDotN));
end;

function TVector3f.Refract(_AN: TVector3f; eta_t: Single; eta_i: Single = 1): TVector3f;
var
  cosi: Single;
  eta: Single;
  k: Single;
begin
  cosi := Max(-1, Min(1, Self.DotProduct(_AN))) * (-1);

  if (cosi < 0) then
  begin
    Result := Self.Refract(_AN.Scale(-1), eta_i, eta_t);
    exit;
  end;

  eta := eta_i / eta_t;
  k := 1 - eta * eta * (1 - cosi * cosi);

  if (k < 0) then
    Result.Create(1, 0, 0)
  else
    Result := Self.Scale(eta).Add(_AN.Scale(eta * cosi - sqrt(k)));
end;

function TVector3f.Scale(_AFactor: Single): TVector3f;
begin
  Result.Create(X * _AFactor,
               Y * _AFactor,
               Z * _AFactor);
end;

function TVector3f.Scale(_AFactor: TVector3f): TVector3f;
begin
  Result.Create(X * _AFactor.X,
               Y * _AFactor.Y,
               Z * _AFactor.Z);
end;

function TVector3f.Subtract(_AVector: TVector3f): TVector3f;
begin
  Result.Create(X - _AVector.X,
               Y - _AVector.Y,
               Z - _AVector.Z);
end;

{ TVector4f }

procedure TVector4f.Create(_AX, _AY, _AZ, _AW: Single);
begin
  X := _AX;
  Y := _AY;
  Z := _AZ;
  W := _AW;
end;

end.
