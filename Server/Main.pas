unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, IdBaseComponent, IdComponent,
  IdUDPBase, IdUDPServer, IdGlobal, IdSocketHandle, FMX.Memo.Types,
  FMX.ScrollBox, FMX.Memo, System.DateUtils, FMX.Objects, MyCommands, System.Generics.Collections,
  IdUDPClient, FMX.Edit;

const symbols: array [1..19] of string = (
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
    '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', ':'
);



type TPacket = packed record
  msLen:Byte;
  colorarray:array [1..40,1..40] of cardinal;
  w:integer;
  h:integer;
  msg:string[255];
end;


type TPicData = class
  pic:TBitmap;
  x:Double;
  y:Double;
  constructor Create(var x,y:Double;var pic:TBitmap); overload;
end;


type TSpriteData = class
  sprite:TBitmap;
  w:Double;
  h:Double;
  constructor Create(var w,h:Double; var sprite:TBitmap); overload;
end;


type TTextData = class
  text:string;
  x1:Double;
  y1:Double;
  x2:Double;
  y2:Double;
  color:string;
  constructor Create(var text:string; var x1,y1,x2,y2:Double; color:string); overload;
end;


type TEllipseData = class
  x1:Double;
  y1:Double;
  x2:Double;
  y2:Double;
  color:string;
  constructor Create(var x1,y1,x2,y2:Double; color:string); overload;
end;

type TCircleData = class
  x0:Integer;
  y0:Integer;
  radius:Integer;
  color:string;
  constructor Create(var x0, y0, radius : Integer; color : string); overload;
end;


type TPixelData = class
  x1:Double;
  y1:Double;
  color:string;
  constructor Create(var x1,y1:Double; color:string); overload;
end;

type TSymbolData = class
  x:Double;
  y:Double;
  color:string;
  symbpos:integer;
  constructor Create(var x, y : Double; color : string;  symbpos : integer); overload;
end;


type TFillRoundedRectangleData = class
  x1:Integer;
  y1:Integer;
  x2:Integer;
  y2:Integer;
  radius:Integer;
  color:string;
  constructor Create(var x1,y1,x2,y2,radius:Integer;color:string); overload;
end;

type TDrawRoundedRectangleData = class
  x1:Integer;
  y1:Integer;
  x2:Integer;
  y2:Integer;
  radius:Integer;
  color:string;
  constructor Create(var x1,y1,x2,y2,radius:Integer;color:string); overload;
end;



type TLineData = class
  p1:TPointF;
  p2:TPointF;
  color:string;
  constructor Create(var p1,p2:TPointF; color:string); overload;
end;

type TCommand=(DRAW_LINE, DRAW_ELLIPSE, DRAW_TEXT,
CLEAR, DRAW_IMAGE, FILL_ROUNDED_RECTANGLE,
DRAW_PIXEL, DRAW_SYMBOL, SET_ORIENTATION,
GET_WIDTH, GET_HEIGHT, LOAD_SPRITE, SHOW_SPRITE,
DRAW_ROUNDED_RECTANGLE, FILL_ELLIPSE, DRAW_CIRCLE,
FILL_CIRCLE, ERROR);

