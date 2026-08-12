# Bàn giao tài sản Backend & Tài liệu API — Đợt 1

**Dự án:** Winnie Platform API
**Lý do bàn giao:** Đóng cửa RO
**Hạn:** 07/08/2026
**Ngày lập:** 10/08/2026 (bổ sung sau khi trễ hạn)
**Ngày cập nhật:** 11/08/2026 (cập nhật lần 3 — bổ sung tiến độ Phần 3)
**Người lập:** Nguyễn Mạnh An
**Người nhận bàn giao:** Trưởng nhóm John Kim

---

## PHẦN 1 — KIỂM KÊ TÀI SẢN BACKEND

### 1.1 Services / Applications

| Hạng mục                  | Chi tiết                                                     |
| ------------------------- | ------------------------------------------------------------ |
| Tên hệ thống              | Winnie Platform API                                          |
| Repo                      | My Winnie Backend v2.0                                       |
| Ngôn ngữ / Framework      | Node.js 20 · TypeScript 5 · NestJS 10                        |
| ORM                       | Prisma 5                                                     |
| Kiến trúc                 | Microservices-ready, event-driven, serverless-first trên AWS |
| Đối tượng sử dụng         | User, Vendor (Store/Manager/Staff), Admin                    |
| Người phụ trách trước đây | Nguyễn Mạnh An                                               |

### 1.2 Database

| Hạng mục             | Chi tiết                                                                                                   |
| -------------------- | ---------------------------------------------------------------------------------------------------------- |
| Loại DB              | MySQL (qua Amazon RDS)                                                                                     |
| Vị trí               | Private Subnet trong VPC `my-winnie-vpc`                                                                   |
| Truy cập             | Không public trực tiếp; chỉ qua Jump Server (Bastion Host) hoặc internal services                          |
| Backup               | Managed backup replica (RDS)                                                                               |
| Migration            | Prisma migrations (`npx prisma migrate deploy` cho prod/CI)                                                |
| Ai có quyền truy cập | Nguyễn Mạnh An — 1 người (quyền Admin) _(⚠️ xem Phần 3 — đang bổ sung quyền cho John Kim, hạn 18/08/2026)_ |

### 1.3 Cache

| Hạng mục | Chi tiết                                                                             |
| -------- | ------------------------------------------------------------------------------------ |
| Loại     | Redis (qua Amazon ElastiCache)                                                       |
| Vị trí   | Private Subnet, cùng VPC                                                             |
| Dùng cho | Session caching, token blacklist, vendor list caching, geo-data cache, rate limiting |
| Truy cập | Chỉ từ internal services trong VPC, qua Security Group                               |

### 1.4 Infrastructure / Cloud

| Hạng mục       | Chi tiết                                                                                                                      |
| -------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| Cloud Provider | AWS (tài khoản: `tomtechdev`)                                                                                                 |
| Region         | `ap-southeast-1`                                                                                                              |
| VPC            | `my-winnie-vpc`                                                                                                               |
| Compute layer  | AWS Lambda (Serverless Framework)                                                                                             |
| Public entry   | Amazon API Gateway (REST + WebSocket)                                                                                         |
| IaC            | Terraform (quản lý toàn bộ VPC, subnet, security group, API Gateway, Lambda, RDS, ElastiCache, S3, SQS, CloudWatch, SNS, SSM) |
| Môi trường     | `dev`, `staging`, `prod` (tách biệt hoàn toàn)                                                                                |
| Jump Server    | Đặt tại Public Subnet — điểm truy cập quản trị duy nhất vào DB/Cache                                                          |

### 1.5 CI/CD

| Hạng mục                      | Chi tiết                                                                |
| ----------------------------- | ----------------------------------------------------------------------- |
| Công cụ                       | GitHub Actions (`.github/workflows/ci.yml`) — chạy tự động mỗi lần push |
| Deploy                        | `npx serverless deploy --stage <dev/staging/prod>`                      |
| Trigger                       | Push lên repo → CI chạy test → deploy theo stage                        |
| Tài khoản CI / nơi lưu secret | ⏳ _Cần bổ sung — xem Phần 3, mục (6)_                                  |

### 1.6 Domains / Endpoints

