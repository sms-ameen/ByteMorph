#############################################################################
# ByteMorph v1.0 @AΣΞΞΠ
#############################################################################
function getBaseToken($passwrd){
 $PSWD=$passwrd
 
 $hasher = [System.Security.Cryptography.HashAlgorithm]::Create('sha256')
 $hash = $hasher.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($PSWD))
 $hashString = [System.BitConverter]::ToString($hash)
 $PSWD=$hashString.Replace('-', '')
 
 $PSWD=[convert]::ToBase64String([System.Text.encoding]::UTF8.GetBytes($PSWD))
 $PSWD=[convert]::ToBase64String([System.Text.encoding]::UTF8.GetBytes($PSWD))
  
 $PSWD = $PSWD.ToCharArray() | select -Unique
 $PSWD = "$PSWD".Replace(" ","")
 $PSWD = "$PSWD".Replace("=","")
 $ONE  = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
 $TWO  = $ONE
 $THR  = $ONE.ToCharArray()

 for ($var = 0; $var -lt $PSWD.length; $var++) {
   $THR[$var] = $PSWD[$var]
   $SS = $PSWD[$var]
   $TWO = $TWO.Replace("$SS","")
  }
 
 $j=0
 for ($var = $var; $var -lt 62; $var++) {
   $THR[$var] = $TWO[$j]
   $j++
  }
 $THR = "$THR".Replace(" ","")

 return "$THR"
}

function Replace-BinaryChars {
    param(
        [string]$InputFile,
        [string]$OutputFile,
        [string]$SourceChars,
        [string]$DestChars
    )

	if (Test-Path $OutputFile) { Write-Host "   E: $OutputFile - dest file exist!" -ForegroundColor Red;exit 1 }

    $map = @{}
    $mapE = @{}
    for ($i = 0; $i -lt $SourceChars.Length; $i++) {
        $map[[byte][char]$SourceChars[$i]] = [byte][char]$DestChars[$i]
		}

    [byte[]]$bytes = [System.IO.File]::ReadAllBytes($InputFile)

	$mapE = ($bytes | ForEach-Object { if ($map.ContainsKey($_)) { $map[$_] } else { $_ } })

	[System.IO.File]::WriteAllBytes($OutputFile, ($mapE -ne $null ? $mapE : @()))
	#Write-Host "   I: $OutputFile - file eNcrypted!" -ForegroundColor Cyan
	Write-Host "   I: DoNe!" -ForegroundColor Cyan
}

Function mmssgg() {
	Write-Host ""
	Write-Host -ForegroundColor Cyan "*****************************************************"
	Write-Host -ForegroundColor Cyan " - Args: e/d file/folder"
	Write-Host -ForegroundColor Cyan "*****************************************************"
	Write-Host ""
}

function EAllFiles() {
	Write-Host " - Please enter Password to eNcrypt: " -ForegroundColor Blue -NoNewline
	$PSWD=Read-Host -AsSecureString
	$PSWD=[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($PSWD))
	$dst = getBaseToken($PSWD);

	Write-Host " - Please enter Password HINT: " -ForegroundColor Blue -NoNewline
	$sHINT=Read-Host
	if ($sHINT -match '[\\/:*?"<>|]') { Write-Host "   E: Hint should not contain any of \ / : * ? "" < > |" -ForegroundColor Red;exit 1 }
	if ($sHINT.Length -eq 0) { $sHINT="_" }
	else { $sHINT = "_"+$sHINT+"_"}

	$iDATE=date -Format yyyyMMdd_HHmmss
	$iDATE="_"+$iDATE
	$dDir=(Get-Item $sDir).Name
	$dDir=$dDir+$iDATE
	$dDir=(Get-Item $sDir).Parent.FullName+"\"+$dDir+"\"

	Get-ChildItem -Recurse -Force $sDir | where { ! $_.PSIsContainer } | foreach {
		$sPath=($_.Directory.FullName)
		$sFName=($_.FullName)
		$sBName=(Get-Item $_.FullName).BaseName
		$sMD=(Get-FileHash -Path $sFName -Algorithm MD5).Hash
		$sMD = $sHINT+$sMD
		
		$dFName=($_.Name).Replace($sBName,$sBName+$sMD)
		$dFName="$sPath\$dFName"
		$dFName=$dFName.Replace($sDir,$dDir)
		New-Item -ItemType Directory -Force -Path (Split-Path $dFName) | Out-Null

		Write-Host "   I: eNcrypting $sFName" -ForegroundColor Cyan
		Replace-BinaryChars -InputFile "$sFName" -OutputFile "$dFName" -SourceChars $src -DestChars $dst
		echo ""
		}
}

