unit uData;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLite3Conn, SQLDB, DB, Forms, Dialogs;

type

  { TdmData }

  TdmData = class(TDataModule)
    conn: TSQLite3Connection;
    trans: TSQLTransaction;
    qryMain: TSQLQuery;
    qryAux: TSQLQuery;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    procedure CreateTables;
    procedure InsertDefaults;
    procedure GenerateDemoData;
    procedure FixMemoFields(AQuery: TSQLQuery);
    procedure SetExpenseDisplayLabels;
    procedure MemoFieldGetText(Sender: TField; var aText: string;
      DisplayText: Boolean);
  public
    procedure ExecSQL(const ASQL: string);
    function GetLastInsertId: Integer;
    procedure OpenQuery(AQuery: TSQLQuery; const ASQL: string);
    procedure OpenExpenseList(const AFilter: string = '');
    procedure OpenCategories(AParentId: Integer = -1);
    function GetCategoryPath(AId: Integer): string;
    procedure OpenContacts(const AFilter: string = '');
    procedure OpenMonthlyReport(AYear, AMonth: Integer);
    procedure OpenCategoryReport(AYear, AMonth: Integer);
  end;

var
  dmData: TdmData;

implementation

{$R *.lfm}

procedure TdmData.DataModuleCreate(Sender: TObject);
var
  dbPath: string;
begin
  dbPath := ExtractFilePath(Application.ExeName) + 'cashlane.db';
  conn.DatabaseName := dbPath;
  conn.Open;
  CreateTables;
end;

procedure TdmData.DataModuleDestroy(Sender: TObject);
begin
  if conn.Connected then
  begin
    trans.Commit;
    conn.Close;
  end;
end;

procedure TdmData.CreateTables;
begin
  ExecSQL('CREATE TABLE IF NOT EXISTS companies (' +
    'id INTEGER PRIMARY KEY AUTOINCREMENT,' +
    'name TEXT NOT NULL,' +
    'tax_no TEXT DEFAULT '''',' +
    'bank TEXT DEFAULT '''',' +
    'account TEXT DEFAULT '''',' +
    'address TEXT DEFAULT '''',' +
    'created_at TEXT DEFAULT (datetime(''now'',''localtime'')))');

  ExecSQL('CREATE TABLE IF NOT EXISTS departments (' +
    'id INTEGER PRIMARY KEY AUTOINCREMENT,' +
    'name TEXT NOT NULL,' +
    'company_id INTEGER DEFAULT 1)');

  ExecSQL('CREATE TABLE IF NOT EXISTS categories (' +
    'id INTEGER PRIMARY KEY AUTOINCREMENT,' +
    'parent_id INTEGER DEFAULT 0,' +
    'name TEXT NOT NULL,' +
    'code TEXT DEFAULT '''',' +
    'sort_order INTEGER DEFAULT 0)');

  ExecSQL('CREATE TABLE IF NOT EXISTS contacts (' +
    'id INTEGER PRIMARY KEY AUTOINCREMENT,' +
    'short_name TEXT NOT NULL,' +
    'full_name TEXT DEFAULT '''',' +
    'tax_no TEXT DEFAULT '''',' +
    'bank TEXT DEFAULT '''',' +
    'account TEXT DEFAULT '''',' +
    'contact_person TEXT DEFAULT '''',' +
    'phone TEXT DEFAULT '''',' +
    'address TEXT DEFAULT '''',' +
    'notes TEXT DEFAULT '''')');

  ExecSQL('CREATE TABLE IF NOT EXISTS expenses (' +
    'id INTEGER PRIMARY KEY AUTOINCREMENT,' +
    'sid TEXT DEFAULT '''',' +
    'entry_date TEXT NOT NULL,' +
    'occur_date TEXT NOT NULL,' +
    'company_id INTEGER DEFAULT 1,' +
    'dept_id INTEGER DEFAULT 0,' +
    'cat1_id INTEGER NOT NULL,' +
    'cat2_id INTEGER DEFAULT 0,' +
    'invoice_content TEXT DEFAULT '''',' +
    'detail TEXT DEFAULT '''',' +
    'quantity REAL DEFAULT 1,' +
    'unit_price REAL DEFAULT 0,' +
    'exchange_rate REAL DEFAULT 1,' +
    'prepaid REAL DEFAULT 0,' +
    'reimburse_amount REAL DEFAULT 0,' +
    'contact_id INTEGER DEFAULT 0,' +
    'pay_method TEXT DEFAULT ''报销'',' +
    'payer TEXT DEFAULT '''',' +
    'reimbursee TEXT DEFAULT '''',' +
    'transfer_recipient TEXT DEFAULT '''',' +
    'doc_id TEXT DEFAULT '''',' +
    'batch_info TEXT DEFAULT '''',' +
    'reimburse_status TEXT DEFAULT ''填单'',' +
    'settlement INTEGER DEFAULT 0,' +
    'is_asset INTEGER DEFAULT 0,' +
    'collect_date TEXT DEFAULT '''',' +
    'notes TEXT DEFAULT '''',' +
    'created_at TEXT DEFAULT (datetime(''now'',''localtime'')))');

  ExecSQL('CREATE TABLE IF NOT EXISTS ledger (' +
    'id INTEGER PRIMARY KEY AUTOINCREMENT,' +
    'entry_date TEXT NOT NULL,' +
    'ledger_type TEXT NOT NULL,' +
    'amount REAL NOT NULL,' +
    'description TEXT DEFAULT '''',' +
    'related_expense_id INTEGER DEFAULT 0,' +
    'created_at TEXT DEFAULT (datetime(''now'',''localtime'')))');

  qryAux.Close;
  qryAux.SQL.Text := 'SELECT COUNT(*) AS cnt FROM categories';
  qryAux.Open;
  if qryAux.FieldByName('cnt').AsInteger = 0 then
    InsertDefaults;
  qryAux.Close;
