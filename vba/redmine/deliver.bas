Option Explicit


    
Sub 受渡の渡リストqueryFromServer()
    Dim offset_records As Long, has_next_page As Boolean
    
    Debug.Print "REDMINEサーバから最新情報を取得します　開始時刻は" & Format(Now, "yyyy-mm-dd hh:mm:ss")
    Application.ScreenUpdating = False
    Application.Calculation = xlCalculationManual
    
    Worksheets("受渡の渡").Select
    Call deactivateAutoFilter
    offset_records = 0
    Do
        has_next_page = 受渡の渡リストqueryOffsetFromServer(offset_records)
        offset_records = offset_records + PAGE_LIMIT
    Loop While has_next_page
    
    Application.ScreenUpdating = True
    Application.Calculation = xlCalculationAutomatic
    Debug.Print "完了。　終了時刻は" & Format(Now, "yyyy-mm-dd hh:mm:ss")

End Sub

Sub 受渡の渡リストsyncToServer()
    Dim row As Long, maxRow As Long
    Worksheets("受渡の渡").Select
    Application.ScreenUpdating = False
    Application.Calculation = xlCalculationManual

    maxRow = Cells(Rows.Count, 1).End(xlUp).row
    
    Debug.Print "REDMINEサーバへ更新します。最終行は" & maxRow & "。　開始時刻は" & Format(Now, "yyyy-mm-dd hh:mm:ss")
    
    For row = 3 To maxRow
        If Cells(row, 1).EntireRow.Hidden = False Then
            Debug.Print "＞＞更新開始　 " & row & "行目"
            Call 受渡の渡syncToServer(row)
        End If
    Next
    
    Application.ScreenUpdating = True
    Application.Calculation = xlCalculationAutomatic
    Debug.Print "完了。　終了時刻は" & Format(Now, "yyyy-mm-dd hh:mm:ss")
End Sub

Sub 受渡の渡リストinsertPrefillURL()
    Dim row As Long, maxRow As Long, i As Long
    Worksheets("受渡の渡").Select
    maxRow = Cells(Rows.Count, 1).End(xlUp).row
    
    Application.ScreenUpdating = False
    Application.Calculation = xlCalculationManual
    
    Debug.Print "最終行は" & maxRow
   
    For row = 3 To maxRow
        If Cells(row, 1).EntireRow.Hidden = False Then
            Call 受渡の渡insertPrefillURL(row)
            Debug.Print "process " & row
        End If
    Next
    Application.ScreenUpdating = True
    Application.Calculation = xlCalculationAutomatic
    
End Sub

Function 受渡の渡リストqueryOffsetFromServer(offset_records As Long) As Boolean
    Dim total_count As Variant
    Dim xml As Object, issues As Object
    Dim query_param As String, url As String
    
    query_param = "utf8=?&set_filter=1&"
    query_param = query_param + "limit=" & PAGE_LIMIT & "&offset=" & offset_records & "&" 'ページネーション
    query_param = query_param + "project_id=13&"  'トッププロジェクト
    query_param = query_param + "tracker_id=9&"   'トラッカーは受渡
    query_param = query_param + "cf_283=" & WorksheetFunction.EncodeURL("契約管理周辺２期第１") & "&" '出し側BOX名は周辺Box
    '※cf_282 出し側BOX名_IDを検索文字列にしてみたが絞り込みされなかった。cf_282は使用してはいけない。
    
    Set xml = GetXmlData(REDMINE_URL & "/issues.xml?key=" & Range("RESTAPI_KEY") & "&" & query_param)
    
    Set issues = xml.getElementsByTagName("issue")
    
    Dim i As Long, row As Long
    Dim issue As Object, issueId As String, cf As Object, cfs As Object
    
    For i = 1 To issues.Length
        Set issue = issues.Item(i - 1)
        issueId = issue.getElementsByTagName("id")(0).FirstChild().Data
        row = offset_records + i + 2
        
        Call setField(row, "#", issueId)
        ActiveSheet.Hyperlinks.Add Cells(row, 1), REDMINE_URL & "/issues/" & issueId
        Call setField(row, "subject", issue.getElementsByTagName("subject")(0).FirstChild().Data)
        Call setField(row, "status", issue.getElementsByTagName("status").Item(0).getAttribute("name"))
        Call setField(row, "updated_on", issue.getElementsByTagName("updated_on")(0).FirstChild().Data)
        Set cfs = issue.getElementsByTagName("custom_field")
        For Each cf In cfs
            If cf.getAttribute("id") = "285" Then
                Call setCustomFieldAsCode(row, cf.getAttribute("id"), cf.Text, "工程")
            ElseIf cf.getAttribute("id") = "415" Or cf.getAttribute("id") = "416" Or cf.getAttribute("id") = "1147" Then
                Call setCustomFieldAsCode(row, cf.getAttribute("id"), cf.Text, "担当")
            Else
                Call setCustomField(row, cf.getAttribute("id"), cf.Text)
            End If
        Next cf
        'Excelの当該行の最終更新日時を設定する
        getCell(row, "L_DATETIME_ON_LAST_SYNC") = Format(Now, "yyyy/mm/dd hh:mm:ss")
    Next
    
    total_count = xml.getAttribute("total_count")
    
    'まだ抽出するチケットが残っていたら、TRUEを返却
    If (offset_records + PAGE_LIMIT < total_count) Then
        受渡の渡リストqueryOffsetFromServer = True
    Else
        受渡の渡リストqueryOffsetFromServer = False
    End If
