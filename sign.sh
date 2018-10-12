#!/usr/bin/env bash
# Inspired by implementation by Will Haley at:
#   https://willhaley.com/blog/generate-jwt-with-bash/
#   https://stackoverflow.com/questions/46657001/how-do-you-create-an-rs256-jwt-assertion-with-bash-shell-scripting
set -o pipefail

# Shared content to use as header template
h_template='{
    "typ": "JWT",
    "kid": "0001",
    "iss": "9134417ABCD42@ComanyOrg",
    'https://127.0.0.1/contract': true
}'

# Functions
build_header() {
        jq -c \
                --arg iat_str "$(date +%s)" \
                --arg alg "${1:-HS256}" \
        '
        ($iat_str | tonumber) as $iat
        | .alg = $alg
        | .iat = $iat
        | .exp = ($iat + 1)
        ' <<<"$h_template" | tr -d '\n'
}

b64enc() { openssl enc -base64 -A | tr '+/' '-_' | tr -d '='; }
json() { jq -c . | LC_CTYPE=C tr -d '\n'; }
hs_sign() { openssl dgst -binary -sha"${1}" -hmac "$2"; }
rs_sign() { openssl dgst -binary -sha"${1}" -sign <(printf '%s\n' "$2"); }

# Main
sign() {
        local algo payload header sig secret=$3
        algo=${1:-RS256}; algo=${algo^^}
        header=$(build_header "$algo") || return
        payload=${2:-$t_payload}
        signed_content="$(json <<<"$header" | b64enc).$(json <<<"$payload" | b64enc)"
        case $algo in
                HS*) sig=$(printf %s "$signed_content" | hs_sign "${algo#HS}" "$secret" | b64enc) ;;
                RS*) sig=$(printf %s "$signed_content" | rs_sign "${algo#RS}" "$secret" | b64enc) ;;
                *) echo "Unknown algorithm" >&2; return 1 ;;
        esac
        printf '%s.%s\n' "${signed_content}" "${sig}"
}

# call sign
(( $# )) && sign "$@"
