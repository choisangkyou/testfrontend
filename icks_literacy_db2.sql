/*
================================================================================
읽쓰문해력(ICKS Literacy) 데이터베이스 설계 정의서
================================================================================

[ 시스템 개요 ]
- 목적: 학생들의 읽기, 쓰기, 문해력 향상을 위한 학습 관리 시스템
- 구성: 8단계 학습 프로세스 기반 데이터 수집 및 분석

[ 수업 진행 구간 (8단계) ]
1. 처음 읽기: 지문 최초 읽기, 시간 및 속도 측정
2. 문제 확인: N개 문제 중 모르는 문제 사전 확인
3. 다시 읽기: 모르는 문제가 있을 경우 재학습
4. 문제 풀이: 6지선다형 독해 문제 풀이 (모름 포함)
5. 정보 처리: 지문에서 정답 근거 문장 찾기
6. 줄거리 순서: 줄거리 순서 배열 (2회 기회)
7. 어휘 문제: 어휘 학습 및 평가
8. 결과: 전체 학습 데이터 통합 요약

[ 주요 특징 ]
- 세션 기반 학습 추적
- 구간별 상세 데이터 수집
- 신호등 판정 시스템 (학습 상태 시각화)
- 서술형 요약 학습 지원
- AI 기반 피드백 제공

================================================================================
*/

-- ============================================
-- 1. 사용자 관리
-- ============================================

