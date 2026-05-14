unit uReport;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Buttons, DBGrids, DB;

type

  { TfrmReport }

  TfrmReport = class(TForm)
    pnlTop: TPanel;
    pnlLeft: TPanel;
    pnlRight: TPanel;
    lblYear: TLabel;
    cmbYear: TComboBox;
    lblMonth: TLabel;
    cmbMonth: TComboBox;
    btnQuery: TSpeedButton;
    dbgReport: TDBGrid;
    lblTotal: TLabel;
    lblTotalValue: TLabel;
    lblCount: TLabel;
    lblCountValue: TLabel;
    lblPrepaid: TLabel;
    lblPrepaidValue: TLabel;
    dbgDetail: TDBGrid;
    dtsReport: TDataSource;
    dtsDetail: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnQueryClick(Sender: TObject);
    procedure dbgReportCellClick(Column: TColumn);
  private
    procedure LoadMonths;
    procedure RefreshReport;
    procedure RefreshDetail(ACat1Name: string);
  end;

var
  frmReport: TfrmReport;

implementation

{$R *.lfm}

uses uData;

procedure TfrmReport.FormCreate(Sender: TObject);
begin
  Position := poMainFormCenter;
  BorderStyle := bsDialog;
  Caption := '📊 费用统计报表';
  Width := 900;
  Height := 600;
end;

procedure TfrmReport.FormShow(Sender: TObject);
begin
  dtsReport.DataSet := dmData.qryAux;
  LoadMonths;
  RefreshReport;
end;

procedure TfrmReport.LoadMonths;
var
  y, m, d: Word;
  i: Integer;
begin
  DecodeDate(Now, y, m, d);
  cmbYear.Items.Clear;
  for i := y - 5 to y do
    cmbYear.Items.Add(IntToStr(i));
  cmbYear.ItemIndex := cmbYear.Items.Count - 1;

  cmbMonth.Items.Clear;
  cmbMonth.Items.Add('全年');
  for i := 1 to 12 do
    cmbMonth.Items.Add(IntToStr(i) + '月');
  cmbMonth.ItemIndex := m;
end;

procedure TfrmReport.RefreshReport;
var
  y, m: Integer;
  total, prepaid: Double;
  cnt: Integer;
begin
  y := StrToInt(cmbYear.Text);
  m := cmbMonth.ItemIndex;

  if m = 0 then
    dmData.OpenQuery(dmData.qryAux,
      'SELECT c1.name AS cat1_name, ' +
      'SUM(e.reimburse_amount) AS total_reimburse, ' +
      'SUM(e.prepaid) AS total_prepaid, ' +
      'COUNT(*) AS cnt ' +
      'FROM expenses e ' +
      'LEFT JOIN categories c1 ON e.cat1_id = c1.id ' +
      'WHERE substr(e.occur_date, 1, 4) = ''' + IntToStr(y) + ''' ' +
      'GROUP BY e.cat1_id ORDER BY total_reimburse DESC')
  else
    dmData.OpenCategoryReport(y, m);

  if dbgReport.Columns.Count >= 4 then
  begin
    dbgReport.Columns[0].Title.Caption := '一级科目';  dbgReport.Columns[0].Width := 120;
    dbgReport.Columns[1].Title.Caption := '报销合计';  dbgReport.Columns[1].Width := 100;
    dbgReport.Columns[2].Title.Caption := '预付合计';  dbgReport.Columns[2].Width := 100;
    dbgReport.Columns[3].Title.Caption := '笔数';      dbgReport.Columns[3].Width := 60;
  end;

  total := 0; prepaid := 0; cnt := 0;
  dmData.qryAux.First;
  while not dmData.qryAux.EOF do
  begin
    total := total + dmData.qryAux.FieldByName('total_reimburse').AsFloat;
    prepaid := prepaid + dmData.qryAux.FieldByName('total_prepaid').AsFloat;
    cnt := cnt + dmData.qryAux.FieldByName('cnt').AsInteger;
    dmData.qryAux.Next;
  end;
  dmData.qryAux.First;

  lblTotalValue.Caption := Format('¥%.2f', [total]);
  lblPrepaidValue.Caption := Format('¥%.2f', [prepaid]);
  lblCountValue.Caption := IntToStr(cnt) + ' 笔';
end;

procedure TfrmReport.RefreshDetail(ACat1Name: string);
var
  y, m: Integer;
  ym: string;
begin
  y := StrToInt(cmbYear.Text);
  m := cmbMonth.ItemIndex;
  if m > 0 then
    ym := Format('%.4d-%.2d', [y, m])
  else
    ym := IntToStr(y);

  dmData.OpenQuery(dmData.qryMain,
    'SELECT e.occur_date, c2.name AS cat2_name, e.detail, ' +
    'e.reimburse_amount, e.prepaid, e.pay_method, e.reimburse_status ' +
    'FROM expenses e ' +
    'LEFT JOIN categories c1 ON e.cat1_id = c1.id ' +
    'LEFT JOIN categories c2 ON e.cat2_id = c2.id ' +
    'WHERE c1.name = ''' + ACat1Name + ''' ' +
    'AND e.occur_date LIKE ''' + ym + '%'' ' +
    'ORDER BY e.occur_date DESC');

  dtsDetail.DataSet := dmData.qryMain;
  if dbgDetail.Columns.Count >= 7 then
  begin
    dbgDetail.Columns[0].Title.Caption := '日期';    dbgDetail.Columns[0].Width := 90;
    dbgDetail.Columns[1].Title.Caption := '二级科目'; dbgDetail.Columns[1].Width := 100;
    dbgDetail.Columns[2].Title.Caption := '明细';    dbgDetail.Columns[2].Width := 200;
    dbgDetail.Columns[3].Title.Caption := '报销费用'; dbgDetail.Columns[3].Width := 80;
    dbgDetail.Columns[4].Title.Caption := '预付';    dbgDetail.Columns[4].Width := 80;
    dbgDetail.Columns[5].Title.Caption := '方式';    dbgDetail.Columns[5].Width := 60;
    dbgDetail.Columns[6].Title.Caption := '状态';    dbgDetail.Columns[6].Width := 60;
  end;
end;

procedure TfrmReport.btnQueryClick(Sender: TObject);
begin
  RefreshReport;
end;

procedure TfrmReport.dbgReportCellClick(Column: TColumn);
begin
  if dmData.qryAux.Active and (dmData.qryAux.RecordCount > 0) then
    RefreshDetail(dmData.qryAux.FieldByName('cat1_name').AsString);
end;

end.