end;

procedure TdmData.InsertDefaults;
begin
  ExecSQL('INSERT INTO companies (name) VALUES (''鑫源科技有限公司'')');
  ExecSQL('INSERT INTO companies (name) VALUES (''鑫源商贸分公司'')');

  ExecSQL('INSERT INTO departments (name, company_id) VALUES (''行政部'', 1)');
  ExecSQL('INSERT INTO departments (name, company_id) VALUES (''财务部'', 1)');
  ExecSQL('INSERT INTO departments (name, company_id) VALUES (''工程部'', 1)');
  ExecSQL('INSERT INTO departments (name, company_id) VALUES (''市场部'', 1)');
  ExecSQL('INSERT INTO departments (name, company_id) VALUES (''人事部'', 1)');

  ExecSQL('INSERT INTO categories (id, parent_id, name, sort_order) VALUES (1, 0, ''员工薪酬'', 1)');
  ExecSQL('INSERT INTO categories (id, parent_id, name, sort_order) VALUES (2, 0, ''福利费'', 2)');
  ExecSQL('INSERT INTO categories (id, parent_id, name, sort_order) VALUES (3, 0, ''招待费'', 3)');
  ExecSQL('INSERT INTO categories (id, parent_id, name, sort_order) VALUES (4, 0, ''办公费'', 4)');
  ExecSQL('INSERT INTO categories (id, parent_id, name, sort_order) VALUES (5, 0, ''营销费'', 5)');
  ExecSQL('INSERT INTO categories (id, parent_id, name, sort_order) VALUES (6, 0, ''差旅费'', 6)');
  ExecSQL('INSERT INTO categories (id, parent_id, name, sort_order) VALUES (7, 0, ''汽车费'', 7)');
  ExecSQL('INSERT INTO categories (id, parent_id, name, sort_order) VALUES (8, 0, ''其他费用'', 8)');
  ExecSQL('INSERT INTO categories (id, parent_id, name, sort_order) VALUES (9, 0, ''建设费用'', 9)');

  ExecSQL('INSERT INTO categories (parent_id, name, sort_order) VALUES (1, ''正式工工资'', 1)');
  ExecSQL('INSERT INTO categories (parent_id, name, sort_order) VALUES (1, ''临时工工资'', 2)');
  ExecSQL('INSERT INTO categories (parent_id, name, sort_order) VALUES (1, ''员工补贴'', 3)');
  ExecSQL('INSERT INTO categories (parent_id, name, sort_order) VALUES (1, ''社保'', 4)');
  ExecSQL('INSERT INTO categories (parent_id, name, sort_order) VALUES (1, ''公积金'', 5)');
  ExecSQL('INSERT INTO categories (parent_id, name, sort_order) VALUES (1, ''年终奖'', 6)');
  ExecSQL('INSERT INTO categories (parent_id, name, sort_order) VALUES (2, ''住宿费'', 1)');
  ExecSQL('INSERT INTO categories (parent_id, name, sort_order) VALUES (2, ''买菜费用'', 2)');
  ExecSQL('INSERT INTO categories (parent_id, name, sort_order) VALUES (2, ''员工活动'', 3)');
  ExecSQL('INSERT INTO categories (parent_id, name, sort_order) VALUES (2, ''房租'', 4)');
  ExecSQL('INSERT INTO categories (parent_id, name, sort_order) VALUES (2, ''水费'', 5)');
  ExecSQL('INSERT INTO categories (parent_id, name, sort_order) VALUES (2, ''电费'', 6)');
  ExecSQL('INSERT INTO categories (parent_id, name, sort_order) VALUES (2, ''日用品'', 7)');
  ExecSQL('INSERT INTO categories (parent_id, name, sort_order) VALUES (3, ''餐费'', 1)');
  ExecSQL('INSERT INTO categories (parent_id, name, sort_order) VALUES (3, ''住宿费'', 2)');
  ExecSQL('INSERT INTO categories (parent_id, name, sort_order) VALUES (3, ''酒'', 3)');
  ExecSQL('INSERT INTO categories (parent_id, name, sort_order) VALUES (3, ''水果'', 4)');
  ExecSQL('INSERT INTO categories (parent_id, name, sort_order) VALUES (3, ''茶叶'', 5)');
  ExecSQL('INSERT INTO categories (parent_id, name, sort_order) VALUES (3, ''礼品'', 6)');
  ExecSQL('INSERT INTO categories (parent_id, name, sort_order) VALUES (4, ''办公用品'', 1)');
  ExecSQL('INSERT INTO categories (parent_id, name, sort_order) VALUES (4, ''耗材'', 2)');
  ExecSQL('INSERT INTO categories (parent_id, name, sort_order) VALUES (4, ''网络费'', 3)');
  ExecSQL('INSERT INTO categories (parent_id, name, sort_order) VALUES (4, ''电话费'', 4)');
  ExecSQL('INSERT INTO categories (parent_id, name, sort_order) VALUES (4, ''水电费'', 5)');
  ExecSQL('INSERT INTO categories (parent_id, name, sort_order) VALUES (4, ''快递费'', 6)');
  ExecSQL('INSERT INTO categories (parent_id, name, sort_order) VALUES (4, ''印刷费'', 7)');
  ExecSQL('INSERT INTO categories (parent_id, name, sort_order) VALUES (6, ''差旅费'', 1)');
  ExecSQL('INSERT INTO categories (parent_id, name, sort_order) VALUES (6, ''交通费'', 2)');
  ExecSQL('INSERT INTO categories (parent_id, name, sort_order) VALUES (7, ''油费'', 1)');
  ExecSQL('INSERT INTO categories (parent_id, name, sort_order) VALUES (7, ''油卡充值'', 2)');
  ExecSQL('INSERT INTO categories (parent_id, name, sort_order) VALUES (7, ''ETC'', 3)');
  ExecSQL('INSERT INTO categories (parent_id, name, sort_order) VALUES (7, ''停车费'', 4)');
  ExecSQL('INSERT INTO categories (parent_id, name, sort_order) VALUES (7, ''修理费'', 5)');
  ExecSQL('INSERT INTO categories (parent_id, name, sort_order) VALUES (7, ''保险费'', 6)');
  ExecSQL('INSERT INTO categories (parent_id, name, sort_order) VALUES (8, ''咨询费'', 1)');
  ExecSQL('INSERT INTO categories (parent_id, name, sort_order) VALUES (8, ''培训费'', 2)');
  ExecSQL('INSERT INTO categories (parent_id, name, sort_order) VALUES (8, ''捐赠'', 3)');

  ExecSQL('INSERT INTO contacts (short_name, full_name, bank, account, contact_person, phone) VALUES (''张伟'', ''张伟'', ''工商银行城东支行'', ''6222021234567890001'', ''张伟'', ''13800001111'')');
  ExecSQL('INSERT INTO contacts (short_name, full_name, bank, account, contact_person, phone) VALUES (''李芳'', ''李芳'', ''建设银行新区支行'', ''6227001234567890002'', ''李芳'', ''13900002222'')');
  ExecSQL('INSERT INTO contacts (short_name, full_name, bank, account, contact_person, phone) VALUES (''王强'', ''王强商贸部'', ''农业银行开发区支行'', ''6228481234567890003'', ''王强'', ''13700003333'')');
  ExecSQL('INSERT INTO contacts (short_name, full_name, bank, account, contact_person, phone) VALUES (''陈静'', ''陈静日用品店'', ''中国银行城南支行'', ''6217001234567890004'', ''陈静'', ''13600004444'')');
  ExecSQL('INSERT INTO contacts (short_name, full_name, bank, account, contact_person, phone) VALUES (''赵明'', ''赵明汽车服务'', ''招商银行新区支行'', ''6214831234567890005'', ''赵明'', ''13500005555'')');

  GenerateDemoData;
