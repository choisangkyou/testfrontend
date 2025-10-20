-- ================================================================================
-- 읽쓰문해력(ICKS Literacy) 데이터베이스 설계 정의서 -- 최종!!
-- ================================================================================

-- [ 시스템 개요 ]
-- - 목적: 학생들의 읽기, 쓰기, 문해력 향상을 위한 학습 관리 시스템
-- - 구성: 8단계 학습 프로세스 기반 데이터 수집 및 분석

-- [ 수업 진행 구간 (8단계) ]
-- 1. 처음 읽기: 지문 최초 읽기, 시간 및 속도 측정
-- 2. 문제 확인: N개 문제 중 모르는 문제 사전 확인
-- 3. 다시 읽기: 모르는 문제가 있을 경우 재학습
-- 4. 문제 풀이: 6지선다형 독해 문제 풀이 (모름 포함)
-- 5. 정보 처리: 지문에서 정답 근거 문장 찾기
-- 6. 줄거리 순서: 줄거리 순서 배열 (2회 기회)
-- 7. 어휘 문제: 어휘 학습 및 평가
-- 8. 결과: 전체 학습 데이터 통합 요약

-- icks_literacy_db.books definition

CREATE TABLE `books` (
  `book_id` int NOT NULL AUTO_INCREMENT,
  `book_name` varchar(255) NOT NULL,
  `volume_number` int NOT NULL COMMENT '권 번호',
  `description` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`book_id`),
  UNIQUE KEY `ux_book_volume` (`book_name`,`volume_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- icks_literacy_db.grade_reading_statistics definition

CREATE TABLE `grade_reading_statistics` (
  `grade_stat_id` int NOT NULL AUTO_INCREMENT,
  `grade` varchar(20) NOT NULL COMMENT '학년 (초1, 초2, ... 중1, 중2, ...)',
  `total_users` int unsigned NOT NULL DEFAULT '0' COMMENT '해당 학년 총 사용자 수',
  `active_users` int unsigned NOT NULL DEFAULT '0' COMMENT '활성 사용자 수',
  `avg_first_reading_cpm` decimal(8,2) DEFAULT NULL COMMENT '학년 평균 처음읽기 CPM',
  `avg_rereading_cpm` decimal(8,2) DEFAULT NULL COMMENT '학년 평균 다시읽기 CPM',
  `avg_overall_cpm` decimal(8,2) DEFAULT NULL COMMENT '학년 전체 평균 CPM',
  `min_cpm` decimal(8,2) DEFAULT NULL COMMENT '최소 CPM',
  `max_cpm` decimal(8,2) DEFAULT NULL COMMENT '최대 CPM',
  `std_dev_cpm` decimal(8,2) DEFAULT NULL COMMENT 'CPM 표준편차',
  `percentile_25_cpm` decimal(8,2) DEFAULT NULL COMMENT '하위 25% CPM',
  `percentile_50_cpm` decimal(8,2) DEFAULT NULL COMMENT '중위값 CPM',
  `percentile_75_cpm` decimal(8,2) DEFAULT NULL COMMENT '상위 25% CPM',
  `avg_sessions_per_user` decimal(8,2) DEFAULT NULL COMMENT '사용자당 평균 세션 수',
  `avg_passages_per_user` decimal(8,2) DEFAULT NULL COMMENT '사용자당 평균 지문 수',
  `calculation_period` varchar(50) DEFAULT NULL COMMENT '집계 기간 (예: 2024-01)',
  `calculated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '통계 계산 일시',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`grade_stat_id`),
  UNIQUE KEY `ux_grade_period` (`grade`,`calculation_period`),
  KEY `idx_grade` (`grade`),
  KEY `idx_avg_cpm` (`avg_overall_cpm`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='학년별 평균 읽기 통계';


-- icks_literacy_db.light_status definition

CREATE TABLE `light_status` (
  `light_status_id` int NOT NULL AUTO_INCREMENT,
  `status_name` varchar(50) NOT NULL COMMENT '표준, 느림, 빠름, 나쁨, 좋음',
  `description` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`light_status_id`),
  UNIQUE KEY `ux_light_status_name` (`status_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- icks_literacy_db.reading_speed_benchmark definition

CREATE TABLE `reading_speed_benchmark` (
  `benchmark_id` int NOT NULL AUTO_INCREMENT,
  `grade` varchar(20) NOT NULL COMMENT '학년',
  `slow_max_cpm` decimal(8,2) NOT NULL COMMENT '느림 최대값',
  `normal_min_cpm` decimal(8,2) NOT NULL COMMENT '보통 최소값',
  `normal_max_cpm` decimal(8,2) NOT NULL COMMENT '보통 최대값',
  `fast_min_cpm` decimal(8,2) NOT NULL COMMENT '빠름 최소값',
  `recommended_cpm` decimal(8,2) NOT NULL COMMENT '권장 CPM',
  `description` text COMMENT '기준 설명',
  `reference_source` varchar(255) DEFAULT NULL COMMENT '기준 출처',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `effective_from` date NOT NULL COMMENT '적용 시작일',
  `effective_to` date DEFAULT NULL COMMENT '적용 종료일',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`benchmark_id`),
  UNIQUE KEY `ux_grade_benchmark` (`grade`,`effective_from`),
  KEY `idx_grade` (`grade`),
  KEY `idx_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='학년별 읽기 속도 기준';


-- icks_literacy_db.`section` definition

CREATE TABLE `section` (
  `section_id` int NOT NULL AUTO_INCREMENT,
  `section_name` varchar(255) NOT NULL,
  `description` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`section_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='구간 정의';


-- icks_literacy_db.`user` definition

CREATE TABLE `user` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `login_id` varchar(50) NOT NULL,
  `user_name` varchar(100) NOT NULL,
  `nickname` varchar(50) DEFAULT NULL,
  `grade` varchar(20) NOT NULL,
  `institution_code` varchar(50) DEFAULT NULL,
  `user_role` enum('학생','교사','관리자','기타') NOT NULL DEFAULT '학생',
  `user_status` enum('활성','정지','탈퇴') NOT NULL DEFAULT '활성',
  `address` varchar(255) DEFAULT NULL,
  `address_detail` varchar(255) DEFAULT NULL,
  `zip_code` char(5) DEFAULT NULL,
  `contact_number` varchar(20) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `login_id` (`login_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- icks_literacy_db.lecture definition

CREATE TABLE `lecture` (
  `lecture_id` int NOT NULL AUTO_INCREMENT,
  `book_id` int NOT NULL,
  `lecture_name` varchar(255) NOT NULL,
  `description` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`lecture_id`),
  KEY `idx_lecture_book` (`book_id`),
  CONSTRAINT `fk_lecture_book` FOREIGN KEY (`book_id`) REFERENCES `books` (`book_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- icks_literacy_db.lecture_content definition

CREATE TABLE `lecture_content` (
  `content_id` int NOT NULL AUTO_INCREMENT,
  `lecture_id` int NOT NULL,
  `content_type` enum('영상','문제','읽기자료','기타') NOT NULL,
  `content_title` varchar(255) NOT NULL,
  `content_body` text,
  `order_index` decimal(5,2) NOT NULL DEFAULT '0.00' COMMENT '정렬 순서',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`content_id`),
  KEY `idx_lecturecontent_lecture` (`lecture_id`),
  CONSTRAINT `fk_lecturecontent_lecture` FOREIGN KEY (`lecture_id`) REFERENCES `lecture` (`lecture_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- icks_literacy_db.passage definition

CREATE TABLE `passage` (
  `passage_id` int NOT NULL AUTO_INCREMENT,
  `lecture_id` int NOT NULL,
  `passage_title` varchar(255) NOT NULL,
  `passage_content` text NOT NULL,
  `reading_level` enum('초급','중급','고급') DEFAULT '중급',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`passage_id`),
  KEY `idx_passage_lecture` (`lecture_id`),
  CONSTRAINT `fk_passage_lecture` FOREIGN KEY (`lecture_id`) REFERENCES `lecture` (`lecture_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- icks_literacy_db.passage_pages definition

CREATE TABLE `passage_pages` (
  `page_id` int NOT NULL AUTO_INCREMENT,
  `passage_id` int NOT NULL,
  `passage_type` enum('도입','본문','결론','보충','기타') NOT NULL DEFAULT '본문',
  `page_content` text NOT NULL,
  `passage_structure` enum('서술형','대화형','설명형','논증형','혼합형') DEFAULT '서술형',
  `character_count` int unsigned NOT NULL DEFAULT '0' COMMENT '글자 수',
  `page_order` int unsigned NOT NULL COMMENT '페이지 순서',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`page_id`),
  UNIQUE KEY `ux_passage_page_order` (`passage_id`,`page_order`),
  KEY `idx_passagepages_passage` (`passage_id`),
  KEY `idx_passagepages_order` (`passage_id`,`page_order`),
  CONSTRAINT `fk_passagepages_passage` FOREIGN KEY (`passage_id`) REFERENCES `passage` (`passage_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- icks_literacy_db.plot_sequence_item definition

CREATE TABLE `plot_sequence_item` (
  `item_id` int NOT NULL AUTO_INCREMENT,
  `passage_id` int NOT NULL,
  `item_number` int unsigned NOT NULL COMMENT '제시된 번호 (1~N)',
  `item_text` varchar(500) NOT NULL COMMENT '줄거리 내용',
  `correct_order` int unsigned NOT NULL COMMENT '정답 순서',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`item_id`),
  UNIQUE KEY `ux_passage_item_num` (`passage_id`,`item_number`),
  KEY `idx_plot_item_passage` (`passage_id`),
  CONSTRAINT `fk_plot_item_passage` FOREIGN KEY (`passage_id`) REFERENCES `passage` (`passage_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- icks_literacy_db.section_standard definition

CREATE TABLE `section_standard` (
  `standard_id` int NOT NULL AUTO_INCREMENT,
  `section_id` int NOT NULL,
  `grade_range` varchar(50) DEFAULT NULL COMMENT '학년 범위',
  `min_time_sec` int unsigned DEFAULT NULL COMMENT '최소 시간(초)',
  `max_time_sec` int unsigned DEFAULT NULL COMMENT '최대 시간(초)',
  `standard_type` enum('시간비율','학년기준','정오판정') NOT NULL DEFAULT '학년기준',
  `extra_condition` json DEFAULT NULL COMMENT '추가 조건',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`standard_id`),
  KEY `idx_section_standard_section` (`section_id`),
  CONSTRAINT `section_standard_section_fk` FOREIGN KEY (`section_id`) REFERENCES `section` (`section_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- icks_literacy_db.user_descript_summary_progress definition

CREATE TABLE `user_descript_summary_progress` (
  `summary_progress_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `book_id` int NOT NULL,
  `lecture_id` int NOT NULL,
  `total_passage_count` int unsigned NOT NULL DEFAULT '0',
  `completed_summary_count` int unsigned NOT NULL DEFAULT '0',
  `pending_summary_count` int unsigned NOT NULL DEFAULT '0',
  `progress_rate` decimal(5,2) GENERATED ALWAYS AS ((case when (`total_passage_count` = 0) then 0 else ((`completed_summary_count` / `total_passage_count`) * 100) end)) STORED COMMENT '진행률 (%)',
  `last_updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`summary_progress_id`),
  UNIQUE KEY `ux_summary_progress_user_lecture` (`user_id`,`lecture_id`),
  KEY `idx_summary_progress_user` (`user_id`),
  KEY `idx_summary_progress_book` (`book_id`),
  KEY `idx_summary_progress_lecture` (`lecture_id`),
  CONSTRAINT `fk_summary_progress_book` FOREIGN KEY (`book_id`) REFERENCES `books` (`book_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_summary_progress_lecture` FOREIGN KEY (`lecture_id`) REFERENCES `lecture` (`lecture_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_summary_progress_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- icks_literacy_db.user_learning_profile definition

CREATE TABLE `user_learning_profile` (
  `profile_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `avg_reading_speed_min` float DEFAULT NULL COMMENT '최소 읽기 속도',
  `avg_reading_speed_max` float DEFAULT NULL COMMENT '최대 읽기 속도',
  `preferred_genres` json DEFAULT NULL COMMENT '선호 장르',
  `preferred_themes` json DEFAULT NULL COMMENT '선호 주제',
  `preferred_tone` varchar(50) DEFAULT NULL COMMENT '선호 톤',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`profile_id`),
  UNIQUE KEY `ux_profile_user` (`user_id`),
  KEY `idx_userprofile_user` (`user_id`),
  CONSTRAINT `fk_userprofile_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- icks_literacy_db.user_learning_section definition

CREATE TABLE `user_learning_section` (
  `section_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `passage_id` int NOT NULL,
  `section_standard_id` int DEFAULT NULL,
  `started_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `completed_at` datetime DEFAULT NULL,
  `current_step` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '현재 단계 (1-8)',
  `is_completed` tinyint(1) NOT NULL DEFAULT '0',
  `total_time_sec` int unsigned DEFAULT NULL COMMENT '전체 소요시간(초)',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`section_id`),
  KEY `idx_session_user` (`user_id`),
  KEY `idx_session_passage` (`passage_id`),
  KEY `idx_session_completed` (`is_completed`),
  KEY `idx_section_standard` (`section_standard_id`),
  CONSTRAINT `fk_section_standard` FOREIGN KEY (`section_standard_id`) REFERENCES `section_standard` (`standard_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_session_passage` FOREIGN KEY (`passage_id`) REFERENCES `passage` (`passage_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_session_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- icks_literacy_db.user_lecture_progress definition

CREATE TABLE `user_lecture_progress` (
  `progress_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `lecture_id` int NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime DEFAULT NULL,
  `is_completed` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`progress_id`),
  KEY `idx_userlecture_user` (`user_id`),
  KEY `idx_userlecture_lecture` (`lecture_id`),
  KEY `idx_userlecture_completed` (`is_completed`),
  CONSTRAINT `fk_userlecture_lecture` FOREIGN KEY (`lecture_id`) REFERENCES `lecture` (`lecture_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_userlecture_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- icks_literacy_db.user_reading_statistics definition

CREATE TABLE `user_reading_statistics` (
  `stat_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `total_sessions` int unsigned NOT NULL DEFAULT '0' COMMENT '총 학습 세션 수',
  `total_passages` int unsigned NOT NULL DEFAULT '0' COMMENT '읽은 지문 수',
  `total_reading_time_sec` int unsigned NOT NULL DEFAULT '0' COMMENT '총 읽기 시간(초)',
  `first_reading_count` int unsigned NOT NULL DEFAULT '0' COMMENT '처음 읽기 횟수',
  `first_reading_total_time_sec` int unsigned NOT NULL DEFAULT '0' COMMENT '처음 읽기 총 시간',
  `first_reading_total_chars` int unsigned NOT NULL DEFAULT '0' COMMENT '처음 읽기 총 글자수',
  `first_reading_avg_cpm` decimal(8,2) DEFAULT NULL COMMENT '처음 읽기 평균 CPM',
  `rereading_count` int unsigned NOT NULL DEFAULT '0' COMMENT '다시 읽기 횟수',
  `rereading_total_time_sec` int unsigned NOT NULL DEFAULT '0' COMMENT '다시 읽기 총 시간',
  `rereading_total_chars` int unsigned NOT NULL DEFAULT '0' COMMENT '다시 읽기 총 글자수',
  `rereading_avg_cpm` decimal(8,2) DEFAULT NULL COMMENT '다시 읽기 평균 CPM',
  `overall_avg_cpm` decimal(8,2) DEFAULT NULL COMMENT '전체 평균 CPM',
  `reading_level` varchar(20) DEFAULT NULL COMMENT '읽기 수준 (초급/중급/고급)',
  `compared_to_grade` varchar(50) DEFAULT NULL COMMENT '학년 대비 수준 (느림/보통/빠름)',
  `last_session_date` datetime DEFAULT NULL COMMENT '마지막 학습 일시',
  `calculated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '통계 계산 일시',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`stat_id`),
  UNIQUE KEY `ux_user_reading_stat` (`user_id`),
  KEY `idx_reading_level` (`reading_level`),
  KEY `idx_avg_cpm` (`overall_avg_cpm`),
  CONSTRAINT `fk_user_reading_stat_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='사용자별 읽기 통계 (누적)';


-- icks_literacy_db.vocabulary definition

CREATE TABLE `vocabulary` (
  `vocab_id` int NOT NULL AUTO_INCREMENT,
  `lecture_id` int NOT NULL,
  `word` varchar(100) NOT NULL,
  `meaning` text NOT NULL,
  `hint` text COMMENT '힌트',
  `example_sentence` text COMMENT '예문',
  `difficulty_level` enum('하','중','상') DEFAULT '중',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`vocab_id`),
  UNIQUE KEY `ux_vocab_lecture_word` (`lecture_id`,`word`),
  KEY `idx_vocab_lecture` (`lecture_id`),
  CONSTRAINT `fk_vocab_lecture` FOREIGN KEY (`lecture_id`) REFERENCES `lecture` (`lecture_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- icks_literacy_db.comprehension_question definition

CREATE TABLE `comprehension_question` (
  `question_id` int NOT NULL AUTO_INCREMENT,
  `passage_id` int NOT NULL,
  `question_text` text NOT NULL,
  `question_number` int unsigned NOT NULL COMMENT '문제 번호',
  `question_type` enum('어휘','사실','추론','비판') NOT NULL DEFAULT '사실' COMMENT '문제 유형',
  `correct_answer_number` tinyint unsigned NOT NULL COMMENT '1-6 정답 번호',
  `explanation` text COMMENT '해설',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`question_id`),
  UNIQUE KEY `ux_passage_question_num` (`passage_id`,`question_number`),
  KEY `idx_comp_question_passage` (`passage_id`),
  KEY `idx_comp_question_type` (`question_type`),
  CONSTRAINT `fk_comp_question_passage` FOREIGN KEY (`passage_id`) REFERENCES `passage` (`passage_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- icks_literacy_db.descript_summary definition

CREATE TABLE `descript_summary` (
  `descript_summary_id` int NOT NULL AUTO_INCREMENT,
  `book_id` int NOT NULL,
  `lecture_id` int NOT NULL,
  `passage_id` int NOT NULL,
  `title` varchar(255) NOT NULL,
  `instruction` text NOT NULL COMMENT '작성 지침',
  `hint_guide` text COMMENT '힌트 안내',
  `model_summary` text NOT NULL COMMENT '모범 요약문',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`descript_summary_id`),
  KEY `idx_dsummary_passage` (`passage_id`),
  KEY `fk_dsummary_book` (`book_id`),
  KEY `fk_dsummary_lecture` (`lecture_id`),
  CONSTRAINT `fk_dsummary_book` FOREIGN KEY (`book_id`) REFERENCES `books` (`book_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_dsummary_lecture` FOREIGN KEY (`lecture_id`) REFERENCES `lecture` (`lecture_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_dsummary_passage` FOREIGN KEY (`passage_id`) REFERENCES `passage` (`passage_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- icks_literacy_db.descript_summary_hint definition

CREATE TABLE `descript_summary_hint` (
  `summary_hint_id` int NOT NULL AUTO_INCREMENT,
  `descript_summary_id` int NOT NULL,
  `hint_order` int unsigned NOT NULL COMMENT '힌트 순서',
  `hint_question` varchar(255) NOT NULL COMMENT '힌트 질문',
  `hint_pattern` varchar(255) DEFAULT NULL COMMENT '작성 패턴',
  `example_answer` text COMMENT '예시 답변',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`summary_hint_id`),
  KEY `idx_dshint_summary` (`descript_summary_id`),
  CONSTRAINT `fk_dshint_summary` FOREIGN KEY (`descript_summary_id`) REFERENCES `descript_summary` (`descript_summary_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- icks_literacy_db.info_processing_answer definition

CREATE TABLE `info_processing_answer` (
  `answer_id` int NOT NULL AUTO_INCREMENT,
  `question_id` int NOT NULL,
  `page_id` int NOT NULL COMMENT '답이 있는 페이지',
  `correct_sentence` text NOT NULL COMMENT '모범 답안 문장',
  `sentence_order` int unsigned NOT NULL COMMENT '페이지 내 문장 순서',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`answer_id`),
  KEY `idx_info_answer_question` (`question_id`),
  KEY `idx_info_answer_page` (`page_id`),
  CONSTRAINT `fk_info_answer_page` FOREIGN KEY (`page_id`) REFERENCES `passage_pages` (`page_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_info_answer_question` FOREIGN KEY (`question_id`) REFERENCES `comprehension_question` (`question_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- icks_literacy_db.light_rule definition

CREATE TABLE `light_rule` (
  `rule_id` int NOT NULL AUTO_INCREMENT,
  `standard_id` int NOT NULL,
  `rule_type` enum('시간비율','정오판정','복합') NOT NULL DEFAULT '시간비율',
  `threshold` json DEFAULT NULL COMMENT '임계값',
  `special_condition` json DEFAULT NULL COMMENT '특수 조건',
  `result_light_status_id` int NOT NULL COMMENT '결과 신호등 상태',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`rule_id`),
  KEY `idx_lightrule_standard` (`standard_id`),
  KEY `idx_lightrule_result` (`result_light_status_id`),
  CONSTRAINT `fk_lightrule_lightstatus` FOREIGN KEY (`result_light_status_id`) REFERENCES `light_status` (`light_status_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_lightrule_standard` FOREIGN KEY (`standard_id`) REFERENCES `section_standard` (`standard_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- icks_literacy_db.step1_first_reading definition

CREATE TABLE `step1_first_reading` (
  `reading_id` int NOT NULL AUTO_INCREMENT,
  `section_id` int NOT NULL,
  `started_at` datetime NOT NULL,
  `ended_at` datetime NOT NULL,
  `reading_time_sec` int unsigned NOT NULL COMMENT '읽기 소요시간(초)',
  `total_characters` int unsigned NOT NULL COMMENT '총 글자 수',
  `chars_per_minute` decimal(8,2) NOT NULL COMMENT '분당 글자수 (CPM)',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`reading_id`),
  UNIQUE KEY `ux_step1_section` (`section_id`),
  KEY `idx_step1_section` (`section_id`),
  CONSTRAINT `fk_step1_section` FOREIGN KEY (`section_id`) REFERENCES `user_learning_section` (`section_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- icks_literacy_db.step2_question_check definition

CREATE TABLE `step2_question_check` (
  `check_id` int NOT NULL AUTO_INCREMENT,
  `section_id` int NOT NULL,
  `attempt_number` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '시도 횟수',
  `started_at` datetime NOT NULL,
  `ended_at` datetime NOT NULL,
  `time_sec` int unsigned NOT NULL COMMENT '소요시간(초)',
  `unknown_question_count` int unsigned NOT NULL DEFAULT '0' COMMENT '모르는 문제 개수',
  `total_question_count` int unsigned NOT NULL COMMENT '전체 문제 개수',
  `needs_rereading` tinyint(1) NOT NULL DEFAULT '0' COMMENT '다시읽기 필요 여부',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`check_id`),
  KEY `idx_step2_section` (`section_id`),
  KEY `idx_step2_section_attempt` (`section_id`,`attempt_number`),
  CONSTRAINT `fk_step2_section` FOREIGN KEY (`section_id`) REFERENCES `user_learning_section` (`section_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- icks_literacy_db.step2_unknown_question definition

CREATE TABLE `step2_unknown_question` (
  `id` int NOT NULL AUTO_INCREMENT,
  `check_id` int NOT NULL,
  `question_id` int NOT NULL,
  `question_number` int unsigned NOT NULL COMMENT '문제 번호',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_step2_unknown_check` (`check_id`),
  KEY `idx_step2_unknown_question` (`question_id`),
  CONSTRAINT `fk_step2_unknown_check` FOREIGN KEY (`check_id`) REFERENCES `step2_question_check` (`check_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_step2_unknown_question` FOREIGN KEY (`question_id`) REFERENCES `comprehension_question` (`question_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- icks_literacy_db.step3_rereading definition

CREATE TABLE `step3_rereading` (
  `rereading_id` int NOT NULL AUTO_INCREMENT,
  `section_id` int NOT NULL,
  `started_at` datetime NOT NULL,
  `ended_at` datetime NOT NULL,
  `reading_time_sec` int unsigned NOT NULL COMMENT '재읽기 소요시간(초)',
  `total_characters` int unsigned NOT NULL COMMENT '총 글자 수',
  `chars_per_minute` decimal(8,2) NOT NULL COMMENT '분당 글자수 (CPM)',
  `still_has_unknown` tinyint(1) NOT NULL DEFAULT '0' COMMENT '여전히 모르는 문제 있음',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`rereading_id`),
  UNIQUE KEY `ux_step3_section` (`section_id`),
  KEY `idx_step3_section` (`section_id`),
  CONSTRAINT `fk_step3_section` FOREIGN KEY (`section_id`) REFERENCES `user_learning_section` (`section_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- icks_literacy_db.step3_still_unknown_question definition

CREATE TABLE `step3_still_unknown_question` (
  `id` int NOT NULL AUTO_INCREMENT,
  `rereading_id` int NOT NULL,
  `question_id` int NOT NULL,
  `question_number` int unsigned NOT NULL COMMENT '문제 번호',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_step3_unknown_rereading` (`rereading_id`),
  KEY `idx_step3_unknown_question` (`question_id`),
  CONSTRAINT `fk_step3_unknown_question` FOREIGN KEY (`question_id`) REFERENCES `comprehension_question` (`question_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_step3_unknown_rereading` FOREIGN KEY (`rereading_id`) REFERENCES `step3_rereading` (`rereading_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- icks_literacy_db.step4_problem_solving definition

CREATE TABLE `step4_problem_solving` (
  `solving_id` int NOT NULL AUTO_INCREMENT,
  `section_id` int NOT NULL,
  `started_at` datetime NOT NULL,
  `ended_at` datetime NOT NULL,
  `time_sec` int unsigned NOT NULL COMMENT '소요시간(초)',
  `total_question_count` int unsigned NOT NULL COMMENT '전체 문제 개수',
  `correct_count` int unsigned NOT NULL DEFAULT '0' COMMENT '정답 개수',
  `wrong_count` int unsigned NOT NULL DEFAULT '0' COMMENT '오답 개수',
  `unknown_count` int unsigned NOT NULL DEFAULT '0' COMMENT '모름 선택 개수',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`solving_id`),
  UNIQUE KEY `ux_step4_section` (`section_id`),
  KEY `idx_step4_section` (`section_id`),
  CONSTRAINT `fk_step4_section` FOREIGN KEY (`section_id`) REFERENCES `user_learning_section` (`section_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- icks_literacy_db.step4_question_answer definition

CREATE TABLE `step4_question_answer` (
  `answer_id` int NOT NULL AUTO_INCREMENT,
  `solving_id` int NOT NULL,
  `question_id` int NOT NULL,
  `selected_choice_number` tinyint unsigned DEFAULT NULL COMMENT '선택한 번호 (1-6), NULL=모름',
  `is_correct` tinyint(1) DEFAULT NULL COMMENT '1=정답, 0=오답, NULL=모름',
  `answered_at` datetime NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`answer_id`),
  KEY `idx_step4_answer_solving` (`solving_id`),
  KEY `idx_step4_answer_question` (`question_id`),
  CONSTRAINT `fk_step4_answer_question` FOREIGN KEY (`question_id`) REFERENCES `comprehension_question` (`question_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_step4_answer_solving` FOREIGN KEY (`solving_id`) REFERENCES `step4_problem_solving` (`solving_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- icks_literacy_db.step5_info_processing definition

CREATE TABLE `step5_info_processing` (
  `processing_id` int NOT NULL AUTO_INCREMENT,
  `section_id` int NOT NULL,
  `started_at` datetime NOT NULL,
  `ended_at` datetime NOT NULL,
  `time_sec` int unsigned NOT NULL COMMENT '소요시간(초)',
  `viewed_model_answer` tinyint(1) NOT NULL DEFAULT '0' COMMENT '모범답안 확인 여부',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`processing_id`),
  UNIQUE KEY `ux_step5_section` (`section_id`),
  KEY `idx_step5_section` (`section_id`),
  CONSTRAINT `fk_step5_section` FOREIGN KEY (`section_id`) REFERENCES `user_learning_section` (`section_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- icks_literacy_db.step5_selected_sentence definition

CREATE TABLE `step5_selected_sentence` (
  `selection_id` int NOT NULL AUTO_INCREMENT,
  `processing_id` int NOT NULL,
  `question_id` int NOT NULL,
  `page_id` int NOT NULL COMMENT '선택한 페이지',
  `selected_sentence` text NOT NULL COMMENT '선택한 문장',
  `sentence_order` int unsigned NOT NULL COMMENT '문장 순서',
  `is_correct` tinyint(1) NOT NULL DEFAULT '0' COMMENT '모범답안과 일치 여부',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`selection_id`),
  KEY `idx_step5_selection_processing` (`processing_id`),
  KEY `idx_step5_selection_question` (`question_id`),
  KEY `idx_step5_selection_page` (`page_id`),
  CONSTRAINT `fk_step5_selection_page` FOREIGN KEY (`page_id`) REFERENCES `passage_pages` (`page_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_step5_selection_processing` FOREIGN KEY (`processing_id`) REFERENCES `step5_info_processing` (`processing_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_step5_selection_question` FOREIGN KEY (`question_id`) REFERENCES `comprehension_question` (`question_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- icks_literacy_db.step6_plot_sequence definition

CREATE TABLE `step6_plot_sequence` (
  `sequence_id` int NOT NULL AUTO_INCREMENT,
  `section_id` int NOT NULL,
  `attempt_number` tinyint unsigned NOT NULL DEFAULT '1' COMMENT '시도 횟수 (1 or 2)',
  `started_at` datetime NOT NULL,
  `ended_at` datetime NOT NULL,
  `time_sec` int unsigned NOT NULL COMMENT '소요시간(초)',
  `is_correct` tinyint(1) NOT NULL DEFAULT '0' COMMENT '정답 여부',
  `total_items` int unsigned NOT NULL COMMENT '전체 항목 개수',
  `correct_items` int unsigned NOT NULL DEFAULT '0' COMMENT '맞춘 항목 개수',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`sequence_id`),
  KEY `idx_step6_section` (`section_id`),
  KEY `idx_step6_section_attempt` (`section_id`,`attempt_number`),
  CONSTRAINT `fk_step6_section` FOREIGN KEY (`section_id`) REFERENCES `user_learning_section` (`section_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- icks_literacy_db.step6_user_sequence definition

CREATE TABLE `step6_user_sequence` (
  `id` int NOT NULL AUTO_INCREMENT,
  `sequence_id` int NOT NULL,
  `item_id` int NOT NULL,
  `user_order` int unsigned NOT NULL COMMENT '사용자가 선택한 순서',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_step6_user_seq_sequence` (`sequence_id`),
  KEY `idx_step6_user_seq_item` (`item_id`),
  CONSTRAINT `fk_step6_user_seq_item` FOREIGN KEY (`item_id`) REFERENCES `plot_sequence_item` (`item_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_step6_user_seq_sequence` FOREIGN KEY (`sequence_id`) REFERENCES `step6_plot_sequence` (`sequence_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- icks_literacy_db.step7_vocabulary_result definition

CREATE TABLE `step7_vocabulary_result` (
  `vocab_result_id` int NOT NULL AUTO_INCREMENT,
  `section_id` int NOT NULL,
  `started_at` datetime NOT NULL,
  `ended_at` datetime NOT NULL,
  `time_sec` int unsigned NOT NULL COMMENT '소요시간(초)',
  `total_vocab_count` int unsigned NOT NULL COMMENT '전체 어휘 개수',
  `correct_count` int unsigned NOT NULL DEFAULT '0' COMMENT '정답 개수',
  `wrong_count` int unsigned NOT NULL DEFAULT '0' COMMENT '오답 개수',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`vocab_result_id`),
  UNIQUE KEY `ux_step7_section` (`section_id`),
  KEY `idx_step7_section` (`section_id`),
  CONSTRAINT `fk_step7_section` FOREIGN KEY (`section_id`) REFERENCES `user_learning_section` (`section_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- icks_literacy_db.step8_final_result definition

CREATE TABLE `step8_final_result` (
  `result_id` int NOT NULL AUTO_INCREMENT,
  `section_id` int NOT NULL,
  `started_date` date NOT NULL COMMENT '시작 일자',
  `total_time_sec` int unsigned NOT NULL COMMENT '전체 소요시간(초)',
  `first_reading_time_sec` int unsigned NOT NULL,
  `first_reading_cpm` decimal(8,2) NOT NULL COMMENT '분당글자수',
  `question_check_time_sec` int unsigned NOT NULL,
  `unknown_question_count` int unsigned NOT NULL COMMENT '모르는 문제 개수',
  `question_check_attempts` tinyint unsigned NOT NULL COMMENT '시도 횟수',
  `rereading_time_sec` int unsigned DEFAULT NULL,
  `rereading_cpm` decimal(8,2) DEFAULT NULL,
  `solving_time_sec` int unsigned NOT NULL,
  `correct_count` int unsigned NOT NULL COMMENT '맞춘 문제 개수',
  `total_question_count` int unsigned NOT NULL COMMENT '전체 문제 개수',
  `unknown_answer_count` int unsigned NOT NULL COMMENT '모름 선택 개수',
  `info_processing_time_sec` int unsigned NOT NULL,
  `plot_sequence_time_sec` int unsigned NOT NULL,
  `plot_success_count` int unsigned NOT NULL COMMENT '성공 개수',
  `plot_total_count` int unsigned NOT NULL COMMENT '전체 개수',
  `plot_attempts` tinyint unsigned NOT NULL COMMENT '시도 횟수',
  `vocabulary_time_sec` int unsigned NOT NULL,
  `vocab_correct_count` int unsigned NOT NULL COMMENT '맞춘 개수',
  `vocab_total_count` int unsigned NOT NULL COMMENT '전체 개수',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`result_id`),
  UNIQUE KEY `ux_step8_section` (`section_id`),
  CONSTRAINT `fk_step8_section` FOREIGN KEY (`section_id`) REFERENCES `user_learning_section` (`section_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- icks_literacy_db.user_descript_hint_response definition

CREATE TABLE `user_descript_hint_response` (
  `hint_response_id` int NOT NULL AUTO_INCREMENT,
  `summary_hint_id` int NOT NULL,
  `user_id` int NOT NULL,
  `user_answer` text NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`hint_response_id`),
  KEY `idx_udresp_hint` (`summary_hint_id`),
  KEY `idx_udresp_user` (`user_id`),
  CONSTRAINT `fk_udresp_hint` FOREIGN KEY (`summary_hint_id`) REFERENCES `descript_summary_hint` (`summary_hint_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_udresp_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- icks_literacy_db.user_descript_summary_result definition

CREATE TABLE `user_descript_summary_result` (
  `summary_result_id` int NOT NULL AUTO_INCREMENT,
  `descript_summary_id` int NOT NULL,
  `user_id` int NOT NULL,
  `my_summary` text NOT NULL COMMENT '사용자 작성 요약문',
  `is_model_checked` tinyint(1) NOT NULL DEFAULT '0' COMMENT '모범답안 확인 여부',
  `ai_score` int unsigned DEFAULT NULL COMMENT 'AI 채점 점수',
  `ai_feedback` text COMMENT 'AI 피드백',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`summary_result_id`),
  KEY `idx_udsummary_result_user` (`user_id`),
  KEY `idx_udsummary_result_summary` (`descript_summary_id`),
  CONSTRAINT `fk_udsummary_result_summary` FOREIGN KEY (`descript_summary_id`) REFERENCES `descript_summary` (`descript_summary_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_udsummary_result_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- icks_literacy_db.user_vocab_status definition

CREATE TABLE `user_vocab_status` (
  `user_vocab_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `vocab_id` int NOT NULL,
  `final_status` enum('known','unknown') NOT NULL,
  `example_written` tinyint(1) NOT NULL DEFAULT '0' COMMENT '예문 작성 여부',
  `quiz_status` tinyint(1) NOT NULL DEFAULT '0' COMMENT '퀴즈 완료 여부',
  `last_study_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_vocab_id`),
  UNIQUE KEY `ux_user_vocab` (`user_id`,`vocab_id`),
  KEY `fk_uservocab_vocab` (`vocab_id`),
  CONSTRAINT `fk_uservocab_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_uservocab_vocab` FOREIGN KEY (`vocab_id`) REFERENCES `vocabulary` (`vocab_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- icks_literacy_db.vocab_question definition

CREATE TABLE `vocab_question` (
  `question_id` int NOT NULL AUTO_INCREMENT,
  `vocab_id` int NOT NULL,
  `question_text` text NOT NULL,
  `question_type` enum('뜻고르기','예문빈칸','동의어','반의어') DEFAULT '뜻고르기',
  `explanation` text COMMENT '해설',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`question_id`),
  KEY `idx_vocabquestion_vocab` (`vocab_id`),
  CONSTRAINT `fk_vocabquestion_vocab` FOREIGN KEY (`vocab_id`) REFERENCES `vocabulary` (`vocab_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- icks_literacy_db.comprehension_choice definition

CREATE TABLE `comprehension_choice` (
  `choice_id` int NOT NULL AUTO_INCREMENT,
  `question_id` int NOT NULL,
  `choice_number` tinyint unsigned NOT NULL COMMENT '1-6 선택지 번호',
  `choice_text` varchar(500) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`choice_id`),
  UNIQUE KEY `ux_question_choice_num` (`question_id`,`choice_number`),
  KEY `idx_comp_choice_question` (`question_id`),
  CONSTRAINT `fk_comp_choice_question` FOREIGN KEY (`question_id`) REFERENCES `comprehension_question` (`question_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- icks_literacy_db.vocab_choice definition

CREATE TABLE `vocab_choice` (
  `choice_id` int NOT NULL AUTO_INCREMENT,
  `question_id` int NOT NULL,
  `choice_text` varchar(255) NOT NULL,
  `is_correct` tinyint(1) NOT NULL DEFAULT '0',
  `display_order` tinyint unsigned NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`choice_id`),
  KEY `idx_vocabchoice_question` (`question_id`),
  CONSTRAINT `fk_vocabchoice_question` FOREIGN KEY (`question_id`) REFERENCES `vocab_question` (`question_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- icks_literacy_db.user_vocab_question_result definition

CREATE TABLE `user_vocab_question_result` (
  `vocab_question_result_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `vocab_id` int NOT NULL,
  `question_id` int NOT NULL,
  `selected_choice_id` int DEFAULT NULL,
  `is_correct` tinyint(1) NOT NULL DEFAULT '0',
  `answered_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`vocab_question_result_id`),
  KEY `idx_uservocabanswer_user` (`user_id`),
  KEY `idx_uservocabanswer_question` (`question_id`),
  KEY `fk_uservocabanswer_choice` (`selected_choice_id`),
  CONSTRAINT `fk_uservocabanswer_choice` FOREIGN KEY (`selected_choice_id`) REFERENCES `vocab_choice` (`choice_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_uservocabanswer_question` FOREIGN KEY (`question_id`) REFERENCES `vocab_question` (`question_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_uservocabanswer_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- icks_literacy_db.step7_vocab_link definition

CREATE TABLE `step7_vocab_link` (
  `link_id` int NOT NULL AUTO_INCREMENT,
  `vocab_result_id` int NOT NULL,
  `vocab_question_result_id` int NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`link_id`),
  KEY `idx_step7_link_result` (`vocab_result_id`),
  KEY `idx_step7_link_vocab` (`vocab_question_result_id`),
  CONSTRAINT `fk_step7_link_result` FOREIGN KEY (`vocab_result_id`) REFERENCES `step7_vocabulary_result` (`vocab_result_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_step7_link_vocab` FOREIGN KEY (`vocab_question_result_id`) REFERENCES `user_vocab_question_result` (`vocab_question_result_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;