type
  TForm1 = class(TForm)
    IdUDPServer1: TIdUDPServer;
    ToolBar1: TToolBar;
    Label2: TLabel;
    PaintBox1: TPaintBox;
    procedure FormCreate(Sender: TObject);
    procedure IdUDPServer1UDPRead(AThread: TIdUDPListenerThread;
      const AData: TIdBytes; ABinding: TIdSocketHandle);
    procedure PaintBox1Paint(Sender: TObject; Canvas: TCanvas);
  private
    bmp:TBitmap;
    packet:TPacket;
    command:TCommand;
    drawcommand:integer;
    loadcommand:integer;
    piclist:TList<TPicData>;
    textlist:TList<TTextData>;
    linelist:TList<TLineData>;
    ellipselist:TList<TEllipseData>;
    fillellipselist:TList<TEllipseData>;
    fillroundedrectanglelist:TList<TFillRoundedRectangleData>;
    drawroundedrectanglelist:TList<TDrawRoundedRectangleData>;
    pixellist:TList<TPixelData>;
    symbollist:TList<TSymbolData>;
    spritelist:TList<TSpriteData>;
    circlelist:TList<TCircleData>;
    fillcirclelist:TList<TCircleData>;
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.FormCreate(Sender: TObject);
begin
  IdUDPServer1.Active:=true;
  TMyCommands.linepath:=TPathData.Create;
  TMyCommands.ellipsepath:=TPathData.Create;
  TMyCommands.clearcolor:='000000';
  piclist:=TList<TPicData>.Create;
  textlist:=TList<TTextData>.Create;
  linelist:=TList<TLineData>.Create;
  ellipselist:=TList<TEllipseData>.Create;
  fillellipselist:=TList<TEllipseData>.Create;
  fillroundedrectanglelist:=TList<TFillRoundedRectangleData>.Create;
  pixellist:=TList<TPixelData>.Create;
  symbollist:=TList<TSymbolData>.Create;
  spritelist:=TList<TSpriteData>.Create;
  drawroundedrectanglelist:=TList<TDrawRoundedRectangleData>.Create;
  circlelist:=TList<TCircleData>.Create;
  fillcirclelist:=TList<TCircleData>.Create;
end;

procedure TForm1.IdUDPServer1UDPRead(AThread: TIdUDPListenerThread;
  const AData: TIdBytes; ABinding: TIdSocketHandle);
var s:string; i:integer;     spl:TArray<string>; iw,jw:integer;
    b1:TBitmapData; picdata:TPicData; textdata:TTextData;
    spritedata:TSpriteData;
    linedata:TLineData; ellipsedata,fillellipsedata:TEllipseData;
    fillroundedrectangledata:TFillRoundedRectangleData;
    pixeldata:TPixelData; px,py:Double; mysymboldata:TSymbolData;
    symbolpos:integer; symbolx,symboly:Double;  symbolcolor:string;
    drawroundedrectangledata:TDrawRoundedRectangleData;
    circledata:TCircleData; fillcircledata:TCircleData;
