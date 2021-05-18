Option Explicit



Sub 受渡の受リストsyncFromServer()
    Dim row As Long, maxRow As Long
    Worksheets("受渡の受").Select
    'Call deactivateAutoFilter
    maxRow = Cells(Rows.Count, 1).End(xlUp).row
    
    Debug.Print "REDMINEサーバから最新情報を取得します。最終行は" & maxRow & "。　開始時刻は" & Format(Now, "yyyy-mm-dd hh:mm:ss")
    For row = 3 To maxRow
        If Cells(row, 1).EntireRow.Hidden = False Then
        Debug.Print "＞＞同期開始 " & row & "行目"
        Call 受渡の受syncFromServer(row)
        End If
    Next
    Debug.Print "完了。　終了時刻は" & Format(Now, "yyyy-mm-dd hh:mm:ss")
End Sub

Sub 受渡の受リストsyncToServer()
    Dim row As Long, maxRow As Long
    Worksheets("受渡の受").Select
    Application.ScreenUpdating = False
    Application.Calculation = xlCalculationManual

    maxRow = Cells(Rows.Count, 1).End(xlUp).row
    
    Debug.Print "REDMINEサーバへ更新します。最終行は" & maxRow & "。　開始時刻は" & Format(Now, "yyyy-mm-dd hh:mm:ss")
    
    For row = 3 To maxRow
        If Cells(row, 1).EntireRow.Hidden = False Then
            Debug.Print "＞＞更新開始　 " & row & "行目"
            Call 受渡の受syncToServer(row)
        End If
    Next
    
    Application.ScreenUpdating = True
    Application.Calculation = xlCalculationAutomatic
    Debug.Print "完了。　終了時刻は" & Format(Now, "yyyy-mm-dd hh:mm:ss")
End Sub

Sub 受渡の受リストinsertPrefillURL()
    Dim row As Long, maxRow As Long, i As Long
    Worksheets("受渡の受").Select
    maxRow = Cells(Rows.Count, 1).End(xlUp).row
    
    Application.ScreenUpdating = False
    Application.Calculation = xlCalculationManual
    
    Debug.Print "最終行は" & maxRow
   
    For row = 3 To maxRow
        If Cells(row, 1).EntireRow.Hidden = False Then
            Call 受渡の受insertPrefillURL(row)
            Debug.Print "process " & row
        End If
    Next
    Application.ScreenUpdating = True
    Application.Calculation = xlCalculationAutomatic
    
End Sub




Sub 受渡の受syncFromServer(row As Long)
    Dim issue As Object, cfs As Object, cf As Object
    Worksheets("受渡の受").Select
    Debug.Print "【１】" & Format(Now, "yyyy-mm-dd hh:mm:ss")
    Set issue = GetXmlData(REDMINE_URL & "issues/" & CStr(Cells(row, 1)) & ".xml?key=" & Range("RESTAPI_KEY"))
    Debug.Print "【２】" & Format(Now, "yyyy-mm-dd hh:mm:ss")
    
    ActiveSheet.Hyperlinks.Add Cells(row, 1), REDMINE_URL & "/issues/" & Cells(row, 1)
    Call setField(row, "subject", issue.getElementsByTagName("subject").Item(0).Text)
    Call setField(row, "updated_on", issue.getElementsByTagName("updated_on").Item(0).Text)
    Call setField(row, "status", issue.getElementsByTagName("status").Item(0).getAttribute("name"))
    Set cfs = issue.getElementsByTagName("custom_field")
    For Each cf In cfs
        If cf.getAttribute("id") = "285" Then
            Call setCustomFieldAsCode(row, cf.getAttribute("id"), cf.Text, "工程")
        ElseIf cf.getAttribute("id") = "415" Or cf.getAttribute("id") = "416" Or cf.getAttribute("id") = "1145" Then
            Call setCustomFieldAsCode(row, cf.getAttribute("id"), cf.Text, "担当")
        Else
            Call setCustomField(row, cf.getAttribute("id"), cf.Text)
        End If
    Next cf
    Debug.Print "【３】" & Format(Now, "yyyy-mm-dd hh:mm:ss")
    'Excelの当該行の最終更新日時を設定する
    getCell(row, "L_DATETIME_ON_LAST_SYNC") = Format(Now, "yyyy/mm/dd hh:mm:ss")
