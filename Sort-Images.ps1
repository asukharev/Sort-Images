. .\Get-Image.ps1
. .\Get-ImageProperty.ps1

$SourceFolder = "E:\Test\Input"
$TargetFolder = "E:\Test\Output\"

Get-ChildItem -File -Recurse -Path $SourceFolder | ForEach-Object {
    $orig_path = $_.FullName
    $img_prop = Get-Image $_.FullName | Get-ImageProperty
    if ($img_prop.DateTime) {
        $date = $img_prop.DateTime.ToString("yyyy-MM")
        $target_part = (Join-Path $TargetFolder $date)
        
        # Make folder is not exist
        if (-not (Test-Path $target_part)) {
            New-Item -ItemType Directory -Path $target_part
        }

        # Check file already exist
        $full_file_path = Join-Path $target_part $_.Name
        if (-not (Test-Path $full_file_path)) {
        }
        else {
            $add = Get-Random -Maximum 10000
            $new_filename = $_.BaseName + "-" + $add + $_.Extension
            $target_part = Join-Path (Join-Path $TargetFolder $date) $new_filename
        }
        "Move image '$orig_path' to '$target_part'"
        Move-Item -Path $_.FullName -Destination $target_part        
    }
    else {
        Write-Host "No date for $orig_path"
    }
}
