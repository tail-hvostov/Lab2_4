Program Lab2_4;
Uses
    System.SysUtils;
Type
    IntArr = Array Of Integer;
    IOPreference = (UseFile, UseStdIO);
Const
    ANS_MAX = 2;
    ANS_MIN = -1;
    MIN_LENGTH = -1;
    MAX_LENGTH = 6001;
    MAX_NUM = 200000000;
    MIN_NUM = -200000000;
    FAULT_VALUE = -1;

Function GoodInteger(MinLimit, MaxLimit, Num : Integer) : Boolean;
Begin
    GoodInteger := ((Num > MinLimit) And (Num < MaxLimit));
End;

//Blame переводится как порицание.
Function GoodIntegerWithBlame(MinLimit, MaxLimit, Num : Integer) : Boolean;
Var
    //Virtue переводится как хорошее качество.
    Virtue : Boolean;
Begin
    Virtue := GoodInteger(MinLimit, MaxLimit, Num);
    If Not Virtue Then
        WriteLn('Your input does not satisfy the requirements!!');
    GoodIntegerWithBlame := Virtue;
End;

//Nail переводится как "забрать".
Function NailInteger(MinLimit, MaxLimit : Integer; Mes : String) : Integer;
Var
    //Virtue переводится как хорошее качество.
    IsCyclical, ErrorFlag, Virtue : Boolean;
    Num : Integer;
Begin
    IsCyclical := True;
    ErrorFlag := False;
    Num := 0;
    While IsCyclical Do
    Begin
        WriteLn(Mes);
        Try
            ReadLn(Num);
        Except
            ErrorFlag := True;
            WriteLn('Cannot read a number...');
        End;
        If Not ErrorFlag Then
        Begin
            Virtue := GoodInteger(MinLimit, MaxLimit, Num);
            If Virtue Then
                IsCyclical := False
            Else
                WriteLn('Enter valid data!');
        End;
        ErrorFlag := False;
    End;
    NailInteger := Num;
End;

//Nail переводится как "забрать".
Function NailString(Mes : String) : String;
Var Return : String;
Begin
    WriteLn(Mes);
    ReadLn(Return);
    NailString := Return;
End;

//Nail переводится как "забрать".
Function NailUserIOPreference() : IOPreference;
Var
    Response : Integer;
Begin
    NailUserIOPreference := IOPreference.UseFile;
    Response := NailInteger(ANS_MIN, ANS_MAX, 'Select the mode of interface(0 - File, 1 - StdIO):');
    If Response = 1 Then
        NailUserIOPreference := IOPreference.UseStdIO;
End;

Procedure checkEOLn(Var Input : TextFile; Var SuccessFlag : Boolean);
Begin
    If SuccessFlag And Eoln(Input) Then
    Begin
        WriteLn('Bad input!');
        SuccessFlag := False;
    End;
End;

Procedure PrepareFileForReading(Var TargetFile : TextFile; Var SuccessFlag, IsOpen : Boolean);
Var
    Path : String;
Begin
    Path := NailString('Enter a path:');
    If Copy(Path, (High(Path) - 3), 4) <> '.txt' Then
    Begin
        SuccessFlag := False;
        WriteLn('You are only allowed to use .txt!!');
    End;
    If SuccessFlag And (Not FileExists(Path)) Then
    Begin
        SuccessFlag := False;
        WriteLn('This file does not exist!!');
    End;
    If SuccessFlag Then
    Begin
        AssignFile(TargetFile, Path);
        Reset(TargetFile);
        IsOpen := True;
    End;
End;

Procedure PrepareFileForWriting(Var TargetFile : TextFile; Var SuccessFlag, IsOpen : Boolean);
Var
    Path : String;
Begin
    Path := NailString('Enter a path:');
    If Copy(Path, (High(Path) - 3), 4) <> '.txt' Then
    Begin
        SuccessFlag := False;
        WriteLn('You are only allowed to use .txt!!');
    End;
    If SuccessFlag Then
    Begin
        AssignFile(TargetFile, Path);
        Try
            Rewrite(TargetFile);
        Except
            WriteLn('Writing is impossible!!');
            SuccessFlag := False;
        End;
    End;
    If SuccessFlag Then
        IsOpen := True;
End;

Procedure ReadInt(Var SuccessFlag : Boolean; Var Input : TextFile; Var Num : Integer; MinLimit, MaxLimit : Integer);
Begin
    checkEOLn(Input, SuccessFlag);
    If SuccessFlag Then
    Begin
        Try
            Read(Input, Num);
        Except
            SuccessFlag := False;
            WriteLn('Cannot read a number...');
        End;
    End;
    If SuccessFlag Then
        SuccessFlag := GoodIntegerWithBlame(MinLimit, MaxLimit, Num);
End;

Procedure StdInput(Var Sequence : IntArr; Var Amount1, Amount2 : Integer);
Var
    ActualAmount, FirstLast, I : Integer;
