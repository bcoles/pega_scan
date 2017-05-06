# PegaScan

## Description

PegaScan is a simple remote scanner for PegaRules.

## Installation

```
bundle install
gem build pega_scan.gemspec
gem install --local pega_scan-0.0.1.gem
```

## Usage (command line)

```
% PegaScan -h
Usage: PegaScan -u <url> [options]
    -u, --url URL                    PegaRules URL to scan
    -s, --skip                       Skip check for PegaRules
    -v, --verbose                    Enable verbose output
    -h, --help                       Show this help

```

## Usage (ruby)

```
require 'pega_scan'
is_pega    = PegaScan.isPegaRules(url)              # Check if a URL is PegaRules
version    = PegaScan.getVersion(url)               # Get PegaRules version
docs       = PegaScan.documentation(url)            # Check if documentation is available
saml_auth  = PegaScan.samlAuth(url)                 # Check if SAMLAuth SSO is enabled
soap_api   = PegaScan.remoteSoapApi(url)            # Check if SOAP API is accessible
rest_api   = PegaScan.remoteRestApi(url)            # Check if REST API is accessible
sys_mgmt   = PegaScan.systemManagementConsole(url)  # Check if System Management Console is available
nodes      = PegaScan.getSystemManagementNodes(url) # Retrieve list of node names from System Management Console
```

