CREATE TABLE "users"(
  "user_id" SERIAL PRIMARY KEY,
  "user_name" VARCHAR(25) UNIQUE NOT NULL,
  "recent_login" TIMESTAMP,
  CONSTRAINT "no_empty_username" CHECK(LENGTH(TRIM("user_name"))>0)
);

CREATE INDEX "recent_login" ON "users" ("recent_login");

CREATE TABLE "topics"(
  "topic_id" SERIAL PRIMARY KEY,
  "topic_name" VARCHAR(30) UNIQUE NOT NULL,
  "topic_description" VARCHAR(500) DEFAULT NULL
);

CREATE TABLE "posts"(
  "post_id" SERIAL PRIMARY KEY,
  "topic_id" INTEGER,
  "user_id"  INTEGER,
  "post_title" VARCHAR(100) NOT NULL,
  "post_url"  VARCHAR DEFAULT NULL,
  "post_content" VARCHAR DEFAULT NULL,
  "created_on" TIMESTAMP,
  CONSTRAINT "topic_id" FOREIGN KEY ("topic_id") REFERENCES "topics" ON DELETE CASCADE,
  CONSTRAINT "user_id" FOREIGN KEY ("user_id") REFERENCES "users" ON DELETE SET NULL,
  CONSTRAINT "url_or_content" CHECK(("post_url" IS NULL AND "post_content" IS NOT NULL)OR("post_url" IS NOT NULL AND "post_content" IS NULL))
);

CREATE TABLE "comments" (
  "comment_id" SERIAL PRIMARY KEY,
  "post_id" INTEGER,
  "user_id" INTEGER,
  "parent_id" INTEGER DEFAULT NULL,
  "comment" VARCHAR NOT NULL,
  "comment_time" TIMESTAMP,
  CONSTRAINT "fk_post_id" FOREIGN KEY ("post_id") REFERENCES "posts" ON DELETE CASCADE,
  CONSTRAINT "fk_user_id" FOREIGN KEY ("user_id") REFERENCES "users" ON DELETE SET NULL,
  CONSTRAINT "fk_parent_id" FOREIGN KEY ("parent_id") REFERENCES "comments" ON DELETE CASCADE
);

CREATE TABLE "votes"(
  "vote_id" SERIAL PRIMARY KEY,
  "post_id" INTEGER,
  "user_id" INTEGER,
  "vote" SMALLINT CHECK ("vote"=1 OR "vote"=-1),
  CONSTRAINT "fk_post_id" FOREIGN KEY ("post_id") REFERENCES "posts" ON DELETE CASCADE,
  CONSTRAINT "fk_user_id" FOREIGN KEY ("user_id") REFERENCES "users" ON DELETE SET NULL
);
