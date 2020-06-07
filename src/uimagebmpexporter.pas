unit uimagebmpexporter;

interface

uses
  sysutils,
  Classes,

  {$IFDEF MSWINDOWS}
   Vcl.Graphics,
  {$ELSE LINUX}
   Graphics,
   LCLIntf,
  {$ENDIF}

  uViewer,
  uVectorTypes;

type
  TImageBMPExporter = class
  private
    class function CreateBitmap(AViewer: TViewer): TBitmap;
  public
    class procedure ExportToFile(AViewer: TViewer; const _AFileName: string);
  end;

implementation

{ TImageBMPExporter }

class function TImageBMPExporter.CreateBitmap(AViewer: TViewer): TBitmap;
type
  TRGBTriple = packed record
    {$IFDEF MSWINDOWS}
    B, G, R: byte;
    {$ELSE IF LINUX}
    R, G, B: byte;
    {$ENDIF}
  end;

  TRGBTripleArray = ARRAY [Word] of TRGBTriple;
  pRGBTripleArray = ^TRGBTripleArray; // use a PByteArray for pf8bit color
var
  x, y: Integer;
  AScanLine: pRGBTripleArray;
  AColor: TByteColor;
begin
  Result := TBitmap.Create;
  try
    Result.Height := AViewer.Height;
    Result.Width := AViewer.Width;
    Result.PixelFormat := pf24Bit;

    for y := AViewer.Height - 1 downto  0 do
    begin
      AScanLine := Result.ScanLine[AViewer.Height - 1 - y];

      for x := 0 to AViewer.Width - 1 do
      begin
        AColor.SetFromVector3f(AViewer.GetPixel(x, y));

        AScanLine[x].R := AColor.R;
        AScanLine[x].G := AColor.G;
        AScanLine[x].B := AColor.B;
      end;
    end;
  except
    Result.Free;
    raise;
  end;
end;

class procedure TImageBMPExporter.ExportToFile(AViewer: TViewer; const _AFileName: string);
var
  ABitmap: TBitmap;
begin
  ABitmap := TImageBMPExporter.CreateBitmap(AViewer);
  try
    ABitmap.SaveToFile(_AFileName);
  finally
    ABitmap.Free;
  end;
end;

end.

