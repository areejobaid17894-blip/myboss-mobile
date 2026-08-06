#!/usr/bin/env bash
# Verify push notification backend chain and optionally dispatch to employee 4.
set -euo pipefail

GATEWAY="${GATEWAY:-http://127.0.0.1:8090}"
INTERNAL_TOKEN="${INTERNAL_TOKEN:-demo-internal-sync}"
EMPLOYEE_ID="${EMPLOYEE_ID:-4}"

echo "==> Push status"
curl -sf "$GATEWAY/notification/api/v1/push/status" | python3 -m json.tool

echo ""
echo "==> Device tokens for employee $EMPLOYEE_ID"
lookup=$(curl -s -X POST "$GATEWAY/user/api/v1/users/internal/device-tokens/lookup" \
  -H "Content-Type: application/json" \
  -H "X-Internal-Service-Token: $INTERNAL_TOKEN" \
  -d "{\"employeeIds\":[\"$EMPLOYEE_ID\"]}")
echo "$lookup" | python3 -m json.tool

token_count=$(echo "$lookup" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))")
real_tokens=$(echo "$lookup" | python3 -c "
import sys,json
rows=json.load(sys.stdin)
real=[r for r in rows if not r['token'].startswith('manual-') and not r['token'].startswith('emulator-test')]
print(len(real))
for r in real:
    print('  REAL', r['token'][:40]+'...')
")

echo ""
echo "Real FCM tokens from app: $real_tokens"
if [ "$real_tokens" = "0" ]; then
  echo "FAIL: No real device token registered. Install latest APK, login, and allow notifications."
  exit 1
fi

echo ""
echo "==> Dispatch test push to employee $EMPLOYEE_ID"
dispatch=$(curl -s -X POST "$GATEWAY/notification/api/v1/push/internal/dispatch" \
  -H "Content-Type: application/json" \
  -H "X-Internal-Service-Token: $INTERNAL_TOKEN" \
  -d "{\"notificationId\":\"cli-push-test-$(date +%s)\",\"employeeIds\":[\"$EMPLOYEE_ID\"],\"pointer\":{\"v\":\"1\",\"type\":\"admin_broadcast\",\"entityId\":\"cli-test\",\"route\":\"/notifications\",\"sentAt\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}}")
echo "$dispatch" | python3 -m json.tool

sent=$(echo "$dispatch" | python3 -c "import sys,json; print(json.load(sys.stdin).get('summary',{}).get('sent',0))")
if [ "$sent" = "0" ]; then
  echo "FAIL: FCM dispatch did not succeed — check notification-service logs."
  exit 1
fi

echo ""
echo "PASS: Push dispatched successfully ($sent sent). Check your phone for the alert."
