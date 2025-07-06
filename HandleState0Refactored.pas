procedure TfMain.HandleState0(i: Integer);
begin
  if IsResetButtonEnabled(i) then
    Exit;

  if IsPowerAboveThreshold(i) then
  begin
    Inc(NumVal[i]);
    SavePowerValue(i, NumVal[i], valW[i]);
    if IsConsecutiveValidReadings(i) then
      StartTest(i);
  end
  else
    ResetValidReadingCounter(i);
end;

// --- Вспомогательные процедуры ---

function TfMain.IsResetButtonEnabled(i: Integer): Boolean;
begin
  Result := TJvXPButton(FindComponent('BtnRes_' + IntToStr(i))).Enabled;
end;

function TfMain.IsPowerAboveThreshold(i: Integer): Boolean;
begin
  Result := valW[i] >= UstW;
end;

procedure TfMain.SavePowerValue(i, idx, value: Integer);
begin
  arrW[i, idx - 1] := value;
end;

function TfMain.IsConsecutiveValidReadings(i: Integer): Boolean;
const
  ConsecutiveValid = 3;
begin
  Result := NumVal[i] = ConsecutiveValid;
end;

procedure TfMain.StartTest(i: Integer);
begin
  edKod[i].Enabled := True;
  edKod[i].Color := clYellow;
  edKod[i].SetFocus;
  lModel[i].Enabled := True;
  BtnState[i].Glyph.LoadFromFile(MyDir + 'Img\Green.bmp');
  pCycl[i].Caption := '0';
  StatePos[i] := 1;
  flOnCmp[i] := True;
  Inc(numOnCmp[i]);
  Data[i].tmStart := Now;
  Data[i].bgnTokr := Tokr;
  flWork1[i] := True;
  tmOnWork1[i] := Data[i].tmStart;
  TmrPerW[i].Enabled := True;
  NumVal[i] := 0;
end;

procedure TfMain.ResetValidReadingCounter(i: Integer);
begin
  NumVal[i] := 0;
end;