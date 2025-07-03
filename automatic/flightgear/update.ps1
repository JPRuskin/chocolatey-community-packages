Import-Module Chocolatey-AU

$changelog = 'https://www.flightgear.org/download/releases/'
$latestVersions = 'https://www.flightgear.org/download/'

function global:au_SearchReplace {
  @{
    ".\tools\chocolateyInstall.ps1" = @{
      "(?i)(^\s*url\s*=\s*)('.*')"            = "`$1'$($Latest.URL32)'"
      "(?i)(^[$]version\s*=\s*)('.*')"        = "`$1'$($Latest.RemoteVersion)'"
    }
    ".\$($Latest.PackageName).nuspec" = @{
      "(?i)(\<releaseNotes\>).*(\<\/releaseNotes\>)" = "`$1$($Latest.ReleaseNotes)`$2"
    }
  }
}

function global:au_GetLatest {
  $version_page = Invoke-WebRequest -UseBasicParsing -Uri $latestVersions
  $re = "Flightgear-(?<Version>.+).exe$"
  if ($urls = @($version_page.Links.href -match $re)) {
    if ($urls[0] -match $re) {
      $version = $Matches.Version
      $short_version = $version.Substring(0, $version.LastIndexOf("."))
    }
  }

  $releaseNotes = "$changelog$($short_version -replace '\.','-')"

  @{
    URL32 = $urls[0]
    Version = $version
    RemoteVersion = $version
    ReleaseNotes = $releaseNotes
  }
}

update -ChecksumFor none
