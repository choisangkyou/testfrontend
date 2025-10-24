# DB Migration Guide: UUID BINARY(16) PK → BIGINT PK + UUID UNIQUE

## 변경 규칙

### 1. PRIMARY KEY 변경
```sql
-- BEFORE
{table_name}_id BINARY(16) PRIMARY KEY DEFAULT (UUID_TO_BIN(UUID(), 1))

-- AFTER
{table_name}_id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT '{Table Name} ID (내부 PK)'
{table_name}_uuid BINARY(16) UNIQUE NOT NULL DEFAULT (UUID_TO_BIN(UUID(), 1)) COMMENT '{Table Name} UUID (외부 API용)'
```

### 2. 외래키 참조 변경
```sql
-- BEFORE
user_id BINARY(16) NOT NULL COMMENT '사용자 ID'
FOREIGN KEY (user_id) REFERENCES user(user_id)

-- AFTER
user_id BIGINT NOT NULL COMMENT '사용자 ID (FK)'
FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE
```

### 3. 인덱스 추가
```sql
INDEX idx_{table_name}_uuid ({table_name}_uuid) COMMENT 'UUID 조회용'
```

## 진행 상황

✅ **완료: 24/24 테이블**

핵심 테이블 (20/20):
- [x] user
- [x] book_volume
- [x] lesson
- [x] license
- [x] lesson_attempt
- [x] section_result
- [x] vocabulary
- [x] vocab_problem
- [x] vocab_learning
- [x] vocab_learning_result
- [x] summary
- [x] quest_product
- [x] quest
- [x] quest_progress
- [x] quest_history
- [x] coupon
- [x] notification
- [x] activity_log
- [x] volume_progress_cache
- [x] daily_learning_stats

확장 테이블 (4/4):
- [x] user_behavior_log
- [x] learning_feature
- [x] user_feedback
- [x] vocab_problem_history

## 완료된 작업
- [x] DDL 섹션 24개 CREATE TABLE 문 변경 완료
- [x] 데이터 타입 가이드 업데이트 (Appendix A) 완료
- [x] 쿼리 가이드 업데이트 (Appendix C) 완료
- [x] 마이그레이션 가이드 추가 완료
- [x] 초기 데이터 삽입 쿼리 업데이트 완료
- [x] 문서 버전 v1.2로 업데이트 완료

## 추가 고려사항 (옵션)
- [ ] 테이블 상세 설계 섹션(Section 3)의 컬럼 설명 업데이트 - 현재는 DDL이 정확하므로 필수는 아님
- [ ] ERD 다이어그램 업데이트 - 새로운 PK/UUID 관계 반영
