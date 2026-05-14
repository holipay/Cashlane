unit uMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  StdCtrls, ComCtrls, Grids, DBGrids, DBCtrls, DB, DateUtils;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    { Sidebar }
    pnlSidebar: TPanel;
    pnlSidebarHeader: TPanel;
    shpLogo: TShape;
    lblLogoLetter: TLabel;
    lblBrand: TLabel;
    lblBrandSub: TLabel;

    { Sidebar search }
    pnlSidebarSearch: TPanel;
    edtSidebarSearch: TEdit;

    { Active indicator }
    shpNavIndicator: TShape;

    { Nav area }
    pnlNavArea: TPanel;

    { Nav sections }
    lblNavSection1: TLabel;
    lblNavSection2: TLabel;
    lblNavSection3: TLabel;
    lblNavSection4: TLabel;
    lblNavSection5: TLabel;

    { Nav items }
    lblNavDashboard: TLabel;
    lblNavExpense: TLabel;
    lblNavContacts: TLabel;
    lblNavCategory: TLabel;
    lblNavReport: TLabel;
    lblNavImport: TLabel;
    lblNavExport: TLabel;
    lblNavSettings: TLabel;

    { Main area }
    pnlMain: TPanel;
    pnlTopbar: TPanel;
    lblBreadcrumb: TLabel;
    btnRefresh: TSpeedButton;
    btnNotification: TSpeedButton;

    { Content scroll }
    scrContent: TScrollBox;

    { Stats cards }
    pnlStats: TPanel;
    pnlStat1: TPanel; shpStat1: TShape; lblStat1Icon: TLabel;
    lblStat1Value: TLabel; lblStat1Label: TLabel;
    pnlStat2: TPanel; shpStat2: TShape; lblStat2Icon: TLabel;
    lblStat2Value: TLabel; lblStat2Label: TLabel;
    pnlStat3: TPanel; shpStat3: TShape; lblStat3Icon: TLabel;
    lblStat3Value: TLabel; lblStat3Label: TLabel;
    pnlStat4: TPanel; shpStat4: TShape; lblStat4Icon: TLabel;
    lblStat4Value: TLabel; lblStat4Label: TLabel;

    { Filter card }
    pnlFilterCard: TPanel;
    pnlFilterInner: TPanel;
    pnlFilterHeader: TPanel;
    lblFilterTitle: TLabel;
    lblFilterToggle: TLabel;
    pnlFilterBody: TPanel;

    { Filter controls }
    lblCompany: TLabel; cmbCompany: TComboBox;
    lblDept: TLabel; cmbDept: TComboBox;
    lblCat1: TLabel; cmbCat1: TComboBox;
    lblCat2: TLabel; cmbCat2: TComboBox;
    lblStatus: TLabel; cmbStatus: TComboBox;
    lblMethod: TLabel; cmbMethod: TComboBox;
    lblDateFrom: TLabel; edtDateFrom: TEdit;
    lblDateTo: TLabel; edtDateTo: TEdit;
    chkDateFilter: TCheckBox;
    lblSearch: TLabel;
    edtSearch: TEdit;
    btnSearch: TSpeedButton;
    btnReset: TSpeedButton;

    { Table card }
    pnlTableCard: TPanel;
    pnlTableInner: TPanel;
    pnlToolbar: TPanel;
    btnAdd: TSpeedButton;
    btnEdit: TSpeedButton;
    btnDelete: TSpeedButton;
    sep1: TShape;
    btnImport: TSpeedButton;
    btnExport: TSpeedButton;
    lblRecordHint: TLabel;

    dbgExpenses: TDBGrid;
    pnlStatusBar: TPanel;
    lblRecordCount: TLabel;
    lblTotalAmount: TLabel;
    navExpense: TDBNavigator;

    { Timer & Datasource }
    tmrToast: TTimer;
    dtsExpense: TDataSource;

    { Events }
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);

    { Nav clicks }
    procedure lblNavDashboardClick(Sender: TObject);
    procedure lblNavExpenseClick(Sender: TObject);
    procedure lblNavContactsClick(Sender: TObject);
    procedure lblNavCategoryClick(Sender: TObject);
    procedure lblNavReportClick(Sender: TObject);
    procedure lblNavImportClick(Sender: TObject);
    procedure lblNavExportClick(Sender: TObject);
    procedure lblNavSettingsClick(Sender: TObject);

    { Nav hover }
    procedure NavItemMouseEnter(Sender: TObject);
    procedure NavItemMouseLeave(Sender: TObject);

    { Sidebar search }
    procedure edtSidebarSearchChange(Sender: TObject);

    { Filter }
    procedure lblFilterToggleClick(Sender: TObject);
    procedure cmbCat1Change(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure btnResetClick(Sender: TObject);

    { Table }
    procedure btnAddClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnExportClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure dbgExpensesDblClick(Sender: TObject);
    procedure dbgExpensesDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);

    { Toast }
    procedure tmrToastTimer(Sender: TObject);

  private
    FActiveNav: TLabel;
    FFilterOpen: Boolean;
    FNavItems: array[0..7] of TLabel;
    procedure SetActiveNav(ALabel: TLabel);
    procedure PositionNavIndicator;
    procedure UpdateBreadcrumb(const APage: string);
    procedure InitFilters;
    procedure LoadCat1;
    procedure LoadCat2(AParentId: Integer);
    procedure LoadCompanies;
    procedure LoadDepts;
    procedure RefreshExpenseList;
    procedure UpdateStatusBar;
    procedure UpdateStats;
    function BuildFilter: string;
    function GetSelectedExpenseId: Integer;
    procedure ShowToast(const AMsg: string);
    procedure ApplyCardStyle(APanel: TPanel);
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

