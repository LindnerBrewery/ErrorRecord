# ErrorRecord

Simple Module that helps creating an ErrorRecord

## Overview

The function New-ErrorRecord will create an error record according to your parameters. -Exception will offer you all locally available exception, so you don't have to look for appropriate exceptions

## Installation

``` PowerShell
Install-Module ErrorRecord
```

## Examples

``` PowerShell
New-ErrorRecord -Message MyError -Exception System.IO.FileNotFoundException -Category ObjectNotFound
```
