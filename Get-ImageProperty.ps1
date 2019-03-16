#requires -version 2.0
function Get-ImageProperty {
    <#
    .Synopsis
    Gets the extended properties of images.

    .Description
    The Get-ImageProperty function gets properties of an image in addition
    to the properties of the object that Get-Image returns.

    The input to Get-ImageProperty is the COM object that Get-Image returns.
    To use Get-ImageProperty, use the Get-Image function to get the image file.
    Then submit or pipe the output from Get-Image to Get-ImageProperty.

    You can use the extended properties to search and organize your image files.
    You can also use the properties with Copy-ImageIntoOrganizedFolder to sort the images into file system folders based on their property values.

    .Notes
    The image that Get-Image returns is stored in the Image property of the object that Get-ImageProperty returns.

    Many of the extended properties that Get-ImageProperty gets are defined by the Exchangeable Image File Format (Exif) specification.
    For information about these properties and their values, see http://www.exif.org.

    The extended properties that Get-ImageProperty gets depend on the information that is recorded in the image and, therefore, vary with the image.

    .Parameter Image
    Specifies the images. Enter image objects, such as ones that are returned by the Get-Image function.
    This parameter is optional, but if you do not include it, or if the value is not valid, Get-ImageProperty returns an error.

    .Example
    Get-Image –file C:\myPics\MyPhoto.jpg | Get-ImageProperty

    .Example
    C:\PS> $images = Get-ChildItem $home\Pictures -Recurse | Get-Image
    C:\PS> Get-ImageProperty –image $images

    .Example
    dir $home\Pictures\Vacation\* | Get-Image | Get-ImageProperty

    .Example
    C:\PS> $MyPhoto = Get-Image –file C:\myPics\MyPhoto.jpg | Get-ImageProperty
    C:\PS> $MyPhoto. EquipModel
    Canon PowerShot S3 IS

    .Example
    $Photos = dir $home\Pictures\Vacation\* | Get-Image | Get-ImageProperty
    PS C:\ps-test> $photos | format-table @{Label="Name"; Expression={$_.Fullname | split-path -leaf}}, DateTime, EquipMake, @{Label="Aperture"; Expression={$_.ExifAperture.Value}}, @{Label="Exposure"; Expression={$_.ExifExposureTime.Value}}, @{Label="Shutter Speed"; Expression={$_.ExifShutterSpeed.value}} –autosize

    Name          DateTime             EquipMake Aperture Exposure Shutter Speed
    ----          --------             --------- -------- -------- -------------
    incline01.jpg 4/27/2007 3:59:22 AM Canon            4    0.005       7.65625
    ...

    .Link
    Get-Image

    .Link
    Copy-ImageIntoOrganizedFolder

    .Link
    "Image Manipulation in PowerShell": http://blogs.msdn.com/powershell/archive/2009/03/31/image-manipulation-in-powershell.aspx

#>
    param(
    [Parameter(ValueFromPipeline=$true,
        Mandatory=$true)]
    $Image
    )

    process {
        New-Module -ArgumentList $image {
            param($image)
            $FullName = $image.FullName
            $Image = $image
            foreach ($property in $image.Properties) {
                if ($property.Value -like "????:??:??*") {
                    $chunks = $property.Value.ToString().Split(" ")
                    $dt = $chunks[0].Replace(":", "/") + ' ' + $chunks[1] -as [DateTime]
                    if ($dt) {
                        New-Variable -Name $property.Name -Value $dt
                        continue
                    }
                }
                New-Variable -Name $property.Name -Value $property.Value

            }
            Export-ModuleMember -Variable *
        } -AsCustomObject
    }
}