begin

          Move(AData[0],packet,sizeof(packet));
          s:=packet.msg;
          spl:=s.Split([' ']);


          command:=TCommand(Integer.Parse(spl[0]));

        case command of
          TCommand.DRAW_LINE:
          begin
            drawcommand:=Integer.Parse(spl[0]);
            TMyCommands.PrepareLine(spl[1],spl[2],spl[3],spl[4],spl[5]);
            linedata:=TLineData.Create(TMyCommands.p1,TMyCommands.p2,TMyCommands.linecolor);
            linelist.Add(linedata);
            PaintBox1.Repaint;
          end;
          TCommand.DRAW_ELLIPSE:
          begin
            drawcommand:=Integer.Parse(spl[0]);
            TMyCommands.PrepareEllipse(spl[1],spl[2],spl[3],spl[4],spl[5]);
            ellipsedata:=TEllipseData.Create(TMyCommands.x1_ellipse,TMyCommands.y1_ellipse,
            TMyCommands.x2_ellipse,TMyCommands.y2_ellipse,TMyCommands.ellipsecolor);
            ellipselist.Add(ellipsedata);
            PaintBox1.Repaint;
          end;
          TCommand.DRAW_TEXT:
          begin
            drawcommand:=Integer.Parse(spl[0]);
            TMyCommands.PrepareText(spl[1],spl[2],spl[3],spl[4],spl[5],spl[6]);
            textdata:=TTextData.Create(TMyCommands.textout,TMyCommands.x1_text,TMyCommands.y1_text,
            TMyCommands.x2_text,TMyCommands.y2_text,TMyCommands.textcolor);
            textlist.Add(textdata);
            PaintBox1.Repaint;
          end;
          TCommand.CLEAR:
          begin
            drawcommand:=Integer.Parse(spl[0]);
            TMyCommands.PrepareClear(spl[1]);
            piclist.Clear;
            textlist.Clear;
            linelist.Clear;
            pixellist.Clear;
            symbollist.Clear;
            ellipselist.Clear;
            spritelist.Clear;
            fillellipselist.Clear;
            drawroundedrectanglelist.Clear;
            circlelist.Clear;
            fillcirclelist.Clear;
            Label2.Text:='';
            fillroundedrectanglelist.Clear;
            Form1.Fill.Color:=StrToInt('$ff'+TMyCommands.clearcolor);
            PaintBox1.Repaint;
          end;
          TCommand.DRAW_IMAGE:
          begin
            drawcommand:=Integer.Parse(spl[0]);
            TMyCommands.PrepareDrawImage(spl[1],spl[2]);
            bmp:=TBitmap.Create();

            bmp.SetSize(packet.w,packet.h);

            bmp.Map(TMapAccess.Write,b1);

            for iw:=1 to Round(bmp.Width) do
            for jw:=1 to Round(bmp.Height) do
            begin
              b1.SetPixel(iw,jw,packet.colorarray[iw,jw]);
            end;
            bmp.Unmap(b1);

            picdata:=TPicData.Create(TMyCommands.ximage,TMyCommands.yimage,bmp);
            piclist.Add(picdata);

            PaintBox1.Repaint;
          end;
          TCommand.FILL_ROUNDED_RECTANGLE:
          begin
            TMyCommands.PrepareFillRoundedRectangle(spl[1],spl[2],spl[3],spl[4],spl[5],spl[6]);
            fillroundedrectangledata:=TFillRoundedRectangleData.Create(TMyCommands.x1,TMyCommands.y1,
              TMyCommands.x2,TMyCommands.y2,TMyCommands.radius,TMyCommands.fillroundedrectanglecolor);
            fillroundedrectanglelist.Add(fillroundedrectangledata);
            PaintBox1.Repaint;
          end;
          TCommand.DRAW_PIXEL:
          begin
            TMyCommands.PreparePixel(spl[1],spl[2],spl[3]);
            px:=TMyCommands.ppoint.X;
            py:=TMyCommands.ppoint.Y;
            pixeldata:=TPixelData.Create(px, py, TMyCommands.pixelcolor);
            pixellist.Add(pixeldata);
            PaintBox1.Repaint;
          end;
          TCommand.DRAW_SYMBOL:
          begin
            TMyCommands.PrepareSymbol(spl[1],spl[2],spl[3],spl[4]);
            for symbolpos:=1 to Length(symbols) do
            begin
              if TMyCommands.symbol=symbols[symbolpos] then
              begin
                symbolx:=TMyCommands.sx;
                symboly:=TMyCommands.sy;
                symbolcolor:=TMyCommands.symbolcolor;
                mysymboldata:=TSymbolData.Create(symbolx, symboly, symbolcolor, (symbolpos-1));
                symbollist.Add(mysymboldata);
              end;
            end;

            PaintBox1.Repaint;
          end;
          TCommand.SET_ORIENTATION:
          begin
            TMyCommands.PrepareOrientation(spl[1]);
            PaintBox1.RotationAngle:=TMyCommands.degrees;
          end;
          TCommand.GET_WIDTH:
          begin
            ShowMessage('Canvas width = '+PaintBox1.Width.ToString);
          end;
          TCommand.GET_HEIGHT:
          begin
            ShowMessage('Canvas height = '+PaintBox1.Height.ToString);
          end;
          TCommand.LOAD_SPRITE:
          begin
            loadcommand:=Integer.Parse(spl[0]);
            TMyCommands.PrepareLoadSprite(spl[1],spl[2]);

            bmp:=TBitmap.Create();

            bmp.SetSize(packet.w,packet.h);

            bmp.Map(TMapAccess.Write,b1);

            for iw:=1 to Round(bmp.Width) do
            for jw:=1 to Round(bmp.Height) do
            begin
              b1.SetPixel(iw,jw,packet.colorarray[iw,jw]);
            end;
            bmp.Unmap(b1);

            spritedata:=TSpriteData.Create(TMyCommands.spritewidth,TMyCommands.spriteheight,bmp);
            spritelist.Add(spritedata);
            Label2.Text:='Sprites loaded='+spritelist.Count.ToString;
          end;
          TCommand.SHOW_SPRITE:
          begin
            TMyCommands.PrepareShowSprite(spl[1],spl[2],spl[3]);
            PaintBox1.Repaint;
          end;
          TCommand.DRAW_ROUNDED_RECTANGLE:
          begin
            TMyCommands.PrepareDrawRoundedRectangle(spl[1],spl[2],spl[3],spl[4],spl[5],spl[6]);
            drawroundedrectangledata:=TDrawRoundedRectangleData.Create(TMyCommands.x1,TMyCommands.y1,
              TMyCommands.x2,TMyCommands.y2,TMyCommands.radius,TMyCommands.fillroundedrectanglecolor);
            drawroundedrectanglelist.Add(drawroundedrectangledata);
            PaintBox1.Repaint;
          end;
          TCommand.FILL_ELLIPSE:
          begin
            TMyCommands.PrepareEllipse(spl[1],spl[2],spl[3],spl[4],spl[5]);
            fillellipsedata:=TEllipseData.Create(TMyCommands.x1_ellipse,TMyCommands.y1_ellipse,
            TMyCommands.x2_ellipse,TMyCommands.y2_ellipse,TMyCommands.ellipsecolor);
            fillellipselist.Add(fillellipsedata);
            PaintBox1.Repaint;
          end;
          TCommand.DRAW_CIRCLE:
          begin
            TMyCommands.PrepareCircle(spl[1],spl[2],spl[3],spl[4]);
            circledata:=TCircleData.Create(TMyCommands.circleX0,TMyCommands.circleY0,
            TMyCommands.CircleRadius,TMyCommands.CircleColor);
            circlelist.Add(circledata);
            PaintBox1.Repaint;
          end;
          TCommand.FILL_CIRCLE:
          begin
            TMyCommands.PrepareCircle(spl[1],spl[2],spl[3],spl[4]);
            fillcircledata:=TCircleData.Create(TMyCommands.circleX0,TMyCommands.circleY0,
            TMyCommands.CircleRadius,TMyCommands.CircleColor);
            fillcirclelist.Add(fillcircledata);
            PaintBox1.Repaint;
          end;
          TCommand.ERROR:
          begin
            ShowMessage('�������! �����i��� ��������i��� �������� ������ � ��i���i!!!');
          end;

        end;

