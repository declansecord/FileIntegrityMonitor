$folderPath = "C:\Users\Lab\Documents\FIM" # Replace with the path to the folder you want to monitor

$filter = "*.*" # This will monitor all files. Adjust as required

$timeout = 5000 # This sets a timeout for waiting for events in milliseconds. Adjust as required

$changeTypes = [IO.NotifyFilters]::FileName -bor `   # Indicates changes to the filename
               [IO.NotifyFilters]::LastWrite -bor `  # Indicates changes to the contents or properties
               [IO.NotifyFilters]::DirectoryName     # Indicates changes to the name of a directory

$watcher = New-Object IO.FileSystemWatcher $folderPath, $filter -Property @{
    IncludeSubdirectories = $true # Change to $false if you do not want to monitor subdirectories
    NotifyFilter = $changetypes
}

# Define the event to be executed when a file is created, deleted or modified
$action = {
    $event = $eventArgs | ForEach-Object {
        $changeType = $_.ChangeType
        $fullPath = $_.FullPath
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Write-Host "$timestamp - $changeType detected on $fullPath"
    }
}


# Register events
$created = Register-ObjectEvent $watcher Created -SourceIdentifier FileCreated -Action $action
$deleted = Register-ObjectEvent $watcher Deleted -SourceIdentifier FileDeleted -Action $action
$changed = Register-ObjectEvent $watcher Changed -SourceIdentifier FileChanged -Action $action
$renamed = Register-ObjectEvent $watcher Renamed -SourceIdentifier FileRenamed -Action $action

# Let the script run and monitor for changes
do {
    $result = Wait-Event -Timeout $timeout
    if (-not $result) {
        # No changes were detected during the timeout period
        # Actions can be added here if required
    } else {
        # Clear the event after processing it
        Remove-Event -SourceIdentifier $result.SourceIdentifier
    }
} while ($true)

# If you ever need to stop the monitor, uncomment and execute the following lines to unregister the events:

# Unregister-Event -SourceIdentifier FileCreated
# Unregister-Event -SourceIdentifier FileDeleted
# Unregister-Event -SourceIdentifier FileChanged
# Unregister-Event -SourceIdentifier FileRenamed

# Failure to do so will cause errors the next time the monitor is run