unit ADC.ImgProcessor;

interface

uses
  System.Classes, System.Types, Winapi.Windows, Vcl.Graphics, Vcl.Imaging.jpeg,
  Vcl.Controls, System.SysUtils, System.Variants, Winapi.UxTheme, Winapi.ActiveX,
  Vcl.Imaging.pngimage, System.RegularExpressions, System.StrUtils, ADC.Types;

type
  TImgProcessor = class(TObject)
  private
    type
      TRGB = record
        B : Byte;
        G : Byte;
        R : Byte;
      end;
    type
      PRGBArray = ^TRGBArray;
      TRGBArray = array[0..32767] of TRGB;
  private
    class procedure BitmapShrink(Src, Dst: TBitmap);
  public
    class procedure SmoothResize(Src, Dst: TBitmap);
    class procedure OpenImage_JPEG(AFileName: string; AJpeg: TJPEGImage);
    class function ImageToByteArray(AJPEG: TJPEGImage; outByteArray: PImgByteArray): Boolean; overload;
    class function ImageToByteArray(ABitmap: TBitmap; outByteArray: PImgByteArray): Boolean; overload;
    class function ByteArrayToImage(ABytes: TImgByteArray; outBitmap: TBitmap): Boolean; overload;
    class function ByteArrayToImage(ABytes: OleVariant; outBitmap: TBitmap): Boolean; overload;
    class function ByteArrayToImage(ABytes: PSafeArray; outBitmap: TBitmap): Boolean; overload;
    class function ByteArrayToImage(ABytes: WideString; outBitmap: TBitmap): Boolean; overload;
    class procedure GetThemeButtons(AHWND: HWND; AHDC: HDC; APartID: Integer;
      ABgColor: TColor; AImgList: TImageList);
  end;

implementation

{ TImgProcessor }

class procedure TImgProcessor.BitmapShrink(Src, Dst: TBitmap);
var
  Lx, Ly, LxS, LyS, LyB, LxB, LySend, LxSend, R : integer;
  P1, P2, P3, P4, P5, P6, P7, P8, P9, POut : pByte;
  PA, PB, PC, PD, PE, PF, PG : pByte;
  LSumR, LSumG, LSumB, LBoxPixels : integer;
  W, WM, HM, WL : integer;
  LRowSkip, LRowSkipOut, LRowSize, LRowSkipBox, LBoxSize : integer;
