$s = "$args"
$i = 0
$base64 = $ending = ''
$base64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
  
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
# Return the Base64 encoded r=====lt
return "$base64"
