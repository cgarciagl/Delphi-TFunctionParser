unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, FuncionParser;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Button1: TButton;
    PaintBox3D: TPaintBox;
    Label2: TLabel;
    Button2: TButton;
    FuncionParser1: TFuncionParser;
    ComboBox1: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FuncionParser1ParserError(Sender: TObject;
      ParseError: Integer);
    procedure FuncionParser1PideVariable(Sender: TObject; Variable: String;
      var Valor: Extended; var Found: Boolean);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    XCen, YCen: Integer;
    function  Get2DPoint(X, Y, Z: Extended): TPoint;
    procedure Do3DGraph;
  public
    { Public declarations }
  end;

const
  Ratio = 35;
  Sections = 90;
  Bounds = 2;

var
  Form1: TForm1;
  X2,Y2: Extended;
implementation

{$R *.DFM}

{determina el Punto Tridimensional en el canvas bidimensional... }
function  TForm1.Get2DPoint(X, Y, Z: Extended): TPoint;
begin
  Result := Point(Round(XCen + Ratio * (X - Y * 1/sqrt(2))),
                  Round(YCen + Ratio * (-Z + y *1/sqrt(2))));
end;

function f(X1,Y1:real):real;
begin
 X2 := X1; Y2 := Y1;
 Form1.FuncionParser1.Parse;
 if not Form1.FuncionParser1.ParseError then
 f := Form1.FuncionParser1.ParseValor else f:= 0;
end;

{ Este es un muy simple aunque no muy rápido algoritmo de  }
{ dibujado tridimensional ... }
procedure TForm1.Do3DGraph;
var
  I: Integer;
  P: TPoint;
  X, Y, H: Extended;
  Max, Min: Array [0..1024] of Integer;
begin
Form1.FuncionParser1.funcion := Form1.Combobox1.text;
Label2.Caption := 'No hay Problema';
  with PaintBox3D.Canvas do begin
    Brush.Color := clBlack;
    FillRect(Rect(0, 0, Width, Height));


    for i := 0 to 1024 do
    begin
      Max[i] := 0;
      Min[i] := Height;
    end;

    X := Bounds;
    H := 2 * Bounds / Sections;
    while X >= -Bounds do begin
      Y := -Bounds;
      while Y <= Bounds do begin
        P := Get2DPoint(X, Y, F(X,Y));
        if P.Y > Max[P.X] then begin
          Pixels[P.X, P.Y] :=clRed;
          Max[P.X] := P.Y;
        end;
        if P.Y < Min[P.X] then begin
          Pixels[P.X, P.Y] := clYellow;
          Min[P.X] := P.Y;
        end;

        Y := Y + H;
      end;
      X := X - H;
    end;
  end;
end;


procedure TForm1.FormCreate(Sender: TObject);
begin
  XCen := PaintBox3D.Width div 2;
  YCen := PaintBox3D.Height div 2;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
Label2.Caption:='';
Form1.FuncionParser1.Funcion := Form1.Combobox1.text;
f(0,0);
if not FuncionParser1.ParseError then
Do3DGraph;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
Close;
end;

procedure TForm1.FuncionParser1ParserError(Sender: TObject;
  ParseError: Integer);
var
    Msg : string;
  begin
    case ParseError of
      1 : Msg := 'Desbordamiento de Pila.';
      2 : Msg := 'Valor Fuera de Rango.';
      3 : Msg := 'Esperaba una Expresión.';
      4 : Msg := 'Esperaba un Operador.';
      5 : Msg := 'Esperaba Parentesis que Abre "(".';
      6 : Msg := 'Esperaba Parentesis que Cierra ")".';
    end; { case }
    Label2.Caption := 'Error! '+Msg;
end;

procedure TForm1.FuncionParser1PideVariable(Sender: TObject;
  Variable: String; var Valor: Extended; var Found: Boolean);
begin
found := true;
 If uppercase(Variable) = 'X' then Valor := X2 else
 If uppercase(Variable) = 'Y' then Valor := Y2 else Found := false;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  Combobox1.ItemIndex := 0;
end;

end.