begin
  W := Dst.Width;
  R := Src.Width div W; // shrink ratio
  WM := W - 1; HM := Dst.Height - 1;
  WL := W - 3;
  P1 := Src.ScanLine[0];
  LRowSize := -(((Src.Width * 24 + 31) and not 31) shr 3);
  P2 := PByte(Integer(P1) + LRowSize);
  POut := Dst.ScanLine[0];
  LRowSkipOut := -(((W * 24 + 31) and not 31) shr 3) - W * 3;
  if R = 2 then
  begin
    LRowSkip := LRowSize shl 1 - W * 6;
    for Ly := 0 to HM do
    begin
      P3 := PByte(Integer(P1) + 3);
      P4 := PByte(Integer(P2) + 3);
      Lx := 0;
      // set output pixel to the average of the 2X2 box of input pixels
      while Lx < WL do
      begin // loop unrolled by 4
        POut^ := (P1^ + P2^ + P3^ + P4^) shr 2; // blue
        Inc(P1); Inc(P2); Inc(P3); Inc(P4); Inc(POut);
        POut^ := (P1^ + P2^ + P3^ + P4^) shr 2; // green
        Inc(P1); Inc(P2); Inc(P3); Inc(P4); Inc(POut);
        POut^ := (P1^ + P2^ + P3^ + P4^) shr 2; // red
        Inc(P1, 4); Inc(P2, 4); Inc(P3, 4); Inc(P4, 4); Inc(POut);
        POut^ := (P1^ + P2^ + P3^ + P4^) shr 2; // blue
        Inc(P1); Inc(P2); Inc(P3); Inc(P4); Inc(POut);
        POut^ := (P1^ + P2^ + P3^ + P4^) shr 2; // green
        Inc(P1); Inc(P2); Inc(P3); Inc(P4); Inc(POut);
        POut^ := (P1^ + P2^ + P3^ + P4^) shr 2; // red
        Inc(P1, 4); Inc(P2, 4); Inc(P3, 4); Inc(P4, 4); Inc(POut);
        POut^ := (P1^ + P2^ + P3^ + P4^) shr 2; // blue
        Inc(P1); Inc(P2); Inc(P3); Inc(P4); Inc(POut);
        POut^ := (P1^ + P2^ + P3^ + P4^) shr 2; // green
        Inc(P1); Inc(P2); Inc(P3); Inc(P4); Inc(POut);
        POut^ := (P1^ + P2^ + P3^ + P4^) shr 2; // red
        Inc(P1, 4); Inc(P2, 4); Inc(P3, 4); Inc(P4, 4); Inc(POut);
        POut^ := (P1^ + P2^ + P3^ + P4^) shr 2; // blue
        Inc(P1); Inc(P2); Inc(P3); Inc(P4); Inc(POut);
        POut^ := (P1^ + P2^ + P3^ + P4^) shr 2; // green
        Inc(P1); Inc(P2); Inc(P3); Inc(P4); Inc(POut);
        POut^ := (P1^ + P2^ + P3^ + P4^) shr 2; // red
        Inc(P1, 4); Inc(P2, 4); Inc(P3, 4); Inc(P4, 4); Inc(POut);
        Inc(Lx, 4);
      end;

      while Lx < W do
      begin
        POut^ := (P1^ + P2^ + P3^ + P4^) shr 2; // blue
        Inc(P1); Inc(P2); Inc(P3); Inc(P4); Inc(POut);
        POut^ := (P1^ + P2^ + P3^ + P4^) shr 2; // green
        Inc(P1); Inc(P2); Inc(P3); Inc(P4); Inc(POut);
        POut^ := (P1^ + P2^ + P3^ + P4^) shr 2; // red
        Inc(P1, 4); Inc(P2, 4); Inc(P3, 4); Inc(P4, 4); Inc(POut);
        Inc(Lx);
      end;
      Inc(POut, LRowSkipOut);
      Inc(P1, LRowSkip); Inc(P2, LRowSkip);
    end;
  end else if R = 3 then
  begin
    LRowSkip := LRowSize * 3 - W * 9;
    P3 := PByte(Integer(P2) + LRowSize);
    for Ly := 0 to HM do
    begin
      P4 := PByte(Integer(P1) + 3);
      P5 := PByte(Integer(P2) + 3);
      P6 := PByte(Integer(P3) + 3);
      P7 := PByte(Integer(P4) + 3);
      P8 := PByte(Integer(P5) + 3);
