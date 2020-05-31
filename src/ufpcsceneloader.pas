unit uFPCSceneLoader;

interface

uses
  Classes,
  SysUtils,
  fpjson,
  jsonparser,
  jsonscanner,
  uscene,
  uSceneElements;

type
  TSceneLoader = class
  private
    class function GetJSONDataFromFile(const _AFileName: string): TJSONObject;

    class function GetMaterialFromJSON(_AJSONObject: TJSONObject): TMaterial;
    class function GetObjectFromJSON(_AJSONObject: TJSONObject): TSphere;
    class function GetLightFromJSON(_AJSONObject: TJSONObject): TLight;
    class function GetCameraFromJSON(_AJSONObject: TJSONObject): TCamera;
  public
    class function Build(const _AFilename: String): TScene;
  end;

implementation

class function TSceneLoader.Build(const _AFilename: String): TScene;
var
  AJSONObject: TJSONObject;

  AJSONSceneObjects: TJSONObject;
  AJSONSceneMaterials: TJSONObject;
  AJSONSceneCamera: TJSONObject;

  AJSONDataItem: TJSONData;
  AJSONObjectItem: TJSONObject;

  s: string;

  i: Integer;

  AObject: TSphere;
begin
  AJSONObject := GetJSONDataFromFile(_AFileName);

  AJSONSceneObjects := TJSONObject(AJSONObject.Find('objects'));
  AJSONSceneMaterials := TJSONObject(AJSONObject.Find('materials'));
  AJSONSceneCamera := TJSONObject(AJSONObject.Find('camera'));

  Result := TScene.Create;

  for i := 0 to AJSONSceneMaterials.Count - 1 do
  begin
    AJSONDataItem := AJSONSceneMaterials.Items[i];

    Result.MaterialList.Add(GetMaterialFromJSON(TJSONObject(AJSONDataItem)));
  end;

  for i := 0 to AJSONSceneObjects.Count - 1 do
  begin
    AJSONDataItem := AJSONSceneObjects.Items[i];

    AJSONObjectItem := TJSONObject(AJSONDataItem);

    s := AJSONObjectItem.Find('object').AsString;

    if s = 'sphere' then
    begin
      AObject := GetObjectFromJSON(AJSONObjectItem); 
      Result.ObjectList.Add(AObject);
      
      s := AJSONObjectItem.Find('materialId').AsString;
      AObject.Material := Result.MaterialList.GetByName(s);
    end
    else if s = 'light' then
      Result.LightList.Add(GetLightFromJSON(AJSONObjectItem));
  end;

  Result.Camera := GetCameraFromJSON(AJSONSceneCamera);
end;

class function TSceneLoader.GetJSONDataFromFile(const _AFileName: string): TJSONObject;
var
  AJSONFile: TFileStream;
  AJSONParser: TJSONParser;
begin
  AJSONFile := TFileStream.Create(_AFileName, fmOpenRead);
  try
    AJSONParser := TJSONParser.Create(AJSONFile);
    try
      AJSONParser.Options := [joStrict];
      Result := TJSONObject(AJSONParser.Parse);
    finally
      AJSONParser.Free;
    end;
  finally
    AJSONFile.Free;
  end;
end;

class function TSceneLoader.GetMaterialFromJSON(_AJSONObject: TJSONObject): TMaterial;
var
  s: string;
  AData: TJSONData;
  x,y,z,w: Single;
begin
  s := _AJSONObject.Find('id').AsString;
  result := TMaterial.Create(s);

  AData := _AJSONObject.Find('diffuse');
  x := AData.Items[0].AsFloat;
  y := AData.Items[1].AsFloat;
  z := AData.Items[2].AsFloat;
  result.DiffuseColor.Create(x, y, z);


  AData := _AJSONObject.Find('albedo');
  x := AData.Items[0].AsFloat;
  y := AData.Items[1].AsFloat;
  z := AData.Items[2].AsFloat;
  w := AData.Items[3].AsFloat;
  result.Albedo.Create(x, y, z, w);

  x := _AJSONObject.Find('specularExp').AsFloat;
  result.SpecularExponent := x;

  x := _AJSONObject.Find('refractiveIndex').AsFloat;
  result.RefractiveIndex := x;
end;

class function TSceneLoader.GetObjectFromJSON(_AJSONObject: TJSONObject): TSphere;
var
  AData: TJSONData;
  x,y,z: Single;
begin
  result := TSphere.Create();

  AData := _AJSONObject.Find('position');
  x := AData.Items[0].AsFloat;
  y := AData.Items[1].AsFloat;
  z := AData.Items[2].AsFloat;
  result.Center.Create(x, y, z);

  x := _AJSONObject.Find('radius').AsFloat;
  result.Radius := x;
end;

class function TSceneLoader.GetLightFromJSON(_AJSONObject: TJSONObject): TLight;
var
  AData: TJSONData;
  x,y,z: Single;
begin
  result := TLight.Create();

  AData := _AJSONObject.Find('position');
  x := AData.Items[0].AsFloat;
  y := AData.Items[1].AsFloat;
  z := AData.Items[2].AsFloat;
  result.Position.Create(x, y, z);

  x := _AJSONObject.Find('intensity').AsFloat;
  result.Intensity := x;
end;

class function TSceneLoader.GetCameraFromJSON(_AJSONObject: TJSONObject): TCamera;
var
  AData: TJSONData;
  x,y,z: Single;
begin
  result := TCamera.Create();

  AData := _AJSONObject.Find('position');
  x := AData.Items[0].AsFloat;
  y := AData.Items[1].AsFloat;
  z := AData.Items[2].AsFloat;
  result.Position.Create(x, y, z);

  AData := _AJSONObject.Find('direction');
  x := AData.Items[0].AsFloat;
  y := AData.Items[1].AsFloat;
  z := AData.Items[2].AsFloat;
  result.Direction.Create(x, y, z);

  x := _AJSONObject.Find('fov').AsFloat;
  result.FOV := x;

  x := _AJSONObject.Find('width').AsFloat;
  result.Width := trunc(x);

  x := _AJSONObject.Find('height').AsFloat;
  result.Height := trunc(x);

  AData := _AJSONObject.Find('backgroundColor');
  x := AData.Items[0].AsFloat;
  y := AData.Items[1].AsFloat;
  z := AData.Items[2].AsFloat;
  result.BackgroundColor.Create(x, y, z);
end;

end.

