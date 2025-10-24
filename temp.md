프로젝트 개발용 Claude 커넥터/도구 추천
1️⃣ 문서 검토 및 분석
도구/커넥터 기능 활용 사례
PDF Tools (Claude) PDF 분석, 데이터 추출, 양식 자동 작성, 비교 기획서, 계약서, 연구 보고서, DB 설계 PDF 검토
Markdown / VS Code 통합 .md 파일 실시간 분석, 코드 블록 검토 기능 정의서, DB 설계서, 분석 보고서 검토
Microsoft Word / Excel Connector DOCX, XLSX 읽기·쓰기 기획서/기능 정의서 DOCX 변환 후 AI 검토, 테이블 기반 DB 설계 검토
2️⃣ 코드 및 DB 설계 검토
도구/커넥터 기능 활용 사례
GitHub / GitLab 커넥터 코드/문서 버전 관리, diff 분석 DB 설계 변경 추적, 기능 정의서 수정 내역 검토
SQL / MySQL Workbench 연결 DB 스키마 분석, 쿼리 검증 설계된 DB 구조 검토, 정규화 및 인덱스 확인
Jupyter Notebook / Python 스크립트 데이터 시뮬레이션, 분석 ERD, 관계 확인, 샘플 데이터 검증
3️⃣ 협업 및 워크플로우 도구
도구/커넥터 기능 활용 사례
Notion / Obsidian 커넥터 프로젝트 문서 중앙 관리 기획서, 기능 정의서, DB 설계 문서 통합 관리
Slack / Teams 커넥터 실시간 피드백, 알림 문서 업데이트, 리뷰 요청 알림
Figma / Lucidchart 커넥터 시각적 설계 검토 UI 기획서, ERD 다이어그램 공유 및 분석

6️⃣ 권장 워크플로우

기획서/기능 정의서 분석 → AI

필요한 테이블, 컬럼 도출

Jupyter → 샘플 데이터 생성/쿼리 테스트

데이터 삽입, 관계 검증

SQL 쿼리 실행 → AI 분석

정규화, 인덱스, 컬럼 타입 최적화

결과 시각화 → 팀 공유

Matplotlib, Seaborn 그래프 활용

🔹 핵심 요약

기획서 → 기능 정의서 → DB 설계 → 구현 → 테스트 → 결과 단계별로 Claude 연계 가능

문서 분석: PDF Tools, Markdown

DB 설계/검증: SQLTools, Workbench, Jupyter Notebook

코드 작성/리뷰: Claude Code, GitHub 연동

결과 공유/시각화: PDF Tools, Figma, Matplotlib, Slack/Teams

Claude + VS Code + 확장 도구 조합으로 프로젝트 문서 분석, 설계 검토, 구현 지원, 테스트 검증, 결과 공유까지 모든 단계에서 AI 도움을 받을 수 있음.

\*\* UUID 이슈 정리
✅ 추천 베스트 프랙티스 요약
항목 권장 설정
UUID 생성 위치 DB (MySQL uuid_v7() DEFAULT) -> 기본생성 안됨(x), ==> 서버 (Spring UIDv7 이브러리) 로 생성
DB 컬럼 타입 BINARY(16) , 조회 시 BIN_TO_UUID() 변환
API 전송 형식 문자열 (36자 UUID)
프론트 처리 방식 문자열로만 관리 (uuid npm 패키지 v7 지원 가능)
ORM 매핑 UUID -> byte[] (MySQL Binary 변환)
조회/로그 변환 BIN_TO_UUID() 함수 사용

** 하이브리드 대안 **
내부 동작: 성능을 위해 내부 클러스터링 인덱스나 분산 트랜잭션에서는 작은 크기의 정수 또는 **최적화된 정렬형 ID (예: UUID v7, ULID)**를 사용합니다.

외부 노출: API나 서비스 간 통신 시에는 UUID 또는 이와 유사한 불투명한(opaque) 식별자를 사용하여 데이터 보안과 시스템 유연성을 확보합니다.

샘플
CREATE TABLE user (
-- 🔑 내부용 Primary Key: 성능 최적화를 위한 BIGINT AUTO_INCREMENT
user_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '내부용 순차적 기본 키 (DB 성능 코어)',

    -- 🔒 외부용 Unique Key: 전역 고유성과 API 노출을 위한 UUID
    user_uuid BINARY(16) NOT NULL UNIQUE
                DEFAULT (UUID_TO_BIN(UUID(), 1)) COMMENT '외부 API 노출용, 순서 최적화된 UUID',

    name VARCHAR(100) NOT NULL COMMENT '학생 이름',
    grade VARCHAR(20) COMMENT '학년 정보',
    user_type ENUM('student', 'admin') DEFAULT 'student' COMMENT '사용자 유형',
    profile_image VARCHAR(255) COMMENT '프로필 이미지 URL',
    created_at DATETIME(6) DEFAULT CURRENT_TIMESTAMP(6) COMMENT '생성 일시',
    updated_at DATETIME(6) DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6) COMMENT '수정 일시',

    -- PK는 BIGINT에 설정하여 클러스터링 인덱스 효율 극대화
    PRIMARY KEY (user_id),

    -- 보조 인덱스는 유지
    INDEX idx_name (name),
    INDEX idx_grade (grade)

) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
COMMENT='사용자 정보 (하이브리드 PK 적용)';

-- 애플리케이션단 검증 ok --
