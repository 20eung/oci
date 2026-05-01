#!/bin/bash
export TZ='Asia/Seoul'

# 1. SSH 공용키를 임시 파일로 저장 (가장 안전한 방법)
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCYwSVX6Vx4cGowRU85+sUjS/tyLplw1+wJRJfMt7ahpScqH89GEaP63fIoHkgWC80d7CnEdgjruzLcPib+M+Pus7RpAPGY/POyUpiK3gN11Xi2YkDHDTkPN/YHijxYEdROhBl6bjet5CSLVVkZC3cxpiWp9NRmGlf6/1Tu9s3uxEPf1H4byxoq4ncECDSn8uOOJiyUe1xKSUeGhBEyIC5u7Hf2ARRLxOqT8nfIIhNF3h9pbY51b8InQhVzoRAra+//vGUbSHr26bnDHg6glNR8gVoFwbZOEOEJuGKtScc4csp1CrULZIl0zL/1LJi8iuWosCMA8VgqLihGrD5WNowb ssh-key-2026-04-30" > oci_key.pub

# 변수 설정 [cite: 1, 2]
AD="kbsi:AP-TOKYO-1-AD-1"
COMPARTMENT_ID="ocid1.compartment.oc1..aaaaaaaa2jis5muvqzhzh6xx3tocztihub4ybre42qvephozo22sivsvhtxq"
SUBNET_ID="ocid1.subnet.oc1.ap-tokyo-1.aaaaaaaawjoxz5j6kcm45p54fpsruq4s36xbo3aiac4cq5sgaw5n3ejuyxmq"
IMAGE_ID="ocid1.image.oc1.ap-tokyo-1.aaaaaaaa7wqqllvzpxla3oqfx7mithspzavu3ihvh2xemhzka5nkrxcyomka"

while true
do
    echo "------------------------------------------------"
    echo "시도 시간: $(date)"
    echo "ARM 인스턴스(4 OCPU, 24GB) 생성을 시도합니다..."

    # OCI CLI 실행 (옵션을 --ssh-authorized-keys-file 로 변경)
    oci compute instance launch \
        --availability-domain "$AD" \
        --compartment-id "$COMPARTMENT_ID" \
        --shape "VM.Standard.A1.Flex" \
        --shape-config '{"ocpus": 4.0, "memoryInGBs": 24.0}' \
        --subnet-id "$SUBNET_ID" \
        --image-id "$IMAGE_ID" \
        --assign-public-ip true \
        --display-name "oci-vm-auto" \
        --ssh-authorized-keys-file "oci_key.pub" \
        --wait-for-state RUNNING

    # 실행 결과 확인
    if [ $? -eq 0 ]; then
        echo "✅ 축하합니다! 인스턴스 생성에 성공했습니다."
        rm oci_key.pub  # 임시 키 파일 삭제
        break
    else
        echo "❌ 생성 실패 (자원 부족 또는 일시적 오류). 120초 후 재시도..."
    fi

    sleep 120
done