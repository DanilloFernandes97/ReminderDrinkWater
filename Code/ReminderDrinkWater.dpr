program ReminderDrinkWater;

uses
  Vcl.Forms,
  UMainForm in 'UMainForm.pas' {frmMainForm},
  UDateTimePickerHelper in 'UDateTimePickerHelper.pas',
  ULocalLibrary in 'ULocalLibrary.pas';

{$R *.res}

begin
  Application.ShowMainForm := False;// Não mostra o form

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Lembrete para tomar água';
  Application.CreateForm(TfrmMainForm, frmMainForm);
  // Deixa o formulário no cantinho da tela.
  frmMainForm.Visible := False;
  frmMainForm.Left := Screen.Width - frmMainForm.Width;
  frmMainForm.Top := Screen.Height - frmMainForm.Height;

  Application.Run;
end.
