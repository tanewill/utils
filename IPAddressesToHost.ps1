$resourceGroup = $args[0]

#determine the number of vm's
$vmlist=azure vm list -g $resourceGroup
$splitVmList=$vmlist -Split '\s+'
$namesInList=ForEach($line in $splitVmList) { 
    if ($line -eq "data:") {
        echo $line
    }; 
}
$numVms=$namesInList.count - 2

#determine the name and resource group of the vm's
$myArray = @()
for($i=1; $i -le $numVms; $i++){ 
	$e=18+($i*8); $f=17+($i*8); 
	$rg=$splitVmList | select -first 1 -skip $f ; 
	$name = $splitVmList | select -first 1 -skip $e; 
	$myObject = New-Object System.Object; 
	$myObject | Add-Member -type NoteProperty -name Name -Value $name -Force; 
	$myObject | Add-Member -type NoteProperty -name ResourceGroup -Value $rg -Force; 
	$myArray += $myObject
}


#assume the nic name is the vm name + 'nic'
#then get the private IP address and take the 5th element in the line
#place into an object
$myArray2 = @()
foreach($object in $myArray) { 
	$nic=$object.Name+'nic';
	$g=azure network nic show -g $object.ResourceGroup -n $nic | Select-String "Private IP address";
	$h=$g -Split '\s+';
	$object | Add-Member -type NoteProperty -name IPAddress -Value $h[5] -Force;
	$myArray2 += $object
}


#write out to screen
foreach($object in $myArray2) {
	$output = $object.IPAddress + '    ' + $object.Name; 
	Write-Output $output
}