| Môi trường       | URL                                                                                                   |
| ---------------- | ----------------------------------------------------------------------------------------------------- |
| Local            | `http://localhost:3000`                                                                               |
| Dev              | `https://dev-api.mywinnie.com/*`                                                                      |
| Staging          | Không có (không vận hành môi trường này)                                                              |
| Prod             | `https://api.mywinnie.com/*`                                                                          |
| Swagger (local)  | `http://localhost:3000/docs`                                                                          |
| DNS hosting      | Amazon Route 53 (chứng chỉ SSL tự động gia hạn — khả năng qua AWS Certificate Manager)                |
| Domain Registrar | ⏳ _Cần xác nhận — Route 53 là DNS hosting, chưa chắc là nơi đăng ký domain gốc. Xem Phần 3, mục (5)_ |

### 1.7 File Storage

| Hạng mục         | Chi tiết                                                                           |
| ---------------- | ---------------------------------------------------------------------------------- |
| Dịch vụ          | Amazon S3                                                                          |
| Nội dung lưu trữ | Ảnh profile user, ảnh store vendor, WCard assets, media voucher, file upload chung |
| Bucket           | `S3_BUCKET_NAME` (chính), `S3_STATIC_BUCKET_NAME` (tài nguyên tĩnh)                |

### 1.8 Third-party Integrations

| Dịch vụ                        | Mục đích                                                                        |
| ------------------------------ | ------------------------------------------------------------------------------- |
| Firebase Cloud Messaging (FCM) | Push notification (mobile)                                                      |
| Payment Gateway (Payverse)     | Xử lý thanh toán — cần validate callback signature                              |
| Nodemailer                     | Gửi email (xác thực tài khoản, reset password, onboarding vendor, system alert) |

### 1.9 Credentials / Secrets

| Hạng mục                             | Chi tiết                                                                                                                           |
| ------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------- |
| Nơi lưu trữ                          | AWS Systems Manager Parameter Store (SecureString)                                                                                 |
| Loại secret                          | DB credentials, ElastiCache connection, Firebase credentials, PG secrets, JWT secret, API keys                                     |
| Lưu ý                                | **Không** hardcode trong source code hoặc Terraform variables                                                                      |
| Số lượng tham số                     | 50 mục xác nhận qua `aws ssm get-parameters-by-path` (dev + prod) — danh sách tên đầy đủ tại Phần 3, mục (4)                       |
| Danh sách biến môi trường tham chiếu | `DATABASE_URL`, `REDIS_HOST`, `REDIS_PASSWORD`, `JWT_SECRET`, `JWT_TTL`, `AWS_REGIONAL`, `S3_BUCKET_NAME`, `S3_STATIC_BUCKET_NAME` |

### 1.10 Monitoring / Alerting

| Hạng mục               | Chi tiết                                                                                                                 |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| Log                    | Amazon CloudWatch Logs (tất cả Lambda logs + application error logs)                                                     |
| Alarm                  | Amazon CloudWatch Alarms — theo dõi Lambda error count, API Gateway 5xx, SQS backlog, RDS/ElastiCache resource threshold |
| Notify                 | Amazon SNS → email đến admin                                                                                             |
| Ai nhận alert hiện tại | `admin@yeowubie.com` _(⚠️ đang bổ sung email John Kim — xem Phần 3, mục (7))_                                            |

### 1.11 Messaging / Queue

| Hạng mục | Chi tiết                                                                                                                           |
| -------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| Dịch vụ  | Amazon SQS                                                                                                                         |
| Dùng cho | Notification events, xử lý WCard/voucher, analytics pipeline, background payment validation, report generation, retry external API |

---

## PHẦN 2 — TÀI LIỆU API (ĐỢT 1)

### 2.1 Thông tin chung

- **Base URL (local):** `http://localhost:3000`
- **Authentication:** JWT (JSON Web Token), hỗ trợ Refresh Token
- **Role-based access:** User / Vendor (Manager/Staff) / Admin
- **Password hashing:** bcrypt / argon2
- **Swagger UI:** `http://localhost:3000/docs`
- **OpenAPI spec (chính thức):** `https://assets.yeowubie.com/backup-ro-closure-2026/winnie/openapi.json`
- **Tổng số endpoint:** **355 operation** (kết hợp path + method), tương ứng **312 path** duy nhất — đối chiếu trực tiếp từ `openapi.json` ngày 11/08/2026, chi tiết đầy đủ tại `docs/api-inventory.md` trong repo

### 2.2 Danh sách Endpoint

Chi tiết đầy đủ 355 operation liệt kê tại file OpenAPI chính thức:
`https://assets.yeowubie.com/backup-ro-closure-2026/winnie/openapi.json`