Begin
    Amount1 := NailInteger(MIN_LENGTH, MAX_LENGTH, 'Enter the length of the first sequence(range: -1 to 6001): ');
    Amount2 := NailInteger(MIN_LENGTH, MAX_LENGTH, 'Enter the length of the second sequence(range: -1 to 6001): ');
    ActualAmount := Amount1 + Amount2;
    If ActualAmount > 0 Then
    Begin
        SetLength(Sequence, ActualAmount);
        FirstLast := Amount1 - 1;
        For I := 0 To FirstLast Do
            Sequence[I] := NailInteger(MIN_NUM, MAX_NUM, 'Enter an element of the first sequence(range: -200000000 to 200000000): ');
        For I := Amount1 To High(Sequence) Do
            Sequence[I] := NailInteger(MIN_NUM, MAX_NUM, 'Enter an element of the second sequence(range: -200000000 to 200000000): ');
    End;
End;

Procedure NextLine(Var SuccessFlag : Boolean; Var TargetFile : TextFile);
Begin
    If SuccessFlag And Not Eof(TargetFile) Then
        ReadLn(TargetFile)
    Else
        SuccessFlag := False;
End;

Procedure FileInput(Var Sequence : IntArr; Var Amount1, Amount2 : Integer);
Var
    IsCyclical, SuccessFlag, IsOpen : Boolean;
    Input : TextFile;
    I, ActualAmount : Integer;
Begin
    IsCyclical := True;
    While IsCyclical Do
    Begin
        IsOpen := False;
        SuccessFlag := True;
        PrepareFileForReading(Input, SuccessFlag, IsOpen);
        ReadInt(SuccessFlag, Input, Amount1, MIN_LENGTH, MAX_LENGTH);
        //ReadInt безопасен для использования без проверки на SuccessFlag
        ReadInt(SuccessFlag, Input, Amount2, MIN_LENGTH, MAX_LENGTH);
        If SuccessFlag Then
        Begin
            ActualAmount := Amount1 + Amount2;
            //Я сделал эту проверку,чтобы избежать приколов в NextLine.
            If ActualAmount > 0 Then
            Begin
                NextLine(SuccessFlag, Input);
                SetLength(Sequence, ActualAmount);
                I := 0;
                While SuccessFlag And (I < ActualAmount) Do
                Begin
                    ReadInt(SuccessFlag, Input, Sequence[I], MIN_NUM, MAX_NUM);
                    I := I + 1;
                End;
            End;
        End;
        If SuccessFlag Then
            IsCyclical := False;
        If IsOpen Then
            CloseFile(Input);
    End;
End;

Procedure LoadData(Var Sequence : IntArr; Var Amount1, Amount2 : Integer);
Var
    Preference : IOPreference;
Begin
    Preference := NailUserIOPreference();
    If (Preference = IOPreference.UseStdIO) Then
        StdInput(Sequence, Amount1, Amount2)
    Else
    Begin
        WriteLn('------------------File scheme------------------');
        WriteLn('1. Lengths of the sequences(0-6000).');
        WriteLn('2. All values, belonging to the both sequences.');
        FileInput(Sequence, Amount1, Amount2);
    End;
End;

Procedure CopySeq(Var ResSeq : IntArr; Const SrcSeq : IntArr);
Begin
    SetLength(ResSeq, Length(SrcSeq));
    ResSeq := SrcSeq;
End;

Function FindDelta(Index, Val : Integer; Const Sequence : IntArr) : Integer;
Begin
    FindDelta := Sequence[Index] - Val;
End;

Function SearchIndex(Const Sequence : IntArr; Elem : Integer) : Integer;
Var
    //DeltaBeg - разность между первым элементом отрезка и новым элементом.
    //В нормальных условиях - число отрицательное.
    //DeltaEnd - разность между последним элементом отрезка и новым элементом.
    //В нормальных условиях - число положительное.
    //DeltaMid - разность между средним элементом отрезка и новым элементом.
    StartIndex, StopIndex, MiddleIndex, DeltaBeg, DeltaEnd, DeltaMid : Integer;
    //ContinueFlag используется для упрощения будущей блок-схемы.
    ContinueFlag : Boolean;
