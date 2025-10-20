# 📊 테이블 분류: 마스터 vs 학습결과

## 🎯 분류 기준

```
┌─────────────────────────────────────────────────────────┐
│                    전체 테이블 구조                        │
└─────────────────────────────────────────────────────────┘
                            ↓
        ┌───────────────────┴───────────────────┐
        ↓                                       ↓
  📚 마스터 테이블                          📝 학습결과 테이블
  (Master Tables)                        (Result Tables)
        │                                       │
  - 콘텐츠 정의                            - 사용자 활동 기록
  - 문제/정답                              - 학습 진행 상황
  - 시스템 설정                            - 성과 데이터
  - 읽기 전용 (관리자만 수정)              - 쓰기 위주 (학생이 생성)
```

---

## 📚 마스터 테이블 (Master Tables)

### **역할**: 학습 콘텐츠, 문제, 시스템 설정 등 기준 데이터 관리

---

### **1. 사용자 관리 마스터**

#### **1-1. user (사용자 기본 정보)**

```sql
CREATE TABLE `user` (
  user_id INT PRIMARY KEY AUTO_INCREMENT,
  login_id VARCHAR(50) UNIQUE,
  user_name VARCHAR(100),
  grade VARCHAR(20),
  user_role ENUM('학생','교사','관리자','기타'),
  -- ...
);
```

**용도**:

- 시스템 사용자 정보
- 인증/권한 관리
- 학생/교사 구분

---

### **2. 교재 구조 마스터 (Content Hierarchy)**

#### **2-1. books (교재)**

```sql
CREATE TABLE books (
  book_id INT PRIMARY KEY AUTO_INCREMENT,
  book_name VARCHAR(255),
  volume_number INT,
  description TEXT,
  -- ...
);
```

#### **2-2. lecture (강좌)**

```sql
CREATE TABLE lecture (
  lecture_id INT PRIMARY KEY AUTO_INCREMENT,
  book_id INT,
  lecture_name VARCHAR(255),
  -- ...
  FOREIGN KEY (book_id) REFERENCES books(book_id)
);
```

#### **2-3. passage (지문)**

```sql
CREATE TABLE passage (
  passage_id INT PRIMARY KEY AUTO_INCREMENT,
  lecture_id INT,
  passage_title VARCHAR(255),
  passage_content TEXT,
  reading_level ENUM('초급','중급','고급'),
  -- ...
  FOREIGN KEY (lecture_id) REFERENCES lecture(lecture_id)
);
```

#### **2-4. passage_pages (지문 페이지)**

```sql
CREATE TABLE passage_pages (
  page_id INT PRIMARY KEY AUTO_INCREMENT,
  passage_id INT,
  page_content TEXT,
  page_order INT,
  character_count INT,
  -- ...
  FOREIGN KEY (passage_id) REFERENCES passage(passage_id)
);
```

#### **2-5. lecture_content (강좌 콘텐츠)**

```sql
CREATE TABLE lecture_content (
  content_id INT PRIMARY KEY AUTO_INCREMENT,
  lecture_id INT,
  content_type ENUM('영상','문제','읽기자료','기타'),
  content_title VARCHAR(255),
  -- ...
);
```

**계층 구조**:

```
books → lecture → passage → passage_pages
```

---

### **3. 독해 문제 마스터 (Comprehension Questions)**

#### **3-1. comprehension_question (독해 문제)**

```sql
CREATE TABLE comprehension_question (
  question_id INT PRIMARY KEY AUTO_INCREMENT,
  passage_id INT,
  question_text TEXT,
  question_number INT,
  correct_answer_number TINYINT,  -- 정답
  explanation TEXT,               -- 해설
  -- ...
);
```

#### **3-2. comprehension_choice (독해 선택지)**

```sql
CREATE TABLE comprehension_choice (
  choice_id INT PRIMARY KEY AUTO_INCREMENT,
  question_id INT,
  choice_number TINYINT,          -- 1-6
  choice_text VARCHAR(500),
  -- ...
);
```

#### **3-3. info_processing_answer (정보처리 모범답안)**

```sql
CREATE TABLE info_processing_answer (
  answer_id INT PRIMARY KEY AUTO_INCREMENT,
  question_id INT,
  page_id INT,
  correct_sentence TEXT,          -- 모범답안 문장
  sentence_order INT,
  -- ...
);
```

**관계**:

