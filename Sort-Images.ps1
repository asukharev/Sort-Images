. .\Get-Image.ps1
. .\Get-ImageProperty.ps1

$SourceFolder = "E:\Test\Input\"
$TargetFolder = "E:\Test\Output\"

Get-ChildItem -File -Recurse -Path $SourceFolder -Include *.JPG | ForEach-Object {
    $orig_path = $_.FullName
    $img_prop = Get-Image $_.FullName | Get-ImageProperty
    if ($img_prop.dt) {
        $date = $img_prop.dt.ToString("yyyy-MM")
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
            $add = Get-Random -Maximum 10000 # or Get-Date -Format "ddMMyyyyHHmmss"
            $new_filename = $_.BaseName + "-" + $add + $_.Extension
            $target_part = Join-Path (Join-Path $TargetFolder $date) $new_filename
        }
        "Move image '$orig_path' to '$target_part'"
        Move-Item -Path $_.FullName -Destination $target_part
    }
    else {
        Write-Host "No date for $orig_path"

        $target_folder = Join-Path $TargetFolder "UnknowDate"
        if (-not (Test-Path $target_folder)) {
            New-Item -ItemType Directory -Path $target_folder
        }

        $full_file_path = Join-Path $target_folder $_.Name
        if (Test-Path $full_file_path) {
            $add = Get-Random -Maximum 10000
            $new_filename = $_.BaseName + "-" + $add + $_.Extension
            $target_path = Join-Path $target_folder $new_filename
            Move-Item -Path $_.FullName -Destination $target_path
            "Move image '$orig_path' to '$target_path'"
        }
        else {
            Move-Item -Path $_.FullName -Destination $target_folder
            "Move image '$orig_path' to '$target_folder'"
        }
        
    }
    Clear-Variable -Name img_prop
}