//      Integer(P9) := Integer(P6) + 3;
      for Lx := 0 to WM do
      begin
        // set output pixel to the average of the 3X3 box of input pixels
        POut^ := (P1^ + P2^ + P3^ + P4^ + P5^ + P6^ + P7^ + P8^{ + P9^}) shr 3;
        Inc(P1); Inc(P2); Inc(P3); Inc(P4); Inc(P5); Inc(P6); Inc(P7); Inc(P8); {Inc(P9);}
        Inc(POut);
        POut^ := (P1^ + P2^ + P3^ + P4^ + P5^ + P6^ + P7^ + P8^ {+ P9^}) shr 3;
        Inc(P1);Inc(P2);Inc(P3);Inc(P4);Inc(P5);Inc(P6);Inc(P7);Inc(P8);{Inc(P9);}
        Inc(POut);
        POut^ := (P1^ + P2^ + P3^ + P4^ + P5^ + P6^ + P7^ + P8^ {+ P9^}) shr 3;
        Inc(P1, 7); Inc(P2, 7); Inc(P3, 7); Inc(P4, 7); Inc(P5, 7); Inc(P6, 7); Inc(P7, 7); Inc(P8, 7); {Inc(P9, 7)}
        Inc(POut);
      end;
      Inc(POut, LRowSkipOut);
      Inc(P1, LRowSkip); Inc(P2, LRowSkip); Inc(P3, LRowSkip);
    end;
  end else if R = 4 then
  begin
    LRowSkip := LRowSize shl 2 - W * 12;
    P3 := PByte(Integer(P2) + LRowSize);
    P4 := PByte(Integer(P3) + LRowSize);
    for Ly := 0 to HM do
    begin
      P5 := PByte(Integer(P1) + 3); P6 := PByte(Integer(P2) + 3);
      P7 := PByte(Integer(P3) + 3); P8 := PByte(Integer(P4) + 3);
      P9 := PByte(Integer(P5) + 3); PA := PByte(Integer(P6) + 3);
      PB := PByte(Integer(P7) + 3); PC := PByte(Integer(P8) + 3);
      PD := PByte(Integer(P9) + 3); PE := PByte(Integer(PA) + 3);
      PF := PByte(Integer(PB) + 3); PG := PByte(Integer(PC) + 3);
      for Lx := 0 to WM do
      begin
        // set output pixel to the average of the 4X4 box of input pixels
        POut^ := (P1^+P2^+P3^+P4^+P5^+P6^+P7^+P8^+P9^+PA^+PB^+PC^+PD^+PE^+PF^+PG^) shr 4;
        Inc(P1);Inc(P2);Inc(P3);Inc(P4);Inc(P5);Inc(P6);Inc(P7);Inc(P8);
        Inc(P9);Inc(PA);Inc(PB);Inc(PC);Inc(PD);Inc(PE);Inc(PF);Inc(PG);
        Inc(POut);
        POut^ := (P1^+P2^+P3^+P4^+P5^+P6^+P7^+P8^+P9^+PA^+PB^+PC^+PD^+PE^+PF^+PG^) shr 4;
        Inc(P1);Inc(P2);Inc(P3);Inc(P4);Inc(P5);Inc(P6);Inc(P7);Inc(P8);
        Inc(P9);Inc(PA);Inc(PB);Inc(PC);Inc(PD);Inc(PE);Inc(PF);Inc(PG);
        Inc(POut);
        POut^ := (P1^+P2^+P3^+P4^+P5^+P6^+P7^+P8^+P9^+PA^+PB^+PC^+PD^+PE^+PF^+PG^) shr 4;
        Inc(P1,10);Inc(P2,10);Inc(P3,10);Inc(P4,10);Inc(P5,10);Inc(P6,10);Inc(P7,10);Inc(P8,10);
        Inc(P9,10);Inc(PA,10);Inc(PB,10);Inc(PC,10);Inc(PD,10);Inc(PE,10);Inc(PF,10);Inc(PG,10);
        Inc(POut);
      end;
      Inc(POut, LRowSkipOut);
      Inc(P1, LRowSkip); Inc(P2, LRowSkip); Inc(P3, LRowSkip); Inc(P4, LRowSkip);
    end;
  end else
  begin // shrink by any ratio > 4
    LBoxPixels := R * R;
    LBoxSize := R * 3;
    LRowSkipBox := LRowSize - LBoxSize;
    LRowSkip := LRowSize * R - R * W * 3;
    LyS := 0;
    for Ly := 0 to HM do
    begin
      LySend := LyS + R - 1;
      LxS := 0;
      for Lx := 0 to WM do
      begin
        LxSend := LxS + R - 1;
        LSumR := 0; LSumG := 0; LSumB := 0;
        P2 := P1; // P1 points to the top left corner of the box
        // loop through super-sampling box of pixels in input bitmap and sum them
        for LyB := LyS to LySend do
        begin
          for LxB := LxS to LxSend do
          begin
            Inc(LSumB, P2^); Inc(P2);
            Inc(LSumG, P2^); Inc(P2);
            Inc(LSumR, P2^); Inc(P2);
          end;
          Inc(P2, LRowSkipBox);
        end;
        Inc(P1, LBoxSize);
        // set output bitmap pixel to the average of the pixels in the box
        POut^ := LSumB div LBoxPixels;
        Inc(POut);
        POut^ := LSumG div LBoxPixels;
        Inc(POut);
        POut^ := LSumR div LBoxPixels;
        Inc(POut);
        Inc(LxS, R);
      end;
      Inc(P1, LRowSkip);
      Inc(POut, LRowSkipOut);
      Inc(LyS, R);
    end;
  end;