```
comprehension_question (1) → (6) comprehension_choice
comprehension_question (1) → (1) info_processing_answer
```

---

### **4. 줄거리 순서 마스터 (Plot Sequence)**

#### **4-1. plot_sequence_item (줄거리 항목)**

```sql
CREATE TABLE plot_sequence_item (
  item_id INT PRIMARY KEY AUTO_INCREMENT,
  passage_id INT,
  item_number INT,                -- 제시 번호
  item_text VARCHAR(500),         -- 줄거리 내용
  correct_order INT,              -- 정답 순서
  -- ...
);
```

**용도**:

- Step 6 (줄거리 순서) 문제 정의
- 정답 순서 저장

---

### **5. 어휘 학습 마스터 (Vocabulary)**

#### **5-1. vocabulary (어휘 기본)**

```sql
CREATE TABLE vocabulary (
  vocab_id INT PRIMARY KEY AUTO_INCREMENT,
  lecture_id INT,
  word VARCHAR(100),
  meaning TEXT,
  hint TEXT,
  example_sentence TEXT,
  difficulty_level ENUM('하','중','상'),
  -- ...
);
```

#### **5-2. vocab_question (어휘 문제)**

```sql
CREATE TABLE vocab_question (
  question_id INT PRIMARY KEY AUTO_INCREMENT,
  vocab_id INT,
  question_text TEXT,
  question_type ENUM('뜻고르기','예문빈칸','동의어','반의어'),
  -- ...
);
```

#### **5-3. vocab_choice (어휘 선택지)**

```sql
CREATE TABLE vocab_choice (
  choice_id INT PRIMARY KEY AUTO_INCREMENT,
  question_id INT,
  choice_text VARCHAR(255),
  is_correct TINYINT(1),          -- 정답 여부
  display_order TINYINT,
  -- ...
);
```

**계층 구조**:

```
vocabulary → vocab_question → vocab_choice
```

---

### **6. 서술형 요약 마스터 (Descriptive Summary)**

#### **6-1. descript_summary (서술요약 문제)**

```sql
CREATE TABLE descript_summary (
  descript_summary_id INT PRIMARY KEY AUTO_INCREMENT,
  passage_id INT,
  title VARCHAR(255),
  instruction TEXT,               -- 작성 지침
  hint_guide TEXT,
  model_summary TEXT,             -- 모범 요약문
  -- ...
);
```

#### **6-2. descript_summary_hint (힌트 질문)**

```sql
CREATE TABLE descript_summary_hint (
  summary_hint_id INT PRIMARY KEY AUTO_INCREMENT,
  descript_summary_id INT,
  hint_order INT,
  hint_question VARCHAR(255),
  hint_pattern VARCHAR(255),
  example_answer TEXT,
  -- ...
);
```

---

### **7. 신호등 판정 시스템 마스터 (Light System)**

#### **7-1. lesson_section (수업 구간)**

```sql
CREATE TABLE lesson_section (
  section_id INT PRIMARY KEY AUTO_INCREMENT,
  lecture_id INT,
  section_name VARCHAR(255),
  description TEXT,
  -- ...
);
```

#### **7-2. light_status (신호등 상태)**

```sql
CREATE TABLE light_status (
  light_status_id INT PRIMARY KEY AUTO_INCREMENT,
  status_name VARCHAR(50),        -- 표준, 느림, 빠름, 나쁨, 좋음
  description TEXT,
  -- ...
);
```

#### **7-3. section_standard (구간 기준)**

```sql
CREATE TABLE section_standard (
  standard_id INT PRIMARY KEY AUTO_INCREMENT,
  section_id INT,
  grade_range VARCHAR(50),
  min_time_sec INT,
  max_time_sec INT,
  standard_type ENUM('시간비율','학년기준','정오판정'),
  extra_condition JSON,
  -- ...
);
```

#### **7-4. light_rule (판정 규칙)**

```sql
CREATE TABLE light_rule (
  rule_id INT PRIMARY KEY AUTO_INCREMENT,
  standard_id INT,
  rule_type ENUM('시간비율','정오판정','복합'),
  threshold JSON,
  result_light_status_id INT,
  -- ...
);
```

---

## 📝 학습결과 테이블 (Result Tables)

### **역할**: 사용자의 학습 활동, 진행 상황, 성과 데이터 저장

---

### **1. 사용자 프로필 결과**

