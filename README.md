# FreshPlan API
[![Build Status](https://travis-ci.com/j-nguyen/FreshPlanAPI.svg?token=bXWz1QBA9UNTPjTyxj4B&branch=master)](https://travis-ci.com/j-nguyen/FreshPlanAPI)
API created in Vapor, and to be used for school project.

## Requirements
- postgresql (Homebrew)

## Set-up Project

1. Put this in `Config/secrets` folder, and call this `postgresql.json`. Set it to your configuration

```json
{
    "hostname": "127.0.0.1",
    "user": "postgres",
    "password": "hello",
    "database": "test",
    "port": 5432
}
```

1. Add this file called `crypto.json` as well.

```json
{
    "hash": {
        "method": "sha256",
        "encoding": "hex",
        "key": "0000000000000000"
    },
    
    "cipher": {
        "method": "aes256",
        "encoding": "base64",
        "key": "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
    }
}
```