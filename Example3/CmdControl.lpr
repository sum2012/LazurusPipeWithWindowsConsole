program ConsoleInput;
{$mode objfpc}{$H+}
uses
  Classes,SysUtils, Process;
var
  Input: string;
  Cmd: TProcess;
  Output: TStringList;


begin
  Input := '';
  Cmd := TProcess.Create(nil);
  Output := TStringList.Create;
  try
    WriteLn('Enter command or type "quit" to exit:');
    while True do
    begin
      Write('> ');
      ReadLn(Input);
      if LowerCase(Input) = 'quit' then
        Break;
      Cmd.Executable := 'cmd.exe';
      Cmd.Parameters.Clear;
      Cmd.Parameters.Add('/c');
      Cmd.Parameters.Add(Input);
      Cmd.Options := [poUsePipes];
      Cmd.Execute;
      Sleep(100);
     Output.LoadFromStream(Cmd.Output);
      Write(Output.Text);
     Cmd.WaitOnExit;
      if Cmd.ExitStatus <> 0 then
        WriteLn('Command failed with exit code ', Cmd.ExitStatus);
    end;
  finally
    Cmd.Free;
    Output.Free;
  end;
end.
