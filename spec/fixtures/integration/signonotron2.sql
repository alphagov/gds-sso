-- Clean data from database
DELETE FROM `oauth_access_grants`;
DELETE FROM `oauth_access_tokens`;
DELETE FROM `oauth_applications`;
DELETE FROM `users`;

-- Setup fixture data
INSERT INTO `oauth_applications` VALUES (1,'GDS_SSO integration test','gds-sso-test','secret','http://www.example-client.com/auth/gds/callback','2012-04-19 13:26:54','2012-04-19 13:26:54');
INSERT INTO `users` VALUES (1,'test@example-client.com','$2a$04$MdMkVFwTq5GLJJkHS8GLIe6dK1.C4ozzba5ZS5Ks2b/NenVsMGGRW',NULL,NULL,0,NULL,NULL,NULL,NULL,0,NULL,'2012-04-19 13:26:54','2012-04-19 13:26:54',NULL,'Test User','integration-uid');
