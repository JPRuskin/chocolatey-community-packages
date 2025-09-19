Import-Module Chocolatey-AU

function global:au_AfterUpdate {
  Remove-Item -Force "$PSScriptRoot\tools\*.exe"
}

function global:au_SearchReplace {
  @{
    ".\tools\chocolateyInstall.ps1"   = @{
      "(?i)(^\s*packageName\s*=\s*)'.*'"  = "`${1}'$($Latest.PackageName)'"
      "(?i)^(\s*url64\s*=\s*)'.*'"        = "`${1}'$($Latest.URL64)'"
      "(?i)^(\s*checksum64\s*=\s*)'.*'"     = "`${1}'$($Latest.Checksum64)'"
      "(?i)^(\s*checksumType64\s*=\s*)'.*'" = "`${1}'$($Latest.ChecksumType64)'"
    }
  }
}

function global:au_GetLatest {
  $releasenotes = 'https://patchmypc.com/release-notes/production-release/home-updater-releases/'
  $url = 'https://homeupdater.patchmypc.com/public/PatchMyPC-HomeUpdater-Portable.exe'

  $version_page = Invoke-WebRequest -Uri $releasenotes -UseBasicParsing
  $re = New-Object regex('<h2 class="wp-block-heading" id="h-[\d-]+-\d{2}-\w+-\d{4}(-preview-only)?">(?<Version>[\d\.]+) \((?<Date>.+?)\)(?<Preview> \(Preview Only\))?<\/h2>')
  $versions = $re.Matches($version_page.Content).Where{
    -not $_.Groups['Preview'].success  # Where we haven't matched the 'Preview Only' group
  }.Groups.Where{$_.Name -eq 'Version'}.Value | Sort-Object {[version]$_}

  @{
    URL64 = $url
    Version = $versions[-1]
  }
}

update -ChecksumFor 64