uses uData, uExpenseEntry, uContacts, uCategory, uReport, uImport;

{ TfrmMain }

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Caption := 'Cashlane - 费用管理系统';
  Position := poScreenCenter;
  Width := 1360;
  Height := 780;
  WindowState := wsMaximized;
  Color := $00F3F3F3;

  FFilterOpen := True;
  FActiveNav := lblNavDashboard;

  { Register all nav items for sidebar search filtering }
  FNavItems[0] := lblNavDashboard;
  FNavItems[1] := lblNavExpense;
  FNavItems[2] := lblNavContacts;
  FNavItems[3] := lblNavCategory;
  FNavItems[4] := lblNavReport;
  FNavItems[5] := lblNavImport;
  FNavItems[6] := lblNavExport;
  FNavItems[7] := lblNavSettings;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  dtsExpense.DataSet := dmData.qryMain;
  SetActiveNav(lblNavDashboard);
  InitFilters;
  RefreshExpenseList;
  UpdateStats;
  ApplyCardStyle(pnlStat1);
  ApplyCardStyle(pnlStat2);
  ApplyCardStyle(pnlStat3);
  ApplyCardStyle(pnlStat4);
  ApplyCardStyle(pnlFilterInner);
  ApplyCardStyle(pnlTableInner);
end;

procedure TfrmMain.FormResize(Sender: TObject);
var
  w, cardW, gap: Integer;
begin
  if not Assigned(pnlStats) then Exit;
  w := pnlStats.Width - 32;
  gap := 12;
  cardW := (w - gap * 3) div 4;

  pnlStat1.SetBounds(16, 10, cardW, 80);
  pnlStat2.SetBounds(16 + cardW + gap, 10, cardW, 80);
  pnlStat3.SetBounds(16 + (cardW + gap) * 2, 10, cardW, 80);
  pnlStat4.SetBounds(16 + (cardW + gap) * 3, 10, cardW, 80);

  { Reposition nav indicator on resize }
  PositionNavIndicator;
end;

{ ===== Sidebar Navigation ===== }

procedure TfrmMain.SetActiveNav(ALabel: TLabel);
begin
  { Reset previous active nav }
  if Assigned(FActiveNav) then
  begin
    FActiveNav.Color := $001B1B1B;
    FActiveNav.Font.Color := $00BBBBBB;
  end;

  { Set new active nav }
  FActiveNav := ALabel;
  ALabel.Color := $003A3A3A;
  ALabel.Font.Color := clWhite;

  { Move the blue indicator bar }
  PositionNavIndicator;
end;

