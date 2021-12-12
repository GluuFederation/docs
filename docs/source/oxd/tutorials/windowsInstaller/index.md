# Windows Service Installer

## Overview

Microsoft Windows services enable to create long-running executable applications that run in their own Windows sessions. These services can be automatically started when the computer boots, can be paused and restarted, and do not show any user interface. These features make services ideal for use on a server or whenever you need long-running functionality that does not interfere with other users who are working on the same computer.

This tutorial covers the steps involved to generate the `exe` file for the installation of oxd-server as service on Windows operating system.

## Generate oxd windows executable installation file

The important point to be noted here is that the `exe` file can be only generated in Windows OS. oxd team is working further so that in upcoming oxd release windows executable installation file can also be generated in Linux OS.

#### Prerequisites

1. Windows OS

      We can generate `exe` only on Windows OS.

2. JRE 8+

      Install [JRE](https://www.oracle.com/technetwork/java/javase/downloads/jre8-downloads-2133155.html) version 8 or higher. Set `JRE_HOME` environment variable on windows.

3. Inno Setup

      Download and install [Inno Setup](http://www.jrsoftware.org/isdl.php) on Windows OS. Set `INNOSETUP_HOME` environment variable pointing to the home folder of Inno Setup installation (eg: `C:\Program Files (x86)\Inno Setup 5`).

#### Steps to generate EXE

1. Clone oxd project from [Github](https://github.com/GluuFederation/oxd)

      If you have `git` installed, just open a console and run below command to clone the project.
   
      ```
      git clone https://github.com/GluuFederation/oxd.git
      ```
   
1. Check the latest version of `commons daemon windows binaries` at https://downloads.apache.org/commons/daemon/binaries/windows/ and update the version in `commons-daemon.bin.version` property in `${OXD_HOME}/oxd-server/pom.xml`.

      ```
      <commons-daemon.bin.version>1.2.1</commons-daemon.bin.version>
      ```

1. Issue the below command to build oxd project
   
      ```
      mvn clean install -Dmaven.test.skip=true -P windows-build
      ```
   
      Depending on connection speed and computer performance, it may take a couple of minutes to download all required dependencies and build the project.

1. Extract `oxd-server-distribution.zip` generated in `${OXD_HOME}/oxd-server/target` folder. Change directory to the `bin` folder inside the extracted zip file.

1. Double click on `oxd-create-win-service-exe.bat` file and this will generate `oxd-server.exe` outside `bin` folder.

### oxd installation using EXE file

1. To install oxd using `exe` file double click on `oxd-server.exe`.

1. During installation first page that will appear will ask whether oxd should be installed as windows service or not. Select the checkbox to install `oxd as service`.

      ![Page 1](../../img/1_oxd_windows_installation.png)

1. The second page will have license agreement which need to accepted before moving forward.

      ![Page 2](../../img/2_oxd_windows_installation.png)

1. The final page will allow user to select installation directory of oxd server.

      ![Page 3](../../img/3_oxd_windows_installation.png)
   
      If installed as `windows service` then the oxd server will start automatically after the windows machine is started and there is no need to start oxd manually.

      ![Page 4](../../img/4_oxd_windows_installation.png)
   
### oxd uninstall

1. The installed oxd can be uninstalled from `Control Pannel--> Programs-->Uninstall a program`.

      ![Uninstall](../../img/oxd_windows_uninstall.png)

1. oxd can be also uninstalled using `unins000.exe` file inside oxd installation directory (eg: `D:\softwares\oxd-server\unins000.exe`).

