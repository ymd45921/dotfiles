function Find-AnimeSharing {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Search
    )
    $part = [System.Uri]::EscapeDataString($Search)
    Start-Process "https://www.anime-sharing.com/search/8619620/?q=$part&t=post&c[child_nodes]=1&c[nodes][0]=47&o=relevance"
}
Set-Alias assearch Find-AnimeSharing