unit uImport;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  ExtCtrls, ComCtrls;

type

  { TfrmImport }

  TfrmImport = class(TForm)
    pnlHeader: TPanel;
    lblHeaderTitle: TLabel;
    pnlFileSelect: TPanel;
    pnlLog: TPanel;
    pnlBottom: TPanel;
    lblFile: TLabel;
    edtFile: TEdit;
    btnBrowse: TSpeedButton;
    lblInfo: TLabel;
    memLog: TMemo;
    btnImport: TBitBtn;
    btnCancel: TBitBtn;
    pbProgress: TProgressBar;
    dlgOpen: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure btnBrowseClick(Sender: TObject);
    procedure btnImportClick(Sender: TObject);
  private
    procedure Log(const AMsg: string);
    procedure ImportCSV(const AFileName: string);
    function MapColumnHeader(const AHeader: string): string;
    function SplitCSVLine(const ALine: string): TStringList;
  end;

var
  frmImport: TfrmImport;

implementation

{$R *.lfm}

uses uData;

procedure TfrmImport.FormCreate(Sender: TObject);
begin
  Position := poMainFormCenter;
  BorderStyle := bsDialog;
  Caption := '导入费用数据';
  Width := 640;
  Height := 480;
  Color := $00F3F3F3;
  memLog.Lines.Clear;
  pbProgress.Visible := False;
end;

procedure TfrmImport.Log(const AMsg: string);
begin
  memLog.Lines.Add(AMsg);
  Application.ProcessMessages;
end;

procedure TfrmImport.btnBrowseClick(Sender: TObject);
begin
  dlgOpen.Filter := 'CSV 文件|*.csv|所有文件|*.*';
  dlgOpen.DefaultExt := 'csv';
  if dlgOpen.Execute then
  begin
    edtFile.Text := dlgOpen.FileName;
    memLog.Lines.Clear;
    Log('文件已选择: ' + ExtractFileName(edtFile.Text));
    Log('');
    Log('=== 列映射规则 ===');
    Log('CSV 第一行为表头，系统自动识别以下列名（不区分大小写）：');
    Log('  填单日期/entry_date → 填单日期');
    Log('  发生日期/occur_date/日期 → 发生日期');
    Log('  公司/company → 公司');
    Log('  部门/department/dept → 部门');
    Log('  一级科目/cat1/科目 → 一级科目');
    Log('  二级科目/cat2 → 二级科目');
    Log('  发票内容/invoice → 发票内容');
    Log('  费用明细/detail/明细 → 费用明细');
    Log('  数量/quantity → 数量');
    Log('  单价/unit_price → 单价');
    Log('  汇率/exchange_rate → 汇率');
    Log('  预付/prepaid → 预付/代付');
    Log('  报销费用/reimburse → 报销费用');
    Log('  供应商/supplier → 供应商');
    Log('  方式/method → 方式');
    Log('  付款人/payer → 付款人');
    Log('  报销人/reimbursee → 报销人');
    Log('  状态/status → 报销状态');
    Log('  备注/notes → 备注');
    Log('');
    Log('请确认文件编码为 UTF-8 或 GBK，然后点击"开始导入"');
  end;
end;

function TfrmImport.MapColumnHeader(const AHeader: string): string;
var
  h: string;
