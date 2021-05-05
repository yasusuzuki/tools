Sub use_f2()
SendKeys "{F2}"
End Sub


Sub auto_open()
Application.OnKey "{F1}", "use_f2"
End Sub

Sub ShowFilePath()
  Dim filename As String, ans As String
  filename = Replace(ActiveWorkbook.FullName, "\\yxee1761\miraishare\MiraiShare\", "F:\")
  ans = InputBox("ファイル名", "ファイル名", filename)

End Sub

Sub フィルタ列を特定()
    Dim i As Long, msg As String, column_letter As String
    With ActiveSheet
        If .AutoFilterMode = True Then
            For i = 1 To .AutoFilter.Filters.Count
                If .AutoFilter.Filters(i).On = True Then
                    column_letter = Split(Cells(1, i).Address, "$")(1)
                    msg = msg & column_letter & "列(" & i & "列目)" & vbCrLf
                End If
            Next i
        End If
    End With
    MsgBox msg
End Sub