end;

procedure TdmData.GenerateDemoData;
var
  i, cat1, cat2, dept, contact, company: Integer;
  amount, qty, price: Double;
  d: TDateTime;
  statuses: array[0..5] of string;
  methods: array[0..2] of string;
  payers: array[0..4] of string;
  details: array[0..19] of string;
  invoices: array[0..9] of string;
  status, method, payer, detail, invoice: string;
  dayOffset: Integer;
begin
  statuses[0] := '填单';  statuses[1] := '签录';  statuses[2] := '完成';
  statuses[3] := '完成';  statuses[4] := '完成';  statuses[5] := '取消';
  methods[0] := '报销';   methods[1] := '请款';   methods[2] := '其他';
  payers[0] := '张伟';    payers[1] := '李芳';    payers[2] := '王强';
  payers[3] := '公司账户'; payers[4] := '财务备用金';
  details[0]  := '办公用品采购';      details[1]  := '部门聚餐费用';
  details[2]  := '出差交通费报销';    details[3]  := '客户接待用餐';
  details[4]  := '办公耗材补充';      details[5]  := '月度水费缴纳';
  details[6]  := '车辆加油费';        details[7]  := '快递寄件费';
  details[8]  := '员工生日活动';      details[9]  := '会议室设备维护';
  details[10] := '培训课程报名费';    details[11] := '打印纸采购';
  details[12] := '宽带续费';          details[13] := '车辆ETC充值';
  details[14] := '茶叶采购(招待用)'; details[15] := '办公家具维修';
  details[16] := '出差住宿费报销';    details[17] := '公司电话费';
  details[18] := '停车费报销';        details[19] := '日用品采购';
  invoices[0] := '增值税专用发票';    invoices[1] := '增值税普通发票';
  invoices[2] := '电子发票';          invoices[3] := '收据';
  invoices[4] := '定额发票';          invoices[5] := '机打发票';
  invoices[6] := '行程单';            invoices[7] := '完税凭证';
  invoices[8] := '银行回单';          invoices[9] := '其他凭证';

  Randomize;
  for i := 1 to 80 do
  begin
    cat1 := Random(8) + 1;
    if cat1 >= 5 then Inc(cat1);
    case cat1 of
      1: cat2 := 10 + Random(6);
      2: cat2 := 16 + Random(7);
      3: cat2 := 23 + Random(6);
      4: cat2 := 29 + Random(7);
      6: cat2 := 36 + Random(2);
      7: cat2 := 38 + Random(6);
      8: cat2 := 44 + Random(3);
    else
      cat2 := 0;
    end;
    dept := Random(5) + 1;
    contact := Random(5) + 1;
    company := Random(2) + 1;
    qty := 1;
    price := (Random(5000) + 10) + Random(100) / 100.0;
    amount := qty * price;
    dayOffset := Random(180);
    d := Now - dayOffset;
    status := statuses[Random(6)];
    method := methods[Random(3)];
    payer := payers[Random(5)];
    detail := details[Random(20)];
    invoice := invoices[Random(10)];

    ExecSQL(Format(
      'INSERT INTO expenses (entry_date, occur_date, company_id, dept_id, ' +
      'cat1_id, cat2_id, invoice_content, detail, quantity, unit_price, ' +
      'exchange_rate, prepaid, reimburse_amount, contact_id, pay_method, ' +
      'payer, reimbursee, reimburse_status, notes) VALUES ' +
      '(''%s'', ''%s'', %d, %d, %d, %d, ''%s'', ''%s'', %.0f, %.2f, 1, 0, %.2f, %d, ''%s'', ''%s'', ''%s'', ''%s'', ''demo'')',
      [FormatDateTime('yyyy-mm-dd', d), FormatDateTime('yyyy-mm-dd', d),
       company, dept, cat1, cat2,
       invoice, detail, qty, price, amount,
       contact, method, payer, payer, status]));
  end;
