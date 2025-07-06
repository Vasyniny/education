procedure TfMain.HandleState1(i: Integer);
begin
  // 1. Проверка, загружены ли параметры модели ХП
  if not AreParamsLoaded(i) then
  begin
    TrackCompressorWithoutParams(i);
    Exit;
  end;

  // 2. Обработка контрольных точек
  ProcessCheckPoint(i);

  // 3. Общая логика включения/выключения компрессора и методов испытания
  TrackCompressorWithParams(i);

  // 4. Постоянно вызываемые процедуры
  DefinedOttaika(i);
  RaschetWch(i);

  // 5. Завершение теста — оставить здесь вашу логику, если потребуется
  // Example:
  // if IsTestTimeExceeded(i) then
  //   FinishTest(i);
end;

// Проверка загружены ли параметры
function TfMain.AreParamsLoaded(i: Integer): Boolean;
begin
  Result := flParams[i];
end;

// Обработка компрессора при незагруженных параметрах
procedure TfMain.TrackCompressorWithoutParams(i: Integer);
begin
  if IsPowerAboveThreshold(i) then
  begin
    Inc(NumVal[i]);
    if IsConsecutiveValidReadings(i) then
    begin
      if not flOnCmp[i] then
      begin
        Inc(numOnCmp[i]);
        SetCompressorState(i, True);
      end;
      NumVal[i] := 0;
    end;
  end
  else
  begin
    Inc(NumOff[i]);
    if IsConsecutiveInvalidReadings(i) then
    begin
      if flOnCmp[i] then
      begin
        Inc(numOffCmp[i]);
        SetCompressorState(i, False);
        UpdateCycleCaption(i);
      end;
      NumOff[i] := 0;
    end;
  end;
end;

// Проверка превышения мощности порога
function TfMain.IsPowerAboveThreshold(i: Integer): Boolean;
begin
  Result := valW[i] >= UstW;
end;

// Проверка достаточного числа последовательных валидных показаний
function TfMain.IsConsecutiveValidReadings(i: Integer): Boolean;
const
  ConsecutiveValid = 3;
begin
  Result := NumVal[i] >= ConsecutiveValid;
end;

// Проверка достаточного числа последовательных невалидных показаний
function TfMain.IsConsecutiveInvalidReadings(i: Integer): Boolean;
const
  ConsecutiveInvalid = 3;
begin
  Result := NumOff[i] >= ConsecutiveInvalid;
end;

// Включение/выключение компрессора и обновление индикатора
procedure TfMain.SetCompressorState(i: Integer; OnState: Boolean);
begin
  flOnCmp[i] := OnState;
  if OnState then
    BtnState[i].Glyph.LoadFromFile(MyDir + 'Img\Green.bmp')
  else
    BtnState[i].Glyph.LoadFromFile(MyDir + 'Img\Yellow.bmp');
end;

// Обновление счетчика циклов
procedure TfMain.UpdateCycleCaption(i: Integer);
begin
  pCycl[i].Caption := IntToStr(numOffCmp[i] div 2);
end;

// Логика работы компрессора при загруженных параметрах
procedure TfMain.TrackCompressorWithParams(i: Integer);
begin
  if not IsPowerAboveThreshold(i) then
    Inc(NumOff[i])
  else
    NumOff[i] := 0;

  if IsConsecutiveInvalidReadings(i) then
  begin
    if flOnCmp[i] then
    begin
      Inc(numOffCmp[i]);
      SetCompressorState(i, False);
      UpdateCycleCaption(i);

      if IsFirstCompressorOff(i) then
        HandleFirstCompressorOff(i);
    end;
  end
  else
  begin
    if IsPowerAboveThreshold(i) then
      Inc(NumVal[i])
    else
      NumVal[i] := 0;

    if IsConsecutiveValidReadings(i) then
    begin
      if not flOnCmp[i] then
      begin
        Inc(numOnCmp[i]);
        SetCompressorState(i, True);
      end;
      NumVal[i] := 0;
    end;
  end;
end;

// Проверка первого отключения компрессора
function TfMain.IsFirstCompressorOff(i: Integer): Boolean;
begin
  Result := numOffCmp[i] = 1;
end;

// Логика при первом отключении компрессора
procedure TfMain.HandleFirstCompressorOff(i: Integer);
begin
  Data[i].TimeOffCmp := Now;
  if chMetod[i] = 'End' then
  begin
    Data[i].ttW := Data[i].curW;
    Data[i].nChW := nChW[i];
    CheckParamWatt(i);
  end
  else
  begin
    if not flSavePar[i] then
    begin
      Data[i].endTokr := Tokr;
      SaveParamIsp(i);
      ParamIspInScreen(i);
      flSavePar[i] := True;
    end;
  end;
end;