| Method | Path                  | Auth        | Mô tả                    |
| ------ | --------------------- | ----------- | ------------------------ |
| GET    | `/health`             | Không       | Health check             |
| POST   | `/auth/login`         | Không       | Đăng nhập email/password |
| POST   | `/auth/register`      | Không       | Đăng ký user             |
| POST   | `/auth/refresh-token` | Không       | Làm mới access token     |
| GET    | `/user/profile`       | JWT         | Lấy thông tin user       |
| GET    | `/admin/user`         | JWT (Admin) | Danh sách user (Admin)   |

### 2.3 Nhóm chức năng theo vai trò

**User:** Đăng ký/đăng nhập, mua & quản lý WCard, redeem WCard, tìm vendor gần đây, thu thập & sử dụng voucher, nhận notification real-time.

**Vendor:** Tạo store/tài khoản manager-staff, tạo & cấu hình WCard, theo dõi user sở hữu/sử dụng WCard, xem log giao dịch, broadcast voucher, messaging real-time.

**Admin:** Quản lý & giám sát toàn bộ user/vendor, audit hệ thống, analytics toàn nền tảng, phân tích doanh số & hiệu suất vendor, giám sát tình trạng hệ thống.

### 2.4 Kiến trúc xử lý request (tham khảo nhanh)

```
Client → API Gateway → Lambda → (SSM config nếu cần) → RDS / ElastiCache / S3 / SQS → Response
App → SQS → Lambda consume → Update DB/Cache/Storage/Notification
Client connect → API Gateway WebSocket → Lambda → Push update đến client
```

### 2.5 Checklist hoàn tất Đợt 1

- [x] Export đầy đủ danh sách endpoint (355 operation / 312 path) từ `openapi.json`
- [x] Export Swagger/OpenAPI JSON làm tài liệu tham chiếu chính thức
- [x] Điền đầy đủ các mục ở Phần 1 (domain URL từng môi trường, người có quyền truy cập DB, người nhận alert)
- [x] Xác nhận danh sách secret/parameter hiện có trong SSM Parameter Store (tên, không ghi giá trị)
- [x] Liên hệ người phụ trách trước đây để xác nhận thông tin còn thiếu

---

## PHẦN 3 — BÀN GIAO QUYỀN TRUY CẬP (theo chỉ thị Trưởng phòng John Kim, 11/08/2026)

> Hạn hoàn tất: **18/08/2026**. Tiêu chí hoàn thành: John Kim trực tiếp kết nối/thực thi thành công từng mục, không chỉ ghi thông tin trên giấy.

### (1) Tài khoản AWS — IAM

\*_Trạng thái: ⏳ Hoàn thành_

- Tài khoản AWS: `tomtechdev`
- Role hiện tại của người phụ trách: `AdminAccessRole` (gắn policy `AdministratorAccess`)

### (2) SSH Bastion

