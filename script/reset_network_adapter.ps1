$adapter = Get-WmiObject win32_networkadapter | where {$_.DeviceId -eq 0}
$adapter.Disable()
$adapter.Enable()