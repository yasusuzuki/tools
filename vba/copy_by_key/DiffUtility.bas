'
' Diffユーティリティの使い方
'　Debug.print Diff(Range("H12").Value, Range("H13").Value)
'
' https://stackoverflow.com/questions/47335747/cell-by-cell-diff-in-excel

Sub TestDiff()
'H12 H13
  Debug.Print Diff(Range("H12").Value, Range("H13").Value)
End Sub

Function LCSLength(C() As Integer, X() As String, Y() As String, M As Integer, N As Integer) As Integer

    Dim I As Integer
    For I = 0 To M
        C(I, LBound(Y)) = 0
    Next

    Dim J As Integer
    For J = 0 To N
        C(LBound(X), J) = 0
    Next

    For I = 1 To M
        For J = 1 To N
            If X(I) = Y(J) Then
                C(I, J) = C(I - 1, J - 1) + 1
            ElseIf C(I, J - 1) < C(I - 1, J) Then
                C(I, J) = C(I - 1, J)
            Else
                C(I, J) = C(I, J - 1)
            End If
        Next
    Next

    LCSLength = C(M, N)

End Function

Function PrintDiff(C() As Integer, X() As String, Y() As String, I As Integer, J As Integer) As String

    Continue = 1

    If Continue = 1 And I > 0 And J > 0 Then
        If X(I) = Y(J) Then
            'PrintDiff = PrintDiff(C, X, Y, I - 1, J - 1) & Chr(10) & "<> " & X(I)
            Continue = 0
        End If
    End If

    If Continue = 1 And J > 0 Then
        If I = 0 Then
            PrintDiff = PrintDiff(C, X, Y, I, J - 1) & Chr(10) & ">   " & Y(J)
            Continue = 0
        ElseIf C(I, J - 1) >= C(I - 1, J) Then
            PrintDiff = PrintDiff(C, X, Y, I, J - 1) & Chr(10) & ">   " & Y(J)
            Continue = 0
        End If
    End If

    If Continue = 1 And I > 0 Then
        If J = 0 Then
            PrintDiff = PrintDiff(C, X, Y, I - 1, J) & Chr(10) & "<   " & X(I)
            Continue = 0
        ElseIf C(I, J - 1) < C(I - 1, J) Then
            PrintDiff = PrintDiff(C, X, Y, I - 1, J) & Chr(10) & "<   " & X(I)
            Continue = 0
        End If
    End If

    If Continue = 1 Then
        PrintDiff = ""
    End If

End Function

Function Diff(A As String, B As String) As String

    Dim X() As String
    X = Split(Chr(10) & A, Chr(10))

    Dim M As Integer
    If (A = "") Then
        M = 0
    Else
        M = UBound(X)
    End If

    Dim Y() As String
    Y = Split(Chr(10) & B, Chr(10))

    Dim N As Integer
    If (B = "") Then
        N = 0
    Else
        N = UBound(Y)
    End If

    Dim C() As Integer
    ReDim C(M, N) As Integer

    Call LCSLength(C, X, Y, M, N)
    Diff = Mid(PrintDiff(C, X, Y, M, N), 2)

End Function



