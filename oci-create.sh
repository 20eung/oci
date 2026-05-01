#!/bin/bash

export TZ='Asia/Seoul'
PATH="$HOME/bin:$PATH"

LOG_FILE="$HOME/Project/oci/oci-instance.log"

COMPARTMENT_ID="ocid1.compartment.oc1..aaaaaaaa2jis5muvqzhzh6xx3tocztihub4ybre42qvephozo22sivsvhtxq"
AVAILABILITY_DOMAIN="kbsi:AP-TOKYO-1-AD-1"
SUBNET_ID="ocid1.subnet.oc1.ap-tokyo-1.aaaaaaaawjoxz5j6kcm45p54fpsruq4s36xbo3aiac4cq5sgaw5n3ejuyxmq"
IMAGE_ID="ocid1.image.oc1.ap-tokyo-1.aaaaaaaa7wqqllvzpxla3oqfx7mithspzavu3ihvh2xemhzka5nkrxcyomka"
SSH_KEY_FILE="$HOME/.oci/oci-ssh-key.pub"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] 인스턴스 자동 생성 시작" | tee -a "$LOG_FILE"

while true; do
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 생성 시도 중..." | tee -a "$LOG_FILE"

    RESULT=$(oci compute instance launch \
        --compartment-id "$COMPARTMENT_ID" \
        --availability-domain "$AVAILABILITY_DOMAIN" \
        --shape "VM.Standard.A1.Flex" \
        --shape-config '{"ocpus": 4, "memoryInGBs": 24}' \
        --subnet-id "$SUBNET_ID" \
        --image-id "$IMAGE_ID" \
        --assign-public-ip true \
        --boot-volume-size-in-gbs 50 \
        --ssh-authorized-keys-file "$SSH_KEY_FILE" \
        --display-name "oci-vm-auto" \
        2>&1)

    if echo "$RESULT" | grep -q "ocid1.instance"; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 성공! 인스턴스가 생성되었습니다." | tee -a "$LOG_FILE"
        echo "$RESULT" | grep -o '"id": "ocid1.instance[^"]*"' | tee -a "$LOG_FILE"
        exit 0
    else
        MSG=$(echo "$RESULT" | grep -o '"message": "[^"]*"' | head -1)
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 실패 - $MSG" | tee -a "$LOG_FILE"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 120초 후 재시도..." | tee -a "$LOG_FILE"
    fi

    sleep 120
done
