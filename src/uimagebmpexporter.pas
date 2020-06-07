unit uimagebmpexporter;

interface

uses
  sysutils,
  Classes,

  {$IFDEF MSWINDOWS}
    {$IFDEF DCC}
     Vcl.Graphics,
    {$ELSE IF FPC}
     Graphics,
     IntfGraphics,
     //LCLProc, 
     //LResources,
     GraphType,
    {$ENDIF}
  {$ELSE IF LINUX}
   Graphics,
   LCLIntf,
  {$ENDIF}

  uViewer,
  uVectorTypes;

type
  TImageBMPExporter = class
  private
    {$IFDEF MSWINDOWS}
    {$IFDEF DCC}
    class function CreateBitmapDelphiWindows(AViewer: TViewer): TBitmap;
    {$ENDIF}     
    {$ENDIF} 
    {$IFDEF FPC}   
    class function CreateBitmapFPC(AViewer: TViewer): TBitmap; 
    {$ENDIF}        
  public
    class procedure ExportToFile(AViewer: TViewer; const _AFileName: string);
  end;

implementation

{ TImageBMPExporter }
{$IFDEF MSWINDOWS}
{$IFDEF DCC}
class function TImageBMPExporter.CreateBitmapDelphiWindows(AViewer: TViewer): TBitmap;
type
  TRGBTriple = packed record
    B, G, R: byte;
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
{$ENDIF}  
{$ENDIF}  

class procedure TImageBMPExporter.ExportToFile(AViewer: TViewer; const _AFileName: string);
var
  ABitmap: TBitmap;
begin
{$IFDEF MSWINDOWS}
{$IFDEF DCC}
  ABitmap := TImageBMPExporter.CreateBitmapDelphiWindows(AViewer);
{$ENDIF}  
{$ENDIF}  
{$IFDEF FPC}   
  ABitmap := TImageBMPExporter.CreateBitmapFPC(AViewer);
{$ENDIF}  
  try
    ABitmap.SaveToFile(_AFileName);
  finally
    ABitmap.Free;
  end;
end;

{$IFDEF FPC}   
class function TImageBMPExporter.CreateBitmapFPC(AViewer: TViewer): TBitmap;
var
  IntfImage: TLazIntfImage;
  ScanLineImage: TLazIntfImage;
  ImgFormatDescription: TRawImageDescription;   
  AScanLine: Pointer; 
  x, y: Integer;
  AColor: TByteColor;  
begin
  Result := TBitmap.Create;
  try
    ScanLineImage := TLazIntfImage.Create(0,0);
    try
      ImgFormatDescription.Init_BPP32_B8G8R8_BIO_TTB(AViewer.Width, AViewer.Height);
      ScanLineImage.DataDescription:=ImgFormatDescription;  

      for y := AViewer.Height - 1 downto  0 do
      begin
        AScanLine := ScanLineImage.GetDataLineStart(y);
        //AScanLine := Result.ScanLine[AViewer.Height - 1 - y];
        for x := 0 to AViewer.Width - 1 do
        begin
          AColor.SetFromVector3f(AViewer.GetPixel(x, y));

          PByte(AScanLine)[x * 4] := AColor.R;
          PByte(AScanLine)[x * 4 + 1] := AColor.G;
          PByte(AScanLine)[x * 4 + 2] := AColor.B;
          PByte(AScanLine)[x * 4 + 3] := 255;
        end;
      end;

      Result.Height := ScanLineImage.Height;
      Result.Width := ScanLineImage.Width;

      IntfImage := Result.CreateIntfImage; 
      try
        IntfImage.CopyPixels(ScanLineImage);  
      finally
        IntfImage.Free;  
      end;
    finally
      ScanLineImage.Free; 
    end;
  except
    Result.Free;
    raise;
  end;  
end;
{$ENDIF}  

end.

