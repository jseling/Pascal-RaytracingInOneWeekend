unit uDelphiSceneLoader;

interface

uses
  Classes,
  SysUtils,
  uSceneElements,
  System.JSON,
  System.IOUtils,
  uScene,
  System.Generics.Collections,
  uVectorTypes;

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

  AJSONSceneObjects: TJSONArray;
  AJSONSceneMaterials: TJSONArray;
  AJSONSceneCamera: TJSONObject;

  AJSONDataItem: TJSONValue;
  AJSONObjectItem: TJSONObject;

  s: string;

  i: Integer;

  AObject: TSphere;
begin
  AJSONObject := GetJSONDataFromFile(_AFileName);

  AJSONSceneObjects := TJSONArray(AJSONObject.GetValue('objects'));
  AJSONSceneMaterials := TJSONArray(AJSONObject.GetValue('materials'));
  AJSONSceneCamera := TJSONObject(AJSONObject.GetValue('camera'));

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

    s := AJSONObjectItem.GetValue('object').Value;

    if s = 'sphere' then
    begin
      AObject := GetObjectFromJSON(AJSONObjectItem);
      Result.ObjectList.Add(AObject);

      s := AJSONObjectItem.GetValue<String>('materialId');
      AObject.Material := Result.MaterialList.GetByName(s);
    end;

    if s = 'light' then
      Result.LightList.Add(GetLightFromJSON(AJSONObjectItem));
  end;

  Result.Camera := GetCameraFromJSON(AJSONSceneCamera);
end;

class function TSceneLoader.GetJSONDataFromFile(const _AFileName: string): TJSONObject;
begin
  Result := TJSONObject.ParseJSONValue(TFile.ReadAllText(_AFileName)) as TJSONObject;
end;


class function TSceneLoader.GetMaterialFromJSON(_AJSONObject: TJSONObject): TMaterial;
var
  s: string;
  AData: TJSONArray;
  x,y,z,w: Single;
begin
  s := _AJSONObject.GetValue('id').Value;
  result := TMaterial.Create(s);

  AData := _AJSONObject.GetValue<TJSONArray>('diffuse');
  x := AData.Items[0].GetValue<single>;
  y := AData.Items[1].GetValue<single>;
  z := AData.Items[2].GetValue<single>;
  result.DiffuseColor.Create(x, y, z);


  AData := _AJSONObject.GetValue<TJSONArray>('albedo');
  x := AData.Items[0].GetValue<single>;
  y := AData.Items[1].GetValue<single>;
  z := AData.Items[2].GetValue<single>;
  w := AData.Items[3].GetValue<single>;
  result.Albedo.Create(x, y, z, w);

  x := _AJSONObject.GetValue<Single>('specularExp');
  result.SpecularExponent := x;

  x := _AJSONObject.GetValue<Single>('refractiveIndex');
  result.RefractiveIndex := x;
end;

class function TSceneLoader.GetObjectFromJSON(_AJSONObject: TJSONObject): TSphere;
var
  AData: TJSONArray;
  x,y,z: Single;
begin
  result := TSphere.Create();

  AData := _AJSONObject.GetValue<TJSONArray>('position');
  x := AData.Items[0].GetValue<single>;
  y := AData.Items[1].GetValue<single>;
  z := AData.Items[2].GetValue<single>;
  result.Center.Create(x, y, z);

  x := _AJSONObject.GetValue<Single>('radius');
  result.Radius := x;
end;

class function TSceneLoader.GetLightFromJSON(_AJSONObject: TJSONObject): TLight;
var
  AData: TJSONArray;
  x,y,z: Single;
begin
  result := TLight.Create();

  AData := _AJSONObject.GetValue<TJSONArray>('position');
  x := AData.Items[0].GetValue<single>;
  y := AData.Items[1].GetValue<single>;
  z := AData.Items[2].GetValue<single>;
  result.Position.Create(x, y, z);

  x := _AJSONObject.GetValue<Single>('intensity');
  result.Intensity := x;
end;

class function TSceneLoader.GetCameraFromJSON(_AJSONObject: TJSONObject): TCamera;
var
  AData: TJSONArray;
  x,y,z: Single;
begin
  result := TCamera.Create();

  AData := _AJSONObject.GetValue<TJSONArray>('position');
  x := AData.Items[0].GetValue<single>;
  y := AData.Items[1].GetValue<single>;
  z := AData.Items[2].GetValue<single>;
  result.Position.Create(x, y, z);

//  AData := _AJSONObject.GetValue<TJSONArray>('direction');
//  x := AData.Items[0].GetValue<single>;
//  y := AData.Items[1].GetValue<single>;
//  z := AData.Items[2].GetValue<single>;
//  result.Direction.Create(x, y, z);

  x := _AJSONObject.GetValue<Single>('fov');
  result.FOV := x;

  x := _AJSONObject.GetValue<Single>('width');
  result.Width := trunc(x);

  x := _AJSONObject.GetValue<Single>('height');
  result.Height := trunc(x);

//  AData := _AJSONObject.GetValue<TJSONArray>('backgroundColor');
//  x := AData.Items[0].GetValue<single>;
//  y := AData.Items[1].GetValue<single>;
//  z := AData.Items[2].GetValue<single>;
//  result.BackgroundColor.Create(x, y, z);
end;

end.

