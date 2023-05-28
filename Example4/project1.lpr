program project1;
//Make from https://www.perplexity.ai/search/3d2199fe-d837-4071-b9fe-4770d3ae0152?s=u
{$mode objfpc}{$H+}

uses
  Classes, SysUtils, Process;

type
  TOutputThread = class(TThread)
  private
    FProcess: TProcess;
  protected
    procedure Execute; override;
  public
    constructor Create(AProcess: TProcess);
  end;

constructor TOutputThread.Create(AProcess: TProcess);
begin
  FProcess := AProcess;
  FreeOnTerminate := True;
  inherited Create(False);
end;

procedure TOutputThread.Execute;
var
  Buffer: array[0..1023] of Char;
  ReadCount: Integer;
begin
  while not Terminated do
  begin
    FillChar(Buffer, SizeOf(Buffer), 0);
    ReadCount := FProcess.Output.Read(Buffer, SizeOf(Buffer));
    if ReadCount > 0 then
      Write(Buffer);
  end;
end;

var
  CmdProcess: TProcess;
  OutputThread: TOutputThread;
  InputLine: String;
begin
  CmdProcess := TProcess.Create(nil);
  try
    CmdProcess.Executable := 'cmd.exe';
    CmdProcess.Options := [poUsePipes, poStderrToOutPut];
    CmdProcess.ShowWindow := swoHIDE;
    CmdProcess.Execute;

    OutputThread := TOutputThread.Create(CmdProcess);

    repeat
      Readln(InputLine);
      Writeln('You input ' + InputLine);
      CmdProcess.Input.Write(InputLine[1], Length(InputLine));
      CmdProcess.Input.Write(LineEnding, Length(LineEnding));
    until InputLine = 'exit';

    OutputThread.Terminate;
    CmdProcess.CloseInput;
    OutputThread.WaitFor;
  finally
    CmdProcess.Free;
  end;
end.

