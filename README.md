# Oracle Cloud 무료 서버 완전 정복 — 처음부터 인스턴스 생성까지

> AWS 프리티어의 1GB 서버에 워드프레스를 올렸다가 메모리 부족(OOM)으로 서버가 자꾸 죽는 경험을 해보셨나요?
> Oracle Cloud에는 **완전 무료로 4 OCPU + 24GB RAM**을 제공하는 숨겨진 괴물 서버가 있습니다.
> 이 문서는 오라클 클라우드를 처음 접하는 분들을 위한 단계별 설정 가이드입니다.

### 목차

1. [구획 생성 (Compartments)](#1-구획-생성-compartments)

2. [가상 클라우드 네트워크 (Virtual Cloud Networks)](#2-가상-클라우드-네트워크-virtual-cloud-networks)

3. [보안 목록 (Security Lists)](#3-보안-목록-security-lists)

4. [공용 IP (Reserved Public IPs)](#4-공용-ip-reserved-public-ips)

5. [인스턴스 생성 (Instances)](#5-인스턴스-생성-instances)

    5.1 [Name (이름)](#51-name-이름)

    5.2 [Placement (배치)](#52-placement-배치)

    5.3 [Images (이미지)](#53-images-이미지)

    5.4 [Shape (구성)](#54-shape-구성)

    5.5 [Networking (네트워킹)](#55-networking-네트워킹)

    5.6 [Add SSH keys](#56-add-ssh-keys)

    5.7 [Boot volume (부트 볼륨)](#57-boot-volume-부트-볼륨)

    5.8 [Information (인스턴스 정보)](#58-information)

    5.9 [Public IP (공용 IP)](#59-public-ip-공용-ip)

    5.10 [Out of host capacity 오류 해결](#510-out-of-host-capacity-오류-해결--자동-재시도-스크립트)

6. [네트워크 보안 그룹 (Network Security Group)](#6-네트워크-보안-그룹-network-security-group)

7. [Ubuntu 서버 Swap 설정](#7-ubuntu-서버-swap-설정)


[참고 링크](#참고-링크)

---

## 1. 구획 생성 (Compartments)

<img src="img/menu.png" width="14" height="20"> 메뉴 버튼을 누르고, **Identity & Security (거버넌스 및 관리)** 메뉴를 선택한 후 **Compartments (구획)** 를 클릭합니다.

![](img/oci-compartments-01.png)



**Create Compartment (구획 생성)** 버튼을 클릭합니다.

![](img/oci-compartments-02.png)



**Name (이름)** 과 **Description (설명)** 을 적고 **Create Compartment (구획 생성)** 버튼을 클릭합니다.

![](img/oci-compartments-03.png)



**1st** 라는 구획이 생성된 것을 확인할 수 있습니다.

![](img/oci-compartments-04.png)

---

## 2. 가상 클라우드 네트워크 (Virtual Cloud Networks)

<img src="img/menu.png" width="14" height="20"> 메뉴 버튼을 누르고, **Networking (네트워킹)** 메뉴를 선택한 후 **Virtual cloud networks (가상 클라우드 네트워크)** 를 클릭합니다.

![](img/oci-vcn-01.png)


**Start VCN Wizard (VCN 마법사 시작)** 버튼을 클릭합니다.

![](img/oci-vcn-02.png)


**Create VCN with Internet Connectivity (인터넷 접속을 통한 VCN)** 선택 후 **Start VCN Wizard (VCN 마법사 시작)** 버튼을 클릭합니다.

![](img/oci-vcn-03.png)



Basic Information (기본 정보)에 **VCN name (VCN 이름)** 에 적당한 이름을 넣고,   
**Next (다음)** 버튼을 클릭합니다.

![](img/oci-vcn-04.png)



Review and Create (검토 및 생성) 화면에서 내용을 확인한 후, **Create (생성)** 버튼을 클릭합니다.

![](img/oci-vcn-05.png)



Virtual Cloud Network (가상 클라우드 네트워크) 생성 진행상황을 볼 수 있고, 아래 그림과 같이 완료된 화면이 나옵니다.

![](img/oci-vcn-06.png)



**View VCN (가상 클라우드 네트워크 보기)** 버튼을 누릅니다.

아래와 같이 **Compartment (구획): 1st** 와 **VCN (가상 네트워크): first-vcn** 를 확인할 수 있습니다.

![](img/oci-vcn-07.png)

---

## 3. 보안 목록 (Security Lists)

오른쪽 **Security (보안)** 항목을 클릭하고 **Security Lists (보안 목록)** 에서 Compartment를 클릭하여, **1st** 를 선택합니다.

![](img/oci-vcn-security-list-01.png)


**security list for private subnet-first-vcn** 을 클릭합니다.

![](img/oci-vcn-security-list-02.png)

Ingress Rules (수신 규칙)에 TCP 22 (SSH) 포트만 설정된 것을 확인할 수 있습니다.

![](img/oci-vcn-security-list-03.png)

추가로 포트를 오픈하고자 하면 **Add Ingress Rules (수신 규칙 추가)** 버튼을 클릭하여   
원하는 규칙을 추가할 수 있습니다.

Egress Rules (송신 규칙)은 기본적으로 모두 오픈되어 있습니다.

---

## 4. 공용 IP (Reserved Public IPs)

<img src="img/menu.png" width="14" height="20"> 메뉴 버튼을 누르고, **Networking (네트워킹)** 메뉴를 선택한 후 **Reserved public IPs (예약된 공용 IP)** 를 클릭합니다.

![](img/oci-public-ip-01.png)


**Reserved public IP Address (예약된 공용 IP 주소)** 버튼을 클릭합니다.

![](img/oci-public-ip-02.png)



**Reserved public IP address name (예약된 공용 IP 주소 이름)** 에 원하는 이름을 적고 **Reserved public IP address (예약된 공용 IP 주소)** 버튼을 클릭합니다.

![](img/oci-public-ip-03.png)



아래와 같이 공용 IP 주소를 확인할 수 있습니다.

![](img/oci-public-ip-04.png)


***

> [!WARNING]
> **Always Free 인스턴스 유휴 회수 정책 (중요)**
>
> Oracle Cloud는 Always Free 인스턴스가 **7일 연속**으로 아래 기준 미만인 유휴 상태일 경우,
> 인스턴스를 자동으로 **중지하거나 회수**할 수 있습니다.
> - CPU 평균 사용률 10% 미만
> - 네트워크 수신 500MB / 7일 미만
>
> **방지 방법**: `cron`으로 주기적으로 부하를 발생시키는 스크립트를 등록합니다.
>
> ```bash
> # crontab -e 로 등록 (매 10분마다 간단한 연산 실행)
> */10 * * * * /usr/bin/sha256sum /dev/urandom | head -c 1M > /dev/null 2>&1
> ```
>
> 또는 실제 서비스(웹서버, 봇 등)를 상시 실행하면 자연스럽게 회수를 방지할 수 있습니다.

---

## 5. 인스턴스 생성 (Instances)

<img src="img/menu.png" width="14" height="20"> 메뉴 버튼을 누르고, **Compute (컴퓨트)** 메뉴를 선택한 후 **Instances (인스턴스)** 를 클릭합니다.

![](img/oci-instance-01.png)


**Create instance (인스턴스 생성)** 버튼을 클릭합니다.

![](img/oci-instance-02.png)


> ### 5.1 Name (이름)

**Name (이름)** 항목에 자신이 원하는 이름을 적습니다.

![](img/oci-instance-03.png)

**Placement (배치)** 항목의 **Edit (편집)** 을 클릭하거나   
**Images and shape (이미지 및 구성)** 항목의 **Edit (편집)** 을 클릭하면


> ### 5.2 Placement (배치)

**Placement (배치)** 에서는 Availability domain (가용성 도메인)을 변경할 수 있습니다.

![](img/oci-instance-04.png)


> ### 5.3 Images (이미지)

**Images and shape (이미지 및 구성)** 에서는 OS 이미지를 변경할 수 있습니다.

기본 OS 이미지는 Oralce Linux 입니다.

**Change image (이미지 변경)** 버튼을 눌러 변경할 수 있습니다.

![](img/oci-instance-05.png)


Ubuntu, Red Hat, CentOS, Windows 등의 OS를 선택할 수 있습니다.

여기서는 **Ubuntu** 와 **Canonical Ubuntu 24.04** 버전을 선택하겠습니다.

> 2026년 기준 표준 지원 중 (2029년 4월까지 지원)
> Ubuntu 20.04 LTS는 2025년부터 ESM(확장 보안 유지보수)으로 전환되었으므로 24.04 LTS를 권장합니다.

![](img/oci-instance-07.png)

하단의 **Select image (이미지 선택)** 버튼을 누릅니다.

OS 이미지가 Oracle Linux에서 Canonical Ubuntu로 바뀐 것을 확인할 수 있습니다.

**Shape (구성)** 의 **Change shape (구성편집)** 버튼을 누르면   
CPU 타입별 구성을 선택할 수 있습니다.

![](img/oci-instance-08.png)


> ### 5.4 Shape (구성)

**Ampere** 를 선택했을 때의 화면입니다.  

**Always Free-eligible (항상 무료 적격)** 이 표시된 것을 확인할 수 있습니다.

![](img/oci-instance-09.png)

> **Oracle Always Free의 핵심 혜택 — Ampere A1 Flex**
>
> Ampere A1 Compute (VM.Standard.A1.Flex) 는 **무료**임에도 아래와 같은 파격적인 스펙을 제공합니다:
>
> | 항목 | 내용 |
> |------|------|
> | 총 무료 할당량 | **4 OCPU + 24 GB RAM** (월 기준) |
> | 활용 방법 | 1개 인스턴스에 4 OCPU / 24 GB 전부 할당 가능 |
> | 분산 사용 | 또는 최대 4개 인스턴스로 나눠서 사용 가능 |
> | 네트워크 | OCPU당 1 Gbps 대역폭 / 월 10 TB 무료 전송량 |
>
> 타사 유료 호스팅 기준으로 월 3~5만 원 이상의 스펙을 완전 무료로 사용할 수 있습니다.
> Nginx와 캐시 플러그인(WP Super Cache, Redis 등)을 세팅하면 **일 방문자 1만~5만 명** 수준의 트래픽도 안정적으로 처리 가능하며,
> 월 네트워크 전송량(10 TB) 기준으로는 **월 500만 뷰**도 감당할 수 있습니다.
>
> AWS, GCP 등 다른 클라우드 무료 티어와 비교하면 압도적인 수준입니다.
> 초보자라면 **Ampere A1 Flex (4 OCPU / 24 GB)** 단일 인스턴스 구성을 강력히 권장합니다.

**VM.Standard.A1.Flex** (Ampere) 를 선택하고, OCPU와 메모리를 원하는 값으로 설정합니다.

![](img/oci-instance-10.png)

**Shape** 가 **VM.Standard.A1.Flex** **4 core OCPU, 24 GB memory** 로 설정된 것을 확인할 수 있습니다.

![](img/oci-instance-11.png)

***
> ### 5.5 Networking (네트워킹)

**Networking (네트워킹)** 의 **Primary VNIC** 의 **VNIC name** 에 이름을 적어줍니다.

![](img/oci-instance-12.png)


Virtual Cloud Network (가상 클라우드 네트워크), Subnet (서브넷), Public IPv4 address (공용 IPv4 주소) 설정을 변경할 수 있습니다.

![](img/oci-instance-13.png)



**Subnet (서브넷)** 을 누르면   
Private subnets (전용 서브넷)과 Public subnets (공용 서브넷)을 선택할 수 있습니다.

![](img/oci-instance-14.png)



**Advanced options (고급 옵션 표시)** 를 클릭하면   
인스턴스의 사설 IP와 호스트 이름을 미리 지정할 수 있습니다.

![](img/oci-instance-15.png)


> ### 5.6 Add SSH keys

인스턴스에 접속하기 위한 SSH 키를 추가하는 메뉴입니다.

오라클 클라우드에서 생성해준 private key (전용 키)와 public key (공용 키)를 다운로드하여 사용할 수 있습니다.

![](img/oci-instance-16.png)

기존에 사용하던 public key (공용 키)를 업로드하여 사용할 수 있습니다.

![](img/oci-instance-17.png)


또는 기존에 사용하던 public key (공용 키)를 텍스트로 복사한 후 붙여넣기로 사용할 수 있습니다.

![](img/oci-instance-18.png)



#### SSH 키를 직접 생성하는 방법 (초보자 권장)

SSH 키가 없다면 아래 방법으로 직접 생성할 수 있습니다.

**Mac / Linux / Windows 11 터미널**

```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
# 저장 경로 물음: Enter 로 기본값(~/.ssh/id_rsa) 사용
# 비밀번호 물음: Enter 로 생략 가능
```

생성 후 공개 키를 확인합니다:

```bash
cat ~/.ssh/id_rsa.pub
```

**Windows PowerShell**

```powershell
ssh-keygen -t rsa -b 4096
# 생성 후 공개 키 확인:
type $env:USERPROFILE\.ssh\id_rsa.pub
```

위에서 출력된 `ssh-rsa AAAA...` 로 시작하는 공개 키 전체를 복사하여   
OCI 콘솔의 **Paste public keys** 란에 붙여넣습니다.



> ### 5.7 Boot volume (부트 볼륨)

Boot volume (부트 볼륨) 크기도 설정 가능합니다.   
오른쪽으로 버튼을 드래그하면

![](img/oci-instance-19.png)

아래와 같이 설정 화면이 나옵니다.

![](img/oci-instance-20.png)

모든 설정을 마쳤으면 아래 **Next (다음)** 버튼을 클릭합니다.

![](img/oci-instance-21.png)


***
> ### 5.8 Information

Instance (인스턴스)
생성이 완료된 화면으로 인스턴스 정보를 확인할 수 있습니다.

- OS 이미지 정보 (Image)
- 구성 정보 (Shape)
- 공용 IP 정보 (Public IP)
- 전용 IP 정보 (Private IP)

![](img/oci-instance-22.png)



***
> ### 5.9 Public IP (공용 IP)

사전에 생성한 Pubic IP (공용 IP)를 사용하려면   
왼쪽 하단의 **Attached VNICs (연결된 VNIC)** 을 클릭합니다.

현재 설정된 내용을 확인할 수 있습니다. Name 항목의 인스턴스 이름을 클릭합니다.

![](img/oci-instance-23.png)



VNIC 정보와 Public IP (공용 IP) 확인할 수 있습니다.

![](img/oci-instance-24.png)



IPv4 Address 항목의 Private IP Address (전용 IP 주소)의    
오른쪽 끝의 점 3개를 클릭한 후 Edit (편집)를 누릅니다.

![](img/oci-instance-26.png)



Public IP Type (공용 IP 유형)에서 No public IP (공용 IP 없음)을 선택 후    
Update (업데이트)를 누릅니다. 자동으로 생성된 Public IP (공용 IP)를 제거하는 작업입니다.

![](img/oci-instance-27.png)



IPv4 Address에서 Public IP Address (공용 IP 주소) 가 비어 있는 것을 확인할 수 있습니다.

다시 오른쪽 끝 점 3개를 클릭한 후 Edit (편집)를 누릅니다.

![](img/oci-instance-28.png)



Public IP Type (공용 IP 유형)에서 Reserved public IP (예약된 공용 IP)을 클릭하면    
Select Existing Reserved IP Address (기존 예약된 IP 주소 선택) 메뉴가 나오고,    
값을 선택할 수 있습니다.

![](img/oci-instance-29.png)



Update (업데이트)를 누릅니다.

사전에 생성한 Pubic IP (공용 IP)로 변경된 것을 확인할 수 있습니다.

![](img/oci-instance-30.png)


> ### 5.10 "Out of host capacity" 오류 해결 — 자동 재시도 스크립트

Ampere A1 Flex 인스턴스는 인기가 많아 **"Out of host capacity."** 오류로 생성이 거부되는 경우가 잦습니다.
수동으로 반복 시도하는 대신 두 가지 방법으로 자동화할 수 있습니다.

> [!NOTE]
> OCI Cloud Shell은 일정 시간 비활성 상태가 되면 세션이 종료되어 `nohup` 프로세스도 함께 종료됩니다.
> **며칠씩 안정적으로 재시도하려면 GitHub Actions 방법을 권장합니다.**

---

#### 방법 A — OCI Cloud Shell (단기 재시도)

브라우저 탭을 유지하는 동안에만 동작합니다. 아래 스크립트를 **OCI Cloud Shell**에서 백그라운드로 실행하면 자원이 확보될 때 자동으로 생성됩니다.

**1단계 — 스크립트 작성**

아래 내용을 `launch.sh`로 저장하고, 변수 4개를 본인 환경에 맞게 수정합니다.

```bash
#!/bin/bash
export TZ='Asia/Seoul'

# SSH 공개 키를 임시 파일로 저장
echo "ssh-rsa AAAA...your_public_key..." > oci_key.pub

# 변수 설정 (본인 환경에 맞게 수정)
AD="kbsi:AP-TOKYO-1-AD-1"
COMPARTMENT_ID="ocid1.compartment.oc1..xxxxxx"
SUBNET_ID="ocid1.subnet.oc1.ap-tokyo-1.xxxxxx"
IMAGE_ID="ocid1.image.oc1.ap-tokyo-1.xxxxxx"

while true
do
    echo "------------------------------------------------"
    echo "시도 시간: $(date)"
    echo "ARM 인스턴스(4 OCPU, 24GB) 생성을 시도합니다..."

    oci compute instance launch \
        --availability-domain "$AD" \
        --compartment-id "$COMPARTMENT_ID" \
        --shape "VM.Standard.A1.Flex" \
        --shape-config '{"ocpus": 4, "memoryInGB": 24}' \
        --subnet-id "$SUBNET_ID" \
        --image-id "$IMAGE_ID" \
        --assign-public-ip true \
        --display-name "oci-vm-auto" \
        --ssh-authorized-keys-file "oci_key.pub" \
        --wait-for-state RUNNING

    if [ $? -eq 0 ]; then
        echo "인스턴스 생성에 성공했습니다."
        rm oci_key.pub
        break
    else
        echo "생성 실패. 120초 후 재시도..."
    fi

    sleep 120
done
```

> **변수 확인 방법**
> - `COMPARTMENT_ID` : **Identity & Security → Compartments** 에서 구획 OCID 복사
> - `SUBNET_ID` : **Networking → Virtual Cloud Networks → 서브넷** 에서 OCID 복사
> - `IMAGE_ID` : 인스턴스 생성 화면에서 이미지 선택 후 이미지 OCID 복사
> - `AD` : 가용성 도메인 이름 (예: `namespace:AP-TOKYO-1-AD-1`)

**2단계 — OCI Cloud Shell에 업로드**

콘솔 오른쪽 상단의 Cloud Shell 아이콘을 클릭한 후, 파일 업로드 기능으로 `launch.sh`를 업로드합니다.

**3단계 — 실행 권한 부여 및 백그라운드 실행**

```bash
chmod +x launch.sh
nohup ./launch.sh > output.log 2>&1 &
```

**4단계 — 로그 확인**

Cloud Shell 세션이 종료되어도 프로세스는 계속 실행됩니다. 아래 명령어로 진행 상황을 확인합니다.

```bash
tail -f output.log
```

로그에 **"인스턴스 생성에 성공했습니다."** 메시지가 출력되면 완료입니다.

---

#### 방법 B — GitHub Actions (장기 재시도, 권장)

브라우저를 닫아도 GitHub 서버에서 10분마다 자동으로 재시도합니다. 인스턴스 생성에 성공하면 워크플로우가 자동으로 비활성화됩니다.

**1단계 — GitHub Secrets 등록**

저장소의 **Settings → Secrets and variables → Actions** 에서 아래 7개 시크릿을 등록합니다.

| Secret 이름 | 값 |
|---|---|
| `OCI_USER_OCID` | 사용자 OCID (`ocid1.user.oc1..xxxxxx`) |
| `OCI_TENANCY_OCID` | 테넌시 OCID (`ocid1.tenancy.oc1..xxxxxx`) |
| `OCI_FINGERPRINT` | API 키 핑거프린트 (`xx:xx:xx:...`) |
| `OCI_PRIVATE_KEY` | API 서명 개인 키 전체 내용 (`-----BEGIN PRIVATE KEY-----` 포함) |
| `OCI_REGION` | 리전 식별자 (예: `ap-tokyo-1`) |
| `OCI_AD` | 가용성 도메인 (예: `namespace:AP-TOKYO-1-AD-1`) |
| `OCI_COMPARTMENT_ID` | 구획 OCID |
| `OCI_SUBNET_ID` | 서브넷 OCID |
| `OCI_IMAGE_ID` | 이미지 OCID |
| `OCI_SSH_PUBLIC_KEY` | SSH 공개 키 전체 내용 (`ssh-rsa AAAA...`) |

> **OCI API 키 발급 방법**
> OCI 콘솔 오른쪽 상단 사용자 아이콘 → **My profile → API keys → Add API key** 에서
> 키 쌍을 생성하고 개인 키(`.pem` 파일)와 핑거프린트를 확인합니다.

**2단계 — 워크플로우 파일 추가**

아래 경로로 파일을 생성합니다: `.github/workflows/launch-oci.yml`

```yaml
name: OCI Instance Auto-Launch

on:
  schedule:
    - cron: '*/10 * * * *'  # 10분마다 실행
  workflow_dispatch:         # 수동 실행 가능

jobs:
  launch:
    runs-on: ubuntu-latest
    timeout-minutes: 8

    steps:
      - name: OCI CLI 설치
        run: pip install oci-cli --quiet

      - name: OCI CLI 설정
        env:
          OCI_PRIVATE_KEY: ${{ secrets.OCI_PRIVATE_KEY }}
          OCI_USER_OCID: ${{ secrets.OCI_USER_OCID }}
          OCI_FINGERPRINT: ${{ secrets.OCI_FINGERPRINT }}
          OCI_TENANCY_OCID: ${{ secrets.OCI_TENANCY_OCID }}
          OCI_REGION: ${{ secrets.OCI_REGION }}
        run: |
          mkdir -p ~/.oci
          printf '%s' "$OCI_PRIVATE_KEY" > ~/.oci/private_key.pem
          chmod 600 ~/.oci/private_key.pem
          cat > ~/.oci/config << EOF
          [DEFAULT]
          user=$OCI_USER_OCID
          fingerprint=$OCI_FINGERPRINT
          tenancy=$OCI_TENANCY_OCID
          region=$OCI_REGION
          key_file=/root/.oci/private_key.pem
          EOF

      - name: 기존 인스턴스 확인
        id: check
        env:
          OCI_COMPARTMENT_ID: ${{ secrets.OCI_COMPARTMENT_ID }}
        run: |
          COUNT=$(oci compute instance list \
            --compartment-id "$OCI_COMPARTMENT_ID" \
            --display-name "oci-vm-auto" \
            --lifecycle-state RUNNING \
            --query 'length(data)' \
            --raw-output 2>/dev/null || echo "0")
          echo "count=$COUNT" >> $GITHUB_OUTPUT

      - name: 인스턴스 생성 시도
        if: steps.check.outputs.count == '0'
        id: launch
        env:
          OCI_AD: ${{ secrets.OCI_AD }}
          OCI_COMPARTMENT_ID: ${{ secrets.OCI_COMPARTMENT_ID }}
          OCI_SUBNET_ID: ${{ secrets.OCI_SUBNET_ID }}
          OCI_IMAGE_ID: ${{ secrets.OCI_IMAGE_ID }}
          OCI_SSH_PUBLIC_KEY: ${{ secrets.OCI_SSH_PUBLIC_KEY }}
        run: |
          printf '%s' "$OCI_SSH_PUBLIC_KEY" > /tmp/oci_key.pub
          echo "시도 시간: $(date '+%Y-%m-%d %H:%M:%S %Z')"
          oci compute instance launch \
            --availability-domain "$OCI_AD" \
            --compartment-id "$OCI_COMPARTMENT_ID" \
            --shape "VM.Standard.A1.Flex" \
            --shape-config '{"ocpus": 4.0, "memoryInGBs": 24.0}' \
            --subnet-id "$OCI_SUBNET_ID" \
            --image-id "$OCI_IMAGE_ID" \
            --assign-public-ip true \
            --display-name "oci-vm-auto" \
            --ssh-authorized-keys-file /tmp/oci_key.pub \
            --wait-for-state RUNNING && \
            echo "success=true" >> $GITHUB_OUTPUT

      - name: 성공 시 워크플로우 자동 비활성화
        if: steps.launch.outputs.success == 'true'
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          GH_REPO: ${{ github.repository }}
        run: |
          curl -s -X PUT \
            -H "Authorization: Bearer $GH_TOKEN" \
            -H "Accept: application/vnd.github+json" \
            "https://api.github.com/repos/$GH_REPO/actions/workflows/launch-oci.yml/disable"
```

**3단계 — 커밋 & 푸시**

```bash
git add .github/workflows/launch-oci.yml
git commit -m "Add OCI instance auto-launch workflow"
git push
```

푸시 후 저장소의 **Actions** 탭에서 실행 상태를 확인할 수 있습니다.
인스턴스 생성에 성공하면 워크플로우가 자동으로 비활성화되고, Actions 탭에서도 확인 가능합니다.

---

## 6. 네트워크 보안 그룹 (Network Security Group)


> ### 6.1 보안 목록(Security Lists)과 네트워크 보안 그룹(Network Security Groups) 차이점

| 보안 도구 | 적용 대상 | 사용 방법 | 제한 사항 |
|----------|----------|----------|----------|
| 보안 목록 | 서브넷의 모든 VNIC | 서브넷에 연결 | 서브넷 당 최대 5개 |
| 네트워크 보안 그룹 | 동일한 VCN의 선택된 NVIC | VNIC에 추가 | VNIC당 최대 5개 |

네트워크 보안 그룹(Network Security Groups)를 사용하면 애플리케이션 보안 요구 사항에서 VCN의 서브넷 아키텍처를 분리할 수 있으므로 Oracle은 보안 목록 대신 NSG를 사용할 것을 권장합니다.


> ### 6.2 **Network Security Group (네트워크 보안 그룹)** 만들기

**VCN (가상 클라우드 네트워크) 등록 정보** 화면의 왼쪽에 있는 Resources (리소스) 중 **Network Security Group (네트워크 보안 그룹)** 을 클릭하고,   
**Create Network Security Group (네트워크 보안 그룹 생성)** 버튼을 누릅니다.

![](img/oci-nsg-01.png)



**Name (이름)** 을 적고 다음 버튼을 누릅니다.

![](img/oci-nsg-02.png)



**Add Security Rules (보안 규칙 추가)** 의 Rule (규칙)에 보안 규칙을 정의한 후 Create (생성) 버튼을 클릭합니다.

- Direction(방향): Ingress(수신), Egress(송신)
- Source Type(소스 유형): CIDR, Services(서비스), NSG(네트워크 보안 그룹)
- IP Protocol: ICMP, RDP, SSH, TCP, UDP, 모든 프로토콜 등
- Destination Port Range(대상 포트 범위): 콤마(,)로 여러 개 입력 가능

![](img/oci-nsg-03.png)



생성된 Security Rules (보안 규칙)을 확인할 수 있습니다.   
**Add Rules (규칙 추가)** 버튼을 눌러 여러 개의 규칙을 추가할 수 있습니다.

![](img/oci-nsg-04.png)


> ### 6.3 **Network Security Group (네트워크 보안 그룹)** 을 인스턴스에 적용하기

<img src="img/menu.png" width="14" height="20"> 메뉴 버튼을 누르고, 
**Compute (컴퓨트)** 메뉴를 선택한 후  
**Instances (인스턴스)** 를 클릭합니다.

인스턴스를 눌러 **Instance Details (세부 등록 정보)** 화면으로 이동합니다.

왼쪽 Resources (리소스) 메뉴 중 **Attached VNICs (연결된 VNIC)** 를 클릭하고, 
인스턴스와 동일한 **기본 VNIC** 을 클릭하여   
**VNIC 세부 정보** 화면으로 이동합니다.

**Primary IP Information (기본 IP 정보)** 의 **Network Security Groups (네트워크 보안 그룹)** 항목의 **Edit (편집)** 을 클릭합니다.

![](img/oci-nsg-05.png)


리스트 박스를 클릭하여 미리 생성한 Network Security Group (네트워크 보안 그룹)을 선택하고, Save changes (변경사항 저장) 버튼을 클릭하여 VNIC에 Network Security Group (네트워크 보안 그룹)을 추가합니다.

이 과정을 최대 5번 반복할 수 있습니다.

![](img/oci-nsg-06.png)



***
## 7. Ubuntu 서버 Swap 설정

워드프레스를 1GB RAM 서버에 올렸을 때 서버가 자꾸 멈추는 가장 흔한 원인이 바로 메모리 부족(OOM, Out of Memory)입니다.
Swap 공간을 설정하면 물리 메모리가 부족할 때 디스크를 임시 메모리로 활용하여 갑작스러운 프로세스 강제 종료를 방지할 수 있습니다.

> **참고**: Ampere A1 Flex (24 GB RAM)를 선택했다면 Swap 설정은 선택 사항입니다.
> AMD VM.Standard.E2.1.Micro (1 GB RAM)를 사용하는 경우에는 반드시 설정하는 것을 권장합니다.

- Ubuntu 22.04 / 24.04 LTS에서도 동일하게 적용 가능합니다.
- Add Swap Space 문서 참조: https://github.com/20eung/ubuntu-swap


***

## 마치며

여기까지 모든 단계를 완료하셨다면, 이제 여러분만의 **완전 무료 클라우드 서버**가 완성된 것입니다.

Ampere A1 Flex 인스턴스(4 OCPU / 24 GB RAM)에 Nginx와 캐시 플러그인을 세팅하면,
워드프레스 기준으로 **일 방문자 1만~5만 명** 수준의 트래픽도 CPU/메모리 그래프가 안정적으로 유지됩니다.
타사 유료 호스팅을 사용했다면 월 3~5만 원 이상 지출해야 할 스펙을, 오라클 클라우드는 평생 무료로 제공합니다.

서버 구축 과정을 블로그 포스팅으로 남겨두면 좋습니다.
"1GB 서버가 OOM으로 자꾸 죽어서 → Ampere A1을 발견하고 → 서버를 완성했다"는 흐름은
독자의 공감을 이끌어내기 좋은 구성이며, 체류 시간과 재방문율을 높이는 데 효과적입니다.

***
> ### 참고 링크

- Docker, Portainer, Watch Tower 설치 방법 : https://github.com/20eung/docker-portainer-watchtower

- 오라클 클라우드 구획, 가상 네트워크, 방화벽, 공용IP 설정하기 : https://www.wsgvet.com/cloud/4

- 오라클 클라우드 인스턴스 생성, SSH 접속하기 : https://www.wsgvet.com/cloud/5
