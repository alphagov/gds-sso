DELETE FROM `oauth_access_tokens`;

INSERT INTO oauth_access_tokens (resource_owner_id, application_id, token, refresh_token, expires_in, created_at)
  VALUES (1, 1, 'caaeb53be5c7277fb0ef158181bfd1537b57f9e3b83eb795be3cd0af6e118b28', '1bc343797483954d7306d67e96687feccdfdaa8b23ed662ae23e2b03e6661d16', 307584000, '2012-06-27 13:57:47');

INSERT INTO oauth_access_tokens (resource_owner_id, application_id, token, refresh_token, expires_in, created_at)
  VALUES (1, 2, '98c72f4da02fdc43398e029d05567542944d2a9b0df3c20b0accd8bd6c5dc728', 'e2da0489a58219fd4f542139909737627874ceacd2af23f5c268ccecb36e85af', 307584000, '2014-07-14 09:06:14');
