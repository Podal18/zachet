unit Edit;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons;

type

  { TfEdit }

  TfEdit = class(TForm)
    bSave: TBitBtn;
    BitBtn2: TBitBtn;
    eName1: TEdit;
    eName2: TEdit;
    eName3: TEdit;
    eTelephone: TEdit;
    eName: TEdit;
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  fEdit: TfEdit;

implementation

{$R *.lfm}

{ TfEdit }

procedure TfEdit.FormShow(Sender: TObject);
begin
  eName.SetFocus;
end;

end.

