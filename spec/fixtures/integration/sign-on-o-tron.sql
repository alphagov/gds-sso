-- Clean data from database
DELETE FROM `oauth_access_tokens`;
DELETE FROM `oauth_authorization_codes`;
DELETE FROM `oauth_authorizations`;
DELETE FROM `oauth_clients`;
DELETE FROM `users`;

-- Setup fixture data
INSERT INTO `oauth_clients` VALUES (1,'GDS_SSO integration test','gds-sso-test','secret','http://www.example-client.com/auth/gds/callback');
INSERT INTO `users` (id,name,email,encrypted_password,uid) VALUES (1,'Test User','test@example-client.com','$2a$04$MdMkVFwTq5GLJJkHS8GLIe6dK1.C4ozzba5ZS5Ks2b/NenVsMGGRW','integration-uid');
