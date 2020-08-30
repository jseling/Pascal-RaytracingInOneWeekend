unit usceneloaderbookcover;

interface

uses
  Classes,
  SysUtils,
  uSceneElements,
  uScene,
  System.Generics.Collections,
  uVectorTypes,
  uRayTracerTypes,
  uRandomUtils;

type
  TBookCoverSceneLoader = class
  public
    class function Build(): TScene;
  end;

implementation

{ TBookCoverSceneLoader }

class function TBookCoverSceneLoader.Build: TScene;
var
  ground_material: TLambertianMaterial;
  world, sphere: TSphere;
  a, b: integer;
  choose_mat: Single;
  center, p: TVector3f;
  sphere_material_dif: TLambertianMaterial;
  sphere_material_metal: TMetalMaterial;
  sphere_material_glass: TDieletricMaterial;
  lookfrom,
  lookat,
  vup: TVector3f;
begin
  Result := TScene.Create;

  ground_material := TLambertianMaterial.Create;
  ground_material.Albedo.Create(0.5, 0.5, 0.5);
  ground_material.Name := 'ground_material';

  Result.MaterialList.Add(ground_material);

  world := TSphere.Create();
  world.Center.Create(0, -1000, 0);
  world.Radius := 1000;
  world.Material := ground_material;

  Result.ObjectList.Add(world);

  for a := -11 to 10 do
    for b := -11 to 10 do
    begin
      choose_mat := TRandomUtils.RandomSingle();
      center.Create(a + 0.9 * TRandomUtils.RandomSingle(), 0.2, b + 0.9 * TRandomUtils.RandomSingle());

      p.Create(4, 0.2, 0);
      if center.Subtract(p).Magnitude > 0.9 then
      begin
        if choose_mat < 0.8 then
        begin
          sphere_material_dif := TLambertianMaterial.Create;
          sphere_material_dif.Albedo := TRandomUtils.RandomVector;
          Result.MaterialList.Add(sphere_material_dif);

          sphere := TSphere.Create();
          sphere.Center := center;
          sphere.Radius := 0.2;
          sphere.Material := sphere_material_dif;
          Result.ObjectList.Add(sphere);
        end
        else if choose_mat < 0.95 then
        begin
          sphere_material_metal := TMetalMaterial.Create;
          sphere_material_metal.Albedo := TRandomUtils.RandomVector;
          sphere_material_metal.Fuzz := TRandomUtils.RandomSingle(0, 0.5);
          Result.MaterialList.Add(sphere_material_metal);

          sphere := TSphere.Create();
          sphere.Center := center;
          sphere.Radius := 0.2;
          sphere.Material := sphere_material_metal;
          Result.ObjectList.Add(sphere);
        end
        else
        begin
          sphere_material_glass := TDieletricMaterial.Create;
          sphere_material_glass.RefractionIndex := 1.5;
          Result.MaterialList.Add(sphere_material_glass);

          sphere := TSphere.Create();
          sphere.Center := center;
          sphere.Radius := 0.2;
          sphere.Material := sphere_material_glass;
          Result.ObjectList.Add(sphere);
        end;
      end;
    end;

  sphere_material_glass := TDieletricMaterial.Create;
  sphere_material_glass.RefractionIndex := 1.5;
  Result.MaterialList.Add(sphere_material_glass);
  sphere := TSphere.Create();
  sphere.Center.Create(0, 1, 0);
  sphere.Radius := 1;
  sphere.Material := sphere_material_glass;
  Result.ObjectList.Add(sphere);

  sphere_material_dif := TLambertianMaterial.Create;
  sphere_material_dif.Albedo.Create(0.4, 0.2, 0.1);
  Result.MaterialList.Add(sphere_material_dif);
  sphere := TSphere.Create();
  sphere.Center.Create(-4, 1, 0);
  sphere.Radius := 1;
  sphere.Material := sphere_material_dif;
  Result.ObjectList.Add(sphere);

  sphere_material_metal := TMetalMaterial.Create;
  sphere_material_metal.Albedo.Create(0.7, 0.6, 0.5);
  sphere_material_metal.Fuzz := 0;
  Result.MaterialList.Add(sphere_material_metal);
  sphere := TSphere.Create();
  sphere.Center.Create(4, 1, 0);
  sphere.Radius := 1;
  sphere.Material := sphere_material_metal;
  Result.ObjectList.Add(sphere);


  lookfrom.Create(13, 2, 3);
  lookat.Create(0,0,0);
  vup.Create(0,1,0);
  Result.Camera := TCamera.Create(lookfrom, lookat, vup, 20, 3/2, 0.1, 10);
  Result.Camera.Width := 3000;
  Result.Camera.Height := 2000;
end;

end.
