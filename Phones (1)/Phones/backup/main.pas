unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Buttons,
  Grids, Edit;

type
  Contacts = record
    Date: string[10];
    Client: string[30];
    Name: string[40];
    Proizvod: string[20];
    Tip: string[15];
  end; // record

type

  { TfMain }

  TfMain = class(TForm)
    Panel1: TPanel;
    bAdd: TSpeedButton;
    bEdit: TSpeedButton;
    bDel: TSpeedButton;
    bSort: TSpeedButton;
    SG: TStringGrid;
    procedure bAddClick(Sender: TObject);
    procedure bDelClick(Sender: TObject);
    procedure bEditClick(Sender: TObject);
    procedure bSortClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  fMain: TfMain;
  adres: string; //адрес, откуда запущена программа


implementation

{$R *.lfm}

{ TfMain }

procedure TfMain.bAddClick(Sender: TObject);
begin
  //очищаем поля, если там что-то есть:
  fEdit.eDate.Text:= '';
  fEdit.eClient.Text:= '';
  fEdit.eName.Text:= '';
  fEdit.eProizvod.Text:= '';
  fEdit.eTip.Text:= '';
  //устанавливаем ModalResult редактора в mrNone:
  fEdit.ModalResult:= mrNone;
  //теперь выводим форму:
  fEdit.ShowModal;
  //если пользователь ничего не ввел - выходим:
  if (fEdit.eDate.Text= '') or (fEdit.eClient.Text= '') then exit;
  //если пользователь не нажал "Сохранить" - выходим:
  if fEdit.ModalResult <> mrOk then exit;
  //иначе добавляем в сетку строку, и заполняем её:
  SG.RowCount:= SG.RowCount + 1;
  SG.Cells[0, SG.RowCount-1]:= fEdit.eDate.Text;
  SG.Cells[1, SG.RowCount-1]:= fEdit.eClient.Text;
  SG.Cells[2, SG.RowCount-1]:= fEdit.eName.Text;
  SG.Cells[3, SG.RowCount-1]:= fEdit.eProizvod.Text;
  SG.Cells[4, SG.RowCount-1]:= fEdit.eTip.Text;
end;

procedure TfMain.bDelClick(Sender: TObject);
begin
  //если данных нет - выходим:
  if SG.RowCount = 1 then exit;
  //иначе выводим запрос на подтверждение:
  if MessageDlg('Требуется подтверждение',
                'Вы действительно хотите удалить контакт "' +
                SG.Cells[0, SG.Row] + '"?',
    mtConfirmation, [mbYes, mbNo, mbIgnore], 0) = mrYes then
      SG.DeleteRow(SG.Row);
end;

procedure TfMain.bEditClick(Sender: TObject);
begin
  //если данных в сетке нет - просто выходим:
  if SG.RowCount = 1 then exit;
  //иначе записываем данные в форму редактора:
  fEdit.eDate.Text:= SG.Cells[0, SG.Row];
  fEdit.eClient.Text:= SG.Cells[1, SG.Row];
  fEdit.eName.Text:= SG.Cells[2, SG.Row];
  fEdit.eProizvod.Text:= SG.Cells[3, SG.Row];
  fEdit.eTip.Text:= SG.Cells[4, SG.Row];
  //устанавливаем ModalResult редактора в mrNone:
  fEdit.ModalResult:= mrNone;
  //теперь выводим форму:
  fEdit.ShowModal;
  //сохраняем в сетку возможные изменения,
  //если пользователь нажал "Сохранить":
  if fEdit.ModalResult = mrOk then begin
    SG.Cells[0, SG.Row]:= fEdit.eDate.Text;
    SG.Cells[1, SG.Row]:= fEdit.eClient.Text;
    SG.Cells[2, SG.Row]:= fEdit.eName.Text;
    SG.Cells[3, SG.Row]:= fEdit.eClient.Text;
    SG.Cells[4, SG.Row]:= fEdit.eTip.Text;
  end;
end;

procedure TfMain.bSortClick(Sender: TObject);
begin
  //если данных в сетке нет - просто выходим:
  if SG.RowCount = 1 then exit;
  //иначе сортируем список:
  SG.SortColRow(true, 0);
end;

procedure TfMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  MyCont: Contacts; //для очередной записи
  f: file of Contacts; //файл данных
  i: integer; //счетчик цикла
begin
  //если строки данных пусты, просто выходим:
  if SG.RowCount = 1 then exit;
  //иначе открываем файл для записи:
  try
    AssignFile(f, adres + 'out.txt');
    Rewrite(f);
    //теперь цикл - от первой до последней записи сетки:
    for i:= 1 to SG.RowCount-1 do begin
      //получаем данные текущей записи:
      MyCont.Date:= SG.Cells[0, i];
      MyCont.Name:= SG.Cells[2, i];
      MyCont.Proizvod:= SG.Cells[3, i];
      MyCont.Tip:= SG.Cells[4, i];
      //записываем их:
      Write(f, MyCont);
    end;
  finally
    CloseFile(f);
  end;
end;

procedure TfMain.FormCreate(Sender: TObject);
var
  MyCont: Contacts; //для очередной записи
  f: file of Contacts; //файл данных
  i: integer; //счетчик цикла
begin
  //сначала получим адрес программы:
  adres:= ExtractFilePath(ParamStr(0));
  //настроим сетку:
  SG.Cells[0, 0]:= 'Имя';
  SG.Cells[1, 0]:= 'Телефон';
  SG.Cells[2, 0]:= 'Примечание';
  SG.ColWidths[0]:= 365;
  SG.ColWidths[1]:= 150;
  SG.ColWidths[2]:= 150;
  //если файла данных нет, просто выходим:
  if not FileExists(adres + 'out.txt') then exit;
  //иначе файл есть, открываем его для чтения и
  //считываем данные в сетку:
  try
    AssignFile(f, adres + 'out.txt');
    Reset(f);
    //теперь цикл - от первой до последней записи сетки:
    while not Eof(f) do begin
      //считываем новую запись:
      Read(f, MyCont);
      //добавляем в сетку новую строку, и заполняем её:
      SG.RowCount:= SG.RowCount + 1;
      MyCont.Date:= SG.Cells[0, i];
      MyCont.Name:= SG.Cells[2, i];
      MyCont.Proizvod:= SG.Cells[3, i];
      MyCont.Tip:= SG.Cells[4, i];
    end;
  finally
    CloseFile(f);
  end;
end;

end.

