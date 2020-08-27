<#
.SYNOPSIS
Resize an Image to match a given byte-size (to smaller only!)

.DESCRIPTION
Take and image, from file or provided as byte array, resize it to match a given filesize (in bytes) and return it either as file or as byte array.
Resizing will only take place if the original is larger than the target picture.

.PARAMETER InputFile
Absolute path of image file

.PARAMETER OutputFile
Absolue path of output file

.PARAMETER ImageBytes
Array of bytes containing image data

.PARAMETER TargetFileSizeInByte
Desired size of the resulting image in bytes

DEFAULT = 100000

.EXAMPLE
# resize pic.jpg to a maximum filesize of 1mb
Resize-Image -InputFile 'C:\Images\pic.jpg' -OutputFile 'C:\Images\pic2.jpg' -TargetFileSizeInBytes ([math]::pow(1024,2))

.EXAMPLE
# resize the Active Directory ThumbnailPhoto of user Einstein and write it back to Active Directory
$ba = (Get-ADUser einstein -Properties thumbnailphoto).thumbnailphoto
$ba = Resize-Image -ImageBytes $ba
Set-ADUser einstein -Replace @{thumbnailphoto=$ba}

.NOTES
Maximilian Otter, 2020-08-27
#>
function Resize-Image
{
    Param(
        [string]$InputFile,
        [string]$OutputFile,  # full path required!!!
        [byte[]]$ImageBytes,
        [Alias('PixelCount')]
        [int32]$TargetFileSizeInByte = 100000
    )

    # run image processing if there is EITHER an image file OR an array of bytes provided
    if ($InputFile -xor $ImageBytes.Count -gt 0) {

        # Add System.Drawing assembly
        try {
            Add-Type -AssemblyName System.Drawing
        } catch {
            Throw 'Assembly System.Drawing could not be loaded in Function Resize-Image.'
        }

#region GETIMAGE
        if ($InputFile) {

            # Get image from file
            $img = [System.Drawing.Image]::FromFile((Get-Item $InputFile))

        } else {

            # Get image from byte array using a MemoryStream
            $InputStream = [System.IO.MemoryStream]::New($ImageBytes)
            $img = [System.Drawing.Image]::FromStream($InputStream)
            $InputStream.Dispose()
            $InputStream.Close()

        }
#endregion GETIMAGE

#region SIZECALCULATION
        # calculate "colorless" size (= max. pixel count); the bitmap class below will
        # create a 32bit image, so we can devide by 4 bytes and ignore all other formats
        $maxpixel = [int32][math]::Round( $TargetFileSizeInByte / 4, 0, 1)

        # we only need to resize if the current picture is larger than our desired output size
        if ($img.Width * $img.Height -gt $maxpixel) {
            # calculate x:y ratio
            $ratio  = [double]$img.Width / $img.Height
        
            # calculate maximum sidelengths
            $Width  = [int32][math]::Round( [math]::Sqrt($maxpixel*$ratio), 0, 1)
            $Height = [int32][math]::Round( [math]::Sqrt($maxpixel/$ratio), 0, 1)      

        } else {

            $Width  = $img.Width
            $Height = $img.Height

        }

        # Create new image
        $img2 = [System.Drawing.Bitmap]::new($img,$Width,$Height)
#endregion SIZECALCULATION

#region OUTIMAGE
        if ($OutputFile) {
            
            # Save the image to disk
            $img2.Save($OutputFile)
            $img.Dispose()

        } else {

            # Return image as byte array using the imageformat of the original image
            $OutputStream = [System.IO.MemoryStream]::New()
            $img2.Save($OutputStream,$img.RawFormat)
            $OutputStream.ToArray()

            $img.Dispose()
            $OutputStream.Dispose()
            $OutputStream.Close()

        }
#region OUTIMAGE        

    } else {

        if ($InputFile -and $ImageBytes.Count -gt 0) {
            Throw 'Only one input allowed. InputFile or InputBytes.'
        } else {
            Throw 'No input provided. Please provide an InputFile or ImageBytes.'
        }
        
    }

}