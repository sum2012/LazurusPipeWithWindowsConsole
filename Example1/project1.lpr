//https://zzzcode.ai/code-generator?id=b0e5dc0f-2568-42c9-9d5b-dfe3b6a6e6ee
program project1;
//program PipeConsole
{$mode objfpc}{$H+}

uses
  Classes, SysUtils, Windows;

//const
//  PIPE_READ = 0;
//  PIPE_WRITE = 1;

var
  ReadPipe, WritePipe: THandle;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  Buffer: array[0..255] of AnsiChar;
  BytesRead: DWORD;
  PipeSecurity: TSecurityAttributes;
  InputString: AnsiString;

begin
  // Set up security attributes for the pipes
  PipeSecurity.nLength := SizeOf(TSecurityAttributes);
  PipeSecurity.bInheritHandle := True;
  PipeSecurity.lpSecurityDescriptor := nil;

  // Create the pipes
  if not CreatePipe(ReadPipe, WritePipe, @PipeSecurity, 0) then
  begin
    WriteLn('Error creating pipe');
    Exit;
  end;

  // Set up the startup info for the child process
  FillChar(StartupInfo, SizeOf(TStartupInfo), 0);
  StartupInfo.cb := SizeOf(TStartupInfo);
  StartupInfo.dwFlags := STARTF_USESTDHANDLES;
  StartupInfo.hStdInput := ReadPipe;
  StartupInfo.hStdOutput := GetStdHandle(STD_OUTPUT_HANDLE);
  StartupInfo.hStdError := GetStdHandle(STD_ERROR_HANDLE);

  // Create the child process
  if not CreateProcess(nil, 'cmd.exe', nil, nil, True, 0, nil, nil, StartupInfo, ProcessInfo) then
  begin
    WriteLn('Error creating process');
    Exit;
  end;

  // Close the unused end of the pipe
  CloseHandle(ReadPipe);

  // Read input from the user and write it to the pipe
  repeat
    Write('Enter input: ');
    ReadLn(InputString);
    InputString := InputString + #13#10;
    WriteFile(WritePipe, InputString[1], Length(InputString), BytesRead, nil);
  until InputString = 'exit'#13#10;

  // Close the write end of the pipe
  CloseHandle(WritePipe);

  // Wait for the child process to exit
  WaitForSingleObject(ProcessInfo.hProcess, INFINITE);

  // Close the process and thread handles
  CloseHandle(ProcessInfo.hProcess);
  CloseHandle(ProcessInfo.hThread);
end.
