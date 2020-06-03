unit uimagebmpexporter;

interface

uses
  sysutils,
  Classes,
  Graphics,

  {$IFDEF WINDOWS}
   Winapi.Windows,
  {$ELSE UNIX}
   LCLIntf,
  {$ENDIF}

  uViewer,
  uVectorTypes;

type
  TImageBMPExporter = class
  private
    class function CreateBitmap(AViewer: TViewer): Graphics.TBitmap;
  public
    class procedure ExportToFile(AViewer: TViewer; const _AFileName: string);
  end;

implementation

{ TImageBMPExporter }

class function TImageBMPExporter.CreateBitmap(AViewer: TViewer): Graphics.TBitmap;
type
  TRGBTriple = packed record
    R, G, B: byte;
  end;

  TRGBTripleArray = ARRAY [Word] of TRGBTriple;
  pRGBTripleArray = ^TRGBTripleArray; // use a PByteArray for pf8bit color
var
  x, y: Integer;
  AScanLine: pRGBTripleArray;
  AColor: TByteColor;
begin
  Result := Graphics.TBitmap.Create;
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

        {$IFDEF WINDOWS}
        AScanLine[x].rgbtRed := AColor.R;
        AScanLine[x].rgbtGreen := AColor.G;
        AScanLine[x].rgbtBlue := AColor.B;
        {$ELSE IF UNIX}
        AScanLine^[x].R := AColor.R;
        AScanLine^[x].G := AColor.G;
        AScanLine^[x].B := AColor.B;
        {$ENDIF}

      end;
    end;
  except
    Result.Free;
    raise;
  end;
end;

class procedure TImageBMPExporter.ExportToFile(AViewer: TViewer; const _AFileName: string);
var
  ABitmap: Graphics.TBitmap;
begin
  ABitmap := TImageBMPExporter.CreateBitmap(AViewer);
  try
    ABitmap.SaveToFile(_AFileName);
  finally
    ABitmap.Free;
  end;
end;

end.