begin
  h := LowerCase(Trim(AHeader));
  if (Length(h) > 1) and (h[1] = '"') then
    h := Copy(h, 2, Length(h) - 2);

  if (h = '填单日期') or (h = 'entry_date') or (h = '填单') then
    Result := 'entry_date'
  else if (h = '发生日期') or (h = 'occur_date') or (h = '日期') or (h = '发生') then
    Result := 'occur_date'
  else if (h = '公司') or (h = 'company') then
    Result := 'company'
  else if (h = '部门') or (h = 'department') or (h = 'dept') then
    Result := 'dept'
  else if (h = '一级科目') or (h = 'cat1') or (h = '科目') then
    Result := 'cat1'
  else if (h = '二级科目') or (h = 'cat2') then
    Result := 'cat2'
  else if (h = '发票内容') or (h = 'invoice') or (h = '发票') then
    Result := 'invoice'
  else if (h = '费用明细') or (h = 'detail') or (h = '明细') or (h = '费用事项') then
    Result := 'detail'
  else if (h = '数量') or (h = 'quantity') then
    Result := 'quantity'
  else if (h = '单价') or (h = 'unit_price') then
    Result := 'unit_price'
  else if (h = '汇率') or (h = 'exchange_rate') then
    Result := 'exchange_rate'
  else if (h = '预付') or (h = '预付/代付') or (h = 'prepaid') or (h = '预付账款') then
    Result := 'prepaid'
  else if (h = '报销费用') or (h = 'reimburse') or (h = '报销') or (h = '金额') or (h = '费用') or (h = '费用（元）') then
    Result := 'reimburse'
  else if (h = '供应商') or (h = 'supplier') or (h = 'contact') then
    Result := 'contact'
  else if (h = '方式') or (h = 'method') or (h = 'pay_method') then
    Result := 'method'
  else if (h = '付款人') or (h = 'payer') then
    Result := 'payer'
  else if (h = '报销人') or (h = 'reimbursee') then
    Result := 'reimbursee'
  else if (h = '报销状态') or (h = 'status') or (h = 'reimburse_status') or (h = '状态') then
    Result := 'status'
  else if (h = '备注') or (h = 'notes') then
    Result := 'notes'
  else if (h = 'sid') then
    Result := 'sid'
  else if (h = '单据id') or (h = 'doc_id') or (h = '单据') then
    Result := 'doc_id'
  else if (h = '用途详细说明') or (h = '用途') then
    Result := 'detail'
  else if (h = '费用名称') then
    Result := 'cat2'
  else if (h = '客户/地点') or (h = '客户') or (h = '地点') then
    Result := 'contact'
  else
    Result := '';
end;

function TfrmImport.SplitCSVLine(const ALine: string): TStringList;
var
  i, len: Integer;
  inQuote: Boolean;
  field: string;
  ch: Char;
begin
  Result := TStringList.Create;
  field := '';
  inQuote := False;
  len := Length(ALine);
  for i := 1 to len do
  begin
    ch := ALine[i];
    if ch = '"' then
      inQuote := not inQuote
    else if (ch = ',') and (not inQuote) then
    begin
      Result.Add(Trim(field));
      field := '';
    end
    else
      field := field + ch;
  end;
  Result.Add(Trim(field));
end;

