unit uContacts;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  ExtCtrls, DBGrids, DBCtrls, DB, StrUtils;

type

  { TfrmContacts }

  TfrmContacts = class(TForm)
    pnlTop: TPanel;
    pnlBottom: TPanel;
    dbgContacts: TDBGrid;
    btnAdd: TSpeedButton;
    btnEdit: TSpeedButton;
    btnDelete: TSpeedButton;
    btnClose: TBitBtn;
    edtSearch: TEdit;
    btnSearch: TSpeedButton;
    dtsContacts: TDataSource;
    navContacts: TDBNavigator;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
  private
    procedure RefreshList;
    function GetSelectedId: Integer;
    function EditContact(AId: Integer = -1): Boolean;
  end;

var
  frmContacts: TfrmContacts;

implementation

{$R *.lfm}

uses uData;

procedure TfrmContacts.FormCreate(Sender: TObject);
begin
  Position := poMainFormCenter;
  BorderStyle := bsDialog;
  Caption := '👤 联系人/供应商管理';
  Width := 800;
  Height := 500;
end;

procedure TfrmContacts.FormShow(Sender: TObject);
begin
  dtsContacts.DataSet := dmData.qryAux;
  RefreshList;
end;

procedure TfrmContacts.RefreshList;
var
  filter: string;
begin
  filter := '';
  if Trim(edtSearch.Text) <> '' then
    filter := 'short_name LIKE ''%' + Trim(edtSearch.Text) + '%'' OR ' +
              'full_name LIKE ''%' + Trim(edtSearch.Text) + '%''';
  dmData.OpenContacts(filter);

  if dbgContacts.Columns.Count >= 10 then
  begin
    dbgContacts.Columns[0].Title.Caption := 'ID';       dbgContacts.Columns[0].Width := 40;
    dbgContacts.Columns[1].Title.Caption := '简称';      dbgContacts.Columns[1].Width := 80;
    dbgContacts.Columns[2].Title.Caption := '全称';      dbgContacts.Columns[2].Width := 180;
    dbgContacts.Columns[3].Title.Caption := '纳税人识别号'; dbgContacts.Columns[3].Width := 120;
    dbgContacts.Columns[4].Title.Caption := '开户银行';   dbgContacts.Columns[4].Width := 130;
    dbgContacts.Columns[5].Title.Caption := '银行账号';   dbgContacts.Columns[5].Width := 140;
    dbgContacts.Columns[6].Title.Caption := '联系人';     dbgContacts.Columns[6].Width := 70;
    dbgContacts.Columns[7].Title.Caption := '联系方式';   dbgContacts.Columns[7].Width := 100;
    dbgContacts.Columns[8].Title.Caption := '地址';       dbgContacts.Columns[8].Width := 150;
    dbgContacts.Columns[9].Title.Caption := '备注';       dbgContacts.Columns[9].Width := 120;
  end;
end;

function TfrmContacts.GetSelectedId: Integer;
begin
  Result := -1;
  if dmData.qryAux.Active and (dmData.qryAux.RecordCount > 0) then
    Result := dmData.qryAux.FieldByName('id').AsInteger;
end;

function TfrmContacts.EditContact(AId: Integer): Boolean;
var
  frm: TForm;
  edtShort, edtFull, edtTax, edtBank, edtAcct, edtPerson, edtPhone, edtAddr: TEdit;
  memNotes: TMemo;
  lbl: array[0..7] of TLabel;
  btnOK, btnCC: TBitBtn;
  i: Integer;
  y: Integer;
