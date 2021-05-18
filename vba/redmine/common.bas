Option Explicit

Public Const DEBUG_FLAG = False
Public Const REDMINE_URL = "http://aitpmtrmweb02/redmine/"

'100件づつチケットを取得。REDMINEで設定できる最大が100．
Public Const PAGE_LIMIT As Long = 60

Private Const TEST_XML As String = _
    "<?xml version=""1.0""?>" & _
    "<issues>" & _
        "<issue><id>100</id><updated_on>aa</updated_on><id>aa</id><subject>SUBJECT</subject><status id='aa' name='bb'><value>aa</value></status><custom_fields><custom_field id='291'><value>291</value></custom_field><custom_field id='276'><value>276</value></custom_field><custom_field id='278'><value>278</value></custom_field><custom_field id='289'><value>289</value></custom_field><custom_field id='415'><value>DUMMY1</value></custom_field><custom_field id='416'><value>DUMMY1</value></custom_field><custom_field id='285'><value>内部設計</value></custom_field><custom_field id='1003'><value>1003</value></custom_field><custom_field id='1004'><value>1004</value></custom_field></custom_fields></issue>" & _
        "<total_count>300</total_count>" & _
    "</issues>"

Public Sub deactivateAutoFilter()
  If ActiveSheet.FilterMode = True Then
    Debug.Print "フィルター設定済み。解除します。"
    ActiveSheet.ShowAllData
  Else
    Debug.Print "フィルター未設定"
  End If
End Sub

'*******************************************************************************************************
'   build系は、Excelに入力した情報をサーバへ更新する場合に使用する
'*******************************************************************************************************
Public Function buildXMLField(row As Long, field_name As String, Optional value As Variant) As String
  If IsMissing(value) Then
    value = getCell(row, field_name)
  End If

  buildXMLField = "<" & field_name & ">" & EscapeHTML(value) & "</" & field_name & ">"
End Function

Public Function buildXMLCustomFieldAsCode(row As Long, field_name As String, range_name As String, Optional value As Variant) As String
  ' コード名称からコード値への変換を行う
  ' ２列構成で、１列目がコード名称、２列目がコード値を想定し、valで２列目を検索して、相対する１列目の名称を特定する。
  Dim code As String
  
  If IsMissing(value) Then
    value = getCell(row, "cf_" & field_name)
  End If
  
  If value <> "" Then
    code = lookupCodeFromName(range_name, value)
    buildXMLCustomFieldAsCode = "<custom_field id=""" & field_name & """><value>" & code & "</value></custom_field>"

  End If
 
End Function


Public Function buildXMLCustomFieldAsDate(row As Long, field_name As String, Optional value As Variant) As String
  If IsMissing(value) Then
    value = getCell(row, "cf_" & field_name)
  End If
  buildXMLCustomFieldAsDate = "<custom_field id=""" & field_name & """><value>" & Format(value, "yyyy-mm-dd") & "</value></custom_field>"
End Function

Public Function buildXMLCustomField(row As Long, field_name As String, Optional value As Variant) As String
  If IsMissing(value) Then
    value = getCell(row, "cf_" & field_name)
  End If
  buildXMLCustomField = "<custom_field id=""" & field_name & """><value>" & EscapeHTML(value) & "</value></custom_field>"
End Function


Public Function buildURLField(row As Long, field_name As String, Optional value As Variant) As String
  If IsMissing(value) Then
    value = getCell(row, field_name)
  End If
  buildURLField = "issue[" & field_name & "]=" & WorksheetFunction.EncodeURL(value) & "&"
End Function

Public Function buildURLCustomFieldAsCode(row As Long, field_name As String, range_name As String, Optional value As Variant) As String
  ' コード名称からコード値への変換を行う
  ' ２列構成で、１列目がコード名称、２列目がコード値を想定し、valで２列目を検索して、相対する１列目の名称を特定する。
  Dim code As String
  
  If IsMissing(value) Then
    value = getCell(row, "cf_" & field_name)
  End If
  
  If value <> "" Then
    code = lookupCodeFromName(range_name, value)
    buildURLCustomFieldAsCode = "issue[custom_field_values][" & field_name & "]=" & code & "&"

  End If
End Function

Public Function buildURLCustomFieldAsDate(row As Long, field_name As String, Optional value As Variant) As String
  If IsMissing(value) Then
    value = getCell(row, "cf_" & field_name)
  End If
  buildURLCustomFieldAsDate = "issue[custom_field_values][" & field_name & "]=" & Format(value, "yyyy-mm-dd") & "&"
End Function

Public Function buildURLCustomField(row As Long, field_name As String, Optional value As Variant) As String
  If IsMissing(value) Then
    value = getCell(row, "cf_" & field_name)
  End If
  value = WorksheetFunction.EncodeURL(value)
  buildURLCustomField = "issue[custom_field_values][" & field_name & "]=" & value & "&"
End Function



Public Function lookupCodeFromName(range_name As String, value As Variant) As String
  Dim code_row As Long
  Debug.Print " * コード値名称検索　... ";
  
  On Error GoTo ERROR_LABEL
  code_row = WorksheetFunction.Match(value, Range(range_name).Columns(1), 0)
  lookupCodeFromName = Range(range_name).Cells(code_row, 2)
  Debug.Print "成功  [変換後：" & lookupCodeFromName & "] [変換前：" & value & "] [コード区分:" & range_name & "]"

  Exit Function
    
ERROR_LABEL:
    MsgBox "エラー: 範囲[" & range_name & "]にコード[" & value & "]が見つかりません。定数シートを見直して再実行してください"
    End   'サーバに更新するコード値が見つからないので、処理を中止する
 
End Function
Public Function getCell(row As Long, field_name As String) As Range
  Dim col As Long
  col = locateColumnByFieldName(field_name)
  If (col >= 1) Then
    Set getCell = Cells(row, col)
  Else
    MsgBox "エラー: 項目コード[" & field_name & "]がシート[" & Range("$A$2:$Z$2").Parent.Name & "]のA2:Z2上に見つかりません"
    End   '項目コードが見つからないので、処理を中止する
  End If
  
End Function

Function EscapeHTML(Text As Variant) As String
  Dim s As String

  s = Replace(Text, "&", "&amp;", Compare:=vbBinaryCompare) ' ◆ 最初に&を置き換えること！
  s = Replace(s, "<", "&lt;", Compare:=vbBinaryCompare)
  s = Replace(s, ">", "&gt;", Compare:=vbBinaryCompare)
  s = Replace(s, """", "&quot;", Compare:=vbBinaryCompare)
  s = Replace(s, "'", "&#039;", Compare:=vbBinaryCompare) ' 必要ないと思うが念のため
