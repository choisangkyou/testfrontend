-- 사용자
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
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 사용자 학습 프로필
CREATE TABLE IF NOT EXISTS user_learning_profile (
  profile_id CHAR(36) NOT NULL PRIMARY KEY,
  user_id CHAR(36) NOT NULL,
  avg_reading_speed_min FLOAT NULL,
  avg_reading_speed_max FLOAT NULL,
  preferred_genres JSON NULL,
  preferred_themes JSON NULL,
  preferred_tone VARCHAR(50) NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  INDEX idx_userprofile_user (user_id),
  CONSTRAINT fk_userprofile_user FOREIGN KEY (user_id)
    REFERENCES `user`(user_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- 교재
CREATE TABLE IF NOT EXISTS books (
  book_id CHAR(36) NOT NULL PRIMARY KEY,
  book_name VARCHAR(255) NOT NULL,
  volume_number INT NOT NULL,
  description TEXT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  UNIQUE KEY ux_book_volume (book_name, volume_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 강좌
CREATE TABLE IF NOT EXISTS lecture (
  lecture_id CHAR(36) NOT NULL PRIMARY KEY,
  book_id CHAR(36) NOT NULL,
  lecture_name VARCHAR(255) NOT NULL,
  description TEXT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  INDEX idx_lecture_book (book_id),
  CONSTRAINT fk_lecture_book FOREIGN KEY (book_id)
    REFERENCES books(book_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 강좌 콘텐츠
CREATE TABLE IF NOT EXISTS lecture_content (
  content_id CHAR(36) NOT NULL PRIMARY KEY,
  lecture_id CHAR(36) NOT NULL,
  content_type ENUM('영상','문제','읽기자료','기타') NOT NULL,
  content_title VARCHAR(255) NOT NULL,
  content_body TEXT NULL,
  order_index DECIMAL(5,2) NOT NULL DEFAULT 0,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  INDEX idx_lecturecontent_lecture (lecture_id),
  CONSTRAINT fk_lecturecontent_lecture FOREIGN KEY (lecture_id)
    REFERENCES lecture(lecture_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 수업 구간
CREATE TABLE IF NOT EXISTS lesson_section (
  section_id CHAR(36) NOT NULL PRIMARY KEY,
  lecture_id CHAR(36) NOT NULL,
  section_name VARCHAR(255) NOT NULL,
  description TEXT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  INDEX idx_section_lecture (lecture_id),
  CONSTRAINT fk_section_lecture FOREIGN KEY (lecture_id)
    REFERENCES lecture(lecture_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- 사용자 강좌 진행
CREATE TABLE IF NOT EXISTS user_lecture_progress (
  progress_id CHAR(36) NOT NULL PRIMARY KEY,
  user_id CHAR(36) NOT NULL,
  lecture_id CHAR(36) NOT NULL,
  start_time DATETIME(6) NOT NULL,
  end_time DATETIME(6) NULL,
  is_completed TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  INDEX idx_userlecture_user (user_id),
  INDEX idx_userlecture_lecture (lecture_id),
  CONSTRAINT fk_userlecture_user FOREIGN KEY (user_id)
    REFERENCES `user`(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_userlecture_lecture FOREIGN KEY (lecture_id)
    REFERENCES lecture(lecture_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 사용자 강좌 구간 진행
CREATE TABLE IF NOT EXISTS user_lecture_section_progress (
  section_progress_id CHAR(36) NOT NULL PRIMARY KEY,
  progress_id CHAR(36) NOT NULL,
  section_id CHAR(36) NOT NULL,
  start_time DATETIME(6) NOT NULL,
  end_time DATETIME(6) NULL,
  is_completed TINYINT(1) NOT NULL DEFAULT 0,
  last_light_status_id CHAR(36) NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
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



-- 신호등 상태
CREATE TABLE IF NOT EXISTS light_status (
  light_status_id CHAR(36) NOT NULL PRIMARY KEY,
  status_name VARCHAR(50) NOT NULL,   -- 표준, 느림, 빠름, 나쁨, 좋음
  description TEXT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 수업 구간 기준
CREATE TABLE IF NOT EXISTS section_standard (
  standard_id CHAR(36) NOT NULL PRIMARY KEY,
  section_id CHAR(36) NOT NULL,
  grade_range VARCHAR(50) NULL,
  min_time_sec INT UNSIGNED NULL,
  max_time_sec INT UNSIGNED NULL,
  standard_type ENUM('시간비율','학년기준','정오판정') NOT NULL DEFAULT '학년기준',
  extra_condition JSON NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  INDEX idx_section_standard_section (section_id),
  CONSTRAINT fk_sectionstandard_section FOREIGN KEY (section_id)
    REFERENCES lesson_section(section_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 신호등 판정 규칙
CREATE TABLE IF NOT EXISTS light_rule (
  rule_id CHAR(36) NOT NULL PRIMARY KEY,
  standard_id CHAR(36) NOT NULL,
  rule_type ENUM('시간비율','정오판정','복합') NOT NULL DEFAULT '시간비율',
  threshold JSON NULL,
  special_condition JSON NULL,
  result_light_status_id CHAR(36) NOT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  INDEX idx_lightrule_standard (standard_id),
  INDEX idx_lightrule_result (result_light_status_id),
  CONSTRAINT fk_lightrule_standard FOREIGN KEY (standard_id)
    REFERENCES section_standard(standard_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_lightrule_lightstatus FOREIGN KEY (result_light_status_id)
    REFERENCES light_status(light_status_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



-- 어휘 기본
CREATE TABLE IF NOT EXISTS vocabulary (
  vocab_id CHAR(36) NOT NULL PRIMARY KEY,
  lecture_id CHAR(36) NOT NULL,
  word VARCHAR(100) NOT NULL UNIQUE,
  meaning TEXT NOT NULL,
  hint TEXT NULL,
  example_sentence TEXT NULL,
  difficulty_level ENUM('하','중','상') DEFAULT '중',
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  CONSTRAINT fk_vocab_lecture FOREIGN KEY (lecture_id)
    REFERENCES lecture(lecture_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 어휘 문제
CREATE TABLE IF NOT EXISTS vocab_question (
  question_id CHAR(36) NOT NULL PRIMARY KEY,
  vocab_id CHAR(36) NOT NULL,
  question_text TEXT NOT NULL,
  question_type ENUM('뜻고르기','예문빈칸','동의어','반의어') DEFAULT '뜻고르기',
  explanation TEXT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
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
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  CONSTRAINT fk_vocabchoice_question FOREIGN KEY (question_id)
    REFERENCES vocab_question(question_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 사용자 문제풀이 결과
CREATE TABLE IF NOT EXISTS user_vocab_question_result (
  vocab_question_result_id CHAR(36) NOT NULL PRIMARY KEY,
  user_id CHAR(36) NOT NULL,
  vocab_id CHAR(36) NOT NULL,
  question_id CHAR(36) NOT NULL,
  selected_choice_id CHAR(36) NULL,
  is_correct TINYINT(1) NOT NULL DEFAULT 0,
  answered_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
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
  example_written TINYINT(1) NOT NULL DEFAULT 0,
  quiz_status TINYINT(1) NOT NULL DEFAULT 0,
  last_study_at DATETIME(6) NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  UNIQUE INDEX ux_user_vocab (user_id, vocab_id),
  CONSTRAINT fk_uservocab_user FOREIGN KEY (user_id)
    REFERENCES `user`(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_uservocab_vocab FOREIGN KEY (vocab_id)
    REFERENCES vocabulary(vocab_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- 지문별 서술요약 문제
CREATE TABLE IF NOT EXISTS descript_summary (
  descript_summary_id CHAR(36) NOT NULL PRIMARY KEY,
  book_id CHAR(36) NOT NULL,
  lecture_id CHAR(36) NOT NULL,
  passage_id CHAR(36) NOT NULL,
  title VARCHAR(255) NOT NULL,
  instruction TEXT NOT NULL,
  hint_guide TEXT NULL,
  model_summary TEXT NOT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  CONSTRAINT fk_dsummary_book FOREIGN KEY (book_id)
    REFERENCES books(book_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_dsummary_lecture FOREIGN KEY (lecture_id)
    REFERENCES lecture(lecture_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 힌트별 질문
CREATE TABLE IF NOT EXISTS descript_summary_hint (
  summary_hint_id CHAR(36) NOT NULL PRIMARY KEY,
  descript_summary_id CHAR(36) NOT NULL,
  hint_order INT UNSIGNED NOT NULL,
  hint_question VARCHAR(255) NOT NULL,
  hint_pattern VARCHAR(255) NULL,
  example_answer TEXT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  CONSTRAINT fk_dshint_summary FOREIGN KEY (descript_summary_id)
    REFERENCES descript_summary(descript_summary_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 사용자 힌트별 답안
CREATE TABLE IF NOT EXISTS user_descript_hint_response (
  hint_response_id CHAR(36) NOT NULL PRIMARY KEY,
  summary_hint_id CHAR(36) NOT NULL,
  user_id CHAR(36) NOT NULL,
  user_answer TEXT NOT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  CONSTRAINT fk_udresp_hint FOREIGN KEY (summary_hint_id)
    REFERENCES descript_summary_hint(summary_hint_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_udresp_user FOREIGN KEY (user_id)
    REFERENCES `user`(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 사용자 최종 요약 결과
CREATE TABLE IF NOT EXISTS user_descript_summary_result (
  summary_result_id CHAR(36) NOT NULL PRIMARY KEY,
  descript_summary_id CHAR(36) NOT NULL,
  user_id CHAR(36) NOT NULL,
  my_summary TEXT NOT NULL,
  is_model_checked TINYINT(1) NOT NULL DEFAULT 0,
  ai_score INT UNSIGNED NULL,
  ai_feedback TEXT NULL,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  CONSTRAINT fk_udsummary_result_user FOREIGN KEY (user_id)
    REFERENCES `user`(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_udsummary_result_summary FOREIGN KEY (descript_summary_id)
    REFERENCES descript_summary(descript_summary_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 사용자 강의별 서술요약 진행
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
  ) STORED,
  last_updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(


