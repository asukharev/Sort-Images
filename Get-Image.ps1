function Get-Image {
    <#
    .Synopsis
        Gets information about images.

    .Description
        Get-Image gets an object that represents each image file.
        The object has many properties and methods that you can use to edit images in Windows PowerShell.

    .Notes
        Get-Image uses Wia.ImageFile, a Windows Image Acquisition COM object to get image data.
        Then it uses the Add-Member cmdlet to add note properties and script methods to the object.

        The Resize script method uses the Add-ScaleFilter function. It has the following syntax:
        Resize ($width, $height, [switch]$DoNotPreserveAspectRation).
        Width and Height can be specified in pixels or percentages.
        For a description of these parameters, type "get-help Add-ScaleFilter –par *".

        The Crop script method uses the uses the Add-CropFilter function. It has the following syntax:
        Crop ([Double]$left, [Double]$top, [Double]$right, [Double]$bottom).
        All dimensions are measured in pixels.
        For a description of these parameters, type "get-help Add-CropFilter –par *".

        The FlipVertical, FlipHorizontal, RotateClockwise and RotateCounterClockwise script methods use the Add-RotateFlipFilter function.
        For a description of these parameters, type "get-help Add-RotateFlipFilter –par *".

    .Parameter File
        [Required] Specifies the image files. Enter the path and file name of an image file, such as $home\pictures\MyPhoto.jpg.
        You can also pipe one or more image files to Get-Image, such as those from Get-Item or Get-Childitem (dir).

    .Example
        Get-Image –file C:\myPics\MyPhoto.jpg

    .Example
        Get-ChildItem $home\Pictures -Recurse | Get-Image

    .Example
        (Get-Image –file C:\myPics\MyPhoto.jpg).resize(80, 120)

    .Example
        # Crops 8 pixels from the top of the image.
        $CatPhoto = Get-Image –file $home\Pictures\Cat.jpg
        $CatPhoto.crop(0,8,0,0)

    .Example
        $CatPhoto = Get-Image –file $home\Pictures\Cat.jpg
        $CatPhoto.flipvertical()

    .Example
        dir $home\pictures\Vacation*.jpg | get-image | format-table fullname, horizontalResolution, PixelDepth –autosize

    .Link
        "Image Manipulation in PowerShell": http://blogs.msdn.com/powershell/archive/2009/03/31/image-manipulation-in-powershell.aspx
    .Link
        Add-CropFilter
    .Link
        Add-ScaleFilter
    .Link
        Add-RotateFlipFilter
    .Link
        Get-ImageProperties
    #>
    param(
    [Parameter(ValueFromPipelineByPropertyName=$true,Mandatory=$true)]
    [Alias('FullName')]
    [string]$file)

    process {
        $realItem = Get-Item $file -ErrorAction SilentlyContinue
        if (-not $realItem) { return }
        $image  = New-Object -ComObject Wia.ImageFile
        try {
            $image.LoadFile($realItem.FullName)
            $image |
                Add-Member NoteProperty FullName $realItem.FullName -PassThru |
                Add-Member ScriptMethod Resize {
                    param($width, $height, [switch]$DoNotPreserveAspectRatio)
                    $image = New-Object -ComObject Wia.ImageFile
                    $image.LoadFile($this.FullName)
                    $filter = Add-ScaleFilter @psBoundParameters -passThru -image $image
                    $image = $image | Set-ImageFilter -filter $filter -passThru
                    Remove-Item $this.Fullname
                    $image.SaveFile($this.FullName)
                } -PassThru |
                Add-Member ScriptMethod Crop {
                    param([Double]$left, [Double]$top, [Double]$right, [Double]$bottom)
                    $image = New-Object -ComObject Wia.ImageFile
                    $image.LoadFile($this.FullName)
                    $filter = Add-CropFilter @psBoundParameters -passThru -image $image
                    $image = $image | Set-ImageFilter -filter $filter -passThru
                    Remove-Item $this.Fullname
                    $image.SaveFile($this.FullName)
                } -PassThru |
                Add-Member ScriptMethod FlipVertical {
                    $image = New-Object -ComObject Wia.ImageFile
                    $image.LoadFile($this.FullName)
                    $filter = Add-RotateFlipFilter -flipVertical -passThru
                    $image = $image | Set-ImageFilter -filter $filter -passThru
                    Remove-Item $this.Fullname
                    $image.SaveFile($this.FullName)
                } -PassThru |
                Add-Member ScriptMethod FlipHorizontal {
                    $image = New-Object -ComObject Wia.ImageFile
                    $image.LoadFile($this.FullName)
                    $filter = Add-RotateFlipFilter -flipHorizontal -passThru
                    $image = $image | Set-ImageFilter -filter $filter -passThru
                    Remove-Item $this.Fullname
                    $image.SaveFile($this.FullName)
                } -PassThru |
                Add-Member ScriptMethod RotateClockwise {
                    $image = New-Object -ComObject Wia.ImageFile
                    $image.LoadFile($this.FullName)
                    $filter = Add-RotateFlipFilter -angle 90 -passThru
                    $image = $image | Set-ImageFilter -filter $filter -passThru
                    Remove-Item $this.Fullname
                    $image.SaveFile($this.FullName)
                } -PassThru |
                Add-Member ScriptMethod RotateCounterClockwise {
                    $image = New-Object -ComObject Wia.ImageFile
                    $image.LoadFile($this.FullName)
                    $filter = Add-RotateFlipFilter -angle 270 -passThru
                    $image = $image | Set-ImageFilter -filter $filter -passThru
                    Remove-Item $this.Fullname
                    $image.SaveFile($this.FullName)
                } -PassThru

        } catch {
            Write-Verbose $_
        }
    }
}