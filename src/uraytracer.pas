unit uRaytracer;

interface

uses
  uVectorTypes,
  uSceneElements,
  uViewer,
  uScene,
  uSceneElementLists,
  uBaseList,
  System.SysUtils,
  uRandomUtils,
  uRaytracerTypes;

type
  TRaytracer = class
  private
    class function CastRay(_ARay: TRay; _AScene: TScene; _ADepth: integer): TVector3f;
    class function SceneIntersect(_AScene: TScene; _ARay: TRay; _At_min, _At_max: single; out _AHit: THit): boolean;
    class function ray_color(r: TRay) : TVector3f;
  public
    class procedure Render(_AViewer: TViewer; _AScene: TScene);
  end;

implementation

uses
  Math;

{ TRaytracer }

class function TRaytracer.ray_color(r: TRay) : TVector3f;
var
 unit_direction: TVector3f;
 t: Single;
 c1, c2: TVector3f;
begin
  unit_direction := r.Dir.Normalize();

  t := 0.5 * (unit_direction.y + 1.0);

  c1.Create(1.0, 1.0, 1.0);
  c2.Create(0.5, 0.7, 1.0);

  c1:=c1.Scale(1.0-t);
  c2:=c2.Scale(t);

  result := c1.Add(c2);
end;

class function TRaytracer.CastRay(_ARay: TRay; _AScene: TScene; _ADepth: integer): TVector3f;
var
  AHit: THit;
//  n: TVector3f;
//  target: TVector3f;
//  ANewRay: TRay;

  scattered: TRay;
  attenuation: TVector3f;
begin
  // If we've exceeded the ray bounce limit, no more light is gathered.
  if (_ADepth <= 0) then
  begin
    result.Create(0,0,0);
    exit;
  end;

  if  SceneIntersect(_AScene, _ARay, 0.001, MaxInt, AHit) then
  begin
//    n := AHit.Normal;  //
//    result.Create(N.x+1, N.y+1, N.z+1);
//    result := result.Scale(0.5);

    if AHit.Material.Scatter(_ARay, AHit, attenuation, scattered) then
    begin
      result := CastRay(scattered, _AScene, _ADepth - 1);
      result := result.Scale(attenuation);
      //result := result.Scale(0.5);
      exit;
    end
    else
    begin
      result.Create(0,0,0);
      exit;
    end;
  end;

  Result := ray_color(_ARay); // background color
end;

class procedure TRaytracer.Render(_AViewer: TViewer; _AScene: TScene);
var
  j: Integer;
  i: integer;
  s: Integer;
  x, y, scale: Single;

  AColor: TVector3f;

  ARay: TRay;

  samples_per_pixel: Integer;
  max_depth: Integer;
begin
  samples_per_pixel := 1000;
  max_depth := 50;

  for j := _AViewer.Height -1 downto 0 do
    for i := 0 to _AViewer.Width - 1 do
    begin
      AColor.Create(0,0,0);

      for s := 0 to samples_per_pixel-1 do
      begin
        x := (i + TRandomUtils.RandomSingle()) / (_AViewer.Width - 1);
        y := (j + TRandomUtils.RandomSingle()) / (_AViewer.Height - 1);

        ARay := _AScene.Camera.GetRay(x , y);

        AColor := AColor.Add(CastRay(ARay, _AScene, max_depth));
      end;

      scale := 1 / samples_per_pixel;

      AColor.x := sqrt(scale * AColor.x);
      AColor.y := sqrt(scale * AColor.y);
      AColor.z := sqrt(scale * AColor.z);

      _AViewer.SetPixel(i, j, AColor);
      writeln('Progress: '+ formatfloat('0.00', ((_AViewer.Height-j)*_AViewer.Width + i) * 100 / (_AViewer.Height*_AViewer.Width)) + ' %.')
    end;
end;

class function TRaytracer.SceneIntersect(_AScene: TScene; _ARay: TRay; _At_min, _At_max: single; out _AHit: THit): boolean;
var
  closest_so_far: Single;
  hit_anything: boolean;

  i: integer;
begin
  hit_anything := False;
  closest_so_far := _At_max;

  for i := 0 to _AScene.ObjectList.Count - 1 do
  begin
    if _AScene.ObjectList.Get(i).RayIntersect(_ARay, _At_min, closest_so_far,_AHit) then
    begin
      hit_anything := True;
      closest_so_far := _AHit.t;
    end;
  end;

  result := hit_anything;
end;

end.
