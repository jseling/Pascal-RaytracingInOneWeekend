unit uScene;

interface

uses
  Classes,
  uSceneElements,
  uSceneElementLists;

type
  { TScene }

  TScene = class
  private
    FObjectList: TMeshObjectList;
    FLightList: TLightList;
    FMaterialList: TMaterialList;
    FCamera: TCamera;
  public
    property ObjectList: TMeshObjectList read FObjectList;
    property LightList: TLightList read FLightList;
    property MaterialList: TMaterialList read FMaterialList;
    property Camera: TCamera read FCamera write FCamera;

    constructor Create();
    destructor Destroy; override;
  end;

implementation

{ TScene }
constructor TScene.Create();
begin
  FObjectList := TMeshObjectList.Create;
  FLightList := TLightList.Create;
  FMaterialList := TMaterialList.Create;
end;

destructor TScene.Destroy;
begin
  FObjectList.Free;
  FLightList.Free;
  FMaterialList.Free;
  FCamera.Free;
end;

end.