begin
  Result := False;
  frm := TForm.CreateNew(nil);
  try
    frm.Caption := IfThen(AId > 0, '编辑联系人', '新增联系人');
    frm.Position := poMainFormCenter;
    frm.BorderStyle := bsDialog;
    frm.Width := 500;
    frm.Height := 460;

    y := 16;
    for i := 0 to 7 do
    begin
      lbl[i] := TLabel.Create(frm);
      lbl[i].Parent := frm;
      lbl[i].Left := 16;
      lbl[i].Top := y + 4;
      lbl[i].Font.Name := 'Microsoft YaHei';
      lbl[i].Font.Size := 9;
      Inc(y, 36);
    end;
    lbl[0].Caption := '简称:';
    lbl[1].Caption := '全称:';
    lbl[2].Caption := '纳税人识别号:';
    lbl[3].Caption := '开户银行:';
    lbl[4].Caption := '银行账号:';
    lbl[5].Caption := '联系人:';
    lbl[6].Caption := '联系方式:';
    lbl[7].Caption := '地址:';

    edtShort := TEdit.Create(frm); edtShort.Parent := frm; edtShort.Left := 100; edtShort.Top := 12; edtShort.Width := 360;
    edtFull := TEdit.Create(frm); edtFull.Parent := frm; edtFull.Left := 100; edtFull.Top := 48; edtFull.Width := 360;
    edtTax := TEdit.Create(frm); edtTax.Parent := frm; edtTax.Left := 100; edtTax.Top := 84; edtTax.Width := 360;
    edtBank := TEdit.Create(frm); edtBank.Parent := frm; edtBank.Left := 100; edtBank.Top := 120; edtBank.Width := 360;
    edtAcct := TEdit.Create(frm); edtAcct.Parent := frm; edtAcct.Left := 100; edtAcct.Top := 156; edtAcct.Width := 360;
    edtPerson := TEdit.Create(frm); edtPerson.Parent := frm; edtPerson.Left := 100; edtPerson.Top := 192; edtPerson.Width := 360;
    edtPhone := TEdit.Create(frm); edtPhone.Parent := frm; edtPhone.Left := 100; edtPhone.Top := 228; edtPhone.Width := 360;
    edtAddr := TEdit.Create(frm); edtAddr.Parent := frm; edtAddr.Left := 100; edtAddr.Top := 264; edtAddr.Width := 360;

    with TLabel.Create(frm) do begin Parent := frm; Left := 16; Top := 304; Caption := '备注:'; Font.Name := 'Microsoft YaHei'; Font.Size := 9; end;
    memNotes := TMemo.Create(frm); memNotes.Parent := frm; memNotes.Left := 100; memNotes.Top := 300; memNotes.Width := 360; memNotes.Height := 60;

    btnOK := TBitBtn.Create(frm); btnOK.Parent := frm; btnOK.Left := 160; btnOK.Top := 380; btnOK.Width := 80; btnOK.Caption := '确定'; btnOK.Kind := bkOK;
    btnCC := TBitBtn.Create(frm); btnCC.Parent := frm; btnCC.Left := 280; btnCC.Top := 380; btnCC.Width := 80; btnCC.Caption := '取消'; btnCC.Kind := bkCancel;

    if AId > 0 then
    begin
      dmData.OpenQuery(dmData.qryAux, 'SELECT * FROM contacts WHERE id = ' + IntToStr(AId));
      if not dmData.qryAux.EOF then
      begin
        edtShort.Text := dmData.qryAux.FieldByName('short_name').AsString;
        edtFull.Text := dmData.qryAux.FieldByName('full_name').AsString;
        edtTax.Text := dmData.qryAux.FieldByName('tax_no').AsString;
        edtBank.Text := dmData.qryAux.FieldByName('bank').AsString;
        edtAcct.Text := dmData.qryAux.FieldByName('account').AsString;
        edtPerson.Text := dmData.qryAux.FieldByName('contact_person').AsString;
        edtPhone.Text := dmData.qryAux.FieldByName('phone').AsString;
        edtAddr.Text := dmData.qryAux.FieldByName('address').AsString;
        memNotes.Text := dmData.qryAux.FieldByName('notes').AsString;
      end;
      dmData.qryAux.Close;
    end;

    if frm.ShowModal = mrOK then
    begin
      if Trim(edtShort.Text) = '' then
      begin
        ShowMessage('简称不能为空');
        Exit;
      end;
      if AId > 0 then
        dmData.ExecSQL(Format(
          'UPDATE contacts SET short_name=''%s'', full_name=''%s'', tax_no=''%s'', ' +
          'bank=''%s'', account=''%s'', contact_person=''%s'', phone=''%s'', ' +
          'address=''%s'', notes=''%s'' WHERE id=%d',
          [StringReplace(Trim(edtShort.Text), '''', '''''', [rfReplaceAll]),
           StringReplace(Trim(edtFull.Text), '''', '''''', [rfReplaceAll]),
           StringReplace(Trim(edtTax.Text), '''', '''''', [rfReplaceAll]),
           StringReplace(Trim(edtBank.Text), '''', '''''', [rfReplaceAll]),
           StringReplace(Trim(edtAcct.Text), '''', '''''', [rfReplaceAll]),
           StringReplace(Trim(edtPerson.Text), '''', '''''', [rfReplaceAll]),
           StringReplace(Trim(edtPhone.Text), '''', '''''', [rfReplaceAll]),
           StringReplace(Trim(edtAddr.Text), '''', '''''', [rfReplaceAll]),
           StringReplace(Trim(memNotes.Text), '''', '''''', [rfReplaceAll]),
           AId]))
      else
        dmData.ExecSQL(Format(
          'INSERT INTO contacts (short_name, full_name, tax_no, bank, account, ' +
          'contact_person, phone, address, notes) VALUES ' +
          '(''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'')',
          [StringReplace(Trim(edtShort.Text), '''', '''''', [rfReplaceAll]),
           StringReplace(Trim(edtFull.Text), '''', '''''', [rfReplaceAll]),
           StringReplace(Trim(edtTax.Text), '''', '''''', [rfReplaceAll]),
           StringReplace(Trim(edtBank.Text), '''', '''''', [rfReplaceAll]),
           StringReplace(Trim(edtAcct.Text), '''', '''''', [rfReplaceAll]),
           StringReplace(Trim(edtPerson.Text), '''', '''''', [rfReplaceAll]),
           StringReplace(Trim(edtPhone.Text), '''', '''''', [rfReplaceAll]),
           StringReplace(Trim(edtAddr.Text), '''', '''''', [rfReplaceAll]),
           StringReplace(Trim(memNotes.Text), '''', '''''', [rfReplaceAll])]));
      Result := True;
    end;
  finally
    frm.Free;
  end;
end;

procedure TfrmContacts.btnAddClick(Sender: TObject);
begin
  if EditContact then RefreshList;
end;

procedure TfrmContacts.btnEditClick(Sender: TObject);
var
  id: Integer;
begin
  id := GetSelectedId;
  if id < 0 then begin ShowMessage('请先选择一条记录'); Exit; end;
  if EditContact(id) then RefreshList;
end;

procedure TfrmContacts.btnDeleteClick(Sender: TObject);
var
  id: Integer;
begin
  id := GetSelectedId;
  if id < 0 then begin ShowMessage('请先选择一条记录'); Exit; end;
  if MessageDlg('确认', '确定要删除该联系人吗？', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    dmData.ExecSQL('DELETE FROM contacts WHERE id = ' + IntToStr(id));
    RefreshList;
  end;
end;

procedure TfrmContacts.btnSearchClick(Sender: TObject);
begin
  RefreshList;
end;

end.