'  s = Replace(s, " ", "&nbsp;", Compare:=vbBinaryCompare) ' 半角スペース
  EscapeHTML = s
End Function

'*******************************************************************************************************
'   set系は、サーバから取得した情報をExcelに設定する場合に使用する
'*******************************************************************************************************

Public Sub setField(row As Long, field_name As String, val As String)
  Dim col As Long
  On Error Resume Next
  col = locateColumnByFieldName(field_name)
  If col >= 1 Then
    Cells(row, col).value = val
    Debug.Print "[" & Cells(1, col) & "(" & field_name & ")：" & val & "] "
  End If
End Sub

Public Sub setCustomField(row As Long, field_name As String, val As String)
  Dim col As Long
  col = locateColumnByFieldName("cf_" & field_name)
  If col >= 1 Then
    Cells(row, col).value = val
    Debug.Print "[" & Cells(1, col) & "(" & field_name & ")：" & val & "] "
  End If
End Sub

Public Sub setCustomFieldAsCode(row As Long, field_name As String, val As String, range_name As String)
  ' コード値からコード名称への変換を行う
  ' ２列構成で、１列目がコード名称、２列目がコード値を想定し、valで２列目を検索して、相対する１列目の名称を特定する。
  Dim col As Long, code_name As String

  col = locateColumnByFieldName("cf_" & field_name)
  
  On Error GoTo ERROR_LABEL
  If col >= 1 And val <> "" Then
    Debug.Print " * コード名称検索　... ";
    code_name = lookupNameFromCode(range_name, CLng(val))
    Cells(row, col).value = code_name
    Debug.Print "[" & Cells(1, col) & "(" & field_name & ")：" & val & "] "
  End If
  
  Exit Sub
ERROR_LABEL:
    MsgBox "エラー: 範囲[" & range_name & "]にコード[" & val & "]が見つかりません。名称変換を省略します"

End Sub



