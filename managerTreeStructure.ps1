function addobject($finalreport,$emp,$type)
{
    $tempReport=$null
    $tempReport=[pscustomobject]@{
    'Name'=$emp.name
    'Emp ID'=$emp.samaccountname
    'Email'=$emp.userprincipalname
    'Manager'=$type
    }
    return $tempReport
}

#variables
$stack = New-Object System.Collections.Stack
$finalreport=@()
Clear-Host
$main=read-host -Prompt "Enter samaccount name"
$main_result=get-aduser $main
$main_result_DN=(get-aduser $main).distinguishedname 

$managedbby=Get-ADUser -Filter { Manager -eq $main_result_dn} | Select-Object Name,samaccountname,distinguishedname,userprincipalname
if($null -eq $managedbby)
{
    $tempReport=addobject $finalreport $main_result $false
    $finalreport+=$tempReport
}
else
{
    $tempReport=addobject $finalreport $main_result $true
    $finalreport+=$tempReport
    $managedbby | ForEach-Object { $stack.Push($_) }
}
while($stack.Count -gt 0 -and ($item = $stack.Pop())) 
{
    $employee=$null
    $DN=$($item.distinguishedname)
    $employee=Get-ADUser -Filter { Manager -eq $DN } | Select-Object Name,samaccountname,distinguishedname,userprincipalname
    if($null -ne $employee)
    {
        Write-Host "Processing manager $($item.samaccountname)"
        $tempReport=addobject $finalreport $item $true
        $finalreport+=$tempReport
        $employee | ForEach-Object { $stack.Push($_) }
    }
    else
    {
        Write-Host "Processing employee $($item.samaccountname)"
        $tempReport=addobject $finalreport $item $false
        $finalreport+=$tempReport
    }
}
$finalreport