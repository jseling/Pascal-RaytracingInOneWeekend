unit uimagebmpexporter;

interface

uses
  sysutils,
  Classes,

  {$IFDEF MSWINDOWS}
    {$IFDEF DCC}
     Vcl.Graphics,
    {$ELSE IF FPC}
    fpimage,
    fpwritebmp;  
    {$ENDIF}
  {$ELSE IF LINUX}
    fpimage,
    fpwritebmp,  
  {$ENDIF}

  uViewer,
  uVectorTypes;

type
  IImageExportable = interface
    procedure SaveToFile();
  end;  

  TImageBMPExporter = class
  private
    {$IFDEF MSWINDOWS}
    {$IFDEF DCC}
    class procedure CreateBitmapDelphiWindows(AViewer: TViewer; const _AFileName: string);
    {$ENDIF}     
    {$ENDIF} 
    {$IFDEF FPC}   
    class procedure CreateBitmapFPC(AViewer: TViewer; const _AFileName: string); 
    {$ENDIF}        
  public
    class procedure ExportToFile(AViewer: TViewer; const _AFileName: string);
  end;

implementation

{ TImageBMPExporter }
{$IFDEF MSWINDOWS}
{$IFDEF DCC}
class procedure TImageBMPExporter.CreateBitmapDelphiWindows(AViewer: TViewer; const _AFileName: string);
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
  ABitmap: TBitmap;
begin
  ABitmap := TBitmap.Create;
  try
    ABitmap.PixelFormat := pf24Bit;
    ABitmap.SetSize(AViewer.Width, AViewer.Height);

    for y := ABitmap.Height - 1 downto  0 do
    begin
      AScanLine := ABitmap.ScanLine[ABitmap.Height - 1 - y];

      for x := 0 to ABitmap.Width - 1 do
      begin
        AColor.SetFromVector3f(AViewer.GetPixel(x, y));

        AScanLine[x].R := AColor.R;
        AScanLine[x].G := AColor.G;
        AScanLine[x].B := AColor.B;
      end;
    end;
    ABitmap.SaveToFile(_AFileName);
  finally
    ABitmap.Free;
  end;
end;
{$ENDIF}  
{$ENDIF}  

class procedure TImageBMPExporter.ExportToFile(AViewer: TViewer; const _AFileName: string);
{$IFDEF DCC}
{$ENDIF}
begin
{$IFDEF MSWINDOWS}
  {$IFDEF DCC}
    TImageBMPExporter.CreateBitmapDelphiWindows(AViewer, _AFileName);
  {$ENDIF}
{$ENDIF}  
{$IFDEF FPC}   
  TImageBMPExporter.CreateBitmapFPC(AViewer, _AFileName);
{$ENDIF}  
end;

{$IFDEF FPC}   
class procedure TImageBMPExporter.CreateBitmapFPC(AViewer: TViewer; const _AFileName: string);
var
  AImage : TFPMemoryImage;
  x, y: Integer;
  clr: TFPColor;  
  AColor: TWordColor;
begin
  AImage := TFPMemoryImage.Create(AViewer.Width, AViewer.Height);  
  try
    AImage.UsePalette:= False;    
    for y := 0 to AImage.Height - 1 do
      for x := 0 to AImage.Width - 1 do
      begin
        AColor.SetFromVector3f(AViewer.GetPixel(x, y));

        clr.Red := AColor.R;
        clr.Green := AColor.G;
        clr.Blue := AColor.B;    

        AImage.Colors[x, (AImage.Height -1 - y)] := clr;
       end;
    AImage.SaveToFile(_AFileName); 
  finally
    AImage.Free;
  end;
end;
{$ENDIF}  

end.

