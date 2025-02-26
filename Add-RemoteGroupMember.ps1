<#
.SYNOPSIS
    Skrypt do zdalnego tworzenia lokalnego u¿ytkownika, ustawienie mu has³a i dodania do wskazanej grupy.

.DESCRIPTION
    Skrypt pobiera nazwy komputerów z pliku C:\Temp\Target.txt, na ka¿dym z tych komputerów próbuje utworzyæ u¿ytkownika ustawiæ mu has³o i dodaæ do wskazanej grupy.
    Has³o w skrypcie trzeba wstawiæ w formie zaszyfrowanego ci¹gu znaków, mo¿na go wygenerowaæ za pomoc¹ skryptu [Get-SREncryptPass.ps1] (https://gitlab.com/powershell1990849/get-srencryptpass). 
    Nazwy komputerów na których wyst¹pi³y jakieœ b³êdy (komputer offline, has³o nie spe³nia polityki, u¿ytkownik ju¿ istnieje), s¹ zapisywane do pliku w lokalizacji C:\Temp\Target.txt,
    plik ten jest nadpisywany i wykorzystywany w kolejnym przebiegu skryptu.

    Plik Target.txt mo¿emy utworzyæ za pomoc¹ polecenia: Get-ADComputer -SearchBase "Œcie¿ka do OU z komputerami" -Filter * -Properties * | Select-Object -ExpandProperty name | Set-Content -Path C:\Temp\Target.txt

    Wymagania: Na komputerch docelowych musi byæ w³¹czona us³uga 'Windows Remote Management (WinRM) ' i otwarte porty 5985, 5986 dla ruchu przychodz¹cego. (Najwygodniej rozpropagowaæ za pomoc¹ GPO)

.PARAMETER LocalUser
    Nazwa u¿ytkownika. Parametr wymagany.

.PARAMETER LocalGroup
    Nazwa grupy. Parametr wymagany.

.INPUTS
    Plik C:\Temp\Target.txt.

.OUTPUTS
    Plik C:\Temp\Target.txt.

.NOTES
    Version:        1.1
    Author:         Sebastian Cichonski
    Creation Date:  1.2024
    Projecturi:     https:/
  
.EXAMPLE
    Add-RemoteGroupMember.ps1 -LocalUser TestUser -LocalGroup administrators   
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory, Position=0)]
    [String] $LocalUser,

    [Parameter(Mandatory, Position=1)]
    [String] $LocalGroup
)

$EncryptedPass = "01000000d08c9ddf0115d1118c7a00c04fc297eb01000000625d34456177704697ebf56209759b940000000002000000000003660000c00000001000000068af91a2411cd2c196a99e7e5b26d23d0000000004800000a0000000100000003de923275a739c5f7272f7a28cd14a95200000005ea129eb4b0604a1b9857ece431a7a2a88ed8b36bbe5d490daf265a98aa20e3114000000281784975f44076bc9882c638acc816a232780f7"
$Pass = ConvertTo-SecureString -String $EncryptedPass 
$FilePath = "C:\Temp"
$File = "Target.txt"
$TargetPath = Join-Path -Path "$FilePath" -ChildPath "$File"

try {
    $Computers = Get-Content -Path $TargetPath -ErrorAction Stop
}
catch {
    Write-Host -ForegroundColor Red "[ERROR] Cannot find file $File in location: $FilePath" 
    return 
}


Get-Item -Path $TargetPath -ErrorAction SilentlyContinue | Remove-Item
New-Item -Path $FilePath -Name $File |Out-Null

$Computers | ForEach-Object -Process {
    $Computer = $_
    try {
        Invoke-Command -ComputerName $Computer -ScriptBlock {
            New-LocalUser -Name $using:LocalUser -AccountNeverExpires -PasswordNeverExpires -Password $using:Pass  -ErrorAction Stop | Out-Null
            Add-LocalGroupMember -Group $using:LocalGroup -Member $using:LocalUser -ErrorAction Stop
        } -ErrorAction Stop 
    }
    catch {
       
        Add-Content -Path $TargetPath -Encoding Ascii -Value "$Computer"
        Write-Verbose "[$Computer] > $_.Exception.Message"
    }
}
