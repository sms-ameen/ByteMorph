function getBaseToken($passwrd){
 $PSWD=$passwrd
 $PSWD=[convert]::ToBase64String([System.Text.encoding]::UTF8.GetBytes($PSWD))
 
 for ($var = 0; $var -lt 1; $var++) {
  $PSWD=[convert]::ToBase64String([System.Text.encoding]::UTF8.GetBytes($PSWD))
  }
 $PSWD = $PSWD.ToCharArray() | select -Unique
 $PSWD = "$PSWD".Replace(" ","")
 $PSWD = "$PSWD".Replace("=","")
 $ONE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
 $TWO = $ONE
 $THR = $ONE.ToCharArray()
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
 
 
 #"PSWD $PSWD"
 #"ONE  $ONE"
 #"TWO  $TWO"
 #"THR  $THR"
 return "$THR"
}

function b64e() {
 $s =    Read-Host "Please enter Statement to encrypt"
 $PSWD = Read-Host "Please enter Password  to encrypt" -AsSecureString
 $PSWD=[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($PSWD))
 
 $BaseToken = getBaseToken($PSWD);
 
 $i = 0
 $base64 = $ending = ''
 #$base64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
 $base64chars = $BaseToken
  
 # Add padding if string is not dividable by 3
 $pad = 3 - ($s.length % 3)
 if ($pad -ne 3) {
         $s += "A" * $pad
         $ending = "=" * $pad
     }
 
 # Iterate though the whole input string
 while ($i -lt $s.length) {
     # Take 3 characters at a time, convert them to 4 base64 chars 
      $b = 0
      for ($j=0; $j -lt 3; $j++) {
     
         # get ASCII code of the next character in line
         $ascii = [int][char]$s[$i]
 		#echo $ascii
         $i++
         
         # Concatenate the three characters together 
         $b += $ascii -shl 8 * (2-$j)
         }
     
     # Convert the 3 chars to four Base64 chars
     $base64 += $base64chars[ ($b -shr 18) -band 63 ]
     $base64 += $base64chars[ ($b -shr 12) -band 63 ]
     $base64 += $base64chars[ ($b -shr 6) -band 63 ]
     $base64 += $base64chars[ $b -band 63 ]
     }
 # Add the actual padding to the end after removing the same number of characters
 if ($pad -ne 3) {
         $base64 = $base64.SubString(0, $base64.length - $pad)
         $base64 += $ending
         }
 echo "$base64"
}


function b64d() {
 $s =    Read-Host "Please enter Statement to decrypt"
 $PSWD = Read-Host "Please enter Password  to decrypt" -AsSecureString
 $PSWD=[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($PSWD))
 
 $BaseToken = getBaseToken($PSWD);
 
 $i = 0
 $base64 = $decoded = ''
 #$base64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
 $base64chars = $BaseToken
 
 # Replace padding with "A" characters for the decoder to work and save the length of the padding to be dropped from the end later
 if ($s.substring($s.length - 2,2) -like "==") {
     $s = $s.substring(0, $s.length - 2) + "AA"
     $padd = 2
     }
 elseif ($s.substring($s.length - 1,1) -like "=") {
     $s = $s.substring(0, $s.length - 1) + "A"
     $padd = 1
 }
 # Take 4 characters at a time
 while ($i -lt $s.length) {
     $d = 0
 
     for ($j=0; $j -lt 4; $j++) {
         $d += $base64chars.indexof($s[$i]) -shl (18 - $j * 6)
         $i++
         }
     # Convert the 4 chars back to ASCII
     $decoded += [char](($d -shr 16) -band 255)
     $decoded += [char](($d -shr 8) -band 255)
     $decoded += [char]($d -band 255)
 }
 # Remove padding
 $decoded = $decoded.substring(0, $decoded.length - $padd)
 # Return the Base64 encoded result
 echo "$decoded"
}



switch( $args[0] ) {
	e {b64e}
	d {b64d}
	default { echo "syntax error!!";exit 0}
}