-- 사용자 기본 정보
CREATE TABLE IF NOT EXISTS `user` (
  user_id CHAR(36) NOT NULL PRIMARY KEY,
  login_id VARCHAR(50) NOT NULL UNIQUE,
  user_name VARCHAR(100) NOT NULL,
  nickname VARCHAR(50) NULL,
  grade VARCHAR(20) NOT NULL,
  institution_code VARCHAR(50) NULL,
  user_role ENUM('학생','교사','관리자','기타') NOT NULL DEFAULT '학생',
  user_status ENUM('활성','정지','탈퇴') NOT NULL DEFAULT '활성',
  address VARCHAR(255) NULL,
  address_detail VARCHAR(255) NULL,
  zip_code CHAR(5) NULL,
  contact_number VARCHAR(20) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 사용자 학습 프로필
CREATE TABLE IF NOT EXISTS user_learning_profile (
  profile_id CHAR(36) NOT NULL PRIMARY KEY,
  user_id CHAR(36) NOT NULL,
  avg_reading_speed_min FLOAT NULL COMMENT '최소 읽기 속도',
  avg_reading_speed_max FLOAT NULL COMMENT '최대 읽기 속도',
  preferred_genres JSON NULL COMMENT '선호 장르',
  preferred_themes JSON NULL COMMENT '선호 주제',
  preferred_tone VARCHAR(50) NULL COMMENT '선호 톤',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_userprofile_user (user_id),
  CONSTRAINT fk_userprofile_user FOREIGN KEY (user_id)
    REFERENCES `user`(user_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================
-- 2. 교재 및 강좌 구조
-- ============================================

-- 교재
CREATE TABLE IF NOT EXISTS books (
  book_id CHAR(36) NOT NULL PRIMARY KEY,
  book_name VARCHAR(255) NOT NULL,
  volume_number INT NOT NULL COMMENT '권 번호',
  description TEXT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY ux_book_volume (book_name, volume_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 강좌
CREATE TABLE IF NOT EXISTS lecture (
  lecture_id CHAR(36) NOT NULL PRIMARY KEY,
  book_id CHAR(36) NOT NULL,
  lecture_name VARCHAR(255) NOT NULL,
  description TEXT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_lecture_book (book_id),
  CONSTRAINT fk_lecture_book FOREIGN KEY (book_id)
    REFERENCES books(book_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 지문 (Passage)
CREATE TABLE IF NOT EXISTS passage (
  passage_id CHAR(36) NOT NULL PRIMARY KEY,
  lecture_id CHAR(36) NOT NULL,
  passage_title VARCHAR(255) NOT NULL,
  passage_content TEXT NOT NULL,
  reading_level ENUM('초급','중급','고급') DEFAULT '중급',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_passage_lecture (lecture_id),
  CONSTRAINT fk_passage_lecture FOREIGN KEY (lecture_id)
    REFERENCES lecture(lecture_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 지문 페이지 (페이지 단위로 분할된 지문)
CREATE TABLE IF NOT EXISTS passage_pages (
  page_id CHAR(36) NOT NULL PRIMARY KEY,
  passage_id CHAR(36) NOT NULL,
  passage_type ENUM('도입','본문','결론','보충','기타') NOT NULL DEFAULT '본문',
  page_content TEXT NOT NULL,
  passage_structure ENUM('서술형','대화형','설명형','논증형','혼합형') DEFAULT '서술형',
  character_count INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '글자 수',
  page_order INT UNSIGNED NOT NULL COMMENT '페이지 순서',
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_passagepages_passage (passage_id),
  INDEX idx_passagepages_order (passage_id, page_order),
  CONSTRAINT fk_passagepages_passage FOREIGN KEY (passage_id)
    REFERENCES passage(passage_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 강좌 콘텐츠 (영상, 읽기자료 등 추가 콘텐츠)
CREATE TABLE IF NOT EXISTS lecture_content (
  content_id CHAR(36) NOT NULL PRIMARY KEY,
  lecture_id CHAR(36) NOT NULL,
  content_type ENUM('영상','문제','읽기자료','기타') NOT NULL,
  content_title VARCHAR(255) NOT NULL,
  content_body TEXT NULL,
  order_index DECIMAL(5,2) NOT NULL DEFAULT 0 COMMENT '정렬 순서',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_lecturecontent_lecture (lecture_id),
  CONSTRAINT fk_lecturecontent_lecture FOREIGN KEY (lecture_id)
    REFERENCES lecture(lecture_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================
-- 3. 독해 문제 (4단계: 문제풀이 / 5단계: 정보처리)
-- ============================================

-- 독해 문제
CREATE TABLE IF NOT EXISTS comprehension_question (
  question_id CHAR(36) NOT NULL PRIMARY KEY,
  passage_id CHAR(36) NOT NULL,
  question_text TEXT NOT NULL,
  question_number INT UNSIGNED NOT NULL COMMENT '문제 번호',
  correct_answer_number TINYINT UNSIGNED NOT NULL COMMENT '1-6 정답 번호',
  explanation TEXT NULL COMMENT '해설',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_comp_question_passage (passage_id),
  CONSTRAINT fk_comp_question_passage FOREIGN KEY (passage_id)
    REFERENCES passage(passage_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 독해 문제 선택지 (6지선다)
CREATE TABLE IF NOT EXISTS comprehension_choice (
  choice_id CHAR(36) NOT NULL PRIMARY KEY,
  question_id CHAR(36) NOT NULL,
  choice_number TINYINT UNSIGNED NOT NULL COMMENT '1-6 선택지 번호',
  choice_text VARCHAR(500) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_comp_choice_question (question_id),
  CONSTRAINT fk_comp_choice_question FOREIGN KEY (question_id)
    REFERENCES comprehension_question(question_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 정보처리 모범답안 (5단계: 정답 근거 문장)
CREATE TABLE IF NOT EXISTS info_processing_answer (
  answer_id CHAR(36) NOT NULL PRIMARY KEY,
  question_id CHAR(36) NOT NULL,
  page_id CHAR(36) NOT NULL COMMENT '답이 있는 페이지',
  correct_sentence TEXT NOT NULL COMMENT '모범 답안 문장',
  sentence_order INT UNSIGNED NOT NULL COMMENT '페이지 내 문장 순서',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_info_answer_question (question_id),
  INDEX idx_info_answer_page (page_id),
  CONSTRAINT fk_info_answer_question FOREIGN KEY (question_id)
    REFERENCES comprehension_question(question_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_info_answer_page FOREIGN KEY (page_id)
    REFERENCES passage_pages(page_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================
-- 4. 줄거리 순서 문제 (6단계)
-- ============================================

-- 줄거리 순서 항목
CREATE TABLE IF NOT EXISTS plot_sequence_item (
  item_id CHAR(36) NOT NULL PRIMARY KEY,
  passage_id CHAR(36) NOT NULL,
  item_number INT UNSIGNED NOT NULL COMMENT '제시된 번호 (1~N)',
  item_text VARCHAR(500) NOT NULL COMMENT '줄거리 내용',
  correct_order INT UNSIGNED NOT NULL COMMENT '정답 순서',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_plot_item_passage (passage_id),
  CONSTRAINT fk_plot_item_passage FOREIGN KEY (passage_id)
    REFERENCES passage(passage_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================
-- 5. 어휘 학습 (7단계)
-- ============================================

-- 어휘 기본
CREATE TABLE IF NOT EXISTS vocabulary (
  vocab_id CHAR(36) NOT NULL PRIMARY KEY,
  lecture_id CHAR(36) NOT NULL,
  word VARCHAR(100) NOT NULL UNIQUE,
  meaning TEXT NOT NULL,
  hint TEXT NULL COMMENT '힌트',
  example_sentence TEXT NULL COMMENT '예문',
  difficulty_level ENUM('하','중','상') DEFAULT '중',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_vocab_lecture (lecture_id),
  CONSTRAINT fk_vocab_lecture FOREIGN KEY (lecture_id)
    REFERENCES lecture(lecture_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 어휘 문제
CREATE TABLE IF NOT EXISTS vocab_question (
  question_id CHAR(36) NOT NULL PRIMARY KEY,
  vocab_id CHAR(36) NOT NULL,
  question_text TEXT NOT NULL,
  question_type ENUM('뜻고르기','예문빈칸','동의어','반의어') DEFAULT '뜻고르기',
  explanation TEXT NULL COMMENT '해설',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_vocabquestion_vocab (vocab_id),
  CONSTRAINT fk_vocabquestion_vocab FOREIGN KEY (vocab_id)
    REFERENCES vocabulary(vocab_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 어휘 선택지
CREATE TABLE IF NOT EXISTS vocab_choice (
  choice_id CHAR(36) NOT NULL PRIMARY KEY,
  question_id CHAR(36) NOT NULL,
  choice_text VARCHAR(255) NOT NULL,
  is_correct TINYINT(1) NOT NULL DEFAULT 0,
  display_order TINYINT UNSIGNED NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_vocabchoice_question (question_id),
  CONSTRAINT fk_vocabchoice_question FOREIGN KEY (question_id)
    REFERENCES vocab_question(question_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 사용자 어휘 문제 풀이 결과
CREATE TABLE IF NOT EXISTS user_vocab_question_result (
  vocab_question_result_id CHAR(36) NOT NULL PRIMARY KEY,
  user_id CHAR(36) NOT NULL,
  vocab_id CHAR(36) NOT NULL,
  question_id CHAR(36) NOT NULL,
  selected_choice_id CHAR(36) NULL,
  is_correct TINYINT(1) NOT NULL DEFAULT 0,
  answered_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_uservocabanswer_user (user_id),
  INDEX idx_uservocabanswer_question (question_id),
  CONSTRAINT fk_uservocabanswer_user FOREIGN KEY (user_id)
    REFERENCES `user`(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_uservocabanswer_question FOREIGN KEY (question_id)
    REFERENCES vocab_question(question_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_uservocabanswer_choice FOREIGN KEY (selected_choice_id)
    REFERENCES vocab_choice(choice_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 사용자 최종 어휘 상태
CREATE TABLE IF NOT EXISTS user_vocab_status (
  user_vocab_id CHAR(36) NOT NULL PRIMARY KEY,
  user_id CHAR(36) NOT NULL,
  vocab_id CHAR(36) NOT NULL,
  final_status ENUM('known','unknown') NOT NULL,
  example_written TINYINT(1) NOT NULL DEFAULT 0 COMMENT '예문 작성 여부',
  quiz_status TINYINT(1) NOT NULL DEFAULT 0 COMMENT '퀴즈 완료 여부',
  last_study_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE INDEX ux_user_vocab (user_id, vocab_id),
  CONSTRAINT fk_uservocab_user FOREIGN KEY (user_id)
    REFERENCES `user`(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_uservocab_vocab FOREIGN KEY (vocab_id)
    REFERENCES vocabulary(vocab_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================
-- 6. 서술형 요약 학습
-- ============================================

-- 지문별 서술요약 문제
CREATE TABLE IF NOT EXISTS descript_summary (
  descript_summary_id CHAR(36) NOT NULL PRIMARY KEY,
  book_id CHAR(36) NOT NULL,
  lecture_id CHAR(36) NOT NULL,
  passage_id CHAR(36) NOT NULL,
  title VARCHAR(255) NOT NULL,
  instruction TEXT NOT NULL COMMENT '작성 지침',
  hint_guide TEXT NULL COMMENT '힌트 안내',
  model_summary TEXT NOT NULL COMMENT '모범 요약문',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_dsummary_passage (passage_id),
  CONSTRAINT fk_dsummary_book FOREIGN KEY (book_id)
    REFERENCES books(book_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_dsummary_lecture FOREIGN KEY (lecture_id)
    REFERENCES lecture(lecture_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_dsummary_passage FOREIGN KEY (passage_id)
    REFERENCES passage(passage_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 힌트별 질문
CREATE TABLE IF NOT EXISTS descript_summary_hint (
  summary_hint_id CHAR(36) NOT NULL PRIMARY KEY,
  descript_summary_id CHAR(36) NOT NULL,
  hint_order INT UNSIGNED NOT NULL COMMENT '힌트 순서',
  hint_question VARCHAR(255) NOT NULL COMMENT '힌트 질문',
  hint_pattern VARCHAR(255) NULL COMMENT '작성 패턴',
  example_answer TEXT NULL COMMENT '예시 답변',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_dshint_summary (descript_summary_id),
  CONSTRAINT fk_dshint_summary FOREIGN KEY (descript_summary_id)
    REFERENCES descript_summary(descript_summary_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 사용자 힌트별 답안
CREATE TABLE IF NOT EXISTS user_descript_hint_response (
  hint_response_id CHAR(36) NOT NULL PRIMARY KEY,
  summary_hint_id CHAR(36) NOT NULL,
  user_id CHAR(36) NOT NULL,
  user_answer TEXT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_udresp_hint (summary_hint_id),
  INDEX idx_udresp_user (user_id),
  CONSTRAINT fk_udresp_hint FOREIGN KEY (summary_hint_id)
    REFERENCES descript_summary_hint(summary_hint_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_udresp_user FOREIGN KEY (user_id)
    REFERENCES `user`(user_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 사용자 최종 요약 결과
CREATE TABLE IF NOT EXISTS user_descript_summary_result (
  summary_result_id CHAR(36) NOT NULL PRIMARY KEY,
  descript_summary_id CHAR(36) NOT NULL,
  user_id CHAR(36) NOT NULL,
  my_summary TEXT NOT NULL COMMENT '사용자 작성 요약문',
  is_model_checked TINYINT(1) NOT NULL DEFAULT 0 COMMENT '모범답안 확인 여부',
  ai_score INT UNSIGNED NULL COMMENT 'AI 채점 점수',
  ai_feedback TEXT NULL COMMENT 'AI 피드백',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_udsummary_result_user (user_id),
  INDEX idx_udsummary_result_summary (descript_summary_id),
  CONSTRAINT fk_udsummary_result_user FOREIGN KEY (user_id)
    REFERENCES `user`(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_udsummary_result_summary FOREIGN KEY (descript_summary_id)
    REFERENCES descript_summary(descript_summary_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 사용자 강의별 서술요약 진행 현황
CREATE TABLE IF NOT EXISTS user_descript_summary_progress (
  summary_progress_id CHAR(36) NOT NULL PRIMARY KEY,
  user_id CHAR(36) NOT NULL,
  book_id CHAR(36) NOT NULL,
  lecture_id CHAR(36) NOT NULL,
  total_passage_count INT UNSIGNED NOT NULL DEFAULT 0,
  completed_summary_count INT UNSIGNED NOT NULL DEFAULT 0,
  pending_summary_count INT UNSIGNED NOT NULL DEFAULT 0,
  progress_rate DECIMAL(5,2) GENERATED ALWAYS AS (
    CASE 
      WHEN total_passage_count = 0 THEN 0
      ELSE (completed_summary_count / total_passage_count) * 100
    END
  ) STORED COMMENT '진행률 (%)',
  last_updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_summary_progress_user (user_id),
  INDEX idx_summary_progress_book (book_id),
  INDEX idx_summary_progress_lecture (lecture_id),
  CONSTRAINT fk_summary_progress_user FOREIGN KEY (user_id)
    REFERENCES `user`(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_summary_progress_book FOREIGN KEY (book_id)
    REFERENCES books(book_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_summary_progress_lecture FOREIGN KEY (lecture_id)
    REFERENCES lecture(lecture_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================
-- 7. 8단계 학습 세션 관리
-- ============================================

-- 사용자 학습 세션 (전체 8단계 관리)
CREATE TABLE IF NOT EXISTS user_learning_session (
  session_id CHAR(36) NOT NULL PRIMARY KEY,
  user_id CHAR(36) NOT NULL,
  passage_id CHAR(36) NOT NULL,
  started_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  completed_at DATETIME NULL,
  current_step TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '현재 단계 (1-8)',
  is_completed TINYINT(1) NOT NULL DEFAULT 0,
  total_time_sec INT UNSIGNED NULL COMMENT '전체 소요시간(초)',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_session_user (user_id),
  INDEX idx_session_passage (passage_id),
  CONSTRAINT fk_session_user FOREIGN KEY (user_id)
    REFERENCES `user`(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_session_passage FOREIGN KEY (passage_id)
    REFERENCES passage(passage_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================
-- 8. Step 1: 처음 읽기
-- ============================================

CREATE TABLE IF NOT EXISTS step1_first_reading (
  reading_id CHAR(36) NOT NULL PRIMARY KEY,
  session_id CHAR(36) NOT NULL,
  started_at DATETIME NOT NULL,
  ended_at DATETIME NOT NULL,
  reading_time_sec INT UNSIGNED NOT NULL COMMENT '읽기 소요시간(초)',
  total_characters INT UNSIGNED NOT NULL COMMENT '총 글자 수',
  chars_per_minute DECIMAL(8,2) NOT NULL COMMENT '분당 글자수 (CPM)',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_step1_session (session_id),
  CONSTRAINT fk_step1_session FOREIGN KEY (session_id)
    REFERENCES user_learning_session(session_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================
-- 9. Step 2: 문제 확인
-- ============================================

CREATE TABLE IF NOT EXISTS step2_question_check (
  check_id CHAR(36) NOT NULL PRIMARY KEY,
  session_id CHAR(36) NOT NULL,
  attempt_number TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '시도 횟수',
  started_at DATETIME NOT NULL,
  ended_at DATETIME NOT NULL,
  time_sec INT UNSIGNED NOT NULL COMMENT '소요시간(초)',
  unknown_question_count INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '모르는 문제 개수',
  total_question_count INT UNSIGNED NOT NULL COMMENT '전체 문제 개수',
  needs_rereading TINYINT(1) NOT NULL DEFAULT 0 COMMENT '다시읽기 필요 여부',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_step2_session (session_id),
  CONSTRAINT fk_step2_session FOREIGN KEY (session_id)
    REFERENCES user_learning_session(session_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Step 2: 모르는 문제 선택 내역
CREATE TABLE IF NOT EXISTS step2_unknown_question (
  id CHAR(36) NOT NULL PRIMARY KEY,
  check_id CHAR(36) NOT NULL,
  question_id CHAR(36) NOT NULL,
  question_number INT UNSIGNED NOT NULL COMMENT '문제 번호',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_step2_unknown_check (check_id),
  INDEX idx_step2_unknown_question (question_id),
  CONSTRAINT fk_step2_unknown_check FOREIGN KEY (check_id)
    REFERENCES step2_question_check(check_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_step2_unknown_question FOREIGN KEY (question_id)
    REFERENCES comprehension_question(question_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================
-- 10. Step 3: 다시 읽기
-- ============================================

CREATE TABLE IF NOT EXISTS step3_rereading (
  rereading_id CHAR(36) NOT NULL PRIMARY KEY,
  session_id CHAR(36) NOT NULL,
  started_at DATETIME NOT NULL,
  ended_at DATETIME NOT NULL,
  reading_time_sec INT UNSIGNED NOT NULL COMMENT '재읽기 소요시간(초)',
  total_characters INT UNSIGNED NOT NULL COMMENT '총 글자 수',
  chars_per_minute DECIMAL(8,2) NOT NULL COMMENT '분당 글자수 (CPM)',
  still_has_unknown TINYINT(1) NOT NULL DEFAULT 0 COMMENT '여전히 모르는 문제 있음',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_step3_session (session_id),
  CONSTRAINT fk_step3_session FOREIGN KEY (session_id)
    REFERENCES user_learning_session(session_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Step 3: 다시 읽기 후 모르는 문제
CREATE TABLE IF NOT EXISTS step3_still_unknown_question (
  id CHAR(36) NOT NULL PRIMARY KEY,
  rereading_id CHAR(36) NOT NULL,
  question_id CHAR(36) NOT NULL,
  question_number INT UNSIGNED NOT NULL COMMENT '문제 번호',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_step3_unknown_rereading (rereading_id),
  INDEX idx_step3_unknown_question (question_id),
  CONSTRAINT fk_step3_unknown_rereading FOREIGN KEY (rereading_id)
    REFERENCES step3_rereading(rereading_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_step3_unknown_question FOREIGN KEY (question_id)
    REFERENCES comprehension_question(question_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================
-- 11. Step 4: 문제 풀이
-- ============================================

CREATE TABLE IF NOT EXISTS step4_problem_solving (
  solving_id CHAR(36) NOT NULL PRIMARY KEY,
  session_id CHAR(36) NOT NULL,
  started_at DATETIME NOT NULL,
  ended_at DATETIME NOT NULL,
  time_sec INT UNSIGNED NOT NULL COMMENT '소요시간(초)',
  total_question_count INT UNSIGNED NOT NULL COMMENT '전체 문제 개수',
  correct_count INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '정답 개수',
  wrong_count INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '오답 개수',
  unknown_count INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '모름 선택 개수',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_step4_session (session_id),
  CONSTRAINT fk_step4_session FOREIGN KEY (session_id)
    REFERENCES user_learning_session(session_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Step 4: 문제별 답안
CREATE TABLE IF NOT EXISTS step4_question_answer (
  answer_id CHAR(36) NOT NULL PRIMARY KEY,
  solving_id CHAR(36) NOT NULL,
  question_id CHAR(36) NOT NULL,
  selected_choice_number TINYINT UNSIGNED NULL COMMENT '선택한 번호 (1-6), NULL=모름',
  is_correct TINYINT(1) NULL COMMENT '1=정답, 0=오답, NULL=모름',
  answered_at DATETIME NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_step4_answer_solving (solving_id),
  INDEX idx_step4_answer_question (question_id),
  CONSTRAINT fk_step4_answer_solving FOREIGN KEY (solving_id)
    REFERENCES step4_problem_solving(solving_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_step4_answer_question FOREIGN KEY (question_id)
    REFERENCES comprehension_question(question_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================
-- 12. Step 5: 정보 처리
-- ============================================

CREATE TABLE IF NOT EXISTS step5_info_processing (
  processing_id CHAR(36) NOT NULL PRIMARY KEY,
  session_id CHAR(36) NOT NULL,
  started_at DATETIME NOT NULL,
  ended_at DATETIME NOT NULL,
  time_sec INT UNSIGNED NOT NULL COMMENT '소요시간(초)',
  viewed_model_answer TINYINT(1) NOT NULL DEFAULT 0 COMMENT '모범답안 확인 여부',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_step5_session (session_id),
  CONSTRAINT fk_step5_session FOREIGN KEY (session_id)
    REFERENCES user_learning_session(session_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Step 5: 정보처리 문제별 선택 문장
CREATE TABLE IF NOT EXISTS step5_selected_sentence (
  selection_id CHAR(36) NOT NULL PRIMARY KEY,
  processing_id CHAR(36) NOT NULL,
  question_id CHAR(36) NOT NULL,
  page_id CHAR(36) NOT NULL COMMENT '선택한 페이지',
  selected_sentence TEXT NOT NULL COMMENT '선택한 문장',
  sentence_order INT UNSIGNED NOT NULL COMMENT '문장 순서',
  is_correct TINYINT(1) NOT NULL DEFAULT 0 COMMENT '모범답안과 일치 여부',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_step5_selection_processing (processing_id),
  INDEX idx_step5_selection_question (question_id),
  INDEX idx_step5_selection_page (page_id),
  CONSTRAINT fk_step5_selection_processing FOREIGN KEY (processing_id)
    REFERENCES step5_info_processing(processing_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_step5_selection_question FOREIGN KEY (question_id)
    REFERENCES comprehension_question(question_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_step5_selection_page FOREIGN KEY (page_id)
    REFERENCES passage_pages(page_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================
-- 13. Step 6: 줄거리 순서
-- ============================================

CREATE TABLE IF NOT EXISTS step6_plot_sequence (
  sequence_id CHAR(36) NOT NULL PRIMARY KEY,
  session_id CHAR(36) NOT NULL,
  attempt_number TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '시도 횟수 (1 or 2)',
  started_at DATETIME NOT NULL,
  ended_at DATETIME NOT NULL,
  time_sec INT UNSIGNED NOT NULL COMMENT '소요시간(초)',
  is_correct TINYINT(1) NOT NULL DEFAULT 0 COMMENT '정답 여부',
  total_items INT UNSIGNED NOT NULL COMMENT '전체 항목 개수',
  correct_items INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '맞춘 항목 개수',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_step6_session (session_id),
  CONSTRAINT fk_step6_session FOREIGN KEY (session_id)
    REFERENCES user_learning_session(session_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Step 6: 줄거리 순서 사용자 배열
CREATE TABLE IF NOT EXISTS step6_user_sequence (
  id CHAR(36) NOT NULL PRIMARY KEY,
  sequence_id CHAR(36) NOT NULL,
  item_id CHAR(36) NOT NULL,
  user_order INT UNSIGNED NOT NULL COMMENT '사용자가 선택한 순서',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_step6_user_seq_sequence (sequence_id),
  INDEX idx_step6_user_seq_item (item_id),
  CONSTRAINT fk_step6_user_seq_sequence FOREIGN KEY (sequence_id)
    REFERENCES step6_plot_sequence(sequence_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_step6_user_seq_item FOREIGN KEY (item_id)
    REFERENCES plot_sequence_item(item_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================
-- 14. Step 7: 어휘 문제
-- ============================================

CREATE TABLE IF NOT EXISTS step7_vocabulary_result (
  vocab_result_id CHAR(36) NOT NULL PRIMARY KEY,
  session_id CHAR(36) NOT NULL,
  started_at DATETIME NOT NULL,
  ended_at DATETIME NOT NULL,
  time_sec INT UNSIGNED NOT NULL COMMENT '소요시간(초)',
  total_vocab_count INT UNSIGNED NOT NULL COMMENT '전체 어휘 개수',
  correct_count INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '정답 개수',
  wrong_count INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '오답 개수',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_step7_session (session_id),
  CONSTRAINT fk_step7_session FOREIGN KEY (session_id)
    REFERENCES user_learning_session(session_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Step 7: 어휘 문제 연결 (기존 user_vocab_question_result 참조)
CREATE TABLE IF NOT EXISTS step7_vocab_link (
  link_id CHAR(36) NOT NULL PRIMARY KEY,
  vocab_result_id CHAR(36) NOT NULL,
  vocab_question_result_id CHAR(36) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_step7_link_result (vocab_result_id),
  INDEX idx_step7_link_vocab (vocab_question_result_id),
  CONSTRAINT fk_step7_link_result FOREIGN KEY (vocab_result_id)
    REFERENCES step7_vocabulary_result(vocab_result_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_step7_link_vocab FOREIGN KEY (vocab_question_result_id)
    REFERENCES user_vocab_question_result(vocab_question_result_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================
-- 15. Step 8: 최종 결과 요약
-- ============================================

CREATE TABLE IF NOT EXISTS step8_final_result (
  result_id CHAR(36) NOT NULL PRIMARY KEY,
  session_id CHAR(36) NOT NULL,
  
  -- 전체 정보
  started_date DATE NOT NULL COMMENT '시작 일자',
  total_time_sec INT UNSIGNED NOT NULL COMMENT '전체 소요시간(초)',
  
  -- 1. 처음읽기
  first_reading_time_sec INT UNSIGNED NOT NULL,
  first_reading_cpm DECIMAL(8,2) NOT NULL COMMENT '분당글자수',
  
  -- 2. 문제확인
  question_check_time_sec INT UNSIGNED NOT NULL,
  unknown_question_count INT UNSIGNED NOT NULL COMMENT '모르는 문제 개수',
  question_check_attempts TINYINT UNSIGNED NOT NULL COMMENT '시도 횟수',
  
  -- 3. 다시읽기
  rereading_time_sec INT UNSIGNED NULL,
  rereading_cpm DECIMAL(8,2) NULL,
  
  -- 4. 문제풀이
  solving_time_sec INT UNSIGNED NOT NULL,
  correct_count INT UNSIGNED NOT NULL COMMENT '맞춘 문제 개수',
  total_question_count INT UNSIGNED NOT NULL COMMENT '전체 문제 개수',
  unknown_answer_count INT UNSIGNED NOT NULL COMMENT '모름 선택 개수',
  
  -- 5. 정보처리
  info_processing_time_sec INT UNSIGNED NOT NULL,
  
  -- 6. 줄거리순서
  plot_sequence_time_sec INT UNSIGNED NOT NULL,
  plot_success_count INT UNSIGNED NOT NULL COMMENT '성공 개수',
  plot_total_count INT UNSIGNED NOT NULL COMMENT '전체 개수',
  plot_attempts TINYINT UNSIGNED NOT NULL COMMENT '시도 횟수',
  
  -- 7. 어휘문제
  vocabulary_time_sec INT UNSIGNED NOT NULL,
  vocab_correct_count INT UNSIGNED NOT NULL COMMENT '맞춘 개수',
  vocab_total_count INT UNSIGNED NOT NULL COMMENT '전체 개수',
  
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  UNIQUE INDEX ux_step8_session (session_id),
  CONSTRAINT fk_step8_session FOREIGN KEY (session_id)
    REFERENCES user_learning_session(session_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================
-- 16. 신호등 판정 시스템
-- ============================================

-- 수업 구간 (기존 활용)
CREATE TABLE IF NOT EXISTS lesson_section (
  section_id CHAR(36) NOT NULL PRIMARY KEY,
  lecture_id CHAR(36) NOT NULL,
  section_name VARCHAR(255) NOT NULL,
  description TEXT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_section_lecture (lecture_id),
  CONSTRAINT fk_section_lecture FOREIGN KEY (lecture_id)
    REFERENCES lecture(lecture_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 신호등 상태
CREATE TABLE IF NOT EXISTS light_status (
  light_status_id CHAR(36) NOT NULL PRIMARY KEY,
  status_name VARCHAR(50) NOT NULL COMMENT '표준, 느림, 빠름, 나쁨, 좋음',
  description TEXT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 사용자 강좌 진행
CREATE TABLE IF NOT EXISTS user_lecture_progress (
  progress_id CHAR(36) NOT NULL PRIMARY KEY,
  user_id CHAR(36) NOT NULL,
  lecture_id CHAR(36) NOT NULL,
  start_time DATETIME NOT NULL,
  end_time DATETIME NULL,
  is_completed TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_userlecture_user (user_id),
  INDEX idx_userlecture_lecture (lecture_id),
  CONSTRAINT fk_userlecture_user FOREIGN KEY (user_id)
    REFERENCES `user`(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_userlecture_lecture FOREIGN KEY (lecture_id)
    REFERENCES lecture(lecture_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 사용자 강좌 구간 결과
CREATE TABLE IF NOT EXISTS user_lecture_section_result (
  section_progress_id CHAR(36) NOT NULL PRIMARY KEY,
  progress_id CHAR(36) NOT NULL,
  section_id CHAR(36) NOT NULL,
  start_time DATETIME NOT NULL,
  end_time DATETIME NULL,
  is_completed TINYINT(1) NOT NULL DEFAULT 0,
  last_light_status_id CHAR(36) NULL COMMENT '최종 신호등 상태',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_sectionprogress_progress (progress_id),
  INDEX idx_sectionprogress_section (section_id),
  INDEX idx_sectionprogress_light (last_light_status_id),
  CONSTRAINT fk_sectionprogress_progress FOREIGN KEY (progress_id)
    REFERENCES user_lecture_progress(progress_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_sectionprogress_section FOREIGN KEY (section_id)
    REFERENCES lesson_section(section_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_sectionprogress_light FOREIGN KEY (last_light_status_id)
    REFERENCES light_status(light_status_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 수업 구간 기준 (제한시간 등)
CREATE TABLE IF NOT EXISTS section_standard (
  standard_id CHAR(36) NOT NULL PRIMARY KEY,
  section_id CHAR(36) NOT NULL,
  grade_range VARCHAR(50) NULL COMMENT '학년 범위',
  min_time_sec INT UNSIGNED NULL COMMENT '최소 시간(초)',
  max_time_sec INT UNSIGNED NULL COMMENT '최대 시간(초)',
  standard_type ENUM('시간비율','학년기준','정오판정') NOT NULL DEFAULT '학년기준',
  extra_condition JSON NULL COMMENT '추가 조건',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_section_standard_section (section_id),
  CONSTRAINT fk_sectionstandard_section FOREIGN KEY (section_id)
    REFERENCES lesson_section(section_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 신호등 판정 규칙
CREATE TABLE IF NOT EXISTS light_rule (
  rule_id CHAR(36) NOT NULL PRIMARY KEY,
  standard_id CHAR(36) NOT NULL,
  rule_type ENUM('시간비율','정오판정','복합') NOT NULL DEFAULT '시간비율',
  threshold JSON NULL COMMENT '임계값',
  special_condition JSON NULL COMMENT '특수 조건',
  result_light_status_id CHAR(36) NOT NULL COMMENT '결과 신호등 상태',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_lightrule_standard (standard_id),
  INDEX idx_lightrule_result (result_light_status_id),
  CONSTRAINT fk_lightrule_standard FOREIGN KEY (standard_id)
    REFERENCES section_standard(standard_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_lightrule_lightstatus FOREIGN KEY (result_light_status_id)
    REFERENCES light_status(light_status_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*
================================================================================
[ 데이터 흐름 요약 ]

1. 사용자가 강좌(lecture)를 시작
2. 지문(passage)을 선택하여 학습 세션(user_learning_session) 생성
3. 8단계 순차 진행:
   - Step 1: 처음 읽기 (step1_first_reading)
   - Step 2: 문제 확인 (step2_question_check, step2_unknown_question)
   - Step 3: 다시 읽기 (step3_rereading, step3_still_unknown_question)
   - Step 4: 문제 풀이 (step4_problem_solving, step4_question_answer)
   - Step 5: 정보 처리 (step5_info_processing, step5_selected_sentence)
   - Step 6: 줄거리 순서 (step6_plot_sequence, step6_user_sequence)
   - Step 7: 어휘 문제 (step7_vocabulary_result, step7_vocab_link)
   - Step 8: 최종 결과 (step8_final_result)
4. 구간별 신호등 판정 (light_rule, light_status)
5. 서술형 요약 별도 학습 (descript_summary 관련 테이블)

[ 주요 지표 ]
- 읽기 속도 (CPM: Chars Per Minute)
- 정답률, 모름 비율
- 소요 시간
- 신호등 상태 (학습 수준 시각화)
- AI 피드백 점수

================================================================================
*/