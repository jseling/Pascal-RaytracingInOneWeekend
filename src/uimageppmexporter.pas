unit uImagePPMExporter;

interface

uses
  sysutils,
  uViewer,
  uVectorTypes,
  Classes;

type
  TImagePPMExporter = class
  public
    class procedure ExportToFile(AViewer: TViewer; const AFileName: string);
  end;

implementation

{ TImagePPMExporter }

class procedure TImagePPMExporter.ExportToFile(AViewer: TViewer;
  const AFileName: string);
var
  AstFile: TStringList;
  x, y: Integer;
  ALine: String;
  AColor: TByteColor;
begin
  AstFile := TStringList.Create;
  try
     AstFile.Append('P3');
     AstFile.Append(IntToStr(AViewer.Width) + ' ' + IntToStr(AViewer.Height));
     AstFile.Append('255');

     for y := AViewer.Height - 1 downto 0 do
     begin
         ALine := '';
         for x := 0 to AViewer.Width - 1 do
         begin
             AColor.SetFromVector3f(AViewer.GetPixel(x, y));
             ALine := ALine + IntToStr(AColor.R) + ' ' + IntToStr(AColor.G) + ' ' + IntToStr(AColor.B) + ' ';
         end;
         AstFile.Append(ALine);
     end;


     AstFile.SaveToFile(AFileName);
  finally
    AstFile.Free;
  end;
end;

end.

