unit ULocalLibrary;

interface

type
  TLocalLibrary = class
  public
    class function SaveIniStringValue(const ANAMESECTION, ANAMEPROPERTY,
      AVALUE: string): Boolean;
    class function ReadIniStringValue(const ANAMESECTION,
      ANAMEPROPERTY: string): string;
  end;

implementation

uses System.SysUtils, Vcl.Forms, IniFiles;

{ TLocalLibrary }

class function TLocalLibrary.ReadIniStringValue(const ANAMESECTION,
  ANAMEPROPERTY: string): string;

var
  _IniFile: TIniFile;
begin
  _IniFile := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'Configuration.ini');
  Result := _IniFile.ReadString(ANAMESECTION, ANAMEPROPERTY,
    'Erro ao ler o valor');
  _IniFile.Free;
end;

class function TLocalLibrary.SaveIniStringValue(const ANAMESECTION,
  ANAMEPROPERTY, AVALUE: string): Boolean;
var
  _IniFile: TIniFile;
begin
  try
    _IniFile := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'Configuration.ini');
    _IniFile.WriteString(ANAMESECTION, ANAMEPROPERTY, AVALUE);
    _IniFile.Free;
    Result := True;
  except
    on E: Exception do
      Result := False;
  end;
end;

end.
