# Terraform AWS 多環境 CI/CD 


---

## 專案實踐步驟

1. **建立可重用的 Terraform Module**
   - 將所有 AWS 資源（VPC, SG, ECS, IAM, SSM 等）包裝成 `modules/app`，方便多服務重複使用。
   - IAM Role 也抽象化，放進 module，讓不同 app 可共用。

2. **加入 ECS 日誌與健康檢查**
   - 在 ECS Task Definition 中設定 CloudWatch Logs。
   - 設定 `wait_for_steady_state = true`，讓 Terraform 部署時會等待服務穩定。

3. **設定 Terraform State 遠端儲存**
   - 使用 S3 作為 remote backend，DynamoDB 做 state lock。

4. **ECR 由 CI/CD 自動建立**
   - 不在 Terraform 建立 ECR，改由 GitHub Actions 透過 `int128/create-ecr-repository-action` 自動建立。

5. **機密管理改用 SSM Parameter Store**
   - 所有敏感資訊（如 DB 密碼）都放在 AWS SSM Parameter Store，ECS 透過 secrets 注入。
   - 不再用 `terraform.tfvars` 或 CLI 傳遞 secrets。

6. **多環境部署與 CI/CD**
   - 使用 GitHub Actions，根據分支（dev, staging, main）自動部署到對應 AWS 帳號/環境。
   - 各環境 AWS credentials 透過 GitHub Environments Secret 管理。

7. **加入映像檔弱點掃描**
   - 在 CI/CD pipeline 中，build 完 Docker image 後用 Trivy 掃描。
   - 只有通過掃描（無 CRITICAL/HIGH 漏洞）才 push 到 ECR。

8. **多 app 架構支援**
   - modules/app 支援多組參數，可重複部署多個 app/service。
   - 建議每個 app 一個目錄（如 dev/app1, dev/app2），各自調用 module。

---


## 額外修改

- `.gitignore` 排除 `terraform.tfstate*`、`.terraform/`、`backend.hcl`
- Go 程式碼若缺少必要環境變數（如 DB_PASSWORD）應直接 crash，方便偵錯
- Go 以及 docker cache 加速
---

## 可選的修改
- 改成 dev 打包 images , stage & prod 只拉取 dev ECR image 下來做 tag & push  不另外打包 ,除了可節省時間也確保版本一致性
---

## 參考指令

- **初始化/部署某環境**
  ```sh
  cd dev # 或 staging, prod
  terraform init
  terraform apply
  ```

- **CI/CD 觸發**
  - 推送到 dev/staging/main 分支自動觸發對應環境部署

- **SSM 參數管理**
  - 建議用 AWS CLI 寫入：
    ```sh
    aws ssm put-parameter --name "/myapp/dev/DB_PASSWORD" --value "yourpassword" --type SecureString
    ```

---

如需更詳細的範例或有任何問題，歡迎提 issue！ 
