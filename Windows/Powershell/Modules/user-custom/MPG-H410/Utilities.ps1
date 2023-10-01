### Convert videos to GIF (simple)
function Convert-VideoToGIF {
    param(
        [string]$InputFile,
        [string]$Output = "output.gif",
        [int]$Loop = 0
    )
    if (-not $InputFile) {
        Write-Host "No input file."
        return  # Powershell function never stop by non-0?
    }
    if (Test-Path $Output) {
        Write-Host "Default output file already exists."
        return
    }
    ffmpeg -i $InputFile -c:v gif -loop $Loop $Output
}