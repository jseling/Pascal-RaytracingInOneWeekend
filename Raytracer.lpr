program Raytracer;

uses
  sysutils,
  dateutils,

  uRaytracer,
  uViewer,
  uScene,
  uFPCSceneLoader,
  uImagePPMExporter, uSceneElementLists, uBaseList;


var
  AViewer: TViewer;
  AScene: TScene;
  AStart, AEnd: TTime;
begin
  //                 Normal    Inline functions
  //    480, 640   = ~420;   //281
  //    768, 1024  = ~1190;
  //    720, 1280  = ~1140   //
  //    768, 1366  = ~1320
  //    1080, 1920 = ~2590
  //    1500, 2000 = ~4560
  //    2160, 3840 = ~10190  //
  //    3000, 4000 = ~18150; //10850

  //TODO:
  //1 - Memory leaks
  //2 - erros de json
  //3 - erros de objetos sem material
  //4 - iterar arrays é mais rapido que TLists
  //5 - usar um profiler para medir desempenho

  AScene := TSceneLoader.Build('scene.json');
  try
    AViewer := TViewer.Create(AScene.Camera);
    try
      ////////////////////////////////////////////////////////////////////////////

        AStart := now;
        TRaytracer.Render(AViewer, AScene);
        AEnd := now;

      ////////////////////////////////////////////////////////////////////////////

      TImagePPMExporter.ExportToFile(AViewer, 'render.ppm');
      //AViewer.SaveToBitmap('render.bmp');
    finally
      AViewer.Free;
    end;
  finally
    AScene.Free;
  end;

  writeln('Done ' + MillisecondsBetween(AStart, AEnd).ToString + ' ms');
  readln;
end.

