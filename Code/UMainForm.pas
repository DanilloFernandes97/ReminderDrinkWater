unit UMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Buttons, Vcl.AppEvnts,
  Vcl.Imaging.jpeg, UDateTimePickerHelper;

type
  TfrmMainForm = class(TForm)
    DateTimePicker: TDateTimePicker;
    CheckBoxShowWaterAlert: TCheckBox;
    TrayIcon: TTrayIcon;
    ApplicationEvents: TApplicationEvents;
    Image: TImage;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure DateTimePickerExit(Sender: TObject);
    procedure DateTimePickerKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TrayIconClick(Sender: TObject);
    procedure ApplicationEventsMinimize(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    FTimerInterval: TTimer;
    FDateTimePickerHelper: TDateTimePickerHelper;
    procedure goTimer(Sender: TObject);
    function getMSecForDateTime: Cardinal;
    procedure prepareTimerInterval;
    procedure startForm;
    procedure configureRunOnStart;
  public
    { Public declarations }
  end;

var
  frmMainForm: TfrmMainForm;

implementation

uses System.DateUtils, System.StrUtils, System.Win.Registry, ULocalLibrary;

{$R *.dfm}
// Sobre como usar o TrayIcon e o AplicationEvents.
// https://www.devmedia.com.br/utilizando-o-componente-ttrayicon-no-delphi/25088

procedure TfrmMainForm.ApplicationEventsMinimize(Sender: TObject);
begin
  Self.Hide();
  Self.WindowState := wsMinimized;
  DateTimePickerExit(Sender);
end;

procedure TfrmMainForm.DateTimePickerExit(Sender: TObject);
begin
  if (DateTimePicker.Time <> StrToTime('00:00:00')) then
  begin
    Self.prepareTimerInterval;
    Self.FDateTimePickerHelper.startDecreasingTime;
  end;
end;

procedure TfrmMainForm.DateTimePickerKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Self.FDateTimePickerHelper.stopDecreasingTime;
  Self.FTimerInterval.Enabled := False;
end;

function TfrmMainForm.getMSecForDateTime: Cardinal;
var
  _Hour, _Min, _Sec, _MSec: Word;
  _ConvertMSec: Double;
begin
  DecodeTime(DateTimePicker.Time, _Hour, _Min, _Sec, _MSec);
  Result := _MSec + (_Sec * 1000) + (_Min * 60000) + (_Hour * 3600000);
end;

procedure TfrmMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  TLocalLibrary.SaveIniStringValue('CONFIG', 'Time',
    TimeToStr(DateTimePicker.Time));
end;

procedure TfrmMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if (Application.MessageBox('Tem certeza que você vai me fechar seu(sua) cavalo(a)?',
    '????', MB_YESNO + MB_DEFBUTTON2) = IDYES) then
  begin
    if (TimeToStr(DateTimePicker.Time) = '00:00:00') then
    begin
      if (Application.MessageBox
        ('Seu intervalo ta zerado, quer salvar com o valor de 30 minutos ao menos?',
        '????', MB_YESNO + MB_DEFBUTTON1) = IDYES) then
      begin
        DateTimePicker.Time := StrToTime('00:30:00');
      end;
    end;
    CanClose := True;
  end
  else
    CanClose := False;
end;

procedure TfrmMainForm.FormCreate(Sender: TObject);
var
  _Time: string;
begin
  Self.configureRunOnStart;

  _Time := TLocalLibrary.ReadIniStringValue('CONFIG', 'Time');
  _Time := ifThen(_Time = 'Erro ao ler o valor', '00:30:00', _Time);
  DateTimePicker.Time := StrToTime(_Time);

  Self.FTimerInterval := TTimer.Create(nil);
  Self.FDateTimePickerHelper := TDateTimePickerHelper.Create(DateTimePicker);

  Self.startForm;

  TrayIcon.Visible := True;
  TrayIcon.Animate := True;

  ApplicationEventsMinimize(Sender);
end;

procedure TfrmMainForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(Self.FTimerInterval);
  FreeAndNil(Self.FDateTimePickerHelper);
end;

procedure TfrmMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) then
    ApplicationEventsMinimize(Sender);
end;

procedure TfrmMainForm.goTimer(Sender: TObject);
begin
  if (CheckBoxShowWaterAlert.Checked) then
  begin
    TrayIcon.ShowBalloonHint;
    Self.FTimerInterval.Enabled := False;
  end;
end;

procedure TfrmMainForm.prepareTimerInterval;
begin
  Self.FTimerInterval.Interval := Self.getMSecForDateTime;
  Self.FTimerInterval.OnTimer := Self.goTimer;
  Self.FTimerInterval.Enabled := True;
end;

procedure TfrmMainForm.configureRunOnStart;
var
  _Registry: TRegistry;
begin
  // Configurar a entrada de inicialização no Registro do Windows
  _Registry := TRegistry.Create;
  try
    _Registry.RootKey := HKEY_CURRENT_USER;
    if (_Registry.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', True)) then
    begin
      _Registry.WriteString('ReminderDrinkWater', Application.ExeName);
      _Registry.CloseKey;
    end;
  finally
    FreeAndNil(_Registry);
  end;
end;

procedure TfrmMainForm.startForm;
begin
  Self.prepareTimerInterval;
  Self.FDateTimePickerHelper.startDecreasingTime;
end;

procedure TfrmMainForm.TrayIconClick(Sender: TObject);
begin
  Self.Show();
  WindowState := wsNormal;
  Application.BringToFront();
end;

end.
