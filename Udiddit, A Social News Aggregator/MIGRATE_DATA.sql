INSERT INTO "users" ("user_name")
  SELECT DISTINCT username
  FROM bad_posts
  UNION
  SELECT DISTINCT username
  FROM bad_comments
  UNION
  SELECT DISTINCT REGEXP_SPLIT_TO_TABLE(upvotes, ',')
  FROM bad_posts
  UNION
  SELECT DISTINCT REGEXP_SPLIT_TO_TABLE(downvotes, ',')
  FROM bad_posts;

INSERT INTO "topics" ("topic_name")
  SELECT DISTINCT topic
  FROM bad_posts;

INSERT INTO "posts" ("topic_id","user_id","post_title","post_url","post_content")
  SELECT topics.topic_id, users.user_id, SUBSTR(bad_posts.title,1,100), bad_posts.url, bad_posts.text_content
  FROM bad_posts
  JOIN users
  ON users.user_name=bad_posts.username
  JOIN topics
  ON topics.topic_name=bad_posts.topic

INSERT INTO "comments" ("post_id", "user_id", "comment")
  SELECT posts.post_id, users.user_id, bad_comments.text_content
  FROM bad_comments
  JOIN posts
  ON posts.post_id=bad_comments.post_id
  JOIN users
  ON users.user_name=bad_comments.username

INSERT INTO "votes" ("post_id","user_id","vote")
  SELECT t1.id, users.user_id, 1 AS vote
  FROM
    (SELECT id, REGEXP_SPLIT_TO_TABLE(upvotes,',') AS upvote_user
     FROM bad_posts) t1
  JOIN users
  ON users.user_name=t1.upvote_user

INSERT INTO "votes" ("post_id","user_id","vote")
  SELECT t2.id, users.user_id, -1 AS vote
  FROM
    (SELECT id, REGEXP_SPLIT_TO_TABLE(downvotes,',') AS downvote_user
     FROM bad_posts) t2
  JOIN users
  ON users.user_name=t2.downvote_user

DROP TABLE bad_comments;
DROP TABLE bad_posts;
