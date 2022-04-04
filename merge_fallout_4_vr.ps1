Write-Host "Starting"

$extensionMap = @{
    ".esl" = ".esp";
}

$dirSep = [IO.Path]::DirectorySeparatorChar

$sourceDir = Join-Path $PSScriptRoot "\Fallout 4\Data"

$destinationDataDir = Join-Path $PSScriptRoot "\Fallout 4 VR\Data"
$destinationReplacedDataDir = Join-Path $PSScriptRoot "\Fallout 4 VR\Data.replaced"
$destinationDisabledDataDir = Join-Path $PSScriptRoot "\Fallout 4 VR\Data.disabled"

foreach ($sourceFile in Get-ChildItem -Path $sourceDir -Recurse -File) {
    $sourcePath = $sourceFile.FullName
    $sourceBaseName = $sourceFile.BaseName
    $sourceExtension = $sourceFile.Extension
    
    $destinationExtension = $sourceExtension
    if ($extensionMap[$sourceExtension]) {
        $destinationExtension = $extensionMap[$sourceExtension]
    }
    
    $relativePath = $sourceFile.Directory.FullName -replace [regex]::Escape($sourceDir), $dirSep

    $destinationFileName = $sourceBaseName + $destinationExtension
    $destinationRelativePath = Join-Path $relativePath $destinationFileName

    if ($sourceFile.BaseName.StartsWith("cc") -or $sourceFile.BaseName.StartsWith("DLCUltraHighResolution")) {
        $destinationPath = Join-Path $destinationDisabledDataDir $destinationRelativePath

        if ([System.IO.File]::Exists($destinationDisabledPath)) {
            $destinationDisabledFile = Get-Item $destinationDisabledPath
            if ($destinationDisabledFile.Attributes -notmatch "ReparsePoint") {
                Write-Host "Disabled already linked (doing nothing):" $destinationRelativePath
            }
            else {
                Write-Host "Disabled already exists (doing nothing):" $destinationRelativePath
            }
        }
        else {
            Write-Host "Disabled (linking to disabled dir):" $destinationRelativePath
            New-Item -ItemType Directory -Path $(Split-Path -Parent $destinationPath) -Force | Out-Null
            New-Item -ItemType SymbolicLink -Path $destinationPath -Value $sourcePath | Out-Null
        }
    }
    else {
        $destinationPath = Join-Path $destinationDataDir $destinationRelativePath

        if ([System.IO.File]::Exists($destinationPath)) {
            $destinationFile = Get-Item $destinationPath
            if ($destinationFile.Attributes -notmatch "ReparsePoint") {
                $sourceHash = Get-FileHash -Path $sourcePath -Algorithm MD5
                $destinationHash = Get-FileHash -Path $destinationPath -Algorithm MD5
                if ($sourceHash.Hash -eq $destinationHash.Hash) {
                    $destinationOriginalFileName = $sourceBaseName + $sourceExtension
                    $destinationOriginalRelativePath = Join-Path $relativePath $destinationOriginalFileName
                    $destinationOriginalPath = Join-Path $destinationDataDir $destinationOriginalRelativePath
                    $destinationReplacedPath = Join-Path $destinationReplacedDataDir $destinationRelativePath

                    Write-Host "Existing in both directories and same (moving away to replaced dir and link):" $destinationRelativePath ($sourceHash.Hash) ($destinationHash.Hash)
                    New-Item -ItemType Directory -Path $(Split-Path -Parent $destinationReplacedPath) -Force | Out-Null
                    Move-Item -Path $destinationOriginalPath -Destination "$($destinationReplacedPath)" | Out-Null

                    New-Item -ItemType Directory -Path $(Split-Path -Parent $destinationPath) -Force | Out-Null
                    New-Item -ItemType SymbolicLink -Path $destinationPath -Value $sourcePath | Out-Null
                }
                else {
                    Write-Host "Existing in both directories and differ (doing nothing):" $destinationRelativePath ($sourceHash.Hash) ($destinationHash.Hash)
                }
            }
            else {
                Write-Host "Already linked (doing nothing):" $destinationRelativePath
            }
        }
        else {
            Write-Host "Existing only in source (linking):" $destinationRelativePath
            New-Item -ItemType Directory -Path $(Split-Path -Parent $destinationPath) -Force | Out-Null
            New-Item -ItemType SymbolicLink -Path $destinationPath -Value $sourcePath | Out-Null
        }
    }
}
