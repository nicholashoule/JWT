# JWT

### Payload:

```
{
 "id": 1,
 "sub": "1234567890",
 "name": "John Doe",
 "admin": true,
 "jti": "ba251445-11b8-43b7-9cf9-ec3e051ea802",
 "iat": 1539362529,
 "exp": 1539366129
}
```

### Example

```
rsa_secret='
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAtHEDjwkBpsjhit+wXZMMj2AaRHyWSKatjzLtVEGdyXrbQGgQ
PjbfqPtqKsBPjcifHh8VAgrEtETbLN8pbE/XLRaB9P76hib6DATBn2JC6XG/NkAu
...
-----END RSA PRIVATE KEY-----
'

t_payload='{
    "Id": 1,
    "Name": "Hello, world!"
}'
sign rs256 "$t_payload" "$rsa_secret"
```
