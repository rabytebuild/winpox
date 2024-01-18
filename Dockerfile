# Use a base image that supports Windows
FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Set environment variables
ENV USER administrator
ENV PASSWORD root

# Install necessary packages and enable Remote Desktop
RUN powershell -Command \
    Install-WindowsFeature -Name RDS-RD-Server -IncludeAllSubFeature -IncludeManagementTools ; \
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0 ; \
    Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "UserAuthentication" -Value 1 ; \
    New-Object PSObject -Property @{ \
        User = $env:USER ; \
        Password = (ConvertTo-SecureString -AsPlainText -Force $env:PASSWORD) ; \
    } | New-LocalUser -PassThru | Add-LocalGroupMember -Group "Administrators"

# Expose the Remote Desktop port
EXPOSE 3389

# Start the Remote Desktop service
CMD ["powershell", "Start-Service -Name TermService -Verbose ; Stop-Service -Name TermService -Force"]