#### **1-1. user_learning_profile (학습 프로필)**

```sql
CREATE TABLE user_learning_profile (
  profile_id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT,
  avg_reading_speed_min FLOAT,
  avg_reading_speed_max FLOAT,
  preferred_genres JSON,
  -- ...
  FOREIGN KEY (user_id) REFERENCES user(user_id)
);
```

**특징**:

- 사용자별 학습 패턴 저장
- 읽기 속도 평균
- 선호도 데이터

---

### **2. 학습 세션 결과 (Session Results)**

#### **2-1. user_learning_session (학습 세션)**

```sql
CREATE TABLE user_learning_session (
  session_id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT,
  passage_id INT,
  started_at DATETIME,
  completed_at DATETIME,
  current_step TINYINT,           -- 현재 단계
  is_completed TINYINT(1),
  total_time_sec INT,
  -- ...
);
```

**용도**: 8단계 학습 세션 전체 관리

---

### **3. Step별 학습 결과 (Step Results)**

#### **Step 1: step1_first_reading (처음 읽기)**

```sql
CREATE TABLE step1_first_reading (
  reading_id INT PRIMARY KEY AUTO_INCREMENT,
  session_id INT,
  started_at DATETIME,
  ended_at DATETIME,
  reading_time_sec INT,
  total_characters INT,
  chars_per_minute DECIMAL(8,2), -- CPM
  -- ...
  FOREIGN KEY (session_id) REFERENCES user_learning_session(session_id)
);
```

#### **Step 2: step2_question_check (문제 확인)**

```sql
CREATE TABLE step2_question_check (
  check_id INT PRIMARY KEY AUTO_INCREMENT,
  session_id INT,
  attempt_number TINYINT,         -- 시도 횟수
  unknown_question_count INT,     -- 모르는 문제 개수
  total_question_count INT,
  needs_rereading TINYINT(1),
  -- ...
);

-- 하위: 모르는 문제 상세
CREATE TABLE step2_unknown_question (
  id INT PRIMARY KEY AUTO_INCREMENT,
  check_id INT,
  question_id INT,                -- 마스터 참조
  question_number INT,
  -- ...
);
```

#### **Step 3: step3_rereading (다시 읽기)**

```sql
CREATE TABLE step3_rereading (
  rereading_id INT PRIMARY KEY AUTO_INCREMENT,
  session_id INT,
  reading_time_sec INT,
  chars_per_minute DECIMAL(8,2),
  still_has_unknown TINYINT(1),
  -- ...
);

-- 하위: 여전히 모르는 문제
CREATE TABLE step3_still_unknown_question (
  id INT PRIMARY KEY AUTO_INCREMENT,
  rereading_id INT,
  question_id INT,                -- 마스터 참조
  -- ...
);
```

#### **Step 4: step4_problem_solving (문제 풀이)**

```sql
CREATE TABLE step4_problem_solving (
  solving_id INT PRIMARY KEY AUTO_INCREMENT,
  session_id INT,
  total_question_count INT,
  correct_count INT,
  wrong_count INT,
  unknown_count INT,              -- 모름 선택
  -- ...
);

-- 하위: 문제별 답안
CREATE TABLE step4_question_answer (
  answer_id INT PRIMARY KEY AUTO_INCREMENT,
  solving_id INT,
  question_id INT,                -- 마스터 참조
  selected_choice_number TINYINT, -- 사용자 선택
  is_correct TINYINT(1),
  answered_at DATETIME,
  -- ...
);
```

#### **Step 5: step5_info_processing (정보 처리)**

```sql
CREATE TABLE step5_info_processing (
  processing_id INT PRIMARY KEY AUTO_INCREMENT,
  session_id INT,
  time_sec INT,
  viewed_model_answer TINYINT(1),
  -- ...
);

-- 하위: 선택 문장
CREATE TABLE step5_selected_sentence (
  selection_id INT PRIMARY KEY AUTO_INCREMENT,
  processing_id INT,
  question_id INT,                -- 마스터 참조
  page_id INT,
  selected_sentence TEXT,         -- 사용자가 선택한 문장
  is_correct TINYINT(1),
  -- ...
);
```

#### **Step 6: step6_plot_sequence (줄거리 순서)**

