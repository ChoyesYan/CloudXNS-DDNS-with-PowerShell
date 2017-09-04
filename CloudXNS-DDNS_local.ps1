#CloudXNS-DDNS with PowerShell
#Github��Ŀ��ַ:https://github.com/lixuy/CloudXNS-DDNS-with-PowerShell
#������Ϣ: https://03k.org/cloudxns-ddns-with-powershell.html
$API_KEY="abcdefghijklmnopqrstuvwxyz1234567"
$SECRET_KEY="abcdefghijk12345"
#[����]�����Ϸ���д���CLoudXNS��API KEY��SECRET KEY.
$DDNS="home.xxxx.com"
#[����]�����Ϸ���д�������������myhome.xxx.com
#��ȷ�������������˺��ڴ��ڣ�����᷵��40x����
$CARD="AA-BB-CC-00-11-22"
#[����]ָ��������mac��ַ
$UPTIME=59
#[��ѡ]�����µ�ʱ�������룩
#API������Ƶ�����ƣ����������ù��̼��
#�������Ҫѭ�������£������ֶ���Ӽƻ����񣩣���ע�ͻ���-1
#$LOGFILE="./ddns.log"
#[��ѡ]���ڼ�¼��־���ļ�·��*.log,ע�͵�����������־
#���ý���
$URL="http://www.cloudxns.net/api2/ddns"


Function UPDNS() 
{if ($SKIP) {return -1;}
$JSON = @"
  {"domain":"$DDNS","ip":"$CARDIP"}
"@
$DATE=get-Date -format r
$md5=New-Object System.Text.StringBuilder 
[System.Security.Cryptography.HashAlgorithm]::Create("MD5").ComputeHash([System.Text.Encoding]::UTF8.GetBytes($API_KEY+$URL+$JSON+$DATE+$SECRET_KEY))|%{[Void]$md5.Append($_.ToString("x2"))}
$HMAC =$md5.ToString()
$POST=new-object System.Net.WebClient
$POST.Encoding=[System.Text.Encoding]::UTF8
$POST.Headers.Add("API-KEY",$API_KEY)
$POST.Headers.Add("API-REQUEST-DATE",$DATE)
$POST.Headers.Add("API-HMAC",$HMAC)
$POST.Headers.Add("HttpRequestHeader.Accept", "json");
$POST.Headers.Add("HttpRequestHeader.ContentType","application/x-www-form-urlencoded; charset=UTF-8");
$Respond=$POST.UploadString($URL,"POST", $JSON);
if ($Respond -match "success"){
Write-Host "����API����DNS�ɹ�`r"}
else {
Write-Host "����API����DNS����`r"
if ($Respond){Write-Host $Respond}
}}

if ($LOGFILE -match "\.log$"){
$null =stop-transcript;
Clear-Host
start-transcript -append -path $LOGFILE}
if (-not(
-join($API_KEY,$API_KEY.Length) -match "^[0-9a-z]{32}32$" -and`
-join($SECRET_KEY,$SECRET_KEY.Length) -match "^[0-9a-z]{16}16$"
)){Write-Warning "���API KEY���ÿ�����������������á�";read-host;exit}
do {
Write-Host "$(Get-date)`r"
if($((Get-NetIPAddress -ifIndex $(Get-NetAdapter | Where-Object -Property MacAddress -EQ $CARD).ifIndex -SuffixOrigin Dhcp -AddressFamily IPv4).IPAddress) -match "\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b")
{$CARDIP=$matches[0]}
else{$CARDIP="�޷���ȡ����IP,���������MAC��ַ`r"}
if($(([Net.DNS]::GetHostEntry($DDNS).AddressList|Where-Object -FilterScript {$_.AddressFamily -eq "InterNetwork"}).IPAddressToString|Out-String) -match "\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b")
{$PCIP=$matches[0]}
else{$PCIP="�޷���ȡ���,��������,����ǽ��DDNS����,������¼�ں�̨�Ƿ����`r"}
Write-Host "���ؽ������:$PCIP`r`n������ȡ���:$CARDIP`r"
$SKIP=0
if ($CARDIP -eq $PCIP){Write-Host "���һ�£���������`r";$SKIP=1}
$null =UPDNS;
if ($UPTIME -gt 0){Write-Host "�´μ�齫��$UPTIME<s>֮��`r";Start-Sleep $UPTIME};
}
while($UPTIME -gt 0)