end;

procedure TdmData.ExecSQL(const ASQL: string);
var
  q: TSQLQuery;
begin
  q := TSQLQuery.Create(nil);
  try
    q.Database := conn;
    q.Transaction := trans;
    q.SQL.Text := ASQL;
    q.ExecSQL;
    trans.CommitRetaining;
  finally
    q.Free;
  end;
end;

function TdmData.GetLastInsertId: Integer;
begin
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT last_insert_rowid() AS lid';
  qryAux.Open;
  Result := qryAux.FieldByName('lid').AsInteger;
  qryAux.Close;
end;

procedure TdmData.FixMemoFields(AQuery: TSQLQuery);
var
  i: Integer;
begin
  for i := 0 to AQuery.Fields.Count - 1 do
    if AQuery.Fields[i].DataType = ftMemo then
      AQuery.Fields[i].OnGetText := @MemoFieldGetText;
end;

procedure TdmData.MemoFieldGetText(Sender: TField; var aText: string;
  DisplayText: Boolean);
begin
  aText := Sender.AsString;
end;

procedure TdmData.SetExpenseDisplayLabels;
begin
  if not qryMain.Active then Exit;
  qryMain.FieldByName('id').DisplayLabel := 'ID';
  qryMain.FieldByName('sid').DisplayLabel := 'SID';
  qryMain.FieldByName('entry_date').DisplayLabel := '填单日期';
  qryMain.FieldByName('occur_date').DisplayLabel := '发生日期';
  qryMain.FieldByName('company_name').DisplayLabel := '公司';
  qryMain.FieldByName('dept_name').DisplayLabel := '部门';
  qryMain.FieldByName('cat1_id').Visible := False;
  qryMain.FieldByName('cat2_id').Visible := False;
  qryMain.FieldByName('cat1_name').DisplayLabel := '一级科目';
  qryMain.FieldByName('cat2_name').DisplayLabel := '二级科目';
  qryMain.FieldByName('invoice_content').DisplayLabel := '发票内容';
  qryMain.FieldByName('detail').DisplayLabel := '费用明细';
  qryMain.FieldByName('quantity').DisplayLabel := '数量';
  qryMain.FieldByName('unit_price').DisplayLabel := '单价';
  qryMain.FieldByName('exchange_rate').DisplayLabel := '汇率';
  qryMain.FieldByName('prepaid').DisplayLabel := '预付/代付';
  qryMain.FieldByName('reimburse_amount').DisplayLabel := '报销费用';
  qryMain.FieldByName('contact_name').DisplayLabel := '供应商';
  qryMain.FieldByName('pay_method').DisplayLabel := '方式';
  qryMain.FieldByName('payer').DisplayLabel := '付款人';
  qryMain.FieldByName('reimbursee').DisplayLabel := '报销人';
  qryMain.FieldByName('transfer_recipient').DisplayLabel := '转账收款';
  qryMain.FieldByName('doc_id').DisplayLabel := '单据ID';
  qryMain.FieldByName('batch_info').DisplayLabel := '批次/张数';
  qryMain.FieldByName('reimburse_status').DisplayLabel := '报销状态';
  qryMain.FieldByName('settlement').DisplayLabel := '结算';
  qryMain.FieldByName('is_asset').DisplayLabel := '资产';
  qryMain.FieldByName('collect_date').DisplayLabel := '领款日期';
  qryMain.FieldByName('notes').DisplayLabel := '备注';
