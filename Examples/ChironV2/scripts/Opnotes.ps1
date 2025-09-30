
$tools = (get-location).path
$drive="${tools}\Collection"
write-host ${tools}\Collection
function Export-CSV {
[CmdletBinding(DefaultParameterSetName='Delimiter',
  SupportsShouldProcess=$true, ConfirmImpact='Medium')]
param(
 [Parameter(Mandatory=$true, ValueFromPipeline=$true,
           ValueFromPipelineByPropertyName=$true)]
 [System.Management.Automation.PSObject]
 ${InputObject},

 [Parameter(Mandatory=$true, Position=0)]
 [Alias('PSPath')]
 [System.String]
 ${Path},
 
 #region -Append (added by Dmitry Sotnikov)
 [Switch]
 ${Append},
 #endregion 

 [Switch]
 ${Force},

 [Switch]
 ${NoClobber},

 [ValidateSet('Unicode','UTF7','UTF8','ASCII','UTF32',
                  'BigEndianUnicode','Default','OEM')]
 [System.String]
 ${Encoding},

 [Parameter(ParameterSetName='Delimiter', Position=1)]
 [ValidateNotNull()]
 [System.Char]
 ${Delimiter},

 [Parameter(ParameterSetName='UseCulture')]
 [Switch]
 ${UseCulture},

 [Alias('NTI')]
 [Switch]
 ${NoTypeInformation})

begin
{
 # This variable will tell us whether we actually need to append
 # to existing file
 $AppendMode = $false
 
 try {
  $outBuffer = $null
  if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
  {
      $PSBoundParameters['OutBuffer'] = 1
  }
  $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Export-Csv',
    [System.Management.Automation.CommandTypes]::Cmdlet)
        
        
 #String variable to become the target command line
 $scriptCmdPipeline = ''

 # Add new parameter handling
 #region Dmitry: Process and remove the Append parameter if it is present
 if ($Append) {
  
  $PSBoundParameters.Remove('Append') | Out-Null
    
  if ($Path) {
   if (Test-Path $Path) {        
    # Need to construct new command line
    $AppendMode = $true
    
    if ($Encoding.Length -eq 0) {
     # ASCII is default encoding for Export-CSV
     $Encoding = 'ASCII'
    }
    
    # For Append we use ConvertTo-CSV instead of Export
    $scriptCmdPipeline += 'ConvertTo-Csv -NoTypeInformation '
    
    # Inherit other CSV convertion parameters
    if ( $UseCulture ) {
     $scriptCmdPipeline += ' -UseCulture '
    }
    if ( $Delimiter ) {
     $scriptCmdPipeline += " -Delimiter '$Delimiter' "
    } 
    
    # Skip the first line (the one with the property names) 
    $scriptCmdPipeline += ' | Foreach-Object {$start=$true}'
    $scriptCmdPipeline += '{if ($start) {$start=$false} else {$_}} '
    
    # Add file output
    $scriptCmdPipeline += " | Out-File -FilePath '$Path'"
    $scriptCmdPipeline += " -Encoding '$Encoding' -Append "
    
    if ($Force) {
     $scriptCmdPipeline += ' -Force'
    }

    if ($NoClobber) {
     $scriptCmdPipeline += ' -NoClobber'
    }   
   }
  }
 } 
  

  
 $scriptCmd = {& $wrappedCmd @PSBoundParameters }
 
 if ( $AppendMode ) {
  # redefine command line
  $scriptCmd = $ExecutionContext.InvokeCommand.NewScriptBlock(
      $scriptCmdPipeline
    )
 } else {
  # execute Export-CSV as we got it because
  # either -Append is missing or file does not exist
  $scriptCmd = $ExecutionContext.InvokeCommand.NewScriptBlock(
      [string]$scriptCmd
    )
 }

 # standard pipeline initialization
 $steppablePipeline = $scriptCmd.GetSteppablePipeline(
        $myInvocation.CommandOrigin)
 $steppablePipeline.Begin($PSCmdlet)
 
 } catch {
   throw
 }
    
}

process
{
  try {
      $steppablePipeline.Process($_)
  } catch {
      throw
  }
}

end
{
  try {
      $steppablePipeline.End()
  } catch {
      throw
  }
}
<#

.ForwardHelpTargetName Export-Csv
.ForwardHelpCategory Cmdlet

#>

}

function Get-NetConfig {
	Get-WmiObject win32_networkadapterconfiguration `
	| Select-Object -Property Description,@{name='IPAddress';Expression={($_.IPAddress[0])}},MacAddress `
	| Where-Object {$_.IPAddress -NE $null}
}
$date = read-host -prompt "`nToday's Date (eg. 01Jan2020) "
$start = read-host -prompt "Enter Collection Start Time (REAL time; eg. 2130) "
$finish = read-host -prompt "Enter Collection Finish Time (REAL time; eg. 2200) "
$os = (get-wmiobject -class win32_operatingsystem).caption;
$version = (get-wmiobject -class win32_operatingsystem).version;
$pack = (get-wmiobject -class win32_operatingsystem).servicepackmajorversion;
if ($pack -eq "0") {
    $build = "$version"
} else {
    $build = "$version Service Pack $pack"
}
$building = read-host -prompt "Enter Building and Room Number (eg. Bldg123 Rm123) "
$location = read-host -prompt "Enter Physical Location of system (eg. `"under desk`") "
$purpose = read-host -prompt "Enter System Purpose (eg. Server/HMI/Production Monitoring) "
$harddrive = read-host -prompt "Enter Collection Hard Drive (eg. Seagate6/S6) "
$analyst = read-host -prompt "Enter Analyst Name "
$success = read-host -prompt "Was Collection Successful? (y/n) "
$notes = read-host -prompt "Enter other notes (eg. chemical produced/second capture/etc.) "
$network = echo " "

$csv = new-object PSObject
$csv | add-member -membertype noteproperty -name Date -value $date
$csv | add-member -membertype noteproperty -name Hostname -value $env:computername
$csv | add-member -membertype noteproperty -name IP/Mac -value $network
$csv | add-member -membertype noteproperty -name OS -value $os
$csv | add-member -membertype noteproperty -name Build -value $build
$csv | add-member -membertype noteproperty -name Building -value $building
$csv | add-member -membertype noteproperty -name Location -value $location
$csv | add-member -membertype noteproperty -name Purpose -value $purpose
$csv | add-member -membertype noteproperty -name Start_Time -value $start
$csv | add-member -membertype noteproperty -name Finish_Time -value $finish
$csv | add-member -membertype noteproperty -name Drive -value $harddrive
$csv | add-member -membertype noteproperty -name Analyst -value $analyst
$csv | add-member -membertype noteproperty -name Successful`? -value $success
$csv | add-member -membertype noteproperty -name Notes -value $notes

#$csv2 = @($env:computername,$start,$finish,$os,$build,$building,$location,$purpose,$harddrive,$analyst,$success,$notes)
write-host "${drive}\Opnotes.csv"
$csv | export-csv -path "${drive}\Opnotes.csv" -notypeinformation -append -Force
get-netconfig | ft -hidetableheaders >> "${drive}\Opnotes.csv"
echo "`n"