procedure TfrmMain.PositionNavIndicator;
begin
  if Assigned(FActiveNav) and Assigned(shpNavIndicator) then
  begin
    shpNavIndicator.Left := 0;
    shpNavIndicator.Top := FActiveNav.Top + 2;
    shpNavIndicator.Height := FActiveNav.Height - 4;
    shpNavIndicator.Width := 3;
    shpNavIndicator.BringToFront;
  end;
end;

procedure TfrmMain.UpdateBreadcrumb(const APage: string);
begin
  lblBreadcrumb.Caption := 'Cashlane / ' + APage;
end;

procedure TfrmMain.NavItemMouseEnter(Sender: TObject);
begin
  if Sender <> FActiveNav then
    TLabel(Sender).Color := $002D2D2D;
end;

procedure TfrmMain.NavItemMouseLeave(Sender: TObject);
begin
  if Sender <> FActiveNav then
    TLabel(Sender).Color := $001B1B1B;
end;

{ ===== Sidebar Search ===== }

procedure TfrmMain.edtSidebarSearchChange(Sender: TObject);
var
  q: string;
  i: Integer;
  navLabel: string;
begin
  q := LowerCase(Trim(edtSidebarSearch.Text));

  { Show/hide nav items based on search query }
  lblNavSection1.Visible := (q = '');
  lblNavSection2.Visible := (q = '');
  lblNavSection3.Visible := (q = '');
  lblNavSection4.Visible := (q = '');
  lblNavSection5.Visible := (q = '');

  for i := 0 to High(FNavItems) do
  begin
    navLabel := LowerCase(FNavItems[i].Caption);
    { Extract text after emoji icons }
    navLabel := StringReplace(navLabel, '📊', '', [rfReplaceAll]);
    navLabel := StringReplace(navLabel, '📋', '', [rfReplaceAll]);
    navLabel := StringReplace(navLabel, '👤', '', [rfReplaceAll]);
    navLabel := StringReplace(navLabel, '🏷️', '', [rfReplaceAll]);
    navLabel := StringReplace(navLabel, '📈', '', [rfReplaceAll]);
    navLabel := StringReplace(navLabel, '📥', '', [rfReplaceAll]);
    navLabel := StringReplace(navLabel, '📤', '', [rfReplaceAll]);
    navLabel := StringReplace(navLabel, '⚙️', '', [rfReplaceAll]);
    navLabel := Trim(navLabel);

    if (q = '') or (Pos(q, navLabel) > 0) then
      FNavItems[i].Visible := True
    else
      FNavItems[i].Visible := False;
  end;

  { Always keep active nav visible }
  if Assigned(FActiveNav) then
    FActiveNav.Visible := True;

  PositionNavIndicator;
end;

{ ===== Nav Click Handlers ===== }

procedure TfrmMain.lblNavDashboardClick(Sender: TObject);
begin
  SetActiveNav(TLabel(Sender));
  UpdateBreadcrumb('仪表盘');
  ShowToast('📂 仪表盘');
end;

procedure TfrmMain.lblNavExpenseClick(Sender: TObject);
begin
  SetActiveNav(TLabel(Sender));
  UpdateBreadcrumb('费用录入');
  ShowToast('📂 费用录入');
end;

procedure TfrmMain.lblNavContactsClick(Sender: TObject);
begin
  SetActiveNav(TLabel(Sender));
  UpdateBreadcrumb('联系人');
  frmContacts.ShowModal;
end;

procedure TfrmMain.lblNavCategoryClick(Sender: TObject);
begin
  SetActiveNav(TLabel(Sender));
  UpdateBreadcrumb('科目分类');
  frmCategory.ShowModal;
  LoadCat1;
  RefreshExpenseList;
end;

procedure TfrmMain.lblNavReportClick(Sender: TObject);
begin
  SetActiveNav(TLabel(Sender));
  UpdateBreadcrumb('报表统计');
  frmReport.ShowModal;
end;

procedure TfrmMain.lblNavImportClick(Sender: TObject);
begin
  SetActiveNav(TLabel(Sender));
  UpdateBreadcrumb('导入');
  frmImport.ShowModal;
  RefreshExpenseList;
  UpdateStats;
end;

