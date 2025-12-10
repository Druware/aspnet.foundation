# FROM mcr.microsoft.com/dotnet/framework/runtime:4.8.1-windowsservercore-ltsc2022
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# since the download fails, we put these in a local folder for install
RUN mkdir \install
COPY ./install/* /install/

# Install 2.9.0 Roslyn compilers
RUN mkdir C:\RoslynCompilers
RUN tar -C C:\RoslynCompilers -zxf c:\install\microsoft.net.compilers.2.9.0.zip
RUN %windir%\Microsoft.NET\Framework64\v4.0.30319\ngen install C:\RoslynCompilers\tools\csc.exe /ExeConfig:C:\RoslynCompilers\tools\csc.exe \
    && %windir%\Microsoft.NET\Framework64\v4.0.30319\ngen install C:\RoslynCompilers\tools\vbc.exe /ExeConfig:C:\RoslynCompilers\tools\vbc.exe \
    && %windir%\Microsoft.NET\Framework64\v4.0.30319\ngen install C:\RoslynCompilers\tools\VBCSCompiler.exe /ExeConfig:C:\RoslynCompilers\tools\VBCSCompiler.exe

# Install 3.6.0 Roslyn compilers
RUN mkdir C:\RoslynCompilers-3.6.0
RUN tar -C C:\RoslynCompilers-3.6.0 -zxf c:\install\microsoft.net.compilers.3.6.0.zip
RUN %windir%\Microsoft.NET\Framework64\v4.0.30319\ngen install C:\RoslynCompilers-3.6.0\tools\csc.exe /ExeConfig:C:\RoslynCompilers-3.6.0\tools\csc.exe \
    && %windir%\Microsoft.NET\Framework64\v4.0.30319\ngen install C:\RoslynCompilers-3.6.0\tools\vbc.exe /ExeConfig:C:\RoslynCompilers-3.6.0\tools\vbc.exe \
    && %windir%\Microsoft.NET\Framework64\v4.0.30319\ngen install C:\RoslynCompilers-3.6.0\tools\VBCSCompiler.exe /ExeConfig:C:\RoslynCompilers-3.6.0\tools\VBCSCompiler.exe

# Install the service monitor

COPY ./install/ServiceMonitor.exe ./

RUN dism /Online /Quiet /Enable-Feature /All /FeatureName:IIS-WebServerRole /FeatureName:NetFx4Extended-ASPNET45 /FeatureName:IIS-ASPNET45
RUN dism /Online /Quiet /Disable-Feature /FeatureName:IIS-WebServerManagementTools
RUN del /q "C:\inetpub\wwwroot\*"
RUN for /D %p IN ("C:\inetpub\wwwroot\*") DO rmdir "%p" /s /q
RUN %windir%\Microsoft.NET\Framework64\v4.0.30319\ngen update \
     && %windir%\Microsoft.NET\Framework\v4.0.30319\ngen update

ENV ROSLYN_COMPILER_LOCATION=C:\RoslynCompilers-3.6.0\tools

EXPOSE 80

ENTRYPOINT ["C:\\ServiceMonitor.exe", "w3svc"]