Private Function lookupNameFromCode(range_name As String, code As Long) As String
  Dim code_row As Long
  Debug.Print " * コード値名称検索　... ";
  
  On Error GoTo ERROR_LABEL
  code_row = WorksheetFunction.Match(code, Range(range_name).Columns(2), 0)
  lookupNameFromCode = Range(range_name).Cells(code_row, 1)
  
  Debug.Print "成功  [変換後：" & lookupNameFromCode & "] [変換前：" & code & "] [コード区分:" & range_name & "]"

  Exit Function
  
ERROR_LABEL:
    MsgBox "エラー: 範囲[" & range_name & "]にコード[" & code & "]が見つかりません。定数シートを見直して再実行してください"
    End   'サーバに更新するコード値が見つからないので、処理を中止する
End Function



Private Function locateColumnByFieldName(field_name As String) As Long
  On Error GoTo ERROR_LABEL:
  locateColumnByFieldName = WorksheetFunction.Match(field_name, Range("$A$2:$Z$2"), 0)
  Exit Function
ERROR_LABEL:
  locateColumnByFieldName = -1
End Function

Function putXMLOverREST(url As String, xml As String)
    
    Debug.Print " * PUT XML OVER REST [URL] " & url
    Debug.Print " * PUT XML OVER REST [XML] " & xml
    
    If DEBUG_FLAG Then
        Exit Function
    End If
    
    Dim xmlHttp As New MSXML2.XMLHTTP60
    
    With xmlHttp
        .Open "PUT", url, False
        .SetRequestHeader "Content-Type", "text/xml"
        .Send xml
        If .Status <> 200 Then
            MsgBox "エラーが発生" & .Status & .statusText
        End If
        
        Debug.Print "HTTP STATUS :"; .Status & " " & .statusText
    End With
End Function

Public Function GetXmlData(url As String) As Object
    'XMLドキュメントを読み込むには、まず最初にDOMDocumentクラスのインスタンスを作成する
    'http://msdn.microsoft.com/ja-jp/library/aa468547.aspx
    Dim dom As Object
    Set dom = CreateObject("MSXML2.DOMDocument")
    
    'ドキュメントのAsyncプロパティをFalseに設定すると、ドキュメントが完全に読み込まれて
    '処理の準備が整うまで、パーサーはコードにコントロールを返しません。
    dom.async = False
    
    'エラー対策
    'http://support.microsoft.com/kb/281142/ja
    dom.setProperty "ServerHTTPRequest", True
 
    'MSXMLパーサーを使用すると、URLを介してXMLドキュメントを読み込むことができます。
    'ドキュメントを読み込むには､Loadメソッドを使用
    Dim ret As Boolean
    If DEBUG_FLAG Then
        ret = dom.LoadXML(TEST_XML)
    Else
        ret = dom.Load(url)
    End If
        
    If ret = False Then
        Dim Text As String
        With dom.parseError
            Text = "XML ドキュメントの読み込みに失敗しました。" & vbCrLf & _
                "次のエラーが原因です :" & vbCrLf & _
                vbCrLf & _
                "エラー番号 # : " & .ErrorCode & vbCrLf & _
                "エラー原因 # : " & .reason & vbCrLf & _
                "行 # : " & .Line & vbCrLf & _
                "行位置 : " & .linepos & vbCrLf & _
                "ファイル内の位置 : " & .filepos & vbCrLf & _
                "ソーステキスト : " & .srcText & vbCrLf & _
                "ドキュメントURL : " & .url
        End With
        MsgBox Text, vbExclamation
        
        'Err.Raise dom.parseError.ErrorCode
        End '強制終了
    End If
    
    Set GetXmlData = dom.ChildNodes.Item(1)
    Set dom = Nothing
End Function




Public Function URLDecode(StringToDecode As String) As String

Dim TempAns As String
Dim CurChr As Integer

CurChr = 1

Do Until CurChr - 1 = Len(StringToDecode)
  Select Case Mid(StringToDecode, CurChr, 1)
    Case "+"
      TempAns = TempAns & " "
    Case "%"
      TempAns = TempAns & Chr(val("&h" & _
         Mid(StringToDecode, CurChr + 1, 2)))
       CurChr = CurChr + 2
    Case Else
      TempAns = TempAns & Mid(StringToDecode, CurChr, 1)
  End Select

CurChr = CurChr + 1
Loop

URLDecode = TempAns
End Function