end;

class procedure TImgProcessor.OpenImage_JPEG(AFileName: string;
  AJpeg: TJPEGImage);
var
  SourceImg: TBitmap;
  ResizedImg: TBitmap;
  ThumbRect: TRect;
begin
  if AJpeg = nil then Exit;

  AJpeg.LoadFromFile(AFileName);
  if (AJpeg.Width > USER_IMAGE_MAX_WIDTH) or ((AJpeg.Height > USER_IMAGE_MAX_HEIGHT)) then
  begin
    SourceImg := TBitmap.Create;
    try
      SourceImg.Assign(AJpeg);
      ResizedImg := TBitmap.Create;
      try
        ThumbRect.Left := 0;
        ThumbRect.Top := 0;
        if SourceImg.Width > SourceImg.Height then
        begin
          ThumbRect.Right := USER_IMAGE_MAX_WIDTH;
          ThumbRect.Bottom := (USER_IMAGE_MAX_WIDTH * SourceImg.Height) div SourceImg.Width;
        end else
        begin
          ThumbRect.Bottom := USER_IMAGE_MAX_HEIGHT;
          ThumbRect.Right := (USER_IMAGE_MAX_HEIGHT * SourceImg.Width) div SourceImg.Height;
        end;
        ResizedImg.Width := ThumbRect.Right;
        ResizedImg.Height := ThumbRect.Bottom;
        SmoothResize(SourceImg, ResizedImg);
        AJpeg.Assign(ResizedImg);
      finally
        ResizedImg.Free;
      end;
    finally
      SourceImg.Free;
    end;
  end;
end;

class function TImgProcessor.ByteArrayToImage(ABytes: TImgByteArray;
  outBitmap: TBitmap): Boolean;
var
  MemStream: TMemoryStream;
  JPEGImage: TJPEGImage;
begin
  Result := False;

  if Length(ABytes) = 0
    then Exit;

  MemStream := TMemoryStream.Create;
  JPEGImage := TJPEGImage.Create;
  try
    MemStream.Size := Length(ABytes);
    MemStream.Write(ABytes[0], MemStream.Size);
    MemStream.Seek(0, soFromBeginning);
    JPEGImage.CompressionQuality := 100;
    JPEGImage.Smoothing := True;
    JPEGImage.LoadFromStream(MemStream);
    if JPEGImage <> nil
      then outBitmap.Assign(JPEGImage);
    Result := True;
  finally
    JPEGImage.Free;
    MemStream.Free;
  end;
end;

class function TImgProcessor.ByteArrayToImage(ABytes: OleVariant;
  outBitmap: TBitmap): Boolean;
var
  PImageData: Pointer;
  MemStream: TMemoryStream;
  JPEGImage: TJPEGImage;
begin
  Result := False;

  if not VarIsArray(ABytes)
    then Exit;

  MemStream := TMemoryStream.Create;
  JPEGImage := TJPEGImage.Create;
  try
    MemStream.Size := VarArrayHighBound(ABytes, 1) - VarArrayLowBound(ABytes,  1) + 1;
    PImageData := VarArrayLock(ABytes);
    MemStream.Write(PImageData^, MemStream.Size);
    VarArrayUnlock(ABytes);
    MemStream.Seek(0, soFromBeginning);
    JPEGImage.CompressionQuality := 100;
    JPEGImage.Smoothing := True;
    JPEGImage.LoadFromStream(MemStream);
    if JPEGImage <> nil then outBitmap.Assign(JPEGImage);
    Result := True;
  finally
    JPEGImage.Free;
    MemStream.Free;
  end;
end;

class function TImgProcessor.ByteArrayToImage(ABytes: PSafeArray;
  outBitmap: TBitmap): Boolean;