```sql
CREATE TABLE step6_plot_sequence (
  sequence_id INT PRIMARY KEY AUTO_INCREMENT,
  session_id INT,
  attempt_number TINYINT,         -- 1 or 2
  is_correct TINYINT(1),
  total_items INT,
  correct_items INT,
  -- ...
);

-- 하위: 사용자 배열
CREATE TABLE step6_user_sequence (
  id INT PRIMARY KEY AUTO_INCREMENT,
  sequence_id INT,
  item_id INT,                    -- 마스터 참조
  user_order INT,                 -- 사용자가 선택한 순서
  -- ...
);
```

#### **Step 7: step7_vocabulary_result (어휘 문제)**

```sql
CREATE TABLE step7_vocabulary_result (
  vocab_result_id INT PRIMARY KEY AUTO_INCREMENT,
  session_id INT,
  total_vocab_count INT,
  correct_count INT,
  wrong_count INT,
  -- ...
);

-- 하위: 기존 결과 연결
CREATE TABLE step7_vocab_link (
  link_id INT PRIMARY KEY AUTO_INCREMENT,
  vocab_result_id INT,
  vocab_question_result_id INT,  -- 기존 어휘 결과 참조
  -- ...
);
```

#### **Step 8: step8_final_result (최종 결과)**

```sql
CREATE TABLE step8_final_result (
  result_id INT PRIMARY KEY AUTO_INCREMENT,
  session_id INT,

  -- 전체 통합 데이터
  started_date DATE,
  total_time_sec INT,

  -- Step 1-7 요약 데이터
  first_reading_time_sec INT,
  first_reading_cpm DECIMAL(8,2),
  question_check_time_sec INT,
  solving_time_sec INT,
  correct_count INT,
  -- ... (각 단계별 핵심 지표)

  UNIQUE INDEX (session_id)
);
```

---

### **4. 어휘 학습 결과 (Vocabulary Results)**

#### **4-1. user_vocab_question_result (어휘 문제 풀이 결과)**

```sql
CREATE TABLE user_vocab_question_result (
  vocab_question_result_id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT,
  vocab_id INT,                   -- 마스터 참조
  question_id INT,                -- 마스터 참조
  selected_choice_id INT,         -- 사용자 선택
  is_correct TINYINT(1),
  answered_at DATETIME,
  -- ...
);
```

#### **4-2. user_vocab_status (어휘 최종 상태)**

```sql
CREATE TABLE user_vocab_status (
  user_vocab_id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT,
  vocab_id INT,                   -- 마스터 참조
  final_status ENUM('known','unknown'),
  example_written TINYINT(1),
  quiz_status TINYINT(1),
  last_study_at DATETIME,
  -- ...
);
```

---

### **5. 서술형 요약 결과 (Summary Results)**

#### **5-1. user_descript_hint_response (힌트별 답안)**

```sql
CREATE TABLE user_descript_hint_response (
  hint_response_id INT PRIMARY KEY AUTO_INCREMENT,
  summary_hint_id INT,            -- 마스터 참조
  user_id INT,
  user_answer TEXT,               -- 사용자 답변
  -- ...
);
```

#### **5-2. user_descript_summary_result (최종 요약 결과)**

```sql
CREATE TABLE user_descript_summary_result (
  summary_result_id INT PRIMARY KEY AUTO_INCREMENT,
  descript_summary_id INT,        -- 마스터 참조
  user_id INT,
  my_summary TEXT,                -- 사용자 요약문
  is_model_checked TINYINT(1),
  ai_score INT,
  ai_feedback TEXT,
  -- ...
);
```

#### **5-3. user_descript_summary_progress (진행 현황)**

```sql
CREATE TABLE user_descript_summary_progress (
  summary_progress_id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT,
  lecture_id INT,
  total_passage_count INT,
  completed_summary_count INT,
  progress_rate DECIMAL(5,2) GENERATED,
  -- ...
);
```

---

### **6. 강좌 진행 결과 (Lecture Progress)**

#### **6-1. user_lecture_progress (강좌 진행)**

```sql
CREATE TABLE user_lecture_progress (
  progress_id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT,
  lecture_id INT,                 -- 마스터 참조
  start_time DATETIME,
  end_time DATETIME,
  is_completed TINYINT(1),
  -- ...
);
```

#### **6-2. user_lecture_section_result (구간 결과)**

