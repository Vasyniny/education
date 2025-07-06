procedure TfMain.HandleState2(i: Integer);
var
  nPoint: Integer;
  stateBlockXK, stateBlockMK: Boolean;
begin
  EnsureCompressorOff(i);

  nPoint := definePoint(i);
  stateBlockXK := AreAllBlockParamsSet(i, nPoint, flBlockXK);
  stateBlockMK := AreAllBlockParamsSet(i, nPoint, flBlockMK);

  if NeedsManualBlockInput(i, stateBlockXK, stateBlockMK) then
  begin
    RequestManualBlockInput(i);
    Exit;
  end;

  EvaluateTestResults(i, nPoint, stateBlockXK);
end;

// --- Вспомогательные процедуры ---

procedure TfMain.EnsureCompressorOff(i: Integer);
begin
  if numOffCmp[i] = 0 then
  begin
    if valW[i] < UstW then
      Inc(numOff[i])
    else
      numOff[i] := 0;

    if numOff[i] = 3 then
    begin
      Inc(numOffCmp[i]);
      pCycl[i].Caption := IntToStr(numOffCmp[i] div 2);
      wCmp[i] := True;
      ttCmp[i] := True;
      Data[i].TimeOffCmp := Now;
      ImgNoOff[i].Visible := False;
    end;
  end;
end;

function TfMain.AreAllBlockParamsSet(i, nPoint: Integer; const BlockArr): Boolean;
var
  k: Integer;
begin
  Result := True;
  for k := 0 to nPoint - 1 do
    if not Boolean((@BlockArr)^[i, k]) then
      Exit(False);
end;

function TfMain.NeedsManualBlockInput(i: Integer; stateBlockXK, stateBlockMK: Boolean): Boolean;
begin
  Result :=
    ((chOffCmp[i]) and (not wCmp[i])) or
    ((chSuma[i]) and (not ttCmp[i])) or
    ((chBlockXK[i]) and (not stateBlockXK)) or
    ((chBlockMK[i]) and (not stateBlockMK)) or
    ((chTimeOn[i]) and (not tmOnWork[i])) or
    ((chTimeOff[i]) and (not tmOffWork[i]));
end;

procedure TfMain.RequestManualBlockInput(i: Integer);
var
  k: Integer;
begin
  if chBlockXK[i] and not AreAllBlockParamsSet(i, nCheckPoint[i]+1, flBlockXK) then
    for k := 0 to nCheckPoint[i] - 1 do
      if not flBlockXK[i, k] then
      begin
        edBlockXK[i].Enabled := True;
        edBlockXK[i].Color := clYellow;
        edBlockXK[i].SetFocus;
        MessageDlgPos('Необходимо ввести данные блока для ' + IntToStr(k + 1) + '-й контрольной точки!', mtWarning, [mbOK], 0, 0);
        Exit;
      end;
end;

procedure TfMain.EvaluateTestResults(i, nPoint: Integer; stateBlockXK: Boolean);
begin
  dm.checkTime.Locate('pos;point', VarArrayOf([i, nCheckPoint[i]]), []);
  if not dm.checkTime['tpCheck'] then
  begin
    ResultIsp(i, nPointBlock[i], True);
    if ResIsp[i] then
    begin
      BtnState[i].Glyph.LoadFromFile(MyDir + 'Img\Blue.bmp');
      Data[i].TimeAllIsp := trunc(DateDiff(mi, Data[i].tmStart, Now));
      StatePos[i] := 3;
    end
    else
    begin
      BtnState[i].Glyph.LoadFromFile(MyDir + 'Img\Green.bmp');
      StatePos[i] := 1;
      Data[i].TimeAllIsp := 0;
    end;
  end
  else
  begin
    ResultIsp(i, nCheckPoint[i], False);
    if ResIsp[i] then
      BtnState[i].Glyph.LoadFromFile(MyDir + 'Img\Ok.bmp')
    else
      BtnState[i].Glyph.LoadFromFile(MyDir + 'Img\brak.bmp');
    StatePos[i] := 3;
    ShowBlockResults(i, nPointBlock[i]);
  end;
end;

procedure TfMain.ShowBlockResults(i, nCount: Integer);
var
  k: Integer;
begin
  if chBlockXK[i] and (nCount > 0) then
  begin
    sgBlockXK[i].Visible := True;
    edBlockXK[i].Enabled := False;
    edBlockXK[i].Color := clWindow;
    for k := 0 to nCount - 1 do
      if ResBlockXK[i, k] then
        sgBlockXK[i].Cells[k + 1, 1] := 'OK'
      else
        sgBlockXK[i].Cells[k + 1, 1] := 'BRAK';
  end;
  // Аналогично для MK, если требуется
end;