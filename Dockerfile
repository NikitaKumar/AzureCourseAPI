# Sample Dockerfile

# Indicates that the windowsservercore image will be used as the base image.
FROM microsoft/windowsservercore

# Metadata indicating an image maintainer.
#MAINTAINER jshelton@contoso.com

# Uses dism.exe to install the IIS role.
RUN dism.exe /online /enable-feature /all /featurename:iis-webserver /NoRestart

# Creates an HTML file and adds content to this file.
#RUN echo "Hello World - Dockerfile" > c:\inetpub\wwwroot\index.html

EXPOSE 80

# Sets a command or process that will run each time a container is run from the new image.
#CMD [ "powershell.exe" ]

# Install Chocolatey (tools to automate commandline compiling)
ENV chocolateyUseWindowsCompression false
RUN @powershell -NoProfile -ExecutionPolicy unrestricted -Command "(iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))) >$null 2>&1" && SET PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin

# Install build tools
RUN powershell add-windowsfeature web-asp-net45 \
&& choco install microsoft-build-tools -y --allow-empty-checksums -version 14.0.23107.10 \
&& choco install dotnet4.6-targetpack --allow-empty-checksums -y \
&& choco install nuget.commandline --allow-empty-checksums -y \
&& nuget install MSBuild.Microsoft.VisualStudio.Web.targets -Version 14.0.0.3 \
&& nuget install WebConfigTransformRunner -Version 1.0.0.1
RUN powershell remove-item C:\inetpub\wwwroot\iisstart.*

# Copy files (temporary work folder)
RUN md c:\build
WORKDIR c:/build
COPY . c:/build

# Restore packages, build, copy
RUN nuget restore \
&& "c:\Program Files (x86)\MSBuild\14.0\Bin\MSBuild.exe" /p:Platform="Any CPU" /p:VisualStudioVersion=12.0 /p:VSToolsPath=c:\MSBuild.Microsoft.VisualStudio.Web.targets.14.0.0.3\tools\VSToolsPath AzureCourseAPI.sln \
&& xcopy c:\build\AzureCourseAPI\* c:\inetpub\wwwroot /s

# NOT NEEDED ANYMORE –> ENTRYPOINT powershell .\InitializeContainer