end;

procedure TdmData.OpenQuery(AQuery: TSQLQuery; const ASQL: string);
begin
  AQuery.Close;
  AQuery.SQL.Text := ASQL;
  AQuery.Open;
  FixMemoFields(AQuery);
end;

procedure TdmData.OpenExpenseList(const AFilter: string);
begin
  qryMain.Close;
  qryMain.SQL.Text :=
    'SELECT e.id, e.sid, e.entry_date, e.occur_date, ' +
    'co.name AS company_name, d.name AS dept_name, ' +
    'e.cat1_id, e.cat2_id, c1.name AS cat1_name, c2.name AS cat2_name, ' +
    'e.invoice_content, e.detail, e.quantity, e.unit_price, ' +
    'e.exchange_rate, e.prepaid, e.reimburse_amount, ' +
    'ct.short_name AS contact_name, ' +
    'e.pay_method, e.payer, e.reimbursee, ' +
    'e.transfer_recipient, e.doc_id, e.batch_info, ' +
    'e.reimburse_status, e.settlement, e.is_asset, ' +
    'e.collect_date, e.notes ' +
    'FROM expenses e ' +
    'LEFT JOIN companies co ON e.company_id = co.id ' +
    'LEFT JOIN departments d ON e.dept_id = d.id ' +
    'LEFT JOIN categories c1 ON e.cat1_id = c1.id ' +
    'LEFT JOIN categories c2 ON e.cat2_id = c2.id ' +
    'LEFT JOIN contacts ct ON e.contact_id = ct.id ';
  if AFilter <> '' then
    qryMain.SQL.Add('WHERE ' + AFilter);
  qryMain.SQL.Add('ORDER BY e.occur_date DESC, e.id DESC');
  qryMain.Open;
  FixMemoFields(qryMain);
  SetExpenseDisplayLabels;
