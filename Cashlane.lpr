program Cashlane;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Interfaces,
  Forms,
  uMain,
  uData,
  uExpenseEntry,
  uContacts,
  uCategory,
  uReport,
  uImport;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TdmData, dmData);
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmExpenseEntry, frmExpenseEntry);
  Application.CreateForm(TfrmContacts, frmContacts);
  Application.CreateForm(TfrmCategory, frmCategory);
  Application.CreateForm(TfrmReport, frmReport);
  Application.CreateForm(TfrmImport, frmImport);
  Application.Run;
end.
