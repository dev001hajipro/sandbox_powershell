# https://docs.microsoft.com/ja-jp/dotnet/standard/base-types/regular-expression-language-quick-reference

# UTF-8 with BOM CRLF
#
## 日本語出力の文字化けについて
#
## 対応方法
#
# Windows10のPowerShell5.1で、BOM付きUTF-8で保存
#
## 問題
# Windows10のPowerShell5.1では、UTF-8でスクリプトを保存し日本語出力すると文字化け発生。
# 解決方法としては以下がある。今回はBOM付きUTF-8で保存することにした。
#
# - BOM付きUTF-8
# - Shift_JIS
# - 日本語使わない。
# - PowerShell 7 のインストール
#
# 改造するときは、Visual Studio Codeなどエンコード検知できるエディタで編集すること。
#

$src_dir = 'src'
$dest_dir = 'dst'


$abs_src_dir = Join-Path -Path $PSScriptRoot -ChildPath $src_dir
$abs_dest_dir = Join-Path -Path $PSScriptRoot -ChildPath $dest_dir

#rite-Output "helloworld"
Write-Output $PSVersionTable

#Set-Location -Path c:\ -PassThru
#Set-Location -Path ~ -PassThru


function Log {
    param (
        $Message
    )
    $datetime = Get-Date -Format G
    Write-Output "$datetime $Message"
}

function rmdir_and_mkdir {
    param (
        $Dir
    )
    if (Test-Path $Dir) {
        Write-Output "remove directory....# $Dir"
        Remove-Item $Dir -Recurse -Force
    }
    if (-not (Test-Path $Dir)) {
        New-Item $Dir -ItemType Directory | Out-Null
    }
}

Log -Message "##BEGIN##"


Write-Output "スクリプトフォルダー:$PSScriptRoot"
Write-Output "スクリプトパス:$PSCommandPath"

Set-Location $PSScriptRoot

# show current directory.
Write-Output "現在のフォルダー: $(Get-Location)"


Write-Output "$abs_src_dir"
Write-Output "$abs_dest_dir"
rmdir_and_mkdir -Dir $abs_src_dir
rmdir_and_mkdir -Dir $abs_dest_dir



# Windowsでは大文字小文字のファイルは初期設定では同じなので、abcde.txtとABCDE.txtは
# 作れない。

$files = @(
    "abcde.txt",
    # "ABCDE.txt",
    "0123456789.txt",
    "1234567890.txt"
    "abcde0123456789.txt",
    #"ABCDE0123456789.txt",
    "ABCDE1234567890.txt",
    "20220414.txt",
    "20220414_abc.txt",
    "20220414_abcd.txt",
    "20220414_zacd.txt",
    "2022年4月1日__1014-NO001-SI999.txt",
    "2022-4-1-__1014-NO002-SI888.txt",
    # YYYY.MM.DD_hhmmss-Xxxxx-abc001-r00d.txt
    "2022.12.30_153345-Xxxab-abc001-r00d.txt",
    "2022.12.30_153345-Yyyab-xyz033-r03d.txt"
)
foreach ($item in $files) {
    New-Item -ItemType File -Path $abs_src_dir -Name $item | Out-Null
}


# ファイル一覧取得と移動
Get-ChildItem -Path $abs_src_dir | Move-Item -Destination $abs_dest_dir

# get fullpath
Get-ChildItem -Path $abs_dest_dir | ForEach-Object { $_.FullName }

$v = Get-ChildItem -Path $abs_dest_dir
foreach ($item in $v) {
    Write-Output "fullName:$($item.FullName)"
}

Write-Output "#####"
Get-ChildItem -Path $abs_dest_dir -File
Write-Output "#####"

# rename with PIPE
Get-ChildItem -Path $abs_dest_dir -File | ForEach-Object { Rename-Item -Path $_.FullName ("DONE-" + $_) }

# 拡張子置換
Get-ChildItem -Path $abs_dest_dir -File | Rename-Item -NewName { $_.Name -replace '.txt', '.log' }

# show full path.
$v = Get-ChildItem -Path $abs_dest_dir -File
foreach ($item in $v) {
    Write-Output "fullName:$($item.FullName)"
}

$lst = Get-ChildItem -Path $abs_dest_dir -File
foreach ($item in $lst) {
    Rename-Item -Path $item.FullName ("DONE-" + $item)
}

# not use ForEach-Object



# https://tonari-it.com/windows-powershell-regularexpression/

#
# Where-Object -matchで正規表現
#
Write-Output "Where-Object####"
Get-ChildItem -Path $abs_dest_dir -File | Where-Object { $_ -ne 1 } | ForEach-Object { Write-Output $_.FullName }

Write-Output "Where-Object MATCH DONE-####"
Get-ChildItem -Path $abs_dest_dir -File | Where-Object { $_.Name -match '^[DONE\-]' } | ForEach-Object { Write-Output $_.FullName }


Write-Output "Where-Object MATCH DONE-DONE-a   ####"
Get-ChildItem -Path $abs_dest_dir -File | Where-Object { $_.Name -match '^DONE-DONE-a' } | ForEach-Object { Write-Output $_.FullName }

# DONE-DONE-20220414_abc.log
Write-Output "Where-Object MATCH DONE-DONE-20220414_abc.log"
Get-ChildItem -Path $abs_dest_dir -File `
| Where-Object { $_.Name -match '(\d{4})\d{2}\d{2}_\w{3}\.' } `
| ForEach-Object { Write-Output $_.FullName }

# 日本語のファイル
# "2022年4月1日__1014-NO001-SI999.txt"
Write-Output "Where-Object MATCH 2022年4月1日__1014-NO001-SI999.txt"
Get-ChildItem -Path $abs_dest_dir -File `
| Where-Object { $_.Name -match '^(\d{4})年\d{1}月\d{1}__\d{4}' } `
| ForEach-Object { Write-Output $_.FullName }


#
# ファイル名置換
#
# Get-ChildItem -Path $abs_dest_dir -File | Rename-Item -NewName { $_.Name -replace '.txt', '.log' }
# YYYY.MM.DD_hhmmss-Xxxxx-abc001-r00d.txt
#    "2022.12.30_153345-Xxxab-abc001-r00d.txt",
#    "2022.12.30_153345-Yyyab-xyz033-r03d.txt"
#
# 1. dstにダミーファイル作成
# 2. 置換
# 3. 
Write-Output "Where-Object MATCH YYYY.MM.DD_hhmmss-Xxxxx-abc001-r00d.log"
Get-ChildItem -Path $abs_dest_dir -File `
| Where-Object { $_.Name -match '^(DONE-DONE-)(\d{4}).(\d{2}).(\d{2})_\d{6}' } `
| Rename-Item -NewName { $_.Name -replace '^(DONE-DONE-)(\d{4}).(\d{2}).(\d{2})_(\d{6})-(\w+)-(\w+)-(\w+).(\w+)', '$2_$3_$4_$5___$6__$7_$8.txt' }


Log -Message "##END##"