end;


procedure TForm1.PaintBox1Paint(Sender: TObject; Canvas: TCanvas);
var i:integer; p:TPicData; t:TTextData; l:TLineData;  e:TEllipseData;  fe:TEllipseData;
    frr:TFillRoundedRectangleData; pixel:TPixelData; a:TSymbolData; drr:TDrawRoundedRectangleData;
    sprite:TSpriteData; c:TCircleData; fc:TCircleData;
begin
  PaintBox1.Canvas.BeginScene();

        for l in linelist do
          TMyCommands.DrawMyLine(l.p1,l.p2,Canvas,StrToInt('$ff'+l.color));

        for e in ellipselist do
          TMyCommands.DrawMyEllipse(e.x1,e.y1,e.x2,e.y2,Canvas,StrToInt('$ff'+e.color));

        for fe in fillellipselist do
          TMyCommands.FillMyEllipse(fe.x1,fe.y1,fe.x2,fe.y2,Canvas,StrToInt('$ff'+fe.color));

        for t in textlist do
          TMyCommands.DrawMyText(t.x1,t.y1,t.x2,t.y2,
             t.text, 30, Canvas, StrToInt('$ff'+t.color));

        for p in piclist do
          TMyCommands.DrawImage(p.x,p.y,p.pic,Canvas);

        for frr in fillroundedrectanglelist do
          TMyCommands.FillRoundedRectangle(frr.x1,frr.y1,frr.x2,frr.y2,frr.radius,
            Canvas,StrToInt('$ff'+frr.color));

        for drr in drawroundedrectanglelist do
          TMyCommands.DrawRoundedRectangle(drr.x1,drr.y1,drr.x2,drr.y2,drr.radius,
            Canvas,StrToInt('$ff'+drr.color));

        for pixel in pixellist do
        begin
          TMyCommands.DrawMyPixel(TPointF.Create(pixel.x1,pixel.y1),
            Canvas,StrToInt('$ff'+pixel.color));
        end;

        for a in symbollist do
        begin
          TMyCommands.DrawSymbol(a.symbpos,TPointF.Create(a.x,a.y),Canvas,StrToInt('$ff'+a.color));
        end;

        for sprite in spritelist do
        begin
          TMyCommands.ShowSprite(TMyCommands.spritexpos, TMyCommands.spriteypos,
          spritelist.Items[TMyCommands.spriteindex].w,
          spritelist.Items[TMyCommands.spriteindex].h,
          spritelist.Items[TMyCommands.spriteindex].sprite, Canvas);
        end;

        for c in circlelist do
          TMyCommands.DrawMyCircle(c.x0, c.y0, c.radius,
          Canvas, StrToInt('$ff'+c.color));

        for fc in fillcirclelist do
          TMyCommands.FillMyCircle(fc.x0, fc.y0, fc.radius,
          Canvas, StrToInt('$ff'+fc.color));

  PaintBox1.Canvas.EndScene;

