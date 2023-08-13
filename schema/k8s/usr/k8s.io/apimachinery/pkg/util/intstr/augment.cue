package intstr

#IntOrString:     int | string
#IntOrStringPort: _portInt | _portRegex

// from https://stackoverflow.com/a/68568978
_portRegex: "^((6553[0-5])|(655[0-2][0-9])|(65[0-4][0-9]{2})|(6[0-4][0-9]{3})|([1-5][0-9]{4})|([0-5]{0,5})|([0][0-9]{1,4})|([0-9]{1,4}))$"
_portInt:   >=1 & <=65535