Begin
    ContinueFlag := True;
    StartIndex := 0;
    DeltaBeg := FindDelta(StartIndex, Elem, Sequence);
    //Следующие 2 проверки нужны для исключения случаев, когда введённое значение
    //больше(меньше) последнего(первого) значения, записанного в Sequence.
    If DeltaBeg > 0 Then
    Begin
        SearchIndex := 0;
        ContinueFlag := False;
    End;
    If ContinueFlag Then
    Begin
        StopIndex := High(Sequence);
        DeltaEnd := FindDelta(StopIndex, Elem, Sequence);
        If (DeltaEnd < 0) Then
        Begin
            SearchIndex := Length(Sequence);
            ContinueFlag := False;
        End;
    End;
    If ContinueFlag And ((DeltaEnd = 0) Or (DeltaBeg = 0)) Then
    Begin
        ContinueFlag := False;
        SearchIndex := FAULT_VALUE;
    End;
    If ContinueFlag Then
    Begin
        Repeat
            MiddleIndex := (StartIndex + StopIndex) Div 2;
            DeltaMid := FindDelta(MiddleIndex, Elem, Sequence);
            If DeltaMid < 0 Then
                StartIndex := MiddleIndex;
            If DeltaMid > 0 Then
                StopIndex := MiddleIndex;
        Until ((StopIndex - StartIndex > 1) Or (DeltaMid <> 0));
        If DeltaMid = 0 Then
            SearchIndex := FAULT_VALUE
        Else
            SearchIndex := StopIndex;
    End;
End;

Procedure PlaceElem(Var Sequence : IntArr; Elem, ResIndex : Integer);
Var
    //FirstShift - индекс самого первого элемента, который нужно сместить.
    //Значение равно индексу ПОСЛЕ смещения.
    FirstShift, I : Integer;
Begin
    FirstShift := ResIndex + 1;
    SetLength(Sequence, Length(Sequence) + 1);
    For I := High(Sequence) DownTo FirstShift Do
        Sequence[I] := Sequence[I - 1];
    Sequence[ResIndex] := Elem;
End;

Procedure ProcessElement(Elem : Integer; Var ResSequence : IntArr);
Var
    ResIndex : Integer;
Begin
    ResIndex := SearchIndex(ResSequence, Elem);
    If (ResIndex <> FAULT_VALUE) Then
        PlaceElem(ResSequence, Elem, ResIndex);
End;

Procedure Solve(Var ResSequence, Sequence : IntArr; Amount1, Amount2 : Integer);
Var
    ContinueFlag : Boolean;
    ElemAm, CurrentIndex : Integer;
Begin
    //Так я попытался импортозаместить return из C++.
    //Всё равно в блок-схеме это проще изобразить.
    ContinueFlag := True;
    If Length(Sequence) = 0 Then
        ContinueFlag := False;
    //Нет смысла включать основной цикл, если одна из последовательностей пустая.
    If ContinueFlag And ((Amount1 = 0) Or (Amount2 = 0)) Then
    Begin
        CopySeq(ResSequence, Sequence);
        ContinueFlag := False;
    End;
    //Реальная программа начинается здесь.
    If ContinueFlag Then
    Begin
        //Предыдущие проверки гарантируют,что сюда попадут только
        //случаи, когда в Sequence больше 1 элемента.
        ElemAm := 1;
        SetLength(ResSequence, ElemAm);
        ResSequence[0] := Sequence[0];
        CurrentIndex := 1;
        For CurrentIndex := CurrentIndex To High(Sequence) Do
            ProcessElement(Sequence[CurrentIndex], ResSequence);
    End;
End;

Procedure StdOutput(Const ResSequence : IntArr);
Var
    I : Integer;
Begin
    If Length(ResSequence) = 0 Then
        Write('No elements!')
    Else
    Begin
        For I := 0 To High(ResSequence) Do
            Write(ResSequence[I], ' ');
    End;
End;

Procedure FileOutput(Const ResSequence : IntArr);
Var
    I : Integer;
    IsCyclical, SuccessFlag, IsOpen : Boolean;
    OutputFile : TextFile;
Begin
    IsCyclical := True;
    While IsCyclical Do
    Begin
        SuccessFlag := True;
        IsOpen := False;
        PrepareFileForWriting(OutputFile, SuccessFlag, IsOpen);
        If SuccessFlag Then
        Begin
            If Length(ResSequence) = 0 Then
                Write(OutputFile, 'No elements!')
            Else
            Begin
                For I := 0 To High(ResSequence) Do
                    Write(OutputFile, ResSequence[I], ' ');
            End;
            IsCyclical := False;
        End;
        If IsOpen Then
            CloseFile(OutputFile);
    End;

End;

Procedure UnloadData(Const ResSequence : IntArr);
Var
    Preference : IOPreference;
Begin
    Preference := NailUserIOPreference();
    If (Preference = IOPreference.UseStdIO) Then
        StdOutput(ResSequence)
    Else
        FileOutput(ResSequence);
End;

Var
    ResSequence, Sequence : IntArr;
    Amount1, Amount2 : Integer;
Begin
    WriteLn('This program generates a union of two sequences,', char(10), ' given by the user.');
    WriteLn('Loading data...');
    //Я посчитал, что нет смысла хранить последовательности отдельно.
    LoadData(Sequence, Amount1, Amount2);
    WriteLn('Solving the problem...');
    Solve(ResSequence, Sequence, Amount1, Amount2);
    WriteLn('Returning the result...');
    UnloadData(ResSequence);
    ReadLn;
End.