End Function

Sub 受渡の渡syncToServer(row As Long)
    Dim body As String
    
    Worksheets("受渡の渡").Select
    
    body = "<?xml version=" & Chr(34) & "1.0" & Chr(34) & "?>"
    body = body & "<issue>"
    body = body & buildXMLCustomFieldAsDate(row, "291")   '提供予定日
    body = body & buildXMLCustomFieldAsDate(row, "292")   '提供実績日
    
    body = body & "<custom_fields type=""array"">"
    '出し側担当IDである416はコードに変換するのは当然だが、サーバ上のデータ設定傾向から
    '出し側担当名である279もコードに変換して送信する必要がある
    body = body & buildXMLCustomFieldAsCode(row, "416", "担当", getCell(row, "cf_416"))
    body = body & buildXMLCustomFieldAsCode(row, "284", "担当", getCell(row, "cf_416"))
    '出し側副担当IDである1147はコードに変換するのは当然だが、サーバ上のデータ設定傾向から
    '出し側副担当名である1146もコードに変換して送信する必要がある
    body = body & buildXMLCustomFieldAsCode(row, "1147", "担当", getCell(row, "cf_1147"))
    body = body & buildXMLCustomFieldAsCode(row, "1146", "担当", getCell(row, "cf_1147"))
    
    body = body & buildXMLCustomField(row, "1003")   '出し側フリー項目１(種類)
    body = body & buildXMLCustomField(row, "1004")   '出し側フリー項目２(対象)
    
    body = body & "</custom_fields>"
    body = body & "</issue>"
    
    Call putXMLOverREST(REDMINE_URL & "issues/" & CStr(Cells(row, 1)) & ".xml?key=" & Range("RESTAPI_KEY"), body)
    
End Sub


Sub 受渡の渡insertPrefillURL(row As Long)
    Dim issueId As Long, url As String
    Worksheets("受渡の渡").Select
    
    issueId = Cells(row, 1).value
    Debug.Print "＞＞更新開始　 " & issueId & "  " & row & "行目"
    
    url = REDMINE_URL & "issues/" & CStr(issueId) & "/edit?"

    url = url & buildURLCustomFieldAsDate(row, "291")  '提供希望日
    url = url & buildURLCustomFieldAsDate(row, "292")  '提供実績日
    url = url & buildURLCustomFieldAsCode(row, "416", "担当")  '出し側担当
    url = url & buildURLCustomFieldAsCode(row, "1147", "担当")  '出し側担当
    url = url & buildURLCustomField(row, "1003")  '出し側フリー項目１(種類)
    url = url & buildURLCustomField(row, "1004")  '出し側フリー項目２(対象)
    Debug.Print url
    
    Dim cell As Range
    Set cell = getCell(row, "L_PREFILL_URL")
    cell.value = url
    'TODO 理想は、HyperlinkとしてURLをセルにセットしたいが、2000バイトあたりを超えるURLはExcelがエラーになってしまう。どう対処すべきか。。
End Sub