var
  bytes: PSafeArray;
  LBound, HBound : Integer;
  ImgBytes: TImgByteArray;
  i: Integer;
  ib: Byte;
  png: TPngImage;
  jpg: TJPEGImage;
  stream: TMemoryStream;
begin
  bytes := ABytes;
  SafeArrayGetLBound(bytes, 1, LBound);
  SafeArrayGetUBound(bytes, 1, HBound);
  SetLength(ImgBytes, HBound + 1);
  for i := LBound to HBound do
  begin
    SafeArrayGetElement(bytes, i, ib);
    ImgBytes[i] := ib;
  end;
  SafeArrayDestroy(bytes);

  png := TPngImage.Create;
  jpg := TJPEGImage.Create;

  try
    stream := TMemoryStream.create;
    try
      stream.Write(ImgBytes[0], Length(ImgBytes));
      stream.Position:= 0;
//      if ContainsText(ucmaContact.PhotoHex, '89-50-4E-47-0D-0A-1A-0A') then
//      begin
//        png.LoadFromStream(stream);
//        Image1.Picture.Bitmap.Assign(png);
//      end else if ContainsText(ucmaContact.PhotoHex, 'FF-D8-FF') then
      begin
        jpg.LoadFromStream(stream);
        outBitmap.Assign(jpg);
      end;

    finally
      stream.Free;
    end;
  finally
    png.Free;
    jpg.Free;
  end;

end;

class procedure TImgProcessor.GetThemeButtons(AHWND: HWND; AHDC: HDC; APartID: Integer;
  ABgColor: TColor; AImgList: TImageList);
const
  _SIZE = 16;
var
  B: TBitmap;
  hT: HTHEME;
  S: TSize;
  R: TRect;
begin
  if AImgList = nil then Exit;

  AImgList.Clear;

  B := TBitmap.Create;

  try
    B.SetSize(_SIZE, _SIZE);
    B.Canvas.Brush.Style := bsClear;
    B.Canvas.Brush.Color := ABgColor;
    R := B.Canvas.ClipRect;

    hT := OpenThemeData(AHWND, 'BUTTON');
    if hT <> 0 then
    begin
      GetThemePartSize(
        hT,
        AHDC,
        APartID,
        CBS_CHECKEDNORMAL,
        @R,
        TS_DRAW,
        S
      );

      R.Offset(
        Trunc((_SIZE - S.cx) / 2),
        Trunc((_SIZE - S.cy) / 2)
      );

      { 1 }
      B.Canvas.FillRect(B.Canvas.ClipRect);

      DrawThemeBackground(
        hT,
        B.Canvas.Handle,
        APartID,
        CBS_UNCHECKEDNORMAL,
        R,
        nil
      );

      AImgList.Add(B, nil);

      { 2 }
      B.Canvas.FillRect(B.Canvas.ClipRect);

      DrawThemeBackground(
        hT,
        B.Canvas.Handle,
        APartID,
        CBS_CHECKEDNORMAL,
        R,
        nil
      );

      AImgList.Add(B, nil);

      { 3 }
      B.Canvas.FillRect(B.Canvas.ClipRect);

      DrawThemeBackground(
        hT,
        B.Canvas.Handle,
        APartID,
        CBS_UNCHECKEDDISABLED,
        R,
        nil
      );

      AImgList.Add(B, nil);

      { 4 }
      B.Canvas.FillRect(B.Canvas.ClipRect);

      DrawThemeBackground(
        hT,
        B.Canvas.Handle,
        APartID,
        CBS_CHECKEDDISABLED,
        R,
        nil
      );

      AImgList.Add(B, nil);
    end;
  finally
    B.Free;
    CloseThemeData(hT);
  end;
end;

class function TImgProcessor.ImageToByteArray(AJPEG: TJPEGImage; outByteArray: PImgByteArray): Boolean;
var
  b: TBitmap;
begin
  b := TBitmap.Create;
  try
    b.Assign(AJPEG);
    Result := ImageToByteArray(b, outByteArray);
  finally
    b.Free;
  end;
end;

