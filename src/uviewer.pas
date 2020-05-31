unit uViewer;

interface

uses
  uVectorTypes,
  uSceneElements;

type
  TViewer = class
  private
    FHeight: Integer;
    FWidth: Integer;
    FFrameBuffer: TArrayVector3f;
    FZBuffer: TArraySingle;
  public
    property Height: Integer read FHeight;
    property Width: Integer read FWidth;
    property FrameBuffer: TArrayVector3f read FFrameBuffer;
    property ZBuffer: TArraySingle read FZBuffer;

    constructor Create(_ACamera: TCamera);
    procedure SetPixel(x, y: Integer; color: TVector3f);
    function GetPixel(x, y: Integer): TVector3f;

    function GetZValue(x, y: Integer): Single;
    procedure SetZValue(x, y: Integer; _AValue: Single);
  end;

implementation

{ TViewer }

constructor TViewer.Create(_ACamera: TCamera);
var
  i: Integer;
  s: Single;
begin
  FHeight := _ACamera.Height;
  FWidth := _ACamera.Width;
  s := MaxInt * (-1);

  SetLength(FFrameBuffer, FWidth * FHeight);
  SetLength(FZBuffer, FWidth * FHeight);

  for i := Low(FZBuffer) to High(FZBuffer) do
    FZBuffer[i] := s;
end;

function TViewer.GetPixel(x, y: Integer): TVector3f;
begin
  Result := FFrameBuffer[x + y * FWidth];
end;

function TViewer.GetZValue(x, y: Integer): Single;
begin
  Result := FZBuffer[x + y * FWidth];
end;

procedure TViewer.SetPixel(x, y: Integer; color: TVector3f);
begin
  FFrameBuffer[x + y * FWidth] := color;
end;

procedure TViewer.SetZValue(x, y: Integer; _AValue: Single);
begin
  FZBuffer[x + y * FWidth] := _AValue;
end;

end.
