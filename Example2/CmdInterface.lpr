program CmdInterface;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, Windows;

type
  TOutputThread = class(TThread)
  protected
    procedure Execute; override;
  end;

var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  SecurityAttr: TSecurityAttributes;
  StdInRead, StdInWrite, StdOutRead, StdOutWrite: THandle;
  OutputThread: TOutputThread;
  Input: string;
  BytesRead: DWORD;
procedure TOutputThread.Execute;
var
  Buffer: array[0..255] of Char;
  BytesRead: DWORD;
begin
  while not Terminated do
  begin
    if ReadFile(StdOutRead, Buffer, SizeOf(Buffer), BytesRead, nil) then
    begin
      Buffer[BytesRead] := #0;
      Write(Buffer);
    end;
  end;
end;

begin
  SecurityAttr.nLength := SizeOf(TSecurityAttributes);
  SecurityAttr.bInheritHandle := True;
  SecurityAttr.lpSecurityDescriptor := nil;

  if not CreatePipe(StdInRead, StdInWrite, @SecurityAttr, 0) then
    Exit;

  if not CreatePipe(StdOutRead, StdOutWrite, @SecurityAttr, 0) then
    Exit;

  FillChar(StartupInfo, SizeOf(TStartupInfo), 0);
  StartupInfo.cb := SizeOf(TStartupInfo);
  StartupInfo.dwFlags := STARTF_USESTDHANDLES;
  StartupInfo.hStdInput := StdInRead;
  StartupInfo.hStdOutput := StdOutWrite;
  StartupInfo.hStdError := StdOutWrite;

  if not CreateProcess(nil, 'cmd.exe', nil, nil, True, 0, nil, nil, StartupInfo, ProcessInfo) then
    Exit;

  OutputThread := TOutputThread.Create(False);

  repeat
    ReadLn(Input);
    Input := Input + #13#10;
    WriteFile(StdInWrite, PChar(Input)^, Length(Input), BytesRead, nil);
  until Input = 'exit' + #13#10;

  OutputThread.Terminate;
  OutputThread.WaitFor;
  OutputThread.Free;

  CloseHandle(ProcessInfo.hProcess);
  CloseHandle(ProcessInfo.hThread);
  CloseHandle(StdInRead);
  CloseHandle(StdInWrite);
  CloseHandle(StdOutRead);
  CloseHandle(StdOutWrite);
end.