procedure TfrmMain.lblNavExportClick(Sender: TObject);
begin
  SetActiveNav(TLabel(Sender));
  UpdateBreadcrumb('导出');
  btnExportClick(nil);
end;

procedure TfrmMain.lblNavSettingsClick(Sender: TObject);
begin
  SetActiveNav(TLabel(Sender));
  UpdateBreadcrumb('设置');
  ShowToast('⚙️ 设置功能开发中...');
end;

{ ===== Filters ===== }

procedure TfrmMain.InitFilters;
begin
  edtDateFrom.Text := FormatDateTime('yyyy-mm-dd', EncodeDate(YearOf(Now), MonthOf(Now), 1));
  edtDateTo.Text := FormatDateTime('yyyy-mm-dd', Now);
  chkDateFilter.Checked := False;

  LoadCompanies;
  LoadDepts;
  LoadCat1;

  cmbCat2.Items.Clear;
  cmbCat2.Items.Add('全部');

  cmbStatus.Items.Clear;
  cmbStatus.Items.Add('全部');
  cmbStatus.Items.Add('填单');
  cmbStatus.Items.Add('签录');
  cmbStatus.Items.Add('完成');
  cmbStatus.Items.Add('取消');
  cmbStatus.Items.Add('付款');
  cmbStatus.Items.Add('发票');
  cmbStatus.ItemIndex := 0;

  cmbMethod.Items.Clear;
  cmbMethod.Items.Add('全部');
  cmbMethod.Items.Add('请款');
  cmbMethod.Items.Add('报销');
  cmbMethod.Items.Add('其他');
  cmbMethod.ItemIndex := 0;

  edtSearch.TextHint := '搜索明细 / 发票内容 / 备注...';
end;

procedure TfrmMain.LoadCompanies;
begin
  cmbCompany.Items.Clear;
  cmbCompany.Items.Add('全部公司');
  dmData.OpenQuery(dmData.qryAux, 'SELECT id, name FROM companies ORDER BY id');
  while not dmData.qryAux.EOF do
  begin
    cmbCompany.Items.AddObject(
      dmData.qryAux.FieldByName('name').AsString,
      TObject(PtrInt(dmData.qryAux.FieldByName('id').AsInteger)));
    dmData.qryAux.Next;
  end;
  cmbCompany.ItemIndex := 0;
end;

procedure TfrmMain.LoadDepts;
begin
  cmbDept.Items.Clear;
  cmbDept.Items.Add('全部部门');
  dmData.OpenQuery(dmData.qryAux, 'SELECT id, name FROM departments ORDER BY name');
  while not dmData.qryAux.EOF do
  begin
    cmbDept.Items.AddObject(
      dmData.qryAux.FieldByName('name').AsString,
      TObject(PtrInt(dmData.qryAux.FieldByName('id').AsInteger)));
    dmData.qryAux.Next;
  end;
  cmbDept.ItemIndex := 0;
end;

procedure TfrmMain.LoadCat1;
begin
  cmbCat1.Items.Clear;
  cmbCat1.Items.Add('全部科目');
  dmData.OpenCategories(0);
  while not dmData.qryAux.EOF do
  begin
    cmbCat1.Items.AddObject(
      dmData.qryAux.FieldByName('name').AsString,
      TObject(PtrInt(dmData.qryAux.FieldByName('id').AsInteger)));
    dmData.qryAux.Next;
  end;
  cmbCat1.ItemIndex := 0;
end;

procedure TfrmMain.LoadCat2(AParentId: Integer);
begin
  cmbCat2.Items.Clear;
  cmbCat2.Items.Add('全部');
  if AParentId > 0 then
  begin
    dmData.OpenCategories(AParentId);
    while not dmData.qryAux.EOF do
    begin
      cmbCat2.Items.AddObject(
        dmData.qryAux.FieldByName('name').AsString,
        TObject(PtrInt(dmData.qryAux.FieldByName('id').AsInteger)));
      dmData.qryAux.Next;
    end;
  end;
  cmbCat2.ItemIndex := 0;
end;