end;



constructor TPicData.Create(var x, y: Double; var pic: TBitmap);
begin
  Self.x:=x;
  Self.y:=y;
  Self.pic:=pic;
end;


constructor TTextData.Create(var text:string; var x1,y1,x2,y2:Double; color:string);
begin
  Self.text:=text;
  Self.x1:=x1;
  Self.y1:=y1;
  Self.x2:=x2;
  Self.y2:=y2;
  Self.color:=color;
end;


constructor TLineData.Create(var p1,p2:TPointF; color:string);
begin
  Self.p1:=p1;
  Self.p2:=p2;
  Self.color:=color;
end;

constructor TEllipseData.Create(var x1, y1, x2, y2: Double; color: string);
begin
  Self.x1:=x1;
  Self.y1:=y1;
  Self.x2:=x2;
  Self.y2:=y2;
  Self.color:=color;
end;


constructor TFillRoundedRectangleData.Create(var x1, y1, x2, y2,
  radius: Integer; color: string);
begin
  Self.x1:=x1;
  Self.y1:=y1;
  Self.x2:=x2;
  Self.y2:=y2;
  Self.radius:=radius;
  Self.color:=color;
end;


constructor TPixelData.Create(var x1, y1: Double; color: string);
begin
  Self.x1:=x1;
  Self.y1:=y1;
  Self.color:=color;
end;


constructor TSymbolData.Create(var x, y: Double; color: string; symbpos : integer);
begin
  Self.symbpos:=symbpos;
  Self.x:=x;
  Self.y:=y;
  Self.color:=color;
end;


constructor TSpriteData.Create(var w, h: Double; var sprite: TBitmap);
begin
  Self.w:=w;
  Self.h:=h;
  Self.sprite:=sprite;
end;


constructor TDrawRoundedRectangleData.Create(var x1, y1, x2, y2,
  radius: Integer; color: string);
begin
  Self.x1:=x1;
  Self.y1:=y1;
  Self.x2:=x2;
  Self.y2:=y2;
  Self.radius:=radius;
  Self.color:=color;
end;


constructor TCircleData.Create(var x0, y0, radius: Integer; color: string);
begin
  Self.x0:=x0;
  Self.y0:=y0;
  Self.radius:=radius;
  Self.color:=color;
end;

end.
