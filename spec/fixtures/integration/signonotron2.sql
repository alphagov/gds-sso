-- Clean data from database
DELETE FROM `oauth_access_grants`;
DELETE FROM `oauth_access_tokens`;
DELETE FROM `oauth_applications`;
DELETE FROM `permissions`;
DELETE FROM `users`;

-- Setup fixture data
INSERT INTO `oauth_applications` VALUES (1,'GDS_SSO integration test','gds-sso-test','secret','http://www.example-client.com/auth/gds/callback','2012-04-19 13:26:54','2012-04-19 13:26:54');
INSERT INTO `users` (id, email, encrypted_password, created_at, updated_at, name, uid, is_admin) VALUES (1,'test@example-client.com','$2a$04$MdMkVFwTq5GLJJkHS8GLIe6dK1.C4ozzba5ZS5Ks2b/NenVsMGGRW','2012-04-19 13:26:54','2012-04-19 13:26:54','Test User','integration-uid', 0);
INSERT INTO `permissions` (id, user_id, application_id, permissions) VALUES (1,1,1,"--- 
- signin
");