function DAllFiles() {
	Write-Host " - Please enter Password to dEcrypt: " -ForegroundColor Blue -NoNewline
	$PSWD=Read-Host -AsSecureString
	$PSWD=[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($PSWD))
	$dst = getBaseToken($PSWD);

	$dDir=(Get-Item $sDir).Parent.FullName+"\"+(Get-Item $sDir).Name+"_dEcrypt\"

	Get-ChildItem -Recurse -Force $sDir | where { ! $_.PSIsContainer } | foreach {
		$sPath=($_.Directory.FullName)
		$sFName=($_.FullName)
		$sBName=(Get-Item $_.FullName).BaseName
		
		$dFName=($_.Name).Replace($sBName,$sBName)
		$dFName="$sPath\$dFName"

		$dFName=$dFName.Replace($sDir,$dDir)
		New-Item -ItemType Directory -Force -Path (Split-Path $dFName) | Out-Null

		Write-Host "   I: dEcrypting $sFName" -ForegroundColor Cyan
		Replace-BinaryChars -InputFile "$sFName" -OutputFile "$dFName" -SourceChars $dst -DestChars $src

		if ($sBName -match '_[A-Fa-f0-9]{32}$') { $sMD5=$sBName.Substring($sBName.Length - 32) }

		if ($sMD5 -ne $null) {
				$oData=(Get-FileHash -Path $dFName -Algorithm MD5).Hash
				if ( $oData -eq $sMD5 ) { Write-Host "   I: MD5 checksum validated!" -ForegroundColor Cyan; echo ""}
				else { Write-Host "   E: MD5 checksum validation failed!" -ForegroundColor Red; echo "" }
		}
		else { Write-Host "   W: MD5 checksum validation skiped!" -ForegroundColor Red; echo ""}
	}

}





if ($args.Count -ne 2) { mmssgg; exit 1 }

$src = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

if (Test-Path $args[1] -PathType Container) {
	$sDir=$args[1]
	$sDir = (Resolve-Path "$sDir").Path
	switch( $args[0] ) {
		e {EAllFiles}
		d {DAllFiles}
		default { mmssgg;exit 1}
	}
}
elseif (Test-Path $args[1] -PathType Leaf) {
	$sDir=$args[1]
	$sDir = (Resolve-Path "$sDir").Path
	switch( $args[0] ) {
		e {	Write-Host " - Please enter Password to eNcrypt: " -ForegroundColor Blue -NoNewline
			$PSWD=Read-Host -AsSecureString
			$PSWD=[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($PSWD))

			Write-Host " - Please enter Password HINT: " -ForegroundColor Blue -NoNewline
			$sHINT=Read-Host
			if ($sHINT -match '[\\/:*?"<>|]') { Write-Host "   E: Hint should not contain any of \ / : * ? "" < > |" -ForegroundColor Red;exit 1 }
			if ($sHINT.Length -eq 0) { $sHINT="_" }
			else { $sHINT = "_"+$sHINT+"_"}

			$sDirBase = (Get-Item "$sDir").BaseName
			$oData=(Get-FileHash -Path $sDir -Algorithm MD5).Hash
			$oData=$sDirBase+$sHINT+$oData
			$dDir=(Get-Item $sDir).Name.Replace($sDirBase,$oData)
			$dDir = (Get-Item $sDir).DirectoryName+"\"+$dDir

			Write-Host "   I: eNcrypting $sDir" -ForegroundColor Cyan
		
			$dst = getBaseToken($PSWD);
			Replace-BinaryChars -InputFile "$sDir" -OutputFile "$dDir" -SourceChars $src -DestChars $dst
			}
		d {	$sDirBase = (Get-Item "$sDir").BaseName
			if ($sDirBase -match '_[A-Fa-f0-9]{32}$') { $sMD5=$sDirBase.Substring($sDirBase.Length - 32) }

			$dDir=(Get-Item $sDir).Name.Replace($sDirBase,$sDirBase+"_dEcrtypt")
			$dDir = (Get-Item $sDir).DirectoryName+"\"+$dDir

			Write-Host " - Please enter Password to dEcrypt: " -ForegroundColor Blue -NoNewline
			$PSWD=Read-Host -AsSecureString
			$PSWD=[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($PSWD))
			Write-Host "   I: dEcrypting $sDir" -ForegroundColor Cyan
		
			$dst = getBaseToken($PSWD);
			Replace-BinaryChars -InputFile "$sDir" -OutputFile "$dDir" -SourceChars $dst -DestChars $src
			
			if ($sMD5 -ne $null) { $oData=(Get-FileHash -Path $dDir -Algorithm MD5).Hash
				if ( $oData -eq $sMD5 ) { Write-Host "   I: MD5 checksum validated!" -ForegroundColor Cyan; echo "" }
				else { Write-Host "   E: MD5 checksum validation failed!" -ForegroundColor Red; echo "" }
				}
			else { Write-Host "   W: MD5 checksum validation skiped!" -ForegroundColor Red; echo ""}
			}
	    default { mmssgg;exit 1}
	}
}
