unit UDateTimePickerHelper;

interface
uses
  SysUtils, DateUtils, ExtCtrls, Vcl.ComCtrls;

type
  TDateTimePickerHelper = class
  private
    FDateTimePicker: TDateTimePicker;
    FTimer: TTimer;
    procedure onTimer(Sender: TObject);
  public
    constructor Create(const ADATETIMEPICKER: TDateTimePicker);
    destructor Destroy;
    procedure startDecreasingTime;
    procedure stopDecreasingTime;
  end;


implementation

{ TDateTimePickerHelper }

constructor TDateTimePickerHelper.Create(const ADATETIMEPICKER: TDateTimePicker);
begin
  Self.FDateTimePicker := ADATETIMEPICKER;
  Self.FTimer := TTimer.Create(nil);
  Self.FTimer.Enabled := False;
  Self.FTimer.Interval := 1000; // Intervalo de 1 segundo
  Self.FTimer.onTimer := Self.onTimer;
end;

destructor TDateTimePickerHelper.Destroy;
begin
  FreeAndNil(Self.FTimer);
end;

procedure TDateTimePickerHelper.onTimer(Sender: TObject);
begin
  if (Self.FDateTimePicker.Time <> StrToTime('00:00:00')) then
    Self.FDateTimePicker.DateTime := IncSecond(Self.FDateTimePicker.DateTime, -1);
end;

procedure TDateTimePickerHelper.startDecreasingTime;
begin
  Self.FTimer.Enabled := True;
end;

procedure TDateTimePickerHelper.stopDecreasingTime;
begin
  Self.FTimer.Enabled := False;
end;

end.
