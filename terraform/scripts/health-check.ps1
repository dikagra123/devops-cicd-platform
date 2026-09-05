param(
    [string]$Url
)

Write-Host "Checking application health at $Url"

$maxAttempts = 10

for ($i = 1; $i -le $maxAttempts; $i++) {

    try {

        $response = Invoke-WebRequest `
            -Uri "$Url/health" `
            -UseBasicParsing `
            -TimeoutSec 5

        if ($response.StatusCode -eq 200) {

            Write-Host "Health check PASSED"

            exit 0
        }

    }
    catch {

        Write-Host "Attempt $i failed"
    }

    Start-Sleep -Seconds 2
}

Write-Host "Health check FAILED"

exit 1