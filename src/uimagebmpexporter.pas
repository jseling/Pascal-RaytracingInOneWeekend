unit uimagebmpexporter;
interface

uses
  sysutils,
  uViewer,
  uVectorTypes,
  Classes,
  Vcl.Graphics,
  Winapi.Windows;

type
  TImageBMPExporter = class
  private
    class function CreateBitmap(AViewer: TViewer): Vcl.Graphics.TBitmap;
  public
    class procedure ExportToFile(AViewer: TViewer; const _AFileName: string);
  end;

implementation

{ TImageBMPExporter }

class function TImageBMPExporter.CreateBitmap(AViewer: TViewer): Vcl.Graphics.TBitmap;
type
  TRGBTripleArray = ARRAY [Word] of TRGBTriple;
  pRGBTripleArray = ^TRGBTripleArray; // use a PByteArray for pf8bit color
var
  x, y: Integer;
  AScanLine: pRGBTripleArray;
  AColor: TByteColor;
begin
  Result := Vcl.Graphics.TBitmap.Create;
  try
    Result.Height := AViewer.Height;
    Result.Width := AViewer.Width;
    Result.PixelFormat := pf24Bit;

    for y := AViewer.Height - 1 downto  0 do
    begin
      AScanLine := Result.ScanLine[AViewer.Height - 1 - y];

      for x := 0 to AViewer.Width - 1 do
      begin
//        if _AFlipVertical then
//          AColor.SetFromVector3f(AViewer.GetPixel(x, AViewer.Height - y));
//        else
        AColor.SetFromVector3f(AViewer.GetPixel(x, y));

        AScanLine[x].rgbtRed := AColor.R;
        AScanLine[x].rgbtGreen := AColor.G;
        AScanLine[x].rgbtBlue := AColor.B;
      end;
    end;
  except
    Result.Free;
    raise;
  end;
end;

class procedure TImageBMPExporter.ExportToFile(AViewer: TViewer; const _AFileName: string);
var
  ABitmap: Vcl.Graphics.TBitmap;
begin
  ABitmap := TImageBMPExporter.CreateBitmap(AViewer);
  try
    ABitmap.SaveToFile(_AFileName);
  finally
    ABitmap.Free;
  end;
end;

end.

