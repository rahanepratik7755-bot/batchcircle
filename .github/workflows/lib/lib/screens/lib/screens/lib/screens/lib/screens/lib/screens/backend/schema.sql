CREATE TYPE user_role AS ENUM ('student', 'teacher', 'admin');
CREATE TYPE verification_status AS ENUM ('pending', 'approved', 'rejected');

CREATE TABLE colleges (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL UNIQUE,
    code VARCHAR(50),
    state VARCHAR(100),
    is_govt BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    google_id VARCHAR(255) UNIQUE,
    role user_role DEFAULT 'student',
    college_id INT REFERENCES colleges(id) ON DELETE SET NULL,
    course_name VARCHAR(100),
    academic_year VARCHAR(10),
    id_card_url VARCHAR(255),
    verification_status verification_status DEFAULT 'pending',
    is_premium BOOLEAN DEFAULT FALSE,
    premium_expiry TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE group_chats (
    id SERIAL PRIMARY KEY,
    college_id INT REFERENCES colleges(id) ON DELETE CASCADE,
    course_name VARCHAR(100) NOT NULL,
    academic_year VARCHAR(10) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(college_id, course_name, academic_year)
);

CREATE TABLE chat_messages (
    id SERIAL PRIMARY KEY,
    group_id INT REFERENCES group_chats(id) ON DELETE CASCADE,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE subscriptions (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    platform VARCHAR(20) CHECK (platform IN ('android', 'ios')),
    plan_type VARCHAR(20) CHECK (plan_type IN ('monthly', 'yearly')),
    transaction_id VARCHAR(255) UNIQUE NOT NULL,
    purchase_token TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    expiry_date TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
