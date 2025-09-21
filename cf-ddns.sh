#!/usr/bin/env bash
set -euo pipefail
CF_API_TOKEN="jps7jP8vEjLBuCwpxWP98_LtCJC3t_44AK1-TJ1R"
ZONE_ID="ccf60e342d8ba4948dbdf799d638fbe4"
ZONE_NAME="iri1968.dpdns.org"
RECORD_NAME="prox1.iri1968.dpdns.org"   # ваш поддомен
RECORD_TYPE="A"                  # или AAAA для IPv6
WAN_IP=$(curl -s https://api.ipify.org)

USE_IPV4=true                              # true/false — обновлять A
USE_IPV6=false                             # true/false — обновлять AAAA
PROXIED=false                              # true чтобы через CF proxy (для HTTP(S)); false для чистого DNS
TTL=1                                      # 1 = Auto; иначе 60..86400

api() {
  local method="$1"; shift
  local path="$1"; shift
  curl -sS -X "$method" "https://api.cloudflare.com/client/v4$path" \
    -H "Authorization: Bearer $CF_API_TOKEN" \
    -H "Content-Type: application/json" "$@"
}

get_zone_id() {
  api GET "/zones?name=${ZONE_NAME}&status=active" | jq -r '.result[0].id // empty'
}

get_record_id() {
  local zone_id="$1" type="$2"
  api GET "/zones/${zone_id}/dns_records?type=${type}&name=${RECORD_NAME}" | jq -r '.result[0].id // empty'
}

current_content() {
  local zone_id="$1" type="$2"
  api GET "/zones/${zone_id}/dns_records?type=${type}&name=${RECORD_NAME}" | jq -r '.result[0].content // empty'
}

detect_ipv4() { curl -s https://api.ipify.org; }
detect_ipv6() { curl -s https://api64.ipify.org; }  # вернёт IPv6 при наличии

ensure_record() {
  local zone_id="$1" type="$2" content="$3"
  local rec_id
  rec_id="$(get_record_id "$zone_id" "$type")"

  # Build JSON payload with printf for robustness against shell quoting issues
  local json_payload
  json_payload=$(printf '{"type":"%s","name":"%s","content":"%s","proxied":%s,"ttl":%s}' \
    "$type" "$RECORD_NAME" "$content" "$PROXIED" "$TTL")

  if [[ -z "$rec_id" ]]; then
    echo "Создаю ${type} ${RECORD_NAME} -> ${content}"
    api POST "/zones/${zone_id}/dns_records" --data "$json_payload" | jq . 
  else
    local old
    old="$(current_content "$zone_id" "$type")"
    if [[ "$old" == "$content" ]]; then
      echo "Без изменений: ${type} ${RECORD_NAME} уже ${content}"
      return 0
    fi
    echo "Обновляю ${type} ${RECORD_NAME}: ${old} -> ${content}"
    api PUT "/zones/${zone_id}/dns_records/${rec_id}" --data "$json_payload" | jq . 
  fi
}

main() {
  if ! command -v jq >/dev/null; then echo "Установи jq"; exit 1; fi
  local zone_id; zone_id="$(get_zone_id)"
  if [[ -z "$zone_id" ]]; then echo "Зона ${ZONE_NAME} не найдена или нет прав"; exit 1; fi

  if [[ "$USE_IPV4" == true ]]; then
    ip4="$(detect_ipv4 || true)"; [[ -n "${ip4:-}" ]] && ensure_record "$zone_id" "A" "$ip4"
  fi
  if [[ "$USE_IPV6" == true ]]; then
    ip6="$(detect_ipv6 || true)"; [[ -n "${ip6:-}" ]] && ensure_record "$zone_id" "AAAA" "$ip6"
  fi
}
main "$@"