```sql
CREATE TABLE user_lecture_section_result (
  section_progress_id INT PRIMARY KEY AUTO_INCREMENT,
  progress_id INT,
  section_id INT,                 -- 마스터 참조
  start_time DATETIME,
  end_time DATETIME,
  is_completed TINYINT(1),
  last_light_status_id INT,       -- 신호등 판정 결과
  -- ...
);
```

---

## 📊 마스터 vs 결과 비교표

| 구분            | 마스터 테이블    | 학습결과 테이블    |
| --------------- | ---------------- | ------------------ |
| **목적**        | 콘텐츠/문제 정의 | 사용자 활동 기록   |
| **데이터 성격** | 정적 (Static)    | 동적 (Dynamic)     |
| **수정 권한**   | 관리자/교사      | 학생 (자동 생성)   |
| **생명주기**    | 장기 보관        | 학습 기간 동안     |
| **데이터 크기** | 상대적으로 작음  | 계속 증가          |
| **읽기/쓰기**   | 읽기 위주        | 쓰기 위주          |
| **참조 관계**   | 주체 (Subject)   | 참조자 (Reference) |

---

## 🔗 테이블 관계도

```
┌─────────────────────────────────────────────┐
│            마스터 테이블 계층                  │
└─────────────────────────────────────────────┘
books → lecture → passage → passage_pages
                    ↓
        comprehension_question → comprehension_choice
                    ↓
        plot_sequence_item
                    ↓
        vocabulary → vocab_question → vocab_choice

        ↓ (참조)

┌─────────────────────────────────────────────┐
│           학습결과 테이블 계층                 │
└─────────────────────────────────────────────┘
user → user_learning_session
            ↓
    ┌───────┴────────┬───────────┬─────────┐
    ↓                ↓           ↓         ↓
step1_result   step2_result  ...  step8_result
    ↓                ↓                    ↓
세부 결과       모르는 문제      통합 요약
```

---

## 💡 실전 활용 예시

### **마스터 데이터 조회 (콘텐츠 가져오기)**

```sql
-- 지문과 관련 문제 가져오기
SELECT
    p.passage_title,
    p.passage_content,
    cq.question_text,
    cc.choice_text
FROM passage p
JOIN comprehension_question cq ON p.passage_id = cq.passage_id
JOIN comprehension_choice cc ON cq.question_id = cc.question_id
WHERE p.passage_id = 1;
```

### **학습 결과 저장 (사용자 답안 기록)**

```sql
-- Step 4: 문제 풀이 결과 저장
INSERT INTO step4_question_answer (
    solving_id,
    question_id,           -- 마스터 참조
    selected_choice_number,
    is_correct
) VALUES (
    1,
    5,                     -- 마스터의 question_id
    3,
    1
);
```

### **통합 분석 쿼리 (마스터 + 결과)**

```sql
-- 사용자별 정답률 (마스터 문제 vs 결과)
SELECT
    u.user_name,
    COUNT(DISTINCT cq.question_id) as total_questions,
    SUM(CASE WHEN qa.is_correct = 1 THEN 1 ELSE 0 END) as correct_answers,
    ROUND(SUM(CASE WHEN qa.is_correct = 1 THEN 1 ELSE 0 END) /
          COUNT(DISTINCT cq.question_id) * 100, 2) as accuracy_rate
FROM user u
JOIN user_learning_session s ON u.user_id = s.user_id
JOIN step4_problem_solving ps ON s.session_id = ps.session_id
JOIN step4_question_answer qa ON ps.solving_id = qa.solving_id
JOIN comprehension_question cq ON qa.question_id = cq.question_id
WHERE u.user_id = 1
GROUP BY u.user_id;
```

---

## ✅ 체크리스트

### **마스터 테이블 완성도**

```
✅ books (교재 등록)
✅ lecture (강좌 등록)
✅ passage (지문 등록)
✅ passage_pages (페이지 분할)
✅ comprehension_question (문제 등록)
✅ comprehension_choice (선택지 6개)
✅ info_processing_answer (정보처리 답안)
✅ plot_sequence_item (줄거리 항목)
✅ vocabulary (어휘 등록)
✅ vocab_question (어휘 문제)
✅ vocab_choice (어휘 선택지)
```

### **학습 결과 테이블 활용**

```
✅ user_learning_session (세션 생성)
✅ step1~7 결과 저장
✅ step8_final_result (최종 집계)
✅ user_vocab_question_result (어휘 결과)
✅ user_lecture_progress (진행 현황)
```
