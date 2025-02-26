
# Add-RemoteGroupMember.ps1

## SYNOPSIS
Skrypt do zdalnego tworzenia lokalnego użytkownika, ustawienia mu hasła i dodania do wskazanej grupy.

## SYNTAX

```
Add-RemoteGroupMember.ps1 [-LocalUser] <String> [-LocalGroup] <String> [<CommonParameters>]
```

## DESCRIPTION
Skrypt pobiera nazwy komputerów z pliku C:\Temp\Target.txt, na każdym z tych komputerów próbuje utworzyć użytkownika ustawić mu hasło i dodać do wskazanej grupy.
Hasło w skrypcie trzeba wstawić w formie zaszyfrowanego ciągu znaków, można go wygenerować za pomocą skryptu [Get-SREncryptPass.ps1](https://gitlab.com/powershell1990849/get-srencryptpass). 
Nazwy komputerów na których wystąpiły jakieś błędy (komputer offline, hasło nie spełnia polityki, użytkownik już istnieje), są zapisywane do pliku w lokalizacji C:\Temp\Target.txt,
plik ten jest nadpisywany i wykorzystywany w kolejnym przebiegu skryptu.

Plik Target.txt możemy utworzyć za pomocą polecenia: Get-ADComputer -SearchBase "Ścieżka do OU z komputerami" -Filter * -Properties * | Select-Object -ExpandProperty name | Set-Content -Path C:\Temp\Target.txt

Wymagania: Na komputerch docelowych musi być włączona usługa 'Windows Remote Management (WinRM) ' i otwarte porty 5985, 5986 dla ruchu przychodzącego.
(Najwygodniej rozpropagować za pomocą GPO)

## EXAMPLES

### EXAMPLE 1
```
Add-RemoteGroupMember.ps1 -LocalUser TestUser -LocalGroup administrators
```

## PARAMETERS

### -LocalUser
Nazwa użytkownika.
Parametr wymagany.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LocalGroup
Nazwa grupy.
Parametr wymagany.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

 Plik C:\Temp\Target.txt.
## OUTPUTS

 Plik C:\Temp\Target.txt.
## NOTES
Version:        1.1

Author:         Sebastian Cichonski

Creation Date:  1.2024

Projecturi:     https://

## RELATED LINKS
