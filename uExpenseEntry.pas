unit uExpenseEntry;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  ExtCtrls, ComCtrls, DBGrids, DBCtrls, StrUtils;

type

  { TfrmExpenseEntry }

  TfrmExpenseEntry = class(TForm)
    pnlHeader: TPanel;
    lblHeaderTitle: TLabel;
    pnlButtons: TPanel;
    btnSave: TBitBtn;
    btnCancel: TBitBtn;
    pcEntry: TPageControl;
    tsBasic: TTabSheet;
    tsDetail: TTabSheet;

    lblEntryDate: TLabel;
    edtEntryDate: TEdit;
    lblOccurDate: TLabel;
    edtOccurDate: TEdit;
    lblCompany: TLabel;
    cmbCompany: TComboBox;
    lblDept: TLabel;
    cmbDept: TComboBox;
    lblCat1: TLabel;
    cmbCat1: TComboBox;
    lblCat2: TLabel;
    cmbCat2: TComboBox;
    lblInvoice: TLabel;
    edtInvoice: TEdit;
    lblDetail: TLabel;
    memDetail: TMemo;
    lblSID: TLabel;
    edtSID: TEdit;
    lblDocId: TLabel;
    edtDocId: TEdit;

    lblQuantity: TLabel;
    edtQuantity: TEdit;
    lblUnitPrice: TLabel;
    edtUnitPrice: TEdit;
    lblExchangeRate: TLabel;
    edtExchangeRate: TEdit;
    lblPrepaid: TLabel;
    edtPrepaid: TEdit;
    lblReimburse: TLabel;
    edtReimburse: TEdit;

    lblMethod: TLabel;
    cmbMethod: TComboBox;
    lblPayer: TLabel;
    edtPayer: TEdit;
    lblReimbursee: TLabel;
    edtReimbursee: TEdit;
    lblTransfer: TLabel;
    edtTransfer: TEdit;
    lblContact: TLabel;
    cmbContact: TComboBox;
    lblBatch: TLabel;
    edtBatch: TEdit;
    lblStatus: TLabel;
    cmbStatus: TComboBox;
    chkAsset: TCheckBox;
    lblCollectDate: TLabel;
    edtCollectDate: TEdit;
    chkCollectDate: TCheckBox;
    lblNotes: TLabel;
    memNotes: TMemo;

    procedure FormCreate(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure cmbCat1Change(Sender: TObject);
    procedure edtQuantityChange(Sender: TObject);
  private
    FExpenseId: Integer;
    FIsAdd: Boolean;
    procedure LoadLookups;
    procedure LoadCat2(AParentId: Integer);
    procedure LoadExpense(AId: Integer);
    function ValidateInput: Boolean;
    function CalcTotal: Double;
  public
    function ShowAdd: Boolean;
    function ShowEdit(AId: Integer): Boolean;
  end;

var
  frmExpenseEntry: TfrmExpenseEntry;

implementation

{$R *.lfm}

uses uData;

procedure TfrmExpenseEntry.FormCreate(Sender: TObject);
begin
  Position := poMainFormCenter;
  BorderStyle := bsDialog;
  Width := 700;
  Height := 620;
  Caption := '费用录入';
  Color := $00F3F3F3;
end;

procedure TfrmExpenseEntry.LoadLookups;
begin
  cmbCompany.Items.Clear;
  dmData.OpenQuery(dmData.qryAux, 'SELECT id, name FROM companies ORDER BY id');
  while not dmData.qryAux.EOF do
  begin
    cmbCompany.Items.AddObject(
      dmData.qryAux.FieldByName('name').AsString,
      TObject(PtrInt(dmData.qryAux.FieldByName('id').AsInteger)));
    dmData.qryAux.Next;
  end;
  if cmbCompany.Items.Count > 0 then cmbCompany.ItemIndex := 0;

  cmbDept.Items.Clear;
  dmData.OpenQuery(dmData.qryAux, 'SELECT id, name FROM departments ORDER BY name');
  while not dmData.qryAux.EOF do
  begin
    cmbDept.Items.AddObject(
      dmData.qryAux.FieldByName('name').AsString,
      TObject(PtrInt(dmData.qryAux.FieldByName('id').AsInteger)));
    dmData.qryAux.Next;
  end;
  if cmbDept.Items.Count > 0 then cmbDept.ItemIndex := 0;

  cmbCat1.Items.Clear;
  dmData.OpenCategories(0);
  while not dmData.qryAux.EOF do
  begin
    cmbCat1.Items.AddObject(
      dmData.qryAux.FieldByName('name').AsString,
      TObject(PtrInt(dmData.qryAux.FieldByName('id').AsInteger)));
    dmData.qryAux.Next;
  end;
  if cmbCat1.Items.Count > 0 then cmbCat1.ItemIndex := 0;
  if cmbCat1.Items.Count > 0 then
    LoadCat2(PtrInt(cmbCat1.Items.Objects[0]));

  cmbContact.Items.Clear;
  cmbContact.Items.Add('(无)');
  dmData.OpenContacts;
  while not dmData.qryAux.EOF do
  begin
    cmbContact.Items.AddObject(
      dmData.qryAux.FieldByName('short_name').AsString,
      TObject(PtrInt(dmData.qryAux.FieldByName('id').AsInteger)));
    dmData.qryAux.Next;
  end;
  cmbContact.ItemIndex := 0;

  cmbMethod.Items.Clear;
  cmbMethod.Items.Add('报销');
  cmbMethod.Items.Add('请款');
  cmbMethod.Items.Add('其他');
  cmbMethod.ItemIndex := 0;

  cmbStatus.Items.Clear;
  cmbStatus.Items.Add('填单');
  cmbStatus.Items.Add('签录');
  cmbStatus.Items.Add('完成');
  cmbStatus.Items.Add('取消');
  cmbStatus.Items.Add('付款');
  cmbStatus.Items.Add('发票');
  cmbStatus.ItemIndex := 0;

  edtEntryDate.Text := FormatDateTime('yyyy-mm-dd', Now);
  edtOccurDate.Text := FormatDateTime('yyyy-mm-dd', Now);
  edtCollectDate.Text := '';
  chkCollectDate.Checked := False;
  edtExchangeRate.Text := '1';
  edtQuantity.Text := '1';
end;

procedure TfrmExpenseEntry.LoadCat2(AParentId: Integer);
begin
  cmbCat2.Items.Clear;
  cmbCat2.Items.Add('(无)');
  dmData.OpenCategories(AParentId);
  while not dmData.qryAux.EOF do
  begin
    cmbCat2.Items.AddObject(
      dmData.qryAux.FieldByName('name').AsString,
      TObject(PtrInt(dmData.qryAux.FieldByName('id').AsInteger)));
    dmData.qryAux.Next;
  end;
  cmbCat2.ItemIndex := 0;
end;

procedure TfrmExpenseEntry.LoadExpense(AId: Integer);
var
  i: Integer;
  cid: Integer;
begin
  dmData.OpenExpenseList('e.id = ' + IntToStr(AId));
  if dmData.qryMain.EOF then Exit;

  edtEntryDate.Text := dmData.qryMain.FieldByName('entry_date').AsString;
  edtOccurDate.Text := dmData.qryMain.FieldByName('occur_date').AsString;
  edtSID.Text := dmData.qryMain.FieldByName('sid').AsString;
  edtDocId.Text := dmData.qryMain.FieldByName('doc_id').AsString;

  for i := 0 to cmbCompany.Items.Count - 1 do
    if cmbCompany.Items[i] = dmData.qryMain.FieldByName('company_name').AsString then
    begin
      cmbCompany.ItemIndex := i;
      Break;
    end;

  for i := 0 to cmbDept.Items.Count - 1 do
    if cmbDept.Items[i] = dmData.qryMain.FieldByName('dept_name').AsString then
    begin
      cmbDept.ItemIndex := i;
      Break;
    end;

  for i := 0 to cmbCat1.Items.Count - 1 do
  begin
    cid := PtrInt(cmbCat1.Items.Objects[i]);
    dmData.OpenQuery(dmData.qryAux, 'SELECT name FROM categories WHERE id = ' + IntToStr(cid));
    if not dmData.qryAux.EOF then
      if dmData.qryAux.FieldByName('name').AsString = dmData.qryMain.FieldByName('cat1_name').AsString then
      begin
        cmbCat1.ItemIndex := i;
        LoadCat2(cid);
        Break;
      end;
  end;

  for i := 0 to cmbCat2.Items.Count - 1 do
    if cmbCat2.Items[i] = dmData.qryMain.FieldByName('cat2_name').AsString then
    begin
      cmbCat2.ItemIndex := i;
      Break;
    end;

  edtInvoice.Text := dmData.qryMain.FieldByName('invoice_content').AsString;
  memDetail.Text := dmData.qryMain.FieldByName('detail').AsString;
  edtQuantity.Text := dmData.qryMain.FieldByName('quantity').AsString;
  edtUnitPrice.Text := dmData.qryMain.FieldByName('unit_price').AsString;
  edtExchangeRate.Text := dmData.qryMain.FieldByName('exchange_rate').AsString;
  edtPrepaid.Text := dmData.qryMain.FieldByName('prepaid').AsString;
  edtReimburse.Text := dmData.qryMain.FieldByName('reimburse_amount').AsString;

  for i := 0 to cmbMethod.Items.Count - 1 do
    if cmbMethod.Items[i] = dmData.qryMain.FieldByName('pay_method').AsString then
    begin
      cmbMethod.ItemIndex := i;
      Break;
    end;

  edtPayer.Text := dmData.qryMain.FieldByName('payer').AsString;
  edtReimbursee.Text := dmData.qryMain.FieldByName('reimbursee').AsString;
  edtTransfer.Text := dmData.qryMain.FieldByName('transfer_recipient').AsString;

  for i := 0 to cmbContact.Items.Count - 1 do
    if cmbContact.Items[i] = dmData.qryMain.FieldByName('contact_name').AsString then
    begin
      cmbContact.ItemIndex := i;
      Break;
    end;

  edtBatch.Text := dmData.qryMain.FieldByName('batch_info').AsString;

  for i := 0 to cmbStatus.Items.Count - 1 do
    if cmbStatus.Items[i] = dmData.qryMain.FieldByName('reimburse_status').AsString then
    begin
      cmbStatus.ItemIndex := i;
      Break;
    end;

  chkAsset.Checked := dmData.qryMain.FieldByName('is_asset').AsInteger = 1;

  if dmData.qryMain.FieldByName('collect_date').AsString <> '' then
  begin
    edtCollectDate.Text := dmData.qryMain.FieldByName('collect_date').AsString;
    chkCollectDate.Checked := True;
  end
  else
  begin
    edtCollectDate.Text := '';
    chkCollectDate.Checked := False;
  end;

  memNotes.Text := dmData.qryMain.FieldByName('notes').AsString;
end;

function TfrmExpenseEntry.ValidateInput: Boolean;
var
  fDummy: Double;
begin
  Result := False;
  if cmbCat1.ItemIndex < 0 then
  begin
    ShowMessage('请选择一级科目');
    cmbCat1.SetFocus;
    Exit;
  end;
  if Trim(edtReimburse.Text) = '' then edtReimburse.Text := '0';
  if Trim(edtPrepaid.Text) = '' then edtPrepaid.Text := '0';
  if not TryStrToFloat(edtReimburse.Text, fDummy) then
  begin
    ShowMessage('报销费用格式不正确');
    edtReimburse.SetFocus;
    Exit;
  end;
  Result := True;
end;

function TfrmExpenseEntry.CalcTotal: Double;
var
  qty, price, rate: Double;
begin
  qty := StrToFloatDef(edtQuantity.Text, 1);
  price := StrToFloatDef(edtUnitPrice.Text, 0);
  rate := StrToFloatDef(edtExchangeRate.Text, 1);
  Result := qty * price * rate;
end;

function TfrmExpenseEntry.ShowAdd: Boolean;
begin
  FIsAdd := True;
  FExpenseId := -1;
  Caption := '新增费用';
  lblHeaderTitle.Caption := '➕ 新增费用记录';
  LoadLookups;
  edtSID.Text := '';
  edtDocId.Text := '';
  edtInvoice.Text := '';
  memDetail.Text := '';
  edtQuantity.Text := '1';
  edtUnitPrice.Text := '';
  edtExchangeRate.Text := '1';
  edtPrepaid.Text := '';
  edtReimburse.Text := '';
  edtPayer.Text := '';
  edtReimbursee.Text := '';
  edtTransfer.Text := '';
  edtBatch.Text := '';
  memNotes.Text := '';
  chkAsset.Checked := False;
  pcEntry.ActivePage := tsBasic;
  Result := ShowModal = mrOK;
end;

function TfrmExpenseEntry.ShowEdit(AId: Integer): Boolean;
begin
  FIsAdd := False;
  FExpenseId := AId;
  Caption := '编辑费用';
  lblHeaderTitle.Caption := '✏️ 编辑费用记录';
  LoadLookups;
  LoadExpense(AId);
  pcEntry.ActivePage := tsBasic;
  Result := ShowModal = mrOK;
end;

procedure TfrmExpenseEntry.btnSaveClick(Sender: TObject);
var
  cat1Id, cat2Id, companyId, deptId, contactId: Integer;
  sql: string;
begin
  if not ValidateInput then Exit;

  cat1Id := PtrInt(cmbCat1.Items.Objects[cmbCat1.ItemIndex]);
  if cmbCat2.ItemIndex > 0 then
    cat2Id := PtrInt(cmbCat2.Items.Objects[cmbCat2.ItemIndex])
  else
    cat2Id := 0;
  if cmbCompany.ItemIndex >= 0 then
    companyId := PtrInt(cmbCompany.Items.Objects[cmbCompany.ItemIndex])
  else
    companyId := 1;
  if cmbDept.ItemIndex >= 0 then
    deptId := PtrInt(cmbDept.Items.Objects[cmbDept.ItemIndex])
  else
    deptId := 0;
  if cmbContact.ItemIndex > 0 then
    contactId := PtrInt(cmbContact.Items.Objects[cmbContact.ItemIndex])
  else
    contactId := 0;

  if FIsAdd then
  begin
    sql := Format(
      'INSERT INTO expenses (sid, entry_date, occur_date, company_id, dept_id, ' +
      'cat1_id, cat2_id, invoice_content, detail, quantity, unit_price, ' +
      'exchange_rate, prepaid, reimburse_amount, contact_id, pay_method, ' +
      'payer, reimbursee, transfer_recipient, doc_id, batch_info, ' +
      'reimburse_status, is_asset, collect_date, notes) VALUES ' +
      '(''%s'', ''%s'', ''%s'', %d, %d, %d, %d, ''%s'', ''%s'', %s, %s, %s, %s, %s, %d, ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', ''%s'', %d, ''%s'', ''%s'')',
      [StringReplace(Trim(edtSID.Text), '''', '''''', [rfReplaceAll]),
       Trim(edtEntryDate.Text),
       Trim(edtOccurDate.Text),
       companyId, deptId, cat1Id, cat2Id,
       StringReplace(Trim(edtInvoice.Text), '''', '''''', [rfReplaceAll]),
       StringReplace(Trim(memDetail.Text), '''', '''''', [rfReplaceAll]),
       StringReplace(edtQuantity.Text, ',', '.', [rfReplaceAll]),
       StringReplace(edtUnitPrice.Text, ',', '.', [rfReplaceAll]),
       StringReplace(edtExchangeRate.Text, ',', '.', [rfReplaceAll]),
       StringReplace(edtPrepaid.Text, ',', '.', [rfReplaceAll]),
       StringReplace(edtReimburse.Text, ',', '.', [rfReplaceAll]),
       contactId,
       cmbMethod.Text,
       StringReplace(Trim(edtPayer.Text), '''', '''''', [rfReplaceAll]),
       StringReplace(Trim(edtReimbursee.Text), '''', '''''', [rfReplaceAll]),
       StringReplace(Trim(edtTransfer.Text), '''', '''''', [rfReplaceAll]),
       StringReplace(Trim(edtDocId.Text), '''', '''''', [rfReplaceAll]),
       StringReplace(Trim(edtBatch.Text), '''', '''''', [rfReplaceAll]),
       cmbStatus.Text,
       Ord(chkAsset.Checked),
       IfThen(chkCollectDate.Checked, Trim(edtCollectDate.Text), ''),
       StringReplace(Trim(memNotes.Text), '''', '''''', [rfReplaceAll])]
    );
  end
  else
  begin
    sql := Format(
      'UPDATE expenses SET sid=''%s'', entry_date=''%s'', occur_date=''%s'', ' +
      'company_id=%d, dept_id=%d, cat1_id=%d, cat2_id=%d, ' +
      'invoice_content=''%s'', detail=''%s'', quantity=%s, unit_price=%s, ' +
      'exchange_rate=%s, prepaid=%s, reimburse_amount=%s, contact_id=%d, ' +
      'pay_method=''%s'', payer=''%s'', reimbursee=''%s'', ' +
      'transfer_recipient=''%s'', doc_id=''%s'', batch_info=''%s'', ' +
      'reimburse_status=''%s'', is_asset=%d, collect_date=''%s'', notes=''%s'' ' +
      'WHERE id=%d',
      [StringReplace(Trim(edtSID.Text), '''', '''''', [rfReplaceAll]),
       Trim(edtEntryDate.Text),
       Trim(edtOccurDate.Text),
       companyId, deptId, cat1Id, cat2Id,
       StringReplace(Trim(edtInvoice.Text), '''', '''''', [rfReplaceAll]),
       StringReplace(Trim(memDetail.Text), '''', '''''', [rfReplaceAll]),
       StringReplace(edtQuantity.Text, ',', '.', [rfReplaceAll]),
       StringReplace(edtUnitPrice.Text, ',', '.', [rfReplaceAll]),
       StringReplace(edtExchangeRate.Text, ',', '.', [rfReplaceAll]),
       StringReplace(edtPrepaid.Text, ',', '.', [rfReplaceAll]),
       StringReplace(edtReimburse.Text, ',', '.', [rfReplaceAll]),
       contactId,
       cmbMethod.Text,
       StringReplace(Trim(edtPayer.Text), '''', '''''', [rfReplaceAll]),
       StringReplace(Trim(edtReimbursee.Text), '''', '''''', [rfReplaceAll]),
       StringReplace(Trim(edtTransfer.Text), '''', '''''', [rfReplaceAll]),
       StringReplace(Trim(edtDocId.Text), '''', '''''', [rfReplaceAll]),
       StringReplace(Trim(edtBatch.Text), '''', '''''', [rfReplaceAll]),
       cmbStatus.Text,
       Ord(chkAsset.Checked),
       IfThen(chkCollectDate.Checked, Trim(edtCollectDate.Text), ''),
       StringReplace(Trim(memNotes.Text), '''', '''''', [rfReplaceAll]),
       FExpenseId]
    );
  end;

  dmData.ExecSQL(sql);
  ModalResult := mrOK;
end;

procedure TfrmExpenseEntry.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmExpenseEntry.cmbCat1Change(Sender: TObject);
begin
  if cmbCat1.ItemIndex >= 0 then
    LoadCat2(PtrInt(cmbCat1.Items.Objects[cmbCat1.ItemIndex]));
end;

procedure TfrmExpenseEntry.edtQuantityChange(Sender: TObject);
begin
  if (Trim(edtUnitPrice.Text) <> '') and (Trim(edtQuantity.Text) <> '') then
    edtReimburse.Text := FormatFloat('0.00', CalcTotal);
end;

end.
