# PS_Downsize-Image
A powershell function to resize an image to a given filesize (file or byte array)

## Why?

While importing data from a cloud Workday tenant to Microsoft Identity Manager I realized, that the users have been uploading profile images in all sort of image files and up to 20 megapixel of size. Since we intended to use the profile pictures for the Active Directory thumbnailPhoto as well as for Skype for Business, Teams and Exchange Online, we had to cut them down somehow.

So I came up with the idea of implementing a function in the import script which downsizes the pictures on the fly.

## Features

* preserves aspect ratio of original image
* supports input and output as files as well as byte-arrays and converting between the two (like InputFile to Byte-Array output or vice versa)
* target size is determined by target file size, not a given aspect ratio
* automatically corrects output file extension if given output file extension does not match the actual image type

## Syntax

`Downsize-Image [-InputFile [string]] [-OutputFile [string]] [-ImageBytes [byte[]]] -[TargetFileSize [int32]]`

While all paramters are setup "optional" the function will require either an `InputFile` or `ImageBytes` to run, but not both (-> terminating error).

If an `OutputFile` is provided, the output will default to the file and not byte array is returned. Is `OutputFile` is not used, the image will be returned as a byte array, as e.g. it is needed to upload the image to the Active Directory thumbnailPhoto attribute.
