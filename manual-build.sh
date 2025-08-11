# 基本參數
export AWS_REGION=ap-northeast-1
export REPO=myapp-dev

# ECR 登入與建立
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
aws ecr describe-repositories --region "$AWS_REGION" --repository-names "$REPO" >/dev/null 2>&1 || \
aws ecr create-repository --region "$AWS_REGION" --repository-name "$REPO" >/dev/null
aws ecr get-login-password --region "$AWS_REGION" | \
docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

# 建 builder + buildx multi-arch
IMAGE_URI=${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO}
SHORT_SHA=$(git rev-parse --short HEAD)
SHORT_SHA=test
docker buildx create --name multiarch --use >/dev/null 2>&1 || docker buildx use multiarch
docker buildx inspect --bootstrap

# 推 multi-arch manifest（amd64 + arm64）
docker buildx build --platform linux/amd64,linux/arm64 \
  -t ${IMAGE_URI}:dev-${SHORT_SHA} -t ${IMAGE_URI}:dev-latest \
  -f Dockerfile --push .

echo "Use this image_tag in Terraform: dev-test"