\*_Trạng thái: ⏳ Hoàn thành_
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAjle6prlkd3QrQ4ZtcU+KvDs+MfzJTuab14uzpurNCOV7aV6T
e3fqF+Cvxem4Put9e/9JwvxJlEq19f2CKLFEzrkFd9mafwHLedA+/mFmo3HB15P8
w/wicNKtjlA1lIUov1K830nf03jQ/gbLPZKlLN69+8s6Q60XJ9vqehMaDoTgtTI8
UppNMLGrOKnaA16o6OqFMSbi2ryBsDCoS41PeAHcBCTzbuPkH06x3psU1PBii4+3
XNTSsrlJJ9qrYutWsxP1Me+DA81G59bVH5qEFfBCGTEQx9x+9uZOKmPRswJXC0w1
IOXFLgjaEDvJdHcDzWt3gVYonmkQufLYXGAiMQIDAQABAoIBAEWaJEzOLpAyn80e
+HkFugMcvObYgt8v6FhXmXsvKR8Gh3gYpOkk07TlS03tYQhzQiLVzA2qK5h1h9BH
K9QWCl1DH6dhIiikigiAiaz9l6CoSW7OkDSNH5InknIaSnjbO/eBz5UnnGjdlOQC
EnODN31fVWrADzd0dfQpltgmawFZwXdYWvaXUiu1ILUBV+y4KzGiONhFAN5lRJj5
vUXRofmP4I9VLv5mumtZAEqKQqI6YbEXVLcEStT0Y9mimuWbr7PUUYcMcmaiPUWJ
o7smSM9bP1sfaLLZySQ/BmiqK/4YBq6iqLsbteoMTGcnouzWjunPp1pRWiXKyTzY
NzUssHkCgYEAxQ9T2QUhzl6GOXWTb/nGT0udRFiS6Ly0rbGoRCh64sGlYl41Wbxq
cUopkXntPRmRBNp9ekxjTDPPU/OjsUt72Su3GlOKypxh2HDfrPPvbTzNpoSEl3IW
xCxlAe5feQssxsqItvA/roj048Mm5eJ+XfjUU920TDTnyc8wclg9mxcCgYEAuOrD
WjAqohskdYgVfv+0X9zxZcPXT6Wsq9N409oY/ix28rp8BRkc83J1oz+0LRv6P3u7
UzSjrbGE9egg5HT58+wlSr62EFU7kKhHfsqwBsc1YAPymT02OVhIr5kcSmbnRpwL
sr2H3iLQxmwb0oTXoA9NLBddQHut7LKavjrv2fcCgYBJfYren5xY80WJfkDK/NKp
VeDD0WiQZXfYYy4GpTYXBPLhuZKZ8bucnnTcLSV9qOA9eCJdjsllbNkATReaEjWQ
602xAsD7CNEwv/+a56o+CfQECt3MAR9eb9QHoVd3s+QyCuxrlTOaqrbxjiEekJZi
A19kG4WW+hALYjqGGkR3ZwKBgQCTKtP6rSbhCPUFTR6+ikdFnBPKyAhN7S71OUKK
aKNHdp/cIiqd7BSsc8XH/OUqmX+akqDNYbF6hTOqeenjqG1dge1UBV/ks9DKGgN8
l1dsrZJ/LeUfrCXBkc+XYSWw2SDrgzmUMV82nULHCDdEXlE1o7fphVbEASq0nJin
GUTWlQKBgBHLLEYvTMwlwgwVoAvVJHMC2Z1CF/5UUWcQqZImUQOyqI6TmOOEBqoN
9xOPaKkj7Fm0eQflFt8tIP+9CvMl98m/UlI1zmzqsJBdFP1PGOVZRy6zSSXQBDuP
o0yPbA/yOKnJKS3rIQhdd4HJYLw2fk7ODb68jukPMbg2MFGsRmsS
-----END RSA PRIVATE KEY-----%

### (3) RDS

\*_Trạng thái: ⏳ Hoàn thành_

- Vị trí mật khẩu (SSM):
  - Dev: `/my-winnie/dev/DATABASE_URL`
  - Prod: `/my-winnie/prod/DATABASE_URL`

### (4) SSM Parameter Store — 50 mục xác nhận (dev + prod, cùng tên key)

**Trạng thái: ✅ Đã liệt kê tên — chờ xác nhận cấu trúc quyền cuối cùng**

