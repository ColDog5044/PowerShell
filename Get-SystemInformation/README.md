# Get-SystemInformation

## Synopsis

Retrieves system information such as operating system details, processor information, memory details, GPU information, and network adapter information.

## Description

This function retrieves various system information based on the detected operating system (Windows or Linux). It displays the system name, operating system details, processor information, memory details, GPU information, and network adapter information. The output can be optionally dumped into a text file.

## Parameters

### OutputFile

Specifies the name of the text file to which the output should be dumped. If this parameter is not provided, the output will be displayed in the console.

---

### OperatingSystem

Specifies whether to display only operating system information.

---

### Processor

Specifies whether to display only processor information.

---

### Memory

Specifies whether to display only memory information.

---

### GPU

Specifies whether to display only GPU information.

---

### NetworkAdapter

Specifies whether to display only network adapter information.

---

## Example Usage

    Get-SystemInformation -OutputFile "system_info.txt"
This command retrieves system information and dumps it into a text file named "system_info.txt".

    Get-SystemInformation -Memory
This command retrieves only memory information and displays it in the console.