procedure TfrmImport.ImportCSV(const AFileName: string);
var
  sl: TStringList;
  row, col: Integer;
  headers: TStringList;
  colMap: TStringList;
  cells: TStringList;
  line: string;

  sEntryDate, sOccurDate, sCompany, sDept, sCat1, sCat2: string;
  sInvoice, sDetail, sContact, sMethod, sPayer, sReimbursee: string;
  sStatus, sNotes, sSid, sDocId: string;
  fQty, fPrice, fRate, fPrepaid, fReimburse: Double;

  cat1Id, cat2Id, deptId, contactId, companyId: Integer;
  imported, skipped, errors: Integer;

  function FindCatId(const AName: string; AParentId: Integer): Integer;
  begin
    if AName = '' then begin Result := 0; Exit; end;
    dmData.OpenQuery(dmData.qryAux,
      'SELECT id FROM categories WHERE name = ''' +
      StringReplace(AName, '''', '''''', [rfReplaceAll]) +
      ''' AND parent_id = ' + IntToStr(AParentId));
    if not dmData.qryAux.EOF then
      Result := dmData.qryAux.FieldByName('id').AsInteger
    else
      Result := 0;
    dmData.qryAux.Close;
  end;

  function FindCompanyId(const AName: string): Integer;
  begin
    if AName = '' then begin Result := 1; Exit; end;
    dmData.OpenQuery(dmData.qryAux,
      'SELECT id FROM companies WHERE name = ''' +
      StringReplace(AName, '''', '''''', [rfReplaceAll]) + '''');
    if not dmData.qryAux.EOF then
      Result := dmData.qryAux.FieldByName('id').AsInteger
    else
    begin
      dmData.ExecSQL('INSERT INTO companies (name) VALUES (''' +
        StringReplace(AName, '''', '''''', [rfReplaceAll]) + ''')');
      Result := dmData.GetLastInsertId;
    end;
    dmData.qryAux.Close;
  end;

  function FindDeptId(const AName: string): Integer;
  begin
    if AName = '' then begin Result := 0; Exit; end;
    dmData.OpenQuery(dmData.qryAux,
      'SELECT id FROM departments WHERE name = ''' +
      StringReplace(AName, '''', '''''', [rfReplaceAll]) + '''');
    if not dmData.qryAux.EOF then
      Result := dmData.qryAux.FieldByName('id').AsInteger
    else
    begin
      dmData.ExecSQL('INSERT INTO departments (name) VALUES (''' +
        StringReplace(AName, '''', '''''', [rfReplaceAll]) + ''')');
      Result := dmData.GetLastInsertId;
    end;
    dmData.qryAux.Close;
  end;

  function FindContactId(const AName: string): Integer;
  begin
    if AName = '' then begin Result := 0; Exit; end;
    dmData.OpenQuery(dmData.qryAux,
      'SELECT id FROM contacts WHERE short_name = ''' +
      StringReplace(AName, '''', '''''', [rfReplaceAll]) + '''');
    if not dmData.qryAux.EOF then
      Result := dmData.qryAux.FieldByName('id').AsInteger
    else
    begin
      dmData.ExecSQL('INSERT INTO contacts (short_name, full_name, contact_person) VALUES (''' +
        StringReplace(AName, '''', '''''', [rfReplaceAll]) + ''', ''' +
        StringReplace(AName, '''', '''''', [rfReplaceAll]) + ''', ''' +
        StringReplace(AName, '''', '''''', [rfReplaceAll]) + ''')');
      Result := dmData.GetLastInsertId;
    end;
    dmData.qryAux.Close;
  end;

  function SafeFloat(const S: string): Double;
  begin
    if not TryStrToFloat(S, Result) then
      Result := 0;
  end;

begin
  sl := TStringList.Create;
  headers := TStringList.Create;
  colMap := TStringList.Create;
  try
    sl.LoadFromFile(AFileName);
    Log('文件已加载，共 ' + IntToStr(sl.Count) + ' 行');
    if sl.Count < 2 then
    begin
      Log('错误: 文件至少需要 2 行（表头 + 数据）');
      Exit;
    end;

    headers := SplitCSVLine(sl[0]);
    colMap.Clear;
    for col := 0 to headers.Count - 1 do
    begin
      colMap.Add(MapColumnHeader(headers[col]));
      if colMap[col] <> '' then
        Log('  列 ' + Char(65 + col) + ' "' + headers[col] + '" → ' + colMap[col]);
    end;

    Log('');
    Log('开始导入...');
    imported := 0; skipped := 0; errors := 0;
    pbProgress.Max := sl.Count - 1;
    pbProgress.Position := 0;
    pbProgress.Visible := True;

    for row := 1 to sl.Count - 1 do
    begin
      pbProgress.Position := row;
      Application.ProcessMessages;
      line := Trim(sl[row]);
      if line = '' then begin Inc(skipped); Continue; end;

      cells := SplitCSVLine(line);
      sEntryDate := ''; sOccurDate := ''; sCompany := ''; sDept := '';
      sCat1 := ''; sCat2 := ''; sInvoice := ''; sDetail := '';
      sContact := ''; sMethod := '报销'; sPayer := ''; sReimbursee := '';
      sStatus := '填单'; sNotes := ''; sSid := ''; sDocId := '';
      fQty := 1; fPrice := 0; fRate := 1; fPrepaid := 0; fReimburse := 0;

      for col := 0 to cells.Count - 1 do
      begin
        if col >= colMap.Count then Break;
        if colMap[col] = '' then Continue;
        if colMap[col] = 'entry_date' then sEntryDate := cells[col]
        else if colMap[col] = 'occur_date' then sOccurDate := cells[col]
        else if colMap[col] = 'company' then sCompany := cells[col]
        else if colMap[col] = 'dept' then sDept := cells[col]
        else if colMap[col] = 'cat1' then sCat1 := cells[col]
        else if colMap[col] = 'cat2' then sCat2 := cells[col]
        else if colMap[col] = 'invoice' then sInvoice := cells[col]
        else if colMap[col] = 'detail' then sDetail := cells[col]
        else if colMap[col] = 'quantity' then fQty := SafeFloat(cells[col])
        else if colMap[col] = 'unit_price' then fPrice := SafeFloat(cells[col])
        else if colMap[col] = 'exchange_rate' then fRate := SafeFloat(cells[col])
        else if colMap[col] = 'prepaid' then fPrepaid := SafeFloat(cells[col])
        else if colMap[col] = 'reimburse' then fReimburse := SafeFloat(cells[col])
        else if colMap[col] = 'contact' then sContact := cells[col]
        else if colMap[col] = 'method' then sMethod := cells[col]
        else if colMap[col] = 'payer' then sPayer := cells[col]
        else if colMap[col] = 'reimbursee' then sReimbursee := cells[col]
        else if colMap[col] = 'status' then sStatus := cells[col]
        else if colMap[col] = 'notes' then sNotes := cells[col]
        else if colMap[col] = 'sid' then sSid := cells[col]
        else if colMap[col] = 'doc_id' then sDocId := cells[col];
      end;
      cells.Free;

      if (sDetail = '') and (sInvoice = '') and (fReimburse = 0) then
      begin
        Inc(skipped);
        Continue;
      end;

      if sEntryDate = '' then sEntryDate := FormatDateTime('yyyy-mm-dd', Now);
      if sOccurDate = '' then sOccurDate := FormatDateTime('yyyy-mm-dd', Now);
      if Pos(' ', sEntryDate) > 0 then sEntryDate := Copy(sEntryDate, 1, Pos(' ', sEntryDate) - 1);
      if Pos(' ', sOccurDate) > 0 then sOccurDate := Copy(sOccurDate, 1, Pos(' ', sOccurDate) - 1);

      if sCompany <> '' then companyId := FindCompanyId(sCompany) else companyId := 1;
      if sDept <> '' then deptId := FindDeptId(sDept) else deptId := 0;
      cat1Id := FindCatId(sCat1, 0);
      if cat1Id > 0 then cat2Id := FindCatId(sCat2, cat1Id) else cat2Id := 0;
      if sContact <> '' then contactId := FindContactId(sContact) else contactId := 0;

      if (fReimburse = 0) and (fPrice > 0) then
        fReimburse := fQty * fPrice * fRate;
      if sStatus = '' then sStatus := '填单';
      if sMethod = '' then sMethod := '报销';

      try
        dmData.ExecSQL(Format(
          'INSERT INTO expenses (sid, entry_date, occur_date, company_id, dept_id, ' +
          'cat1_id, cat2_id, invoice_content, detail, quantity, unit_price, ' +
          'exchange_rate, prepaid, reimburse_amount, contact_id, pay_method, ' +
          'payer, reimbursee, reimburse_status, notes) VALUES ' +
          '(''%s'', ''%s'', ''%s'', %d, %d, %d, %d, ''%s'', ''%s'', %.0f, %.2f, %.4f, %.2f, %.2f, %d, ''%s'', ''%s'', ''%s'', ''%s'', ''%s'')',
          [StringReplace(sSid, '''', '''''', [rfReplaceAll]),
           sEntryDate, sOccurDate,
           companyId, deptId, cat1Id, cat2Id,
           StringReplace(sInvoice, '''', '''''', [rfReplaceAll]),
           StringReplace(sDetail, '''', '''''', [rfReplaceAll]),
           fQty, fPrice, fRate, fPrepaid, fReimburse,
           contactId, sMethod,
           StringReplace(sPayer, '''', '''''', [rfReplaceAll]),
           StringReplace(sReimbursee, '''', '''''', [rfReplaceAll]),
           sStatus,
           StringReplace(sNotes, '''', '''''', [rfReplaceAll])]
        ));
        Inc(imported);
      except
        on E: Exception do
        begin
          Inc(errors);
          if errors <= 10 then
            Log('  行 ' + IntToStr(row + 1) + ' 失败: ' + E.Message);
        end;
      end;
    end;

    pbProgress.Visible := False;
    Log('');
    Log('=== 导入完成 ===');
    Log(Format('成功导入: %d 条', [imported]));
    Log(Format('跳过空行: %d 条', [skipped]));
    Log(Format('导入失败: %d 条', [errors]));

    if imported > 0 then
      ShowMessage(Format('导入完成！成功 %d 条，跳过 %d 条，失败 %d 条',
        [imported, skipped, errors]))
    else
      ShowMessage('没有导入任何数据，请检查 CSV 文件和列标题');
  finally
    sl.Free;
    headers.Free;
    colMap.Free;
  end;
end;

procedure TfrmImport.btnImportClick(Sender: TObject);
begin
  if Trim(edtFile.Text) = '' then
  begin
    ShowMessage('请先选择 CSV 文件');
    Exit;
  end;
  if not FileExists(edtFile.Text) then
  begin
    ShowMessage('文件不存在: ' + edtFile.Text);
    Exit;
  end;
  if MessageDlg('确认导入', '即将从 CSV 文件导入数据，已有数据不会受影响。继续？',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    ImportCSV(edtFile.Text);
end;

end.