procedure TfrmMain.cmbCat1Change(Sender: TObject);
begin
  if cmbCat1.ItemIndex > 0 then
    LoadCat2(PtrInt(cmbCat1.Items.Objects[cmbCat1.ItemIndex]))
  else
  begin
    cmbCat2.Items.Clear;
    cmbCat2.Items.Add('全部');
    cmbCat2.ItemIndex := 0;
  end;
end;

procedure TfrmMain.lblFilterToggleClick(Sender: TObject);
begin
  FFilterOpen := not FFilterOpen;
  pnlFilterBody.Visible := FFilterOpen;
  if FFilterOpen then
  begin
    lblFilterToggle.Caption := '▼';
    pnlFilterInner.Height := 138;
    pnlFilterCard.Height := 148;
  end
  else
  begin
    lblFilterToggle.Caption := '▶';
    pnlFilterInner.Height := 44;
    pnlFilterCard.Height := 54;
  end;
end;

function TfrmMain.BuildFilter: string;
var
  parts: TStringList;
begin
  parts := TStringList.Create;
  try
    if cmbCompany.ItemIndex > 0 then
      parts.Add('e.company_id = ' + IntToStr(PtrInt(cmbCompany.Items.Objects[cmbCompany.ItemIndex])));
    if cmbDept.ItemIndex > 0 then
      parts.Add('e.dept_id = ' + IntToStr(PtrInt(cmbDept.Items.Objects[cmbDept.ItemIndex])));
    if cmbCat1.ItemIndex > 0 then
      parts.Add('e.cat1_id = ' + IntToStr(PtrInt(cmbCat1.Items.Objects[cmbCat1.ItemIndex])));
    if cmbCat2.ItemIndex > 0 then
      parts.Add('e.cat2_id = ' + IntToStr(PtrInt(cmbCat2.Items.Objects[cmbCat2.ItemIndex])));
    if cmbStatus.ItemIndex > 0 then
      parts.Add('e.reimburse_status = ''' + cmbStatus.Text + '''');
    if cmbMethod.ItemIndex > 0 then
      parts.Add('e.pay_method = ''' + cmbMethod.Text + '''');
    if chkDateFilter.Checked and (Trim(edtDateFrom.Text) <> '') then
      parts.Add('e.occur_date >= ''' + Trim(edtDateFrom.Text) + '''');
    if chkDateFilter.Checked and (Trim(edtDateTo.Text) <> '') then
      parts.Add('e.occur_date <= ''' + Trim(edtDateTo.Text) + ' 23:59:59''');
    if Trim(edtSearch.Text) <> '' then
      parts.Add('(e.detail LIKE ''%' + Trim(edtSearch.Text) + '%'' OR ' +
        'e.invoice_content LIKE ''%' + Trim(edtSearch.Text) + '%'' OR ' +
        'e.notes LIKE ''%' + Trim(edtSearch.Text) + '%'')');
    Result := parts.Text;
    Result := StringReplace(Result, sLineBreak, ' AND ', [rfReplaceAll]);
    Result := Trim(Result);
  finally
    parts.Free;
  end;
end;

procedure TfrmMain.btnSearchClick(Sender: TObject);
begin
  RefreshExpenseList;
end;

procedure TfrmMain.btnResetClick(Sender: TObject);
begin
  cmbCompany.ItemIndex := 0;
  cmbDept.ItemIndex := 0;
  cmbCat1.ItemIndex := 0;
  cmbCat2.ItemIndex := 0;
  cmbStatus.ItemIndex := 0;
  cmbMethod.ItemIndex := 0;
  chkDateFilter.Checked := False;
  edtDateFrom.Text := '';
  edtDateTo.Text := '';
  edtSearch.Text := '';
  RefreshExpenseList;
end;

{ ===== Data ===== }

procedure TfrmMain.RefreshExpenseList;
var
  filter: string;
begin
  filter := BuildFilter;
  dmData.OpenExpenseList(filter);
  if dbgExpenses.Columns.Count > 0 then
    dbgExpenses.Columns[dbgExpenses.Columns.Count - 1].Width := 150;
  UpdateStatusBar;
  UpdateStats;
end;

procedure TfrmMain.UpdateStatusBar;
var
  total: Double;
  cnt: Integer;
