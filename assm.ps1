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
Add-Content -Path .\MEMBUF.obj -NoNewline -Value `
': Memory Management - Chunk Buffer                                              : Version 1.1.0                                                                 : https://github.com/bkrug/TI-string-buffer                                     '
Add-Content -Path .\ARRAY.obj -NoNewline -Value `
': Memory Management - Arrays                                                    : Version 1.1.0                                                                 : https://github.com/bkrug/TI-string-buffer                                     '
Add-Content -Path .\VAR.obj -NoNewline -Value `
': Memory Management - library non-static memory                                 : Version 1.1.0                                                                 : https://github.com/bkrug/TI-string-buffer                                     '

# Add some files to a Disk image
$diskName = 'BufferAndArray.dsk'
if (Test-Path $diskName) {
    Remove-Item $diskName
}
xdm99.py -X sssd $diskName
xdm99.py $diskName -a 'MEMBUF.obj' -f DIS/FIX80
xdm99.py $diskName -a 'ARRAY.obj' -f DIS/FIX80
xdm99.py $diskName -a 'VAR.obj' -f DIS/FIX80

# Add TIFILES header to all object files
$objectFiles = Get-ChildItem ".\" -Filter *.obj
ForEach($objectFile in $objectFiles) {
    xdm99.py -T $objectFile.Name -f DIS/FIX80 -o $objectFile.Name
}