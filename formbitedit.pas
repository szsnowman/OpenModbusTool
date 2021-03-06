unit formBitEdit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  CheckLst, Buttons, ExtCtrls;

type
  TBitEditFormats = (
    edfWide1byte,
    edfWide2byte,
    edfWide4byte,
    edfBits,
    edfFloat32bit,
    edf32Bit,
    edf16Bit,
    edf8Bit);

  { TfrmBitEdit }

  TfrmBitEdit = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    chListBit8_1: TCheckListBox;
    chListBit8_2: TCheckListBox;
    chListBit8_3: TCheckListBox;
    chListBit8_4: TCheckListBox;
    edValueDec16_1: TEdit;
    edValueDec16_2: TEdit;
    edValueDec32: TEdit;
    edValueDec8_1: TEdit;
    edValueDec8_2: TEdit;
    edValueDec8_3: TEdit;
    edValueDec8_4: TEdit;
    edValueFloat: TEdit;
    edValueHex32: TEdit;
    lbFloat: TLabel;
    lbValueDec16: TLabel;
    lbValueDec32: TLabel;
    lbValueDec8: TLabel;
    lbValueDec9: TLabel;
    lbValueHex32: TLabel;
    PanelFloat: TPanel;
    PanelBtn: TPanel;
    PanelGroup1: TPanel;
    Panel16: TPanel;
    Panel8: TPanel;
    Panel32: TPanel;
    PanelBits: TPanel;
    PanelHex32: TPanel;
    procedure chListBitAnyClickCheck(Sender: TObject);
    procedure edValueDecAnyChange(Sender: TObject);
    procedure edValueHex32Change(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
    // lock other update process
    InProcess: boolean;
  public
    { public declarations }
    ValueIs32: boolean;
    FirstShow: boolean;
    CurrentValue: DWORD;
    EditResult: DWORD;

    function GetResult(Is32: boolean; DefaultValue: DWORD): boolean;
    procedure UpdateValue(Changer: TControl);
    procedure UpdateValueInBitList(Value: Byte; List: TCheckListBox);
    procedure ChangeValue(NewValue: DWORD; ByteBitCount: byte; ByteNum: byte);
    procedure ChangeValueCheckList(ChList: TCheckListBox; ByteNum: byte);
  end;

var
  frmBitEdit: TfrmBitEdit;

implementation

{$R *.lfm}

uses StrUtils;

{ TfrmBitEdit }

function GetBit(Value: QWord; Index: byte): boolean;
begin
  Result := ((Value shr Index) and 1) = 1;
end;

procedure TfrmBitEdit.edValueDecAnyChange(Sender: TObject);
begin
  (Sender as TEdit).Color:=clDefault;
  if not InProcess then
    try
      ChangeValue(StrToInt((Sender as TEdit).Text), (Sender as TEdit).Tag div 10, ((Sender as TEdit).Tag mod 10)-1);
      UpdateValue(Sender as TControl);
    except
      // just ignore and set error color
      on E: EConvertError do (Sender as TEdit).Color:=clRed;
    end;
end;

procedure TfrmBitEdit.chListBitAnyClickCheck(Sender: TObject);
begin
  ChangeValueCheckList(Sender as TCheckListBox, ((Sender as TCheckListBox).Tag mod 10)-1);
  UpdateValue(Sender as TControl);
end;

procedure TfrmBitEdit.edValueHex32Change(Sender: TObject);
begin
  (Sender as TEdit).Color:=clDefault;
  if not InProcess then
    try
      CurrentValue := DWORD(Hex2Dec((Sender as TEdit).Text));
      UpdateValue(Sender as TControl);
    except
      // just ignore and set error color
      on E: EConvertError do (Sender as TEdit).Color:=clRed;
    end;
end;

procedure TfrmBitEdit.FormShow(Sender: TObject);
begin
  if FirstShow then
  begin
    FirstShow := false;
    if ValueIs32 then
      FocusControl(edValueDec32) else
      FocusControl(edValueDec16_1);
  end;
end;

function TfrmBitEdit.GetResult(Is32: boolean; DefaultValue: DWORD): boolean;
begin
  Result := false;
  ValueIs32 := Is32;
  FirstShow := true;
  PanelFloat.Visible := ValueIs32;
  Panel32.Visible := ValueIs32;
  edValueDec16_2.Visible := ValueIs32;
  edValueDec8_3.Visible := ValueIs32;
  edValueDec8_4.Visible := ValueIs32;
  chListBit8_3.Visible:=ValueIs32;
  chListBit8_4.Visible:=ValueIs32;
  CurrentValue := DefaultValue;
  UpdateValue(nil);

  if ShowModal() = mrOK then
  begin
    if Is32 then
      EditResult := CurrentValue and $FFFFFFFF else
      EditResult := CurrentValue and $FFFF;
    Result := true;
  end;
end;

procedure TfrmBitEdit.UpdateValue(Changer: TControl);
begin
  if InProcess then exit;
  InProcess := true;
  try
    if Changer <> edValueHex32 then
      edValueHex32.Text:=hexStr(CurrentValue, 8);
    if Changer <> edValueDec32 then
      edValueDec32.Text:=IntToStr(CurrentValue);
    if Changer <> edValueDec16_1 then
      edValueDec16_1.Text:=IntToStr(CurrentValue and $FFFF);
    if Changer <> edValueDec16_2 then
      edValueDec16_2.Text:=IntToStr(CurrentValue shr 16 and $FFFF);
    if Changer <> edValueDec8_1 then
      edValueDec8_1.Text:=IntToStr(CurrentValue and $FF);
    if Changer <> edValueDec8_2 then
      edValueDec8_2.Text:=IntToStr(CurrentValue shr 8 and $FF);
    if Changer <> edValueDec8_3 then
      edValueDec8_3.Text:=IntToStr(CurrentValue shr 16 and $FF);
    if Changer <> edValueDec8_4 then
      edValueDec8_4.Text:=IntToStr(CurrentValue shr 24 and $FF);
    if Changer <> chListBit8_1 then
      UpdateValueInBitList(CurrentValue and $FF, chListBit8_1);
    if Changer <> chListBit8_2 then
      UpdateValueInBitList(CurrentValue shr 8 and $FF, chListBit8_2);
    if Changer <> chListBit8_3 then
      UpdateValueInBitList(CurrentValue shr 16 and $FF, chListBit8_3);
    if Changer <> chListBit8_4 then
      UpdateValueInBitList(CurrentValue shr 24 and $FF, chListBit8_4);
    if Changer <> edValueFloat then
      edValueFloat.Text:=FloatToStr(PSingle(@CurrentValue)^);
      //if ValueIs64 then
      //  edValueFloat.Text:=FloatToStr(PDouble(@CurrentValue)^) else ...;
  finally
    InProcess := false;
  end;
end;

procedure TfrmBitEdit.UpdateValueInBitList(Value: Byte; List: TCheckListBox);
var i: byte;
begin
  for i:=0 to 7 do
    List.Checked[i] := GetBit(Value, i);
end;

function Get1Bits32(BitCount: byte): DWORD;
begin
  Result := $FFFFFFFF shr (32-BitCount);
end;

procedure TfrmBitEdit.ChangeValue(NewValue: DWORD; ByteBitCount: byte; ByteNum: byte);
begin
  if not InProcess then
    CurrentValue :=
      CurrentValue and not (Get1Bits32(ByteBitCount) shl (ByteNum * 8)) or
      ((NewValue and Get1Bits32(ByteBitCount)) shl (ByteNum * 8));
end;

procedure TfrmBitEdit.ChangeValueCheckList(ChList: TCheckListBox; ByteNum: byte);
var i, v: byte;
begin
  if not InProcess then
  begin
    v:=0;
    for i:=7 downto 0 do
      v := (v shl 1) or byte(ChList.Checked[i]);
    ChangeValue(v, 8, ByteNum);
  end;
end;

end.

