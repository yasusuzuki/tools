
Sub CopyFrom稼働疎通Toサブ間()
  Debug.Print "開始"
  
  Set sheet_from = Workbooks("aa.xls").Worksheets("aa")
  Set sheet_to = Workbooks("bb.xlsx").Worksheets("bb")
  
  'コピー元とコピー先の列を定義する。コピー元とコピー先は同じ列が前提
  '★カスタマイズ箇所：　現時点でコピーしたい列は以下のとおり
  Dim copy_column_list As Variant
  copy_column_list = Array("C", "D", "E", "F", "G", "H", "AS", "AT", "AU", "AV", "AW", "AX", "AY")
      
      
  Open "C:\tmp\vba_log.txt" For Append As #1
  Dim debug_counter As Integer
  
  'コピー元の検索キーの範囲を設定する
  '★カスタマイズ箇所：　コピー元シートのセルB9から最終行までをキーとする
  Dim iteration As Range
  Set from_end_key = sheet_from.Cells(sheet_from.Rows.Count, "B").End(xlUp)
  Set iteration = sheet_from.Range("B9", from_end_key)
  
  Dim orig_key_cell As Range
  For Each orig_key_cell In iteration
    Debug.Print orig_key_cell.Address
    Print #1, " ----"
    Print #1, "FROM(key cell):" & orig_key_cell.Address & "@[" & orig_key_cell.Parent.Parent.Name & "]"
    
    '検索キーをコピー先で一致するように変換する。
    '★カスタマイズ箇所：　現時点では、KKSS10ITB1234　→　KKSS00ITB1234のように変換する
    lookup_key = Left(orig_key_cell.Value, 4) & "00" & Right(orig_key_cell.Value, 7)
    Print #1, "KEY :" & lookup_key
    
    '検索キーが属する行の指定の範囲をコピーする
    Dim orig_copy_range As Range, orig_copy_col As Variant
    Set orig_copy_range = sheet_from.Cells(orig_key_cell.Row, copy_column_list(0))
    For Each orig_copy_col In copy_column_list
        Set orig_copy_range = Union(orig_copy_range, sheet_from.Cells(orig_key_cell.Row, orig_copy_col))
    Next orig_copy_col
    

    With sheet_to
        'コピー先シートでキーに該当するセルが存在するか検索して確認する
        Set dest_key_cell = .Cells.Find(What:=lookup_key, After:=ActiveCell, LookIn:=xlValues _
            , LookAt:=xlPart, SearchOrder:=xlByRows, SearchDirection:=xlNext, _
            MatchCase:=False, MatchByte:=False, SearchFormat:=False)
        
        'コピー先シートでキーに該当するセルが存在すれば、その行にコピーする。
        '行単位で一括コピーするほうが高速だが、コピー元が飛び地の範囲指定している場合にそなえて、セルを１つ１つコピーする
        If Not dest_key_cell Is Nothing Then
            Dim dest_copy_cell As Range, orig_copy_cell As Range
            Print #1, "TO  (key cell):" & dest_key_cell.Address & "@[" & dest_key_cell.Parent.Parent.Name & "]"
            For Each orig_copy_cell In orig_copy_range
            
                'コピー元で指定した列と同じ列にコピーする（ただし、コピー先の行はコピー元のものと異なる）
                Set dest_copy_cell = .Cells(dest_key_cell.Row, orig_copy_cell.Column)
                'DEBUG時は、以下のコードと入れ替えることで、いったん、別列にコピーすることもできる
                'Set dest_copy_cell = .Cells(dest_key_cell.Row, orig_copy_cell.Column).Offset(0, 55)

                'ログファイルに処理詳細を出力する
                Print #1, "Copy from:" & orig_copy_cell.Address & " to:  " & dest_copy_cell.Address
                Dim diff_string As String
                'セル間のテキストの差分をとる。書式の差異などは抽出できないので注意
                diff_string = Diff(orig_copy_cell.Value, dest_copy_cell.Value)
                If diff_string <> "" Then
                    Print #1, "DIFF " & vbCrLf & diff_string
                End If
                
                'DIFFの有無に関係なくコピーする。書式のみの差分も反映したいため。
                '性能が問題になるようであれば、↓のコードを↑のIF文の中にいれて、書式の差分反映を犠牲にして性能改善することもできる
                '*** DEBUGでは↓ここをコメントする *******
                'orig_copy_cell.Copy Destination:=dest_copy_cell
            
            Next orig_copy_cell
        Else
            Print #1, "!!!!! key not found in TO"
        End If
        
    End With
    'debug_counter = debug_counter + 1
    'If debug_counter > 5 Then
    '    Exit For
    'End If
  Next orig_key_cell
  

  Close #1
  Debug.Print "完了"
  
End Sub
