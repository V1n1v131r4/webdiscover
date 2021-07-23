
__    __     _          ___ _
/ / /\ \ \___| |__      /   (_)___  ___ _____   _____ _ __
\ \/  \/ / _ \ '_ \    / /\ / / __|/ __/ _ \ \ / / _ \ '__|
 \  /\  /  __/ |_) |  / /_//| \__ \ (_| (_) \ V /  __/ |
  \/  \/ \___|_.__/  /___,' |_|___/\___\___/ \_/ \___|_|



The purpose of this script is to automate the web enumeration process and search for exploits and vulns.

Added Tools (dependencies are installed during script execution):

- seclist
- ffuf
- namelist
- dnsrecon
- subfinder
- whatweb
- gospider
- nuclei
- searchsploit
- go-exploitdb

It creates a directory with the scan outputs, as shown in the example below.

![Captura de Tela 2021-07-21 às 12 16 45](https://user-images.githubusercontent.com/1153876/126514379-036f10ff-922b-4d1a-81b5-750d427f7e4a.png)


# Usage

Prerequisites
 * Docker service installed

If you want to build the container yourself manually, git clone the repo:

```
git clone git@github.com:V1n1v131r4/webdiscover.git
```

Then build your docker container

```
docker build -t webdiscover .
```

After building the container, run the following:

```
docker run --rm -it -v /path/to/local/directory:/webdiscoverData webdiscover
```