begin
  total := 0;
  cnt := 0;
  dmData.qryMain.First;
  while not dmData.qryMain.EOF do
  begin
    total := total + dmData.qryMain.FieldByName('reimburse_amount').AsFloat
                   + dmData.qryMain.FieldByName('prepaid').AsFloat;
    Inc(cnt);
    dmData.qryMain.Next;
  end;
  dmData.qryMain.First;
  lblRecordCount.Caption := Format('记录数: %d', [cnt]);
  lblRecordHint.Caption := Format('共 %d 条', [cnt]);
  lblTotalAmount.Caption := Format('合计金额: ¥%.2f', [total]);
end;

procedure TfrmMain.UpdateStats;
var
  totalReimburse, totalPrepaid, balance: Double;
  cnt, pending: Integer;
  ym: string;
begin
  ym := FormatDateTime('yyyy-mm', Now);
  totalReimburse := 0;
  totalPrepaid := 0;
  cnt := 0;
  pending := 0;
  balance := 0;

  dmData.OpenQuery(dmData.qryAux,
    'SELECT COUNT(*) AS cnt, COALESCE(SUM(reimburse_amount), 0) AS total_r, ' +
    'COALESCE(SUM(prepaid), 0) AS total_p FROM expenses ' +
    'WHERE substr(occur_date, 1, 7) = ''' + ym + '''');
  if not dmData.qryAux.EOF then
  begin
    cnt := dmData.qryAux.FieldByName('cnt').AsInteger;
    totalReimburse := dmData.qryAux.FieldByName('total_r').AsFloat;
    totalPrepaid := dmData.qryAux.FieldByName('total_p').AsFloat;
  end;

  dmData.OpenQuery(dmData.qryAux,
    'SELECT COUNT(*) AS cnt FROM expenses WHERE reimburse_status IN (''填单'', ''签录'')');
  if not dmData.qryAux.EOF then
    pending := dmData.qryAux.FieldByName('cnt').AsInteger;

  dmData.OpenQuery(dmData.qryAux,
    'SELECT COALESCE(SUM(prepaid - reimburse_amount), 0) AS bal FROM expenses WHERE prepaid > 0');
  if not dmData.qryAux.EOF then
    balance := dmData.qryAux.FieldByName('bal').AsFloat;

  lblStat1Value.Caption := IntToStr(cnt);
  lblStat2Value.Caption := Format('¥%s', [FormatFloat('#,##0', totalReimburse)]);
  lblStat3Value.Caption := IntToStr(pending);
  lblStat4Value.Caption := Format('¥%s', [FormatFloat('#,##0', balance)]);
end;

function TfrmMain.GetSelectedExpenseId: Integer;
begin
  Result := -1;
  if dmData.qryMain.Active and (dmData.qryMain.RecordCount > 0) then
    Result := dmData.qryMain.FieldByName('id').AsInteger;
end;

{ ===== Toolbar ===== }

procedure TfrmMain.btnAddClick(Sender: TObject);
begin
  if frmExpenseEntry.ShowAdd then
  begin
    RefreshExpenseList;
    ShowToast('✅ 费用记录已保存');
  end;
end;

procedure TfrmMain.btnEditClick(Sender: TObject);
var
  eid: Integer;
begin
  eid := GetSelectedExpenseId;
  if eid < 0 then
  begin
    ShowToast('✏️ 请先选择一条记录');
    Exit;
  end;
  if frmExpenseEntry.ShowEdit(eid) then
  begin
    RefreshExpenseList;
    ShowToast('✅ 费用记录已更新');
  end;
end;

procedure TfrmMain.btnDeleteClick(Sender: TObject);
var
  eid: Integer;
begin
  eid := GetSelectedExpenseId;
  if eid < 0 then
  begin
    ShowToast('🗑️ 请先选择一条记录');
    Exit;
  end;
  if MessageDlg('确认删除', '确定要删除这条费用记录吗？此操作不可恢复。',
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    dmData.ExecSQL('DELETE FROM expenses WHERE id = ' + IntToStr(eid));
    RefreshExpenseList;
    ShowToast('🗑️ 记录已删除');
  end;
end;

procedure TfrmMain.btnExportClick(Sender: TObject);
var
  dlg: TSaveDialog;
begin
  dlg := TSaveDialog.Create(nil);
  try
    dlg.Filter := 'CSV files|*.csv';
    dlg.DefaultExt := 'csv';
    dlg.FileName := 'Cashlane_Export_' + FormatDateTime('yyyymmdd', Now) + '.csv';
    if dlg.Execute then
      ShowToast('📤 导出功能开发中...');
  finally
    dlg.Free;
  end;
end;

procedure TfrmMain.btnRefreshClick(Sender: TObject);
begin
  RefreshExpenseList;
  ShowToast('🔄 数据已刷新');
end;

{ ===== Grid ===== }

procedure TfrmMain.dbgExpensesDblClick(Sender: TObject);
begin
  btnEditClick(nil);
end;

procedure TfrmMain.dbgExpensesDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  grid: TDBGrid;
begin
  grid := TDBGrid(Sender);

  { Alternate row colors }
  if Odd(grid.DataSource.DataSet.RecNo) then
    grid.Canvas.Brush.Color := $00FAFAFA
  else
    grid.Canvas.Brush.Color := clWhite;

  { Selected row highlight }
  if gdSelected in State then
    grid.Canvas.Brush.Color := $00F7E4CC;

  { Amount columns: bold + red }
  if (Column.FieldName = 'prepaid') or (Column.FieldName = 'reimburse_amount') then
  begin
    grid.Canvas.Font.Style := [fsBold];
    grid.Canvas.Font.Color := $001C1CC4;
  end;

  { Status column: colored badges }
  if Column.FieldName = 'reimburse_status' then
  begin
    grid.Canvas.Font.Style := [fsBold];
    case Column.Field.AsString of
      '完成': begin
        grid.Canvas.Font.Color := $000F7B0F;
        grid.Canvas.Brush.Color := $00DDF6DD;
      end;
      '取消': begin
        grid.Canvas.Font.Color := clGray;
        grid.Canvas.Brush.Color := $00F0F0F0;
      end;
      '填单': begin
        grid.Canvas.Font.Color := $00005D9D;
        grid.Canvas.Brush.Color := $00CEFFF4;
      end;
      '签录', '发票': begin
        grid.Canvas.Font.Color := $00D47800;
        grid.Canvas.Brush.Color := $00FDF4E8;
      end;
      '付款': begin
        grid.Canvas.Font.Color := $000F7B0F;
        grid.Canvas.Brush.Color := $00DDF6DD;
      end;
    else
      grid.Canvas.Font.Color := $00D47800;
      grid.Canvas.Brush.Color := $00FDF4E8;
    end;
  end;

  { ID column accent color }
  if Column.FieldName = 'doc_id' then
    grid.Canvas.Font.Color := $00D47800;

  grid.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;

{ ===== Toast ===== }

procedure TfrmMain.ShowToast(const AMsg: string);
begin
  lblBreadcrumb.Caption := AMsg;
  tmrToast.Enabled := False;
  tmrToast.Enabled := True;
end;

procedure TfrmMain.tmrToastTimer(Sender: TObject);
begin
  tmrToast.Enabled := False;
  if Assigned(FActiveNav) then
  begin
    if FActiveNav = lblNavDashboard then UpdateBreadcrumb('仪表盘')
    else if FActiveNav = lblNavExpense then UpdateBreadcrumb('费用录入')
    else if FActiveNav = lblNavContacts then UpdateBreadcrumb('联系人')
    else if FActiveNav = lblNavCategory then UpdateBreadcrumb('科目分类')
    else if FActiveNav = lblNavReport then UpdateBreadcrumb('报表统计')
    else if FActiveNav = lblNavImport then UpdateBreadcrumb('导入')
    else if FActiveNav = lblNavExport then UpdateBreadcrumb('导出')
    else if FActiveNav = lblNavSettings then UpdateBreadcrumb('设置');
  end;
end;

{ ===== Helpers ===== }

procedure TfrmMain.ApplyCardStyle(APanel: TPanel);
begin
  APanel.BevelOuter := bvNone;
  APanel.BorderStyle := bsSingle;
  APanel.BorderWidth := 1;
  APanel.Color := clWhite;
end;

end.
