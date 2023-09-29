# Creating a File Integrity Monitor

## Introduction to File Integrity Monitoring

File integrity monitoring (FIM) is the process of validating the integrity of operating system and application software files. This method compares the current file state to a known, good baseline, ensuring files remain unaltered.

## Why are File Integrity Monitors Important?

- **Security**: Detects changes in system files, indicating possible malware or insider threats.
- **Compliance**: Many standards, like PCI-DSS, mandate FIM for data security.
- **System Reliability**: Early warning for system issues like disk corruption or misconfigurations.

## My File Integrity Monitor in PowerShell

In this project, I've used PowerShell, a powerful framework, to develop a simple file integrity monitor. The backbone of this project is the [`FileSystemWatcher`](https://learn.microsoft.com/en-us/dotnet/api/system.io.filesystemwatcher?view=net-7.0) class.

The project is based upon a flowchart I created outlining the logical set of processes I reached when decompomsing this problem.

<img src="https://i.imgur.com/uMh6uP3.png" alt="A flow chart ">

### Setting up the Monitor Parameters

```powershell
$folderToMonitor = "C:\path\to\desired\folder"
$filter = "*.*"
$timeout = 5000
```

- `$folderToMonitor`: Directory to observe.
- `$filter`: File types to watch.
- `$timeout`: Wait time (ms) before event times out.

### Defining the Type of Changes to Monitor

```powershell
$changeTypes = [IO.NotifyFilters]::FileName -bor `
               [IO.NotifyFilters]::LastWrite -bor `
               [IO.NotifyFilters]::DirectoryName
```

Changes monitored:

- File names (`FileName`)
- File content (`LastWrite`)
- Directory names (`DirectoryName`)

### Initialising the FileSystemWatcher

```powershell
$watcher = New-Object IO.FileSystemWatcher $folderToMonitor, $filter -Property {
   IncludeSubdirectories = $false 
   NotifyFilter = $changeTypes
}
```

We initialise the FileSystemWatcher object, which will actively monitor the specified directory based on the types of changes we're interested in.

### Event Handling with Timestamp

```powershell
$action = {
    $event = $eventArgs | ForEach-Object {
        $changeType = $_.ChangeType
        $fullPath = $_.FullPath
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Write-Host "$timestamp - $changeType detected on $fullPath"
    }
}
```

Each time a file change event occurs, it's essential not only to know what type of change happened and which file was affected, but also when it took place. To this end, this action captures all these details.

### Event Registration

```powershell
$created = Register-ObjectEvent $watcher Created -SourceIdentifier FileCreated -Action $action
$deleted = Register-ObjectEvent $watcher Deleted -SourceIdentifier FileDeleted -Action $action
$changed = Register-ObjectEvent $watcher Changed -SourceIdentifier FileChanged -Action $action
$renamed = Register-ObjectEvent $watcher Renamed -SourceIdentifier FileRenamed -Action $action
```

Here, we're linking the previously defined action with specific file change events, such as file creation, deletion, and so on.

### Monitoring Loop

```powershell
do {
    $result = Wait-Event -Timeout $timeout
    if (-not $result) {
        # No changes detected within the timeout period.
    } else {
        Remove-Event -SourceIdentifier $result.SourceIdentifier
    }
} while ($true)
```

This segment of the code ensures that the script keeps running in a loop, continuously monitoring for and processing file change events as they occur.


### Execution of the Script

Upon executing the File Integrity Monitor, the script diligently begins monitoring the target directory for any changes. Any changes that are identified are reported in the console, with a time stamp and appropriate message:

<img src="https://i.imgur.com/GJ4rDLR.png" alt="An example output from the script">

### Conclusion

Building the File Integrity Monitor was a hands-on exploration of using PowerShell to address a genuine IT concern: monitoring file changes in real-time. This project not only honed my skills in scripting but also deepened my understanding of file systems and the importance of data integrity. It's a practical tool that underscores the significance of vigilant monitoring in today's digital landscape. As I look back on this project, I'm reminded of the potential of simple solutions to address complex challenges, and I'm eager to tackle more projects in the future.
