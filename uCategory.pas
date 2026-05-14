unit uCategory;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Buttons,
  ExtCtrls, ComCtrls, DBGrids, DBCtrls, DB, StrUtils;

type

  { TfrmCategory }

  TfrmCategory = class(TForm)
    pnlTop: TPanel;
    pnlBottom: TPanel;
    tvCategory: TTreeView;
    pnlRight: TPanel;
    dbgSub: TDBGrid;
    btnAddMain: TSpeedButton;
    btnAddSub: TSpeedButton;
    btnEdit: TSpeedButton;
    btnDelete: TSpeedButton;
    btnClose: TBitBtn;
    dtsCategory: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnAddMainClick(Sender: TObject);
    procedure btnAddSubClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure tvCategorySelectionChanged(Sender: TObject);
  private
    procedure LoadTree;
    procedure LoadSubCategories(AParentId: Integer);
    function GetSelectedCatId: Integer;
    function InputCategory(var AName: string; AParentId: Integer = 0): Boolean;
  end;

var
  frmCategory: TfrmCategory;

implementation

{$R *.lfm}

uses uData;

procedure TfrmCategory.FormCreate(Sender: TObject);
begin
  Position := poMainFormCenter;
  BorderStyle := bsDialog;
  Caption := '🏷️ 科目分类管理';
  Width := 700;
  Height := 500;
end;

procedure TfrmCategory.FormShow(Sender: TObject);
begin
  dtsCategory.DataSet := dmData.qryAux;
  LoadTree;
end;

procedure TfrmCategory.LoadTree;
var
  node: TTreeNode;
begin
  tvCategory.Items.Clear;
  dmData.OpenCategories(0);
  while not dmData.qryAux.EOF do
  begin
    node := tvCategory.Items.Add(nil, dmData.qryAux.FieldByName('name').AsString);
    node.Data := TObject(PtrInt(dmData.qryAux.FieldByName('id').AsInteger));
    dmData.qryAux.Next;
  end;
  if tvCategory.Items.Count > 0 then
    tvCategory.Selected := tvCategory.Items[0];
end;

procedure TfrmCategory.LoadSubCategories(AParentId: Integer);
begin
  dmData.OpenCategories(AParentId);
  if dbgSub.Columns.Count >= 4 then
  begin
    dbgSub.Columns[0].Title.Caption := 'ID';             dbgSub.Columns[0].Width := 50;
    dbgSub.Columns[1].Visible := False;
    dbgSub.Columns[2].Title.Caption := '二级科目名称';    dbgSub.Columns[2].Width := 200;
    dbgSub.Columns[3].Title.Caption := '编码';            dbgSub.Columns[3].Width := 100;
  end;
end;

function TfrmCategory.GetSelectedCatId: Integer;
begin
  Result := -1;
  if dmData.qryAux.Active and (dmData.qryAux.RecordCount > 0) then
    Result := dmData.qryAux.FieldByName('id').AsInteger;
end;

function TfrmCategory.InputCategory(var AName: string; AParentId: Integer): Boolean;
var
  s: string;
begin
  s := AName;
  Result := InputQuery(
    IfThen(AParentId > 0, '新增二级科目', '新增一级科目'), '名称:', s);
  if Result then
  begin
    AName := Trim(s);
    Result := AName <> '';
  end;
end;

procedure TfrmCategory.btnAddMainClick(Sender: TObject);
var
  catName: string;
begin
  catName := '';
  if InputCategory(catName) then
  begin
    dmData.ExecSQL(Format(
      'INSERT INTO categories (parent_id, name, sort_order) VALUES (0, ''%s'', 0)',
      [StringReplace(catName, '''', '''''', [rfReplaceAll])]));
    LoadTree;
  end;
end;

procedure TfrmCategory.btnAddSubClick(Sender: TObject);
var
  pid: Integer;
  catName: string;
begin
  if tvCategory.Selected = nil then
  begin
    ShowMessage('请先选择一个一级科目');
    Exit;
  end;
  pid := PtrInt(tvCategory.Selected.Data);
  catName := '';
  if InputCategory(catName, pid) then
  begin
    dmData.ExecSQL(Format(
      'INSERT INTO categories (parent_id, name, sort_order) VALUES (%d, ''%s'', 0)',
      [pid, StringReplace(catName, '''', '''''', [rfReplaceAll])]));
    LoadSubCategories(pid);
  end;
end;

procedure TfrmCategory.btnEditClick(Sender: TObject);
var
  id: Integer;
  catName: string;
begin
  id := GetSelectedCatId;
  if id < 0 then begin ShowMessage('请先选择一条记录'); Exit; end;
  catName := dmData.qryAux.FieldByName('name').AsString;
  if InputQuery('编辑分类', '名称:', catName) then
  begin
    dmData.ExecSQL(Format(
      'UPDATE categories SET name = ''%s'' WHERE id = %d',
      [StringReplace(Trim(catName), '''', '''''', [rfReplaceAll]), id]));
    LoadTree;
  end;
end;

procedure TfrmCategory.btnDeleteClick(Sender: TObject);
var
  id: Integer;
begin
  id := GetSelectedCatId;
  if id < 0 then begin ShowMessage('请先选择一条记录'); Exit; end;
  if MessageDlg('确认', '确定要删除该分类吗？', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    dmData.ExecSQL('DELETE FROM categories WHERE id = ' + IntToStr(id));
    LoadTree;
  end;
end;

procedure TfrmCategory.tvCategorySelectionChanged(Sender: TObject);
begin
  if tvCategory.Selected <> nil then
    LoadSubCategories(PtrInt(tvCategory.Selected.Data));
end;

end.
