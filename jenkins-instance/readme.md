# Google Cloud Jenkins Instance Deployment with Terraform

이 저장소는 Terraform을 사용하여 Google Cloud에 Jenkins 인스턴스를 배포하는 코드를 포함하고 있습니다.

## 사전 준비 사항

* Google Cloud Platform (GCP) 계정
* GCP 프로젝트 생성 및 Billing 활성화
* Terraform CLI 설치 ([Terraform 공식 웹사이트](https://www.terraform.io/downloads))
* gcloud CLI 설치 및 초기 설정 ([Google Cloud 문서](https://cloud.google.com/sdk/docs/install))

## 설정

1.  **변수 설정**: `variables.tf` 파일을 확인하고, 필요한 경우 기본값을 수정합니다. 환경별로 다른 값을 사용하려면 `terraform.tfvars` 파일을 생성하거나, 명령줄에서 `-var` 옵션을 사용하여 변수 값을 전달합니다.

    ```terraform
    # variables.tf
    variable "project_id" {
      description = "Google Cloud Project ID"
      type        = string
      default     = "<YOUR_PROJECT_ID>" # 기본값 설정
    }

    variable "region" {
      description = "Google Cloud Region"
      type        = string
      default     = "us-central1" # 기본값 설정
    }

    variable "zone" {
      description = "Google Cloud Zone"
      type        = string
      default     = "us-central1-a" # 기본값 설정
    }
    ```

    ```terraform
    # terraform.tfvars (예시)
    project_id = "my-jenkins-project"
    region     = "us-central1"
    zone       = "us-central1-a"
    ```

2.  **서비스 계정 권한**: `main.tf` 파일에서 `google_project_iam_member` 리소스의 `role`을 Jenkins 인스턴스가 필요한 권한으로 변경합니다.

    ```terraform
    # main.tf (일부)
    resource "google_project_iam_member" "jenkins_sa_compute_viewer" {
      project = var.project_id
      role    = "roles/compute.viewer" # 필요한 권한으로 변경
      member  = "serviceAccount:${google_service_account.jenkins_sa.email}"
    }
    ```

3. Container Analysis API 활성화
```
gcloud services enable containeranalysis.googleapis.com 
gcloud services enable ondemandscanning.googleapis.com
```

## 배포

1.  **Terraform 초기화**: 다음 명령어를 실행하여 필요한 provider를 다운로드합니다.

    ```bash
    terraform init
    ```

2.  **Terraform 계획**: 다음 명령어를 실행하여 변경 사항을 확인합니다.

    ```bash
    terraform plan
    ```

3.  **Terraform 적용**: 다음 명령어를 실행하여 인프라를 생성합니다.

    ```bash
    terraform apply
    ```

    환경별 변수값을 적용하려면 다음처럼 실행합니다.

    ```bash
    terraform apply -var-file="terraform.tfvars"
    ```

4.  **Jenkins 접속**: Terraform 적용 후 출력되는 Jenkins 인스턴스의 외부 IP 주소에 `8080` 포트를 붙여 웹 브라우저에서 접속합니다.

    ```
    http://<외부_IP_주소>:8080
    ```

5.  **초기 비밀번호 확인**: VM 인스턴스에 SSH로 접속하여 `/var/lib/jenkins/secrets/initialAdminPassword` 파일에서 초기 비밀번호를 확인합니다.

    ```bash
    sudo cat /var/lib/jenkins/secrets/initialAdminPassword
    ```

6.  **Jenkins 설정**: 초기 비밀번호를 입력하고, 플러그인 설치 및 사용자 설정을 진행합니다.

## 정리

배포된 리소스를 삭제하려면 다음 명령어를 실행합니다.

```bash
terraform destroy