End Sub

Sub 受渡の受syncToServer(row As Long)
    Dim body As String
    
    Worksheets("受渡の受").Select
    
    body = "<?xml version=" & Chr(34) & "1.0" & Chr(34) & "?>"
    body = body & "<issue>"
    body = body & buildXMLField(row, "subject")    '題名
    body = body & "<custom_fields type=""array"">"
    body = body & buildXMLCustomFieldAsDate(row, "290")    '確認予定日
    body = body & buildXMLCustomFieldAsDate(row, "293")    '確認実績日
    
    '出し側サブPJT IDと名前
    '名称項目である281の列から値を取得して、コードに変換して、コード項目である280として設定したい
    body = body & buildXMLCustomFieldAsCode(row, "280", "組織", getCell(row, "cf_281"))
    body = body & buildXMLCustomField(row, "281")
    '出し側BOX IDと名前
    body = body & buildXMLCustomFieldAsCode(row, "282", "組織", getCell(row, "cf_283"))
    body = body & buildXMLCustomField(row, "283")
    
    body = body & buildXMLCustomFieldAsDate(row, "289")    '提供希望日
    
    '受け側担当IDである415はコードに変換するのは当然だが、サーバ上のデータ設定傾向から
    '受け側担当名である279もコードに変換して送信する必要がある
    body = body & buildXMLCustomFieldAsCode(row, "415", "担当", getCell(row, "cf_415"))
    body = body & buildXMLCustomFieldAsCode(row, "279", "担当", getCell(row, "cf_415"))
    '受け側担当IDである1145はコードに変換するのは当然だが、サーバ上のデータ設定傾向から
    '受け側担当名である1144もコードに変換して送信する必要がある
    body = body & buildXMLCustomFieldAsCode(row, "1145", "担当", getCell(row, "cf_1145"))
    body = body & buildXMLCustomFieldAsCode(row, "1144", "担当", getCell(row, "cf_1145"))
    
    body = body & buildXMLCustomFieldAsCode(row, "285", "工程")    '該当局面
    body = body & buildXMLCustomField(row, "1001")    '受け側フリー項目１(種類)
    body = body & buildXMLCustomField(row, "1002")    '受け側フリー項目２(対象)
    body = body & buildXMLCustomField(row, "287")    '受渡詳細
    
    body = body & "</custom_fields>"
    body = body & "</issue>"

    Call putXMLOverREST(REDMINE_URL & "issues/" & CStr(Cells(row, 1)) & ".xml?key=" & Range("RESTAPI_KEY"), body)
    
End Sub


Sub 受渡の受insertPrefillURL(row As Long)
    Dim issueId As Long, url As String
    Worksheets("受渡の受").Select
    
    issueId = Cells(row, 1).value
    Debug.Print "＞＞更新開始　 " & issueId & "  " & row & "行目"
    
    url = REDMINE_URL & "issues/" & CStr(issueId) & "/edit?"

    url = url & buildURLField(row, "subject")    '題名
    url = url & buildURLCustomFieldAsDate(row, "290")    '確認予定日
    url = url & buildURLCustomFieldAsDate(row, "293")    '確認実績日
    url = url & buildURLCustomField(row, "281")  '出し側サブPJT名
    url = url & buildURLCustomField(row, "283")  '出し側BOX名
    url = url & buildURLCustomFieldAsCode(row, "415", "担当")  '受け側担当ID
    url = url & buildURLCustomFieldAsCode(row, "1145", "担当")  '受け側担当ID
    url = url & buildURLCustomFieldAsDate(row, "289")  '提供希望日
    url = url & buildURLCustomFieldAsCode(row, "285", "工程")  '該当局面
    url = url & buildURLCustomField(row, "1001")  '受け側フリー項目１(種類)
    url = url & buildURLCustomField(row, "1002")  '受け側フリー項目２(対象)
    url = url & buildURLCustomField(row, "287")  '受渡詳細
    Debug.Print url

    Dim cell As Range
    Set cell = getCell(row, "L_PREFILL_URL")
    cell.value = url
    'TODO 理想は、HyperlinkとしてURLをセルにセットしたいが、2000バイトあたりを超えるURLはExcelがエラーになってしまう。どう対処すべきか。。
End Sub
