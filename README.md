# NiklasSchmitt-CSPViolation
This is a Znuny package to collect Content-Security-Policy violations.

The Content-Security-Policy of the framework will be enhanced with the `report-uri` directive which sends violations to an webservice. This webservice logs them into SystemLog as `info`.

## Prerequisites
 - Znuny LTS 6.5.x

## Configuration
No additional configuration is needed.

The required Znuny webservice will be installed and configured within the package installation.