end;

procedure TdmData.OpenCategories(AParentId: Integer);
begin
  qryAux.Close;
  if AParentId >= 0 then
  begin
    qryAux.SQL.Text :=
      'SELECT id, parent_id, name, code, sort_order FROM categories ' +
      'WHERE parent_id = :pid ORDER BY sort_order, name';
    qryAux.ParamByName('pid').AsInteger := AParentId;
  end
  else
    qryAux.SQL.Text :=
      'SELECT id, parent_id, name, code, sort_order FROM categories ' +
      'ORDER BY parent_id, sort_order, name';
  qryAux.Open;
  FixMemoFields(qryAux);
end;

function TdmData.GetCategoryPath(AId: Integer): string;
var
  pid: Integer;
  cname: string;
begin
  Result := '';
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT parent_id, name FROM categories WHERE id = :id';
  qryAux.ParamByName('id').AsInteger := AId;
  qryAux.Open;
  if not qryAux.EOF then
  begin
    cname := qryAux.FieldByName('name').AsString;
    pid := qryAux.FieldByName('parent_id').AsInteger;
    if pid > 0 then
    begin
      qryAux.Close;
      qryAux.SQL.Text := 'SELECT name FROM categories WHERE id = :id';
      qryAux.ParamByName('id').AsInteger := pid;
      qryAux.Open;
      if not qryAux.EOF then
        Result := qryAux.FieldByName('name').AsString + ' > ' + cname
      else
        Result := cname;
    end
    else
      Result := cname;
  end;
  qryAux.Close;
end;

procedure TdmData.OpenContacts(const AFilter: string);
begin
  qryAux.Close;
  qryAux.SQL.Text :=
    'SELECT id, short_name, full_name, tax_no, bank, account, ' +
    'contact_person, phone, address, notes FROM contacts ';
  if AFilter <> '' then
    qryAux.SQL.Add('WHERE ' + AFilter);
  qryAux.SQL.Add('ORDER BY short_name');
  qryAux.Open;
  FixMemoFields(qryAux);
end;

procedure TdmData.OpenMonthlyReport(AYear, AMonth: Integer);
var
  ym: string;
begin
  ym := Format('%.4d-%.2d', [AYear, AMonth]);
  qryAux.Close;
  qryAux.SQL.Text :=
    'SELECT c1.name AS cat1_name, c2.name AS cat2_name, ' +
    'SUM(e.reimburse_amount) AS total, COUNT(*) AS cnt ' +
    'FROM expenses e ' +
    'LEFT JOIN categories c1 ON e.cat1_id = c1.id ' +
    'LEFT JOIN categories c2 ON e.cat2_id = c2.id ' +
    'WHERE substr(e.occur_date, 1, 7) = :ym ' +
    'GROUP BY e.cat1_id, e.cat2_id ' +
    'ORDER BY c1.sort_order, total DESC';
  qryAux.ParamByName('ym').AsString := ym;
  qryAux.Open;
  FixMemoFields(qryAux);
end;

procedure TdmData.OpenCategoryReport(AYear, AMonth: Integer);
var
  ym: string;
begin
  ym := Format('%.4d-%.2d', [AYear, AMonth]);
  qryAux.Close;
  qryAux.SQL.Text :=
    'SELECT c1.name AS cat1_name, ' +
    'SUM(e.reimburse_amount + e.prepaid) AS total_reimburse, ' +
    'SUM(e.prepaid) AS total_prepaid, ' +
    'COUNT(*) AS cnt ' +
    'FROM expenses e ' +
    'LEFT JOIN categories c1 ON e.cat1_id = c1.id ' +
    'WHERE substr(e.occur_date, 1, 7) = :ym ' +
    'GROUP BY e.cat1_id ' +
    'ORDER BY total_reimburse DESC';
  qryAux.ParamByName('ym').AsString := ym;
  qryAux.Open;
  FixMemoFields(qryAux);
end;

end.