class function TImgProcessor.ImageToByteArray(ABitmap: TBitmap;
  outByteArray: PImgByteArray): Boolean;
var
  Stream: TMemoryStream;
  JPEGImg: TJPEGImage;
begin
  Result := False;

  if outByteArray = nil
    then Exit;

  Stream := TMemoryStream.Create;
  JPEGImg := TJPEGImage.Create;
  try
    JPEGImg.Smoothing := True;
    JPEGImg.CompressionQuality := 100;
    JPEGImg.Assign(ABitmap);
    JPEGImg.SaveToStream(Stream);
    Stream.Seek(0, soFromBeginning);
    SetLength(outByteArray^, Stream.size);
    Stream.ReadBuffer(outByteArray^[0], Length(outByteArray^));
    Result := True;
  finally
    Stream.Free;
    JPEGImg.Free;
  end;
end;

class procedure TImgProcessor.SmoothResize(Src, Dst: TBitmap);
var
  Lx, Ly : integer;
  LyBox, LxBox, LyBox1, LyBox2, LxBox1, LxBox2 : integer;
  TR, TG, TB : integer;
  LRowIn, LRowOut, LRowInStart : pRGBArray;
  LBoxCount : integer;
  LRowBytes, LRowBytesIn : integer;
  LBoxRows : array of pRGBArray;
  LRatioW, LRatioH : Real;
begin
  Src.PixelFormat := pf24bit;
  Dst.PixelFormat := pf24bit;

  LRatioH := Src.Height / Dst.Height;
  LRatioW := Src.Width / Dst.Width;

  if (Frac(LRatioW) = 0) and (Frac(LRatioH) = 0) then
  begin
    BitmapShrink(Src, Dst);
    Exit;
  end;

  SetLength(LBoxRows, trunc(LRatioW) + 1);

  LRowOut := Dst.ScanLine[0];
  LRowBytes := -(((Dst.Width * 24 + 31) and not 31) shr 3);
  LRowBytesIn := -(((Src.Width * 24 + 31) and not 31) shr 3);
  LRowInStart := Src.ScanLine[0];

  for Ly := 0 to Dst.Height-1 do
  begin
    LyBox1 := trunc(Ly * LRatioH);
    LyBox2 := trunc((Ly+1) * LRatioH) - 1;

    for LyBox := LyBox1 to LyBox2 do
      LBoxRows[LyBox - LyBox1] := pRGBArray(Integer(LRowInStart) + LyBox * LRowBytesIn);

    for Lx := 0 to Dst.Width-1 do
    begin
      LxBox1 := trunc(Lx * LRatioW);
      LxBox2 := trunc((Lx + 1) * LRatioW) - 1;
      TR := 0; TG := 0; TB := 0;
      LBoxCount := 0;
      for LyBox := LyBox1 to LyBox2 do
      begin
        LRowIn := LBoxRows[LyBox - LyBox1];
        for LxBox := LxBox1 to LxBox2 do
        begin
          Inc(TB, LRowIn[LxBox].B);
          Inc(TG, LRowIn[LxBox].G);
          Inc(TR, LRowIn[LxBox].R);
          Inc(LBoxCount);
        end;
      end;
      LRowOut[Lx].B := TB div LBoxCount;
      LRowOut[Lx].G := TG div LBoxCount;
      LRowOut[Lx].R := TR div LBoxCount;
    end;
    LRowOut := pRGBArray(Integer(LRowOut) + LRowBytes);
  end;
end;

class function TImgProcessor.ByteArrayToImage(ABytes: WideString;
  outBitmap: TBitmap): Boolean;
var
  regEx: TRegEx;
  bStr: WideString;
  bArr: TBytes;
  i: Integer;
begin
  regEx := TRegEx.Create('[^0-9A-F]');
  bStr := LowerCase(regEx.Replace(ABytes, ''));
  SetLength(bArr, Length(bStr) div 2);
  if Length(bArr) > 0 then
  begin
    HexToBin(PChar(bStr), bArr, Length(bArr));

    TImgProcessor.ByteArrayToImage(bArr, outBitmap);
  end;
end;

end.
