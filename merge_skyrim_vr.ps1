Write-Host "Starting"

$scriptDir = Split-Path -Parent $PSCommandPath

$sourceDir = Join-Path $scriptDir "\Skyrim Special Edition\data"
$destinationDir = Join-Path $scriptDir "\SkyrimVR\data"

foreach ($sourceFile in Get-ChildItem -Path $sourceDir -Recurse -File) {
    $relativePath = $sourceFile.Fullname -replace [regex]::Escape($sourceDir), ""

    if ($sourceFile.BaseName.StartsWith("cc")) {
        continue
    }

    $sourcePath = $sourceFile.FullName
    $destinationPath = Join-Path $destinationDir $relativePath
    
    if ([System.IO.File]::Exists($destinationPath)) {
        $destinationFile = Get-Item $destinationPath
        if ($destinationFile.Attributes -notmatch "ReparsePoint") {
            $sourceHash = Get-FileHash -Path $sourceFile.FullName -Algorithm MD5
            $destinationHash = Get-FileHash -Path $destinationFile.FullName -Algorithm MD5
            if ($sourceHash.Hash -eq $destinationHash.Hash) {
                Write-Host "Existing in both directories and same (moving away and link):" $relativePath ($sourceHash.Hash) ($destinationHash.Hash)            
                Move-Item -Path $destinationFile.FullName -Destination "$($destinationFile.FullName).org"
                New-Item -ItemType SymbolicLink -Path $destinationPath -Value $sourcePath | Out-Null
            }
            else {
                Write-Host "Existing in both directories and differ (doing nothing):" $relativePath ($sourceHash.Hash) ($destinationHash.Hash)                
            }
        }
        else {
            Write-Host "Already linked:" $relativePath
        }
    }
    else {
        Write-Host "Existing only in source:" $relativePath
        New-Item -ItemType SymbolicLink -Path $destinationPath -Value $sourcePath | Out-Null
    }
}