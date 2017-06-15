import-module au
import-module $PSScriptRoot\..\..\scripts\au_extensions.psm1

$releases = 'http://www.nssm.cc/download'

function global:au_SearchReplace {
   @{
        ".\legal\VERIFICATION.txt" = @{
          "(?i)(\s+x32:).*"            = "`${1} $($Latest.URL32)"
          "(?i)(checksum32:).*"        = "`${1} $($Latest.Checksum32)"
        }
    }
}
function global:au_BeforeUpdate { Get-RemoteFiles -Purge -NoSuffix }
function global:au_AfterUpdate  { Set-DescriptionFromReadme -SkipFirst 2 }

function global:au_GetLatest {
    $download_page = Invoke-WebRequest -Uri $releases -UseBasicParsing
    $re    = 'release.+\.zip$'
    $url   = $download_page.links | ? href -match $re | select -First 1 -expand href

    @{
        Version = $url -split '-|\.zip' | select -Last 1 -Skip 1
        URL32   = "http://www.nssm.cc/$url"
    }
}

update -ChecksumFor none
