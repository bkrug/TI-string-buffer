# Run this script with XAS99 to assemble all files
# See https://endlos99.github.io/xdt99/
#
# If you can't run powershell scripts research this command locally:
# Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

# Assemble the files
$files = Get-ChildItem ".\" -Filter *.asm |
         Where-Object { $_.Name -ne 'LOADTSTS.asm' }
ForEach($file in $files) {
    write-host 'Assembling' $file.Name
    $listFile = $file.Name.Replace(".asm", "") + ".lst"
    xas99.py -q -S -R $file.Name -L $listFile
}

# Add version information to some files
$comment = ': Memory Management - 1.3.0 - https://github.com/bkrug/TI-string-buffer     '  # This line is intentionally 76 char long
$filesToEdit = 'MEMBUF.obj', 'ARRAY.obj', 'VAR.obj'
ForEach($fileToEdit in $filesToEdit) {
    $fileContent = (Get-Content $fileToEdit)
    $lastLineNo = $fileContent.Substring($fileContent.Length - 4)
    $newContent = $fileContent.Substring(0, $fileContent.Length - 80) + $comment + $lastLineNo
    Set-Content $fileToEdit $newContent
}

# Add some files to a Disk image
$diskName = 'BufferAndArray.dsk'
Write-Host 'Creating disk image' $diskName
if (Test-Path $diskName) {
    Remove-Item $diskName
}
xdm99.py -X sssd $diskName
xdm99.py $diskName -a 'MEMBUF.obj' -f DIS/FIX80
xdm99.py $diskName -a 'ARRAY.obj' -f DIS/FIX80
xdm99.py $diskName -a 'VAR.obj' -f DIS/FIX80

# Create a version of the object files that can be used by XDT99
Write-Host 'Creating headerless object files'
Copy-Item 'MEMBUF.obj' 'MEMBUF.noheader.obj'
Copy-Item 'ARRAY.obj' 'ARRAY.noheader.obj'
Copy-Item 'VAR.obj' 'VAR.noheader.obj'

# Add TIFILES header to most object files
Write-Host 'Adding TIFILES header to other object files'
$objectFiles = Get-ChildItem ".\" -Filter *.obj |
               Where-Object { $_.Name.EndsWith('.noheader.obj') -ne 1 }
ForEach($objectFile in $objectFiles) {
    xdm99.py -T $objectFile.Name -f DIS/FIX80 -o $objectFile.Name
}