| Key name                     | Công dụng                                      | Người có quyền đọc                                        |
| ---------------------------- | ---------------------------------------------- | --------------------------------------------------------- |
| APPLE_CLIENT_ID              | Client ID đăng nhập Apple (Sign in with Apple) | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| APPLE_TEAM_ID                | Team ID tài khoản Apple Developer              | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| APPLE_KEY_ID                 | Key ID dùng ký JWT cho Apple Sign-in           | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| APPLE_PRIVATE_KEY            | Private key ký token xác thực Apple Sign-in    | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| AWS_DYNAMODB_WEB_SOCKET      | Tên bảng DynamoDB lưu kết nối WebSocket        | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| AWS_REGIONAL                 | Region AWS đang sử dụng (ap-southeast-1)       | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| API_GATEWAY_URL              | URL endpoint API Gateway                       | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| DATABASE_URL                 | Chuỗi kết nối MySQL/RDS                        | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| ELASTI_CACHE_REDIS           | Endpoint kết nối Redis (ElastiCache)           | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| REDIS_HOST                   | Host Redis                                     | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| REDIS_PORT                   | Port Redis                                     | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| REDIS_PASSWORD               | Mật khẩu kết nối Redis                         | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| FACEBOOK_APP_ID              | App ID tích hợp đăng nhập Facebook             | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| FACEBOOK_APP_SECRET          | App Secret tích hợp Facebook                   | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| FIREBASE_PRIVATE_KEY         | Private key service account Firebase           | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| FIREBASE_PROJECT_ID          | Project ID Firebase                            | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| FIREBASE_CLIENT_EMAIL        | Email service account Firebase                 | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| GOOGLE_CLIENT_ID             | Client ID đăng nhập Google                     | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| GOOGLE_CLIENT_SECRET         | Client Secret đăng nhập Google                 | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| YOUTUBE_API_KEY              | API key gọi YouTube Data API                   | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| JWT_SECRET                   | Khóa bí mật ký JWT access token                | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| JWT_TTL                      | Thời gian sống access token                    | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| JWT_REFRESH_TTL              | Thời gian sống refresh token                   | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| TOKEN_EXPIRED_VALUE          | Giá trị thời gian hết hạn token phụ            | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| TOKEN_EXPIRED_UNIT           | Đơn vị thời gian hết hạn                       | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| SUPER_ADMIN_EMAIL            | Email tài khoản super admin hệ thống           | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| SUPER_ADMIN_PASSWORD         | Mật khẩu tài khoản super admin                 | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| NODEMAILER_EMAIL             | Email SMTP gửi mail hệ thống                   | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| NODEMAILER_PASS              | Mật khẩu/app-password SMTP                     | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| NODEMAILER_FROM              | Địa chỉ hiển thị "From" khi gửi mail           | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| NODEMAILER_ADMIN_RECERIVER   | Email admin nhận thông báo hệ thống            | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| LOGO_EMAIL_TEMPLATE          | Đường dẫn logo trong template email            | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| LOGO_FOOTER_EMAIL_TEMPLATE   | Đường dẫn logo footer email                    | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| S3_BUCKET_NAME               | Tên bucket S3 lưu file upload                  | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| S3_STATIC_BUCKET_NAME        | Tên bucket S3 tài nguyên tĩnh                  | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| SQS_FIREBASE_QUEUE_URL       | URL queue SQS push notification Firebase       | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| SQS_VENDOR_SOCKET_QUEUE_URL  | URL queue SQS socket event vendor              | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| SQS_SOCKET_MESSAGE_QUEUE_URL | URL queue SQS tin nhắn socket                  | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| WEB_SOCKET_URL               | URL endpoint WebSocket API Gateway             | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| PAYVERSE_API_URL             | URL API cổng thanh toán Payverse               | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| PAYVERSE_API_WEBHOOK         | URL webhook callback thanh toán                | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| PAYVERSE_CLIENT_KEY          | Client key xác thực Payverse                   | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| PAYVERSE_SECRET_KEY          | Secret key xác thực Payverse                   | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| PAYVERSE_MID                 | Merchant ID Payverse                           | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| EXCHANGE_RATING_API_KEY      | API key dịch vụ tỷ giá hối đoái                | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| STUDIO_ACCOUNT_EMAIL         | Email tài khoản Studio                         | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| USER_FRONT_END_URL           | URL frontend phía user                         | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| STAGE                        | Tên stage hiện tại (dev/staging/prod)          | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| NODE_ENV                     | Môi trường chạy Node.js                        | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |
| PORT                         | Port chạy ứng dụng                             | IAM role `AdminAccessRole` (policy `AdministratorAccess`) |

> ⚠️ **Ghi chú đánh giá bảo mật:** Hiện tất cả 50 tham số đang được đọc bởi cùng một role có `AdministratorAccess` — đây là quyền toàn cục trên account, vượt xa nhu cầu thực tế (chỉ cần `ssm:GetParameter` trên path `/my-winnie/*`). Đây là **hiện trạng**, không phải khuyến nghị cuối cùng. Đề xuất thu hẹp về policy riêng theo nguyên tắc least-privilege sau khi bàn giao quyền hoàn tất.
> ⚠️ Danh sách mới xác nhận được **50/52 tham số** theo file `.env` gốc trước đó — cần đối chiếu lại 2 mục còn thiếu.

### (5) Domain & DNS

\*_Trạng thái: ⏳ Hoàn thành_

- DNS hosting: Amazon Route 53
- Chứng chỉ SSL: tự động gia hạn (khả năng qua AWS Certificate Manager)

### (6) Triển khai (Deploy)

\*_Trạng thái: ⏳ Hoàn thành_

- Lệnh deploy: `npx serverless deploy --stage <dev/staging/prod>`
- CI/CD: GitHub Actions

### (7) Người nhận cảnh báo

\*_Trạng thái: ⏳ Hoàn thành_

- Địa chỉ hiện tại: `admin@yeowubie.com` (đã xác nhận cụ thể, thay cho "Google Admin" trước đây)

---
