program Raytracer;

uses
  sysutils,
  dateutils,

  uRaytracer,
  uViewer,
  uScene,
  uFPCSceneLoader,
  uImagePPMExporter,
  uSceneElementLists,
  uBaseList,
  uRaytracerTypes,
  uImageBMPExporter,
  usceneloaderbookcover;

var
  AViewer: TViewer;
  AScene: TScene;
  AStart, AEnd: TTime;
  sTime: string;
begin
  //AScene := TSceneLoader.Build('scene.json');
  AScene := TBookCoverSceneLoader.Build();
  try
    AViewer := TViewer.Create(AScene.Camera);
    try
      ////////////////////////////////////////////////////////////////////////////

        AStart := now;
        TRaytracer.Render(AViewer, AScene);
        AEnd := now;

      ////////////////////////////////////////////////////////////////////////////

      sTime := MillisecondsBetween(AStart, AEnd).ToString;
      //TImagePPMExporter.ExportToFile(AViewer, 'render.ppm');
      TImageBMPExporter.ExportToFile(AViewer, 'render.bmp');
    finally
      AViewer.Free;
    end;
  finally
    AScene.Free;
  end;

  writeln('Done ' + sTime + ' ms');
